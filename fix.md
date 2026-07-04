# Fixes Log

A chronological log of bug fixes applied to this project. Each entry: date, symptom, root cause, files touched, follow-up steps.

---

## 2026-07-04 — Refonte de l'écran Profil : photo de profil, champs profil cassés, mot de passe cassé, URL serveur factice

### Symptom

- La photo de profil ne pouvait pas être modifiée (aucune UI, aucun endpoint câblé).
- Le formulaire "Informations personnelles" semblait fonctionner (200 OK, message
  de succès) mais le prénom/nom n'étaient jamais mis à jour côté serveur.
- Le changement de mot de passe échouait systématiquement en 400.
- Le champ "Changer l'URL du serveur" affichait un succès mais ne changeait
  jamais réellement le serveur utilisé par l'app.

### Root cause

- `profile_screen.dart` envoyait `first_name`/`last_name` au PATCH
  `/user/profile/`, mais le serializer backend (`UserSerializer`) attend
  `prenom`/`nom` — les clés inconnues sont silencieusement ignorées par DRF.
- `AuthRepository.changePassword` n'envoyait pas `confirm_password`, pourtant
  requis par `ChangePasswordSerializer` côté backend → 400 à chaque appel.
- `AuthRepository.setBaseUrl` ne faisait que persister l'URL en secure storage ;
  `DioClient` lit `ApiConstants.baseUrl` (constante figée) une seule fois à la
  construction et ne relit jamais la valeur sauvegardée. Le bouton déclenchait
  en plus `AuthProfileUpdated` (PATCH `/user/profile/` avec un champ
  `api_base_url` inexistant côté backend) au lieu de `AuthBaseUrlUpdated`.
- Affichage de la photo (`profile_screen.dart` + `app_drawer.dart`) : le test
  `user?.profilePictureUrl != null` est toujours vrai car `profilePictureUrl`
  est un `String` non nullable (défaut `''`), pas un `String?` — l'app tentait
  systématiquement `Image.network('')` avant de retomber sur les initiales.

### Fix

- Refonte visuelle de l'écran Profil (bandeau dégradé, avatar avec halo doré,
  badge appareil photo) et ajout d'un widget `UserAvatar` partagé (photo
  distante via `cached_network_image`, fallback initiales, `isNotEmpty` correct)
  réutilisé par `profile_screen.dart` et `app_drawer.dart`.
- Ajout du changement de photo de profil (galerie/caméra via `image_picker`,
  upload multipart) : `AuthRepository.updateProfilePicture`,
  `AuthBloc.AuthProfilePictureUpdated`, permissions Android/iOS/macOS.
- `AuthUser` : ajout du champ `phoneNumber` (`phone_number`) affiché/éditable.
- Formulaire Informations : envoi de `prenom`/`nom`/`email`/`phone_number`
  (au lieu de `first_name`/`last_name`).
- `AuthRepository.changePassword` : ajout de `confirm_password`.
- URL serveur réellement fonctionnelle : `DioClient.updateBaseUrl` /
  `loadPersistedBaseUrl` (relecture au démarrage dans `main.dart`),
  `AuthRepository.setBaseUrl` applique désormais l'URL immédiatement au client
  Dio, et `profile_screen.dart` dispatch `AuthBaseUrlUpdated` (nouvel état
  `AuthBaseUrlUpdateSuccess`) avec une validation d'URL correcte. Champ déplacé
  dans une section "Paramètres avancés" repliable.

### Files touched

- `lib/presentation/screens/profile/profile_screen.dart` (refonte complète)
- `lib/presentation/widgets/user_avatar.dart` (nouveau)
- `lib/presentation/widgets/app_drawer.dart`
- `lib/data/models/auth_model.dart`
- `lib/data/repositories/auth_repository.dart`
- `lib/presentation/blocs/auth/auth_bloc.dart`
- `lib/core/network/dio_client.dart`
- `lib/main.dart`
- `pubspec.yaml` (ajout `image_picker`)
- `android/app/src/main/AndroidManifest.xml`, `ios/Runner/Info.plist`,
  `macos/Runner/Info.plist`, `macos/Runner/{Debug,Release}.entitlements`

### Follow-up

- Les entitlements macOS ne déclaraient pas `com.apple.security.network.client`
  du tout (seulement `network.server`) : corrigé au passage, sinon aucun appel
  API n'aurait fonctionné sur une build macOS sandboxée.
- La barre supérieure desktop et le pied de la sidebar (`main_layout.dart`)
  n'affichent que des initiales et n'ont pas été branchés sur la photo réelle ;
  à harmoniser avec `UserAvatar` si souhaité plus tard.

---

## 2026-07-01 — Refresh en 500 (token blacklisté) : rotation des refresh tokens non persistée

### Symptom

Le refresh réussit une fois (`200`), puis un second refresh quasi simultané
échoue en `500` : `Attempt to refresh blacklisted or invalid token` /
`Token is blacklisted or invalid`. Plusieurs requêtes protégées 401 en cascade
déclenchent plusieurs refresh.

### Root cause

Le backend a `ROTATE_REFRESH_TOKENS=True` + `BLACKLIST_AFTER_ROTATION=True` :
chaque refresh **invalide l'ancien refresh token** et en renvoie un nouveau dans
`data.refresh`. Or DioClient ne sauvegardait que le **nouvel access token**, pas
le nouveau refresh token → le refresh suivant réutilisait l'ancien (blacklisté)
→ 500. Aggravé par les 401 concurrents : chaque requête relançait son propre
refresh.

### Fix

- Extraction et **persistance du nouveau refresh token** après refresh
  (`_extractRefreshToken` + `saveRefreshToken`).
- **Court-circuit concurrent** : si le jeton courant diffère de celui utilisé par
  la requête échouée, on rejoue directement avec le jeton courant sans relancer
  de refresh (`_retryOriginal`).
- **Garde anti-boucle** : `requestOptions.extra['__retried__']` empêche qu'une
  requête rejouée ne redéclenche un cycle de refresh.
- onError ignore désormais explicitement les endpoints d'auth (pas de refresh sur
  un échec de refresh lui-même).

### Files touched

- `lib/core/network/dio_client.dart` — `_extractToken`/`_extractRefreshToken`,
  sauvegarde du refresh token, `_retryOriginal`, court-circuit + garde anti-boucle

### Follow-up

- Rotation active → chaque appareil possède une chaîne de refresh tokens ; une
  reconnexion sur un autre appareil peut invalider la session courante (attendu).

---

## 2026-07-01 — Refresh renvoie 401 : l'access token périmé était réattaché à la requête de refresh

### Symptom

Après ~1 min (expiration de l'access token), une requête protégée renvoie 401,
l'app tente `/api/auth/token/refresh/` → **401** aussi → déconnexion. Le refresh
token est pourtant valide (`REFRESH_TOKEN_LIFETIME = 7 jours`).

### Root cause

La requête de refresh utilisait `Options(headers: {'Authorization': null})` pour
partir sans en-tête, mais l'intercepteur `onRequest` de DioClient réattachait
**inconditionnellement** l'access token (périmé) lu depuis le storage. Le endpoint
refresh hérite de `BaseAPIView` : DRF authentifie l'en-tête, l'access token expiré
lève `AuthenticationFailed` → **401 avant même d'exécuter `post()`**. Le refresh
ne pouvait donc jamais aboutir.

### Fix

`onRequest` n'attache plus jamais l'`Authorization` aux endpoints
d'authentification (`_isAuthEndpoint` : token refresh / login / register). La
requête de refresh part désormais sans en-tête et est acceptée.

### Files touched

- `lib/core/network/dio_client.dart` — helper `_isAuthEndpoint()` + exclusion de
  l'en-tête dans `onRequest`

### Follow-up

- `ACCESS_TOKEN_LIFETIME = 1 min` (backend `gestion_p/settings.py:302`) génère un
  cycle 401→refresh toutes les minutes. Fonctionnel, mais bavard : envisager
  15–30 min pour une expérience plus fluide (le refresh à 7 j reste inchangé).
- Le `refresh_expires_in:120` vu dans une réponse register antérieure venait
  d'une ancienne config ; la valeur actuelle est 7 jours.

---

## 2026-07-01 — Contrat API auth incohérent front/back (cause racine register + refresh)

> Backend : `../backend` (Django/DRF). Pas de fix-log côté backend → consigné ici.

### Symptom

- Register renvoyait une réponse double-enveloppée `{"success":{"success":true,
  "data":{...}}}` → crash de parsing côté Flutter.
- Le renouvellement de jeton échouait systématiquement (déconnexion au bout de
  ~1 min, l'access token expirant en 60 s).

### Root cause (backend)

1. **Register double-enveloppé** — `accounts/auth/views.py` faisait
   `standardized_response(response_data)` (positionnel → param `success`) au lieu
   de `standardized_response(**response_data)`. Le service renvoyait déjà
   `{"success":true,"data":{...}}`, d'où l'imbrication.
2. **Refresh toujours en 500** — `accounts/auth/services.py::RefreshToken` lisait
   `tokens["access_token"]/["refresh_token"]/["expire_in"]`, alors que
   `TokenManager.generate_token()` renvoie `access/refresh/access_expires_in/…`
   → `KeyError` capturé → réponse 500 à chaque refresh.
3. **Noms de champs incohérents front/back** — le front envoyait `{'refresh': …}`
   pour refresh et logout, mais le backend lit `request.data.get("refresh_token")`.

### Fix (backend — ../backend)

- `accounts/auth/views.py` : `standardized_response(**response_data)` pour le
  register ; bloc cookie du refresh aligné sur les clés natives
  (`refresh` / `refresh_expires_in`).
- `accounts/auth/services.py` : `RefreshToken` renvoie directement `data: tokens`
  (structure native de `generate_token`, cohérente avec login/register) + gestion
  du cas `tokens is None` (rotation désactivée → 401) ; 1er retour d'erreur de
  `register` transformé en dict (sinon `**` planterait sur une chaîne).

### Fix (frontend)

- `lib/data/repositories/auth_repository.dart` : `register()` déballe de façon
  type-safe (ne descend dans `success`/`data`/`user` que si c'est un `Map`) →
  tolère l'ancienne et la nouvelle forme ; `refresh`→`refresh_token` dans le
  body de logout.
- `lib/core/network/dio_client.dart` : `refresh`→`refresh_token` dans le body du
  refresh ; `_extractAccessToken` récupère `access` sous `data`.

### Contrat API confirmé (après fix)

- Register/Login → `{"success":true,"data":{"user":{…},"tokens":{"access",
  "refresh","token_type","access_expires_in","refresh_expires_in",…}}}`.
- Refresh → body `{"refresh_token":"…"}` ; réponse
  `{"success":true,"data":{"access","refresh","access_expires_in",…}}`.
- Le user renvoyé utilise `prenom`/`nom` (géré par `AuthUser.fromJson`).

### Follow-up

- `access_expires_in = 60 s` : le refresh transparent doit fonctionner en continu
  maintenant — tester une session > 1 min pour valider bout en bout.
- Redémarrer le serveur Django après ces changements.

---

## 2026-07-01 — Renouvellement de jeton : 3 tentatives puis déconnexion + redirection

### Symptom / demande

Le renouvellement du jeton d'accès (401) ne réessayait qu'une seule fois et, en
cas d'échec, n'effaçait pas les jetons ni ne redirigeait vers `/login`.
Souhaité : après **trois** tentatives de renouvellement infructueuses, effacer
tous les jetons et rediriger vers l'écran de connexion.

De plus, le projet **ne compilait plus** : le constructeur `DioClient` exigeait
un `AuthRepository` (dépendance circulaire `DioClient → AuthRepository →
DioClient`) alors que la DI ne lui passait que `SecureStorage`
(`not_enough_positional_arguments` à `injection.dart:33`).

### Root cause

- `DioClient` avait été couplé à `AuthRepository` uniquement pour appeler
  `logout()` en cas d'échec de refresh → cycle de dépendances + build cassé.
- Aucune logique de comptage de tentatives ; aucune notification à l'`AuthBloc`
  (donc le router GoRouter ne redirigeait jamais vers `/login`).

### Fix

- `DioClient` ne dépend plus d'`AuthRepository`. Il efface les jetons via
  `SecureStorage.clearAll()` et expose un callback `onSessionExpired`.
- `App` câble `onSessionExpired` sur l'instance réelle d'`AuthBloc` (celle que
  le router écoute) → dispatch `AuthLogoutRequested` → état
  `AuthUnauthenticated` → redirection `/login` via `refreshListenable`.
- Boucle de renouvellement jusqu'à `_maxRefreshAttempts = 3` ; après 3 échecs
  (ou jeton d'accès absent/vide) → `_expireSession()` (efface tout + callback).
- `_extractAccessToken()` tolère les enveloppes serveur variées
  (`{access}`, `{data:{access}}`, `{tokens:{access}}`, `{success:{data:{tokens:{access}}}}`).

### Files touched

- `lib/core/network/dio_client.dart` — suppression dépendance AuthRepository,
  callback `onSessionExpired`, boucle 3 tentatives, `_expireSession()`,
  `_extractAccessToken()`
- `lib/core/di/injection.dart` — commentaire ; `DioClient(sl<SecureStorage>())`
  redevient valide
- `lib/app.dart` — import DioClient + câblage `onSessionExpired`

### Follow-up

- `AuthBloc` reste enregistré en factory dans la DI, mais `App` utilise une seule
  instance partagée (`_authBloc`) pour le provider, le router et le callback —
  cohérent. Ne pas appeler `sl<AuthBloc>()` ailleurs en s'attendant à la même
  instance.
- Les requêtes mises en file (`_failedQueue`) sont abandonnées sur échec final
  (comportement inchangé) ; à revoir si un blocage de requêtes concurrentes
  apparaît.

---

## 2026-07-01 — Crash au register : `Null is not a subtype of Map<String, dynamic>`

### Symptom

À l'inscription : `_TypeError (type 'Null' is not a subtype of type
'Map<String, dynamic>' in type cast)`. La réponse serveur était pourtant valide
(compte créé, tokens présents).

### Root cause

Deux problèmes dans `AuthRepository.register()` :
1. La réponse est enveloppée : `{"success":{"success":true,"data":{"user":{...},
   "tokens":{...}}}}`. Le code lisait `response.data["data"]` (null, car `data`
   est sous `success`) → cast `Null → Map` échoue. De plus il passait tout le
   bloc `{user, tokens, ...}` à `AuthUser.fromJson` au lieu de `["user"]`.
2. Le serveur renvoie les noms en français (`prenom`/`nom`), alors que
   `AuthUser.fromJson` ne lisait que `first_name`/`last_name` → nom vide dans le
   message de bienvenue.

### Fix

- `register()` déballe la charge de façon tolérante :
  `body['success'] ?? body` → `['data'] ?? wrapper` → `['user'] ?? payload`,
  puis `AuthUser.fromJson` sur l'objet user.
- `AuthUser.fromJson` accepte désormais `first_name`/`prenom` et `nom`/`last_name`
  (fallback additif, sans impact sur le login).

### Files touched

- `lib/data/repositories/auth_repository.dart` — déballage robuste dans `register()`
- `lib/data/models/auth_model.dart` — fallback `prenom`/`nom` dans `AuthUser.fromJson`

### Follow-up

- L'écran register navigue vers `/login` (pas d'auto-login), donc les tokens de
  la réponse register ne sont volontairement pas persistés.
- Si le login présente le même enveloppage `success`, appliquer le même déballage
  dans `login()`/`getCurrentUser()`/`getUserProfile()`.

---

## 2026-07-01 — Requêtes serveur au démarrage même sans utilisateur connecté

### Symptom

À l'ouverture de l'application (même si aucun compte n'est créé ni connecté),
l'app effectue immédiatement des requêtes vers le serveur (membres, groupes,
événements, finances). Ces requêtes échouent en 401 sans token et déclenchent
inutilement des tentatives de rafraîchissement de token.

### Root cause

`main.dart` appelle `PeriodicSyncManager.startPeriodicSync()` de façon
inconditionnelle au démarrage. Cette méthode lance immédiatement
`SyncService.syncAll()`, qui ne vérifiait que la connectivité (`isOnline()`) et
jamais l'état d'authentification. Résultat : les 4 endpoints étaient appelés dès
l'ouverture, avant toute connexion.

### Fix

`SyncService` reçoit désormais `SecureStorage` (injecté via DI) et vérifie la
présence d'un access token via `_isAuthenticated()` au début de `syncAll()` et
`syncEntity()`. Sans token valide, aucune requête serveur n'est effectuée — ni
au démarrage, ni au cycle périodique de 5 min.

### Files touched

- `lib/core/sync/sync_service.dart` — ajout du champ `_secureStorage`, du helper
  `_isAuthenticated()`, et des gardes dans `syncAll()` / `syncEntity()`
- `lib/core/di/injection.dart` — passe `secureStorage: sl<SecureStorage>()` à
  `SyncService`

### Follow-up

- La première sync pour un utilisateur authentifié se fera au prochain tick du
  timer (max 5 min) ; les écrans chargent de toute façon leurs données à la
  demande via les repositories. Si une sync immédiate après login est souhaitée,
  déclencher `PeriodicSyncManager.forceSyncNow()` depuis `AuthBloc` sur
  `AuthAuthenticated`.

---

## 2026-05-30 — L'interface ne se met pas à jour après ajout/modification/suppression

### Symptom

Après un create/update/delete d'un membre, groupe, événement ou transaction,
l'opération réussit côté serveur mais la liste affichée reste inchangée. Il
fallait attendre le cycle de synchronisation (5 min) puis quitter et revenir sur
l'écran pour que les données s'actualisent.

### Root cause

Les méthodes `getXxx()` des repositories renvoient le cache SQLite dès qu'il
n'est **pas vide** (sans même vérifier la validité de 5 min), et les méthodes
`createXxx/updateXxx/deleteXxx` n'invalidaient jamais ce cache. Le BLoC
rechargeait bien la liste (`add(LoadXxx())`) après la mutation, mais `getXxx()`
lui resservait le cache obsolète. Seul le `PeriodicSyncManager` (toutes les 5
min) écrasait le cache via `saveItems`, d'où l'attente.

### Fix

Invalider le cache de l'entité concernée juste après chaque mutation réussie,
via `_databaseService?.clearTable('<table>')`. Au prochain `getXxx()` déclenché
par le rechargement du BLoC, le cache vide force un `fetchXxx()` serveur qui
repeuple le cache et renvoie des données fraîches → l'écran courant s'actualise
immédiatement.

### Files touched

- `lib/data/repositories/membre_repository.dart` (createMembre, updateMembre, patchMembre, deleteMembre)
- `lib/data/repositories/groupe_repository.dart` (createGroupe, updateGroupe, patchGroupe, deleteGroupe)
- `lib/data/repositories/evenement_repository.dart` (createEvenement, updateEvenement, patchEvenement, deleteEvenement)
- `lib/data/repositories/finance_repository.dart` (createTransaction, updateTransaction, patchTransaction, deleteTransaction)

### Follow-up

La librairie n'utilise pas encore le cache local (pas de `DatabaseService`
injecté), donc rien à invalider là. Si une table cachée est ajoutée plus tard,
appliquer le même `clearTable(...)` dans ses mutations.

---

## 2026-05-29 — App crashes (pops last page off stack) when confirming a delete

### Symptom

Tapping "Supprimer" in a delete-confirmation dialog (membres, groupes,
événements, finances) crashed with:

```text
You have popped the last page off of the stack, there are no pages left to show
'package:go_router/src/delegate.dart': Failed assertion: 'currentConfiguration.isNotEmpty'
'package:flutter/src/widgets/navigator.dart': Failed assertion: '!_debugLocked' is not true.
```

The "Annuler" button worked fine; only "Supprimer" crashed.

### Root cause

`showDialog` pushes the dialog onto the **root** navigator (default
`useRootNavigator: true`). The confirm button called `Navigator.pop(ctx)` where
`ctx` was the **screen** context, which lives inside the `ShellRoute`'s nested
navigator. So `Navigator.of(ctx)` resolved to the nested navigator and popped
the current **page** instead of the dialog — emptying the shell's route stack.
The "Annuler" button used the dialog builder's `context` (correct), which is why
it worked. The librairie screen and the sacrement dialog were already correct
because their builder param is named `ctx` (the dialog context).

### Files touched

- `lib/presentation/screens/groupes/groupes_screen.dart:54`
- `lib/presentation/screens/finances/finances_screen.dart:68`
- `lib/presentation/screens/evenements/evenements_screen.dart:61`
- `lib/presentation/screens/membres/membres_screen.dart:62`

Changed the confirm button's `Navigator.pop(ctx)` → `Navigator.pop(context)`
(the dialog builder's context). The subsequent `ctx.read<Bloc>()` still uses the
screen context, which is valid.

### Follow-up

- Unrelated `NetworkException` lines in the log are just the backend being
  offline — the cache serves data correctly.
- Separate, still-open: RenderFlex overflow (12–28px) in
  `lib/presentation/screens/groupes/groupes_screen.dart:174` (card content too
  tall for `childAspectRatio: 1.9`).

---

## 2026-05-29 — `PlatformException(KeyringLocked)` on Linux at first auth read

### Symptom

`lib/core/storage/secure_storage.dart:16` threw at app startup the moment
`AuthBloc` ran `AuthCheckRequested`:

```text
PlatformException(KeyringLocked, KeyringLocked, null, null)
```

### Root cause

`flutter_secure_storage` v10 on Linux is backed by libsecret → GNOME keyring.
The `gnome-keyring-daemon` was running, but the **Login keyring was locked**
(common on auto-login sessions or when the keyring password differs from the
login password). Every read/write/delete on libsecret throws `KeyringLocked`
in this state, with no fallback in the package. The original
`SecureStorage` made bare calls with no error handling, so a routine startup
read crashed the auth flow.

### Fix

- Rewrote `lib/core/storage/secure_storage.dart` to:
  - Introduce a typed `SecureStorageLockedException`.
  - Wrap reads/deletes: return `null` / no-op on `KeyringLocked` (graceful
    degradation — caller sees "no token", app falls back to the login screen
    instead of crashing).
  - Wrap writes: throw `SecureStorageLockedException` with a French
    user-facing message so callers (BLoCs) can surface it cleanly.
  - Add a `probe()` method that attempts a sentinel read so callers can
    detect the locked state up front.
- `lib/main.dart`: on Linux only, call `SecureStorage.probe()` after DI
  setup; pass the result into `App(secureStorageLocked: …)`.
- `lib/app.dart`: when `secureStorageLocked` is true, schedule a one-time
  post-frame `AlertDialog` (rendered via GoRouter's navigator context) that
  explains the lock state and how to unlock via Seahorse.

### Files touched

- `lib/core/storage/secure_storage.dart` — full rewrite with error handling
  + `probe()` + typed exception.
- `lib/main.dart` — added Linux probe + flag passthrough to `App`.
- `lib/app.dart` — `App.secureStorageLocked` field, post-frame warning
  dialog.

### Follow-up (manual)

Unlock the keyring once so the app can persist tokens:

```bash
# GUI (recommended):
#   Open Seahorse → Passwords → Login → right-click → Unlock
#   (or set an empty password so GDM auto-unlocks on every login)

# CLI smoke test that triggers the unlock prompt:
secret-tool lookup test test
```

Then `flutter run -d linux` again — the warning dialog should no longer
appear and login will persist across restarts.

---

## 2026-05-29 — SqfliteFfiException on Linux: `sqlite3_initialize` not found

### Symptom

At app startup on Linux, the first access to `DatabaseService.database`
(`lib/core/database/database_service.dart:16`) threw:

```text
SqfliteFfiException: Couldn't resolve native function 'sqlite3_initialize'
  in 'package:sqlite3/src/ffi/libsqlite3.g.dart'
  No asset with id 'package:sqlite3/src/ffi/libsqlite3.g.dart' found.
  No available native assets. Attempted to fallback to process lookup.
  libflutter_linux_gtk.so: undefined symbol: sqlite3_initialize.
```

### Root cause

Two compounding issues:

1. **No native SQLite available on Linux.** `sqflite_common_ffi` on Linux
   tries to load `libsqlite3.so` via `DynamicLibrary.process()` then the
   system loader. Neither resolves because (a) Flutter's Linux GTK shell
   doesn't link sqlite3, and (b) no asset-bundled SQLite was declared.
2. **FFI init ordering in `main.dart`.** `sqfliteFfiInit()` and
   `databaseFactory = databaseFactoryFfi` ran **after**
   `setupDependencies()`, so any DI step that touched the DB would use
   the default (mobile) factory.

### Fix

- Added `sqlite3_flutter_libs: ^0.5.24` to `pubspec.yaml` to bundle a
  native SQLite library on Linux/Windows/macOS (no system install needed).
- Rewrote `lib/main.dart` to:
  - Initialize FFI **before** `setupDependencies()`.
  - Guard the FFI init with `!kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS)` so mobile (Android/iOS) still uses native `sqflite`.

### Files touched

- `pubspec.yaml` — added `sqlite3_flutter_libs`.
- `lib/main.dart` — reordered init + added platform guard.

### Follow-up (manual)

```bash
flutter pub get
flutter clean        # required: Linux build bundle is stale
flutter run -d linux
```
