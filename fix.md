# Fixes Log

A chronological log of bug fixes applied to this project. Each entry: date, symptom, root cause, files touched, follow-up steps.

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
