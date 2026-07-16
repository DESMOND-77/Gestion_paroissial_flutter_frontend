# Fixes Log

A chronological log of bug fixes applied to this project. Each entry: date, symptom, root cause, files touched, follow-up steps.

---

## 2026-07-16 — Détail groupe : assigner plusieurs responsables + ajouter un membre

### Besoin

Depuis le détail d'un groupe : une liste déroulante pour assigner un ou
plusieurs responsables, et une option pour ajouter un membre au groupe.

### Fix

**Backend** :
- `groupes/models.py` : ajout du M2M `Groupe.responsables` (le FK `responsable`
  singulier est conservé pour compat). Migration `groupes/0002`.
- `groupes/serializers.py` : `responsables` (écriture, PrimaryKeyRelated many) +
  `responsables_noms` (lecture, {id: nom}).
- `groupes/views.py` : `GroupeDetailView` PUT/PATCH via `serializer.save()`
  (gère le M2M) ; `GroupeMembresView` reçoit **POST** (ajoute un membre :
  `membre.groupe = groupe`) et **DELETE** (retire), permission
  `IsSecretaryOrAbove`.

**Frontend** :
- `groupe_model.dart` : `responsables` (List) + `responsablesNoms` (Map).
- `GroupeRepository` : **corrige `getGroupeMembres`** (lisait mal la réponse
  `{membres:[...]}` → liste toujours vide) ; ajoute `getUsers`,
  `assignResponsables` (PATCH), `addMembreToGroupe`/`removeMembreFromGroupe`.
- `groupes_bloc` : events `AssignResponsables` / `AddMembreToGroupe` /
  `RemoveMembreFromGroupe` + rechargement du détail après action.
- `groupe_detail_screen` : carte **Responsables** (puces + bouton « Assigner »
  → dialogue multi-sélection d'utilisateurs) et carte **Membres** (bouton
  « Ajouter » → sélection d'un membre hors groupe, retrait par ligne). Actions
  réservées à `canManageGroupes`. Écran passé en Stateful (cache le détail pour
  éviter le clignotement lors des états transitoires).

### Files

- `../backend/groupes/{models,serializers,views}.py` (+ migration `0002`)
- `lib/data/models/groupe_model.dart`,
  `lib/data/repositories/groupe_repository.dart`,
  `lib/core/constants/api_constants.dart`
- `lib/presentation/blocs/groupes/groupes_bloc.dart`,
  `lib/presentation/screens/groupes/groupe_detail_screen.dart`

### Follow-up

- Backend : 90 tests OK, migration appliquée, smoke-test shell (2 responsables +
  ajout membre) OK. Frontend : `flutter analyze` 0 erreur. **Redémarrer le
  backend** pour servir les nouveaux champs/endpoints.
- Le FK legacy `responsable` reste affiché (fusionné avec les multi-responsables)
  mais n'est plus édité par l'app ; à retirer un jour si plus utilisé ailleurs.

## 2026-07-16 — Icône de l'app + logo de login remplacés par logo.svg

### Besoin

Utiliser `assets/images/logo.svg` comme icône d'application et comme logo sur
l'écran de connexion.

### Fix

- **Icône de l'app** : `flutter_launcher_icons` exige un PNG. `logo.svg` a été
  rendu en `assets/images/logo.png` (1024², fond blanc) via **Chrome headless**
  (ImageMagick rendait des artefacts noirs sur les dégradés faute de délégué
  rsvg). Un foreground d'icône adaptative Android padé
  (`logo_adaptive.png`, logo à ~68 % centré sur canevas transparent) évite le
  rognage par la zone de sécurité. Config `flutter_launcher_icons` mise à jour
  (`image_path` → `logo.png`, fond blanc, adaptive fg/bg) puis
  `dart run flutter_launcher_icons` (Android + iOS régénérés).
- **Logo de login** : ajout de la dépendance `flutter_svg: ^2.0.10` ;
  `login_screen.dart` affiche désormais `SvgPicture.asset('assets/images/logo.svg')`
  dans un badge blanc arrondi (remplace l'ancien `Icon(Icons.church)` sur carré
  crimson). Le SVG n'utilise que tracés + dégradés → rendu fidèle par flutter_svg.

### Files

- `assets/images/logo.png` (+ `logo_adaptive.png`), `android/**/mipmap-*`,
  `ios/**/AppIcon.appiconset` (régénérés)
- `pubspec.yaml` (dep `flutter_svg`, config `flutter_launcher_icons`)
- `lib/presentation/screens/auth/login_screen.dart`

### Follow-up

- `flutter analyze` : 0 erreur. Icône Android vérifiée (rendu correct).
- **Non fait** : le splash natif (`flutter_native_splash`) utilise encore
  `gestparr_logo.png` — le basculer sur `logo.png` + regénérer si souhaité.
- Rappel : recompiler l'app (les icônes natives ne changent qu'au prochain build
  d'installation).

## 2026-07-16 — Thème recodé (clair/sombre) sur la palette du logo ; éléments invisibles corrigés

### Symptom

En clair comme en sombre, certains éléments étaient illisibles (texte
quasi-invisible, cartes/barres blanches en mode sombre).

### Root cause

- Le `darkTheme` était quasi vide → les composants Material n'avaient pas de
  couleurs sombres correctes.
- Surtout, des dizaines de widgets référencent des **couleurs statiques**
  `AppTheme.textPrimary` / `textSecondary` / `surfaceColor` (const, valeurs
  claires) qui ne s'adaptent pas au mode sombre → texte foncé sur fond foncé.
- Des fonds de surface étaient codés en dur `Colors.white` (barres de recherche,
  top-bar) → restaient blancs en sombre, masquant le contenu.

### Fix

- **`app_theme.dart` recodé** sur la palette du logo : primaire crimson
  `#90151F`, secondaire orange `#F3751E`, accent bleu `#2F9ADC`, papier
  `#FDFDFC`. `lightTheme` **et** `darkTheme` entièrement définis (colorScheme,
  appBar, cartes, boutons, inputs, textTheme, chips, dataTable, tabBar, popup,
  dialog, listTile…). En sombre, la primaire d'avant-plan est éclaircie
  (`primaryOnDark #E0727A`) pour rester lisible.
- **Neutres adaptatifs** : `textPrimary` / `textSecondary` / `surfaceColor` /
  `backgroundColor` / `cardColor` / `dividerColor` sont désormais des **getters**
  qui suivent la luminosité système (`platformDispatcher.platformBrightness`,
  l'app étant en `ThemeMode.system`). Les widgets existants deviennent lisibles
  dans les deux modes sans réécriture.
- Conséquence : ~82 usages de ces neutres étaient dans des expressions `const` →
  `const` retiré (script piloté par l'analyzer). Défaut de paramètre
  `_buildEmpty({Color color = AppTheme.textSecondary})` résolu à l'intérieur.
- **Fonds de surface** codés `Colors.white` (top-bar desktop + barres de
  recherche membres/groupes/événements/finances/librairie) → `AppTheme.cardColor`
  (adaptatif). Le texte blanc sur fonds de marque (sidebar, boutons, avatars)
  est conservé.

### Files

- `lib/core/theme/app_theme.dart` (recode complet)
- écrans `membres/groupes/evenements/finances/librairie/dashboard/auth/profile`,
  `widgets/main_layout.dart` (de-const + fonds de surface)

### Follow-up

- `flutter analyze` : 0 erreur. **Non vérifié visuellement ici** (lancer l'app
  et basculer clair/sombre système pour confirmer le rendu).
- **Limite connue** : `AppTheme.primaryColor` reste constant (crimson foncé).
  Utilisé en *fond*, c'est parfait ; utilisé en *avant-plan* direct sur du
  sombre (ex. `labelColor: AppTheme.primaryColor` de certains TabBar, liens de
  tableau), le contraste est faible. À affiner en remplaçant ces usages
  d'avant-plan par la primaire éclaircie si nécessaire.
- Si un jour un bouton de bascule manuel de thème est ajouté, remplacer
  `platformBrightness` par la source du `ThemeMode` choisi.

## 2026-07-16 — Changement de mot de passe : message « mot de passe actuel incorrect » peu clair

### Constat

La vérification du mot de passe actuel **existait déjà** de bout en bout :
- backend `ChangePasswordView` → `if not user.check_password(old_password)` →
  400 `error="Mot de passe actuel incorrect"` ;
- frontend : le formulaire (profil) collecte « Mot de passe actuel », le repo
  envoie `old_password`/`new_password`/`confirm_password`, Dio lève sur le 400
  (pas de `validateStatus` permissif), le BLoC émet `AuthError`, l'écran affiche
  un snackbar.

Mais le message affiché était trompeur : `ApiException._extractMessage` ne
gérait pas la clé `error` de l'enveloppe standardisée du backend. Résultat :
préfixe parasite `error: Mot de passe actuel incorrect`, et les erreurs de
validation DRF (`error` = dict) retombaient sur un générique « Requête
invalide » — donnant l'impression que rien n'était vérifié.

### Fix

`lib/core/network/api_exception.dart` — `_extractMessage` rendu **récursif et
conscient de l'enveloppe** : gère `error` (chaîne → message direct ; dict/list →
descente récursive), garde les `null`, et ignore les clés d'enveloppe
(`success`/`error`/`message`/`detail`/`non_field_errors`) dans la boucle des
erreurs par champ. Le rejet du mauvais mot de passe actuel s'affiche désormais
proprement : « Mot de passe actuel incorrect ».

### Files

- `lib/core/network/api_exception.dart`

### Follow-up

- `flutter analyze` : 0 erreur. Amélioration transverse (tous les messages
  d'erreur API sont plus lisibles).
- Rappel : après un changement réussi, le backend blackliste les jetons ; la
  session se termine au prochain appel (re-login attendu) — comportement de
  sécurité, non modifié ici.

## 2026-07-16 — Un fidèle atterrit sur le tableau de bord au démarrage malgré son absence du menu

### Symptom

Masquer une section dans le drawer/la sidebar (ex. Tableau de bord pour un
fidèle) n'empêchait pas d'y accéder : au démarrage / après connexion,
l'utilisateur était quand même envoyé sur `/dashboard`.

### Root cause

Le contrôle d'affichage était fait **uniquement dans la navigation** (visibilité
des items). Le **routeur** n'avait aucune garde par rôle et redirigeait tout le
monde vers `/dashboard` en dur : `AppRouter.redirect` (`return '/dashboard'`
après login) et `SplashScreen._resolveTarget` (`_targetRoute = '/dashboard'`).
Masquer un item ≠ bloquer la route.

### Fix

Source de vérité unique de l'accès aux sections dans `AppPermissions`
(`core/auth/permissions.dart`) :

- `canAccessRoute(location)` : accès par section (dashboard→canViewDashboard,
  membres→canManageMembres, groupes→canManageGroupes, evenements→toujours,
  finances→canViewFinances, librairie→canManageLibrairie && !isResponsable,
  profile→toujours), sous-routes gérées via `startsWith`.
- `landingRoute` : première section accessible (repli `/profile`).

Utilisée partout :

- **Routeur** (`app_router.dart`) : après login → `perms.landingRoute` (au lieu
  de `/dashboard`) ; **garde** : si la route courante n'est pas accessible →
  redirection vers `landingRoute`. Le splash n'est pas court-circuité.
- **Splash** (`splash_screen.dart`) : cible = `landingRoute` selon le rôle.
- **Sidebar desktop** (`main_layout.dart`) : items filtrés par `canAccessRoute`
  (aligné sur le drawer ; suppression du prédicat `visibleWhen` devenu inutile).

Pour un fidèle : `landingRoute` = `/evenements` ; `/dashboard` et `/finances`
en accès direct sont renvoyés vers `/evenements`.

### Files

- `lib/core/auth/permissions.dart`, `lib/core/router/app_router.dart`
- `lib/presentation/screens/splash/splash_screen.dart`
- `lib/presentation/widgets/main_layout.dart`

### Follow-up

- `flutter analyze` : 0 erreur. Le drawer (déjà personnalisé) reste cohérent car
  ses prédicats correspondent à `canAccessRoute`.
- Rappel : garde côté client = confort UX ; la vraie protection reste le backend.

## 2026-07-15 — Affichage des éléments UI selon le rôle / les permissions

### Besoin

Masquer/afficher les éléments d'interface (boutons Modifier/Supprimer/Créer,
entrées de navigation) selon le rôle de l'utilisateur, en cohérence avec la
logique de permissions du backend.

### Analyse

Les vues DRF protègent les écritures par des **classes hiérarchiques de rôle**
(`core/permissions.py` : `IsSecretaryOrAbove`, `IsTreasurerOrAbove`, `IsAdmin`)
— et non (encore) par les permissions granulaires de `core/rbac.py`. Pour que
l'UI ne montre jamais un bouton qui renverrait 403 (ni n'en cache un qui
passerait), le frontend reproduit **ces ensembles de rôles**, pas le catalogue
granulaire.

### Fix

- **`AuthUser`** (`auth_model.dart`) : ajout du champ `role` (parse `role`,
  toJson/copyWith/props). Login et `/auth/me/` le renvoient déjà (UserSerializer).
- **`lib/core/auth/permissions.dart`** (nouveau) : `AppPermissions(role)` miroir
  des ensembles backend (`secretaryRoles`/`treasurerRoles`/`adminRoles`) +
  capacités par domaine (`canManageMembres`, `canDeleteMembres`,
  `canRecordSacrement`, `canManageGroupes`, `canManageEvenements`,
  `canDeleteEvenements`, `canViewFinances`, `canManageFinances`,
  `canDeleteFinances`, `canManageLibrairie`, `canDeleteLibrairie`). Extension
  `context.perms` (via `watch<AuthBloc>`).
- **Boutons gâtés** (create FAB / edit / delete / ajouter sacrement /
  réapprovisionner) dans : membres (liste+détail), groupes (liste+détail),
  événements (liste+détail — cumulé avec la désactivation « passé »), finances
  (liste), librairie (liste + FAB vente/article).
- **Navigation** : l'entrée **Finances** est masquée sauf `canViewFinances`
  (sidebar desktop `main_layout.dart` + drawer mobile `app_drawer.dart`), car la
  vue liste backend exige elle-même `IsTreasurerOrAbove`.

Mapping appliqué (= enforcement réel des vues) : membres create/edit =
secrétaire+, delete = admin ; groupes create/edit/delete = admin ; événements
create/edit = secrétaire+, delete = admin ; finances view/create/edit =
trésorier+, delete = admin ; librairie create/edit = secrétaire+, delete = admin.

### Files

- `lib/data/models/auth_model.dart`, `lib/core/auth/permissions.dart`
- `lib/presentation/screens/{membres,groupes,evenements,finances,librairie}/**`
- `lib/presentation/widgets/{main_layout.dart,app_drawer.dart}`

### Follow-up

- `flutter analyze` : 0 erreur. La sécurité reste **côté backend** — ce gating
  n'est qu'un confort d'affichage (le backend refuse toujours un appel non
  autorisé).
- Le gating reproduit les classes de rôle. Si le backend bascule sur
  `HasPermission` (granulaire, `core/rbac.py`), réaligner `AppPermissions`.
- **Non traité** : le `DashboardBloc` interroge les finances pour ses stats ;
  pour un rôle < trésorier, cet appel peut renvoyer 403 — à gâter séparément si
  besoin (afficher la carte Finances du tableau de bord seulement si
  `canViewFinances`).

## 2026-07-15 — Événements : conviés (convocations) + détails groupe/événement

### Symptom / besoin

Fonctionnalités demandées : (1) détail d'un groupe montrant ses membres et son
responsable ; (2) à la création d'un événement, choisir les conviés (rôle
précis / tous / ensemble de rôles / groupe entier ou sélection de membres) ;
(3) la liste des événements ne montre que ceux où l'utilisateur est convié ;
(4) écran de détail d'un événement avec gestion des conviés ; (5) boutons
modifier/supprimer désactivés si l'événement est passé.

### Fix (frontend ; backend documenté dans `../backend/fixs.md`)

- **Modèle** `evenement_model.dart` : champs `inviteTous`, `rolesInvites`,
  `groupesInvites`, `membresInvites`, `groupesInvitesNoms`,
  `membresInvitesNoms`, `estPasse` (repli calculé depuis les dates si le
  backend ne fournit pas `est_passe`).
- **Détail groupe** (nouveau `groupe_detail_screen.dart` + route `/groupes/:id`)
  : infos + responsable + liste des membres (avatars) ; carte de groupe rendue
  cliquable. `groupes_bloc` : `LoadGroupeDetail` charge maintenant groupe +
  membres en parallèle.
- **Sélecteur de conviés** dans `evenement_form_screen.dart` : switch « toute la
  paroisse », FilterChips de rôles, sélecteurs multi (dialog avec recherche)
  pour groupes entiers et membres précis ; groupes/membres chargés via
  repositories. Envoi de `invite_tous`/`roles_invites`/`groupes_invites`/
  `membres_invites` ; préremplissage à l'édition.
- **Détail événement** (nouveau `evenement_detail_screen.dart` + route
  `/evenements/:id`) : infos, conviés (puces), participants ; boutons
  modifier/supprimer **désactivés si `estPasse`**. Carte de la liste rendue
  cliquable ; menu modifier/supprimer désactivé si passé.

### Files

- `lib/data/models/evenement_model.dart`
- `lib/presentation/blocs/groupes/groupes_bloc.dart`
- `lib/presentation/screens/groupes/{groupe_detail_screen.dart,groupes_screen.dart}`
- `lib/presentation/screens/evenements/{evenement_detail_screen.dart,evenement_form_screen.dart,evenements_screen.dart}`
- `lib/core/router/app_router.dart`

### Follow-up

- `flutter analyze` : 0 erreur. Backend : 90 tests OK, migration
  `evenements/0002` appliquée. **Redémarrer le backend** pour servir les
  nouveaux champs.
- Visibilité retenue : **chacun ne voit que ses convocations**, mais le
  **créateur** voit toujours ses propres événements (sinon le personnel
  perdrait l'accès à ce qu'il crée).
- Non couvert offline : la sélection groupes/membres du form nécessite d'avoir
  déjà chargé groupes+membres (repli cache). Reste online-only :
  l'inscription (`inscrire`).

## 2026-07-15 — Photo de profil du membre absente du `membre_detail_screen`

### Symptom

L'en-tête du détail membre n'affichait pas la photo de profil. Le code de
l'avatar était par ailleurs cassé (5 erreurs de compilation) : il lisait
`membre.user?.profilePictureUrl` / `membre.user?.firstName` alors que
`membre.user` est un `String?` (l'UUID du compte lié), pas un objet, et un
`CircleAvatar` en doublon subsistait juste après.

### Root cause

Le serializer `MembreSerializer` n'exposait aucune URL de photo : la photo
appartient au compte `user` associé (`user.profile_picture`), mais seuls
`email` et `phone_number` en étaient dérivés. Le frontend n'avait donc aucune
URL à afficher.

### Fix

Bout-en-bout (backend + frontend) :

- **Backend** (`membres/serializers.py`) : ajout d'un
  `profile_picture_url = SerializerMethodField()` sur `MembreSerializer` (donc
  hérité par `MembreDetailSerializer`), renvoyant l'URL absolue de
  `obj.user.profile_picture` (repli URL relative si `request` hors contexte).
  `membres/views.py` : passage de `context={"request": request}` aux
  serializers de la liste et du détail pour obtenir une URL absolue.
- **Frontend** (`lib/data/models/membre_model.dart`) : nouveau champ
  `profilePictureUrl` (parse `profile_picture_url`, inclus dans
  toJson/copyWith/props et la sous-classe `MembreDetail`).
- **Écran** (`membre_detail_screen.dart`) : avatar réparé — un seul
  `UserAvatar` (halo activé) avec `imageUrl: membre.profilePictureUrl`, repli
  hors ligne sur `getCachedProfilePicture(membre.user!)`, initiales sur le
  prénom ; doublon `CircleAvatar` supprimé ; import `AuthRepository` ajouté.

### Files

- `../backend/membres/serializers.py`, `../backend/membres/views.py`
- `lib/data/models/membre_model.dart`
- `lib/presentation/screens/membres/membre_detail_screen.dart`

### Follow-up

- `flutter analyze` : 0 erreur. Backend `py_compile` OK.
- `getCachedProfilePicture` est indexé par id de compte user : la copie locale
  n'existe que pour l'utilisateur connecté ; pour les autres membres, le repli
  hors ligne tombe sur les initiales (la photo distante s'affiche en ligne).
- La colonne du tableau (`membres_screen`) pourrait aussi afficher l'avatar —
  non fait ici (demande limitée au détail).

## 2026-07-15 — Le numéro de téléphone ne s'affiche pas dans le tableau des membres

### Symptom

La colonne « Téléphone » du tableau des membres (et le détail membre) affiche
toujours « - », quel que soit le membre.

### Root cause

Le serializer backend expose le téléphone sous la clé **`phone_number`**
(source `user.phone_number`) ; il n'existe aucun champ `telephone` sur le
modèle `Membre`. Or `Membre.fromJson` lisait `json['telephone']` → toujours
`null`.

### Fix

`lib/data/models/membre_model.dart` : `fromJson` lit désormais
`json['phone_number']` (repli sur `telephone` pour compat), et `toJson` émet la
clé `phone_number` pour que la valeur survive à l'aller-retour par le cache
local (`saveItems`/`getItems`).

### Files

- `lib/data/models/membre_model.dart`

### Follow-up

- `phone_number` est en lecture seule côté backend (dérivé du compte `user`) :
  éditer le téléphone depuis la fiche membre n'a aucun effet serveur — à
  traiter séparément si le besoin se confirme.

## 2026-07-15 — Intégration de l'endpoint de synchronisation offline `/api/v1/sync/`

### Symptom

Le backend expose un endpoint de synchronisation bidirectionnelle
(`POST /api/v1/sync/`, push/pull, last-write-wins via `updated_at`, soft-delete
`is_deleted`, UUID générés côté client) mais le frontend ne l'utilisait pas :
les écritures (création / modification / suppression) échouaient purement et
simplement hors ligne, sans file d'attente ni reprise.

### Root cause

La synchro frontend était **pull-only** : `SyncService` rechargeait les listes
REST dans le cache Isar toutes les 5 min, mais aucune brique ne poussait les
écritures locales. Les repositories faisaient un appel réseau direct
(POST/PUT/PATCH/DELETE) qui levait `NetworkException` hors ligne.

### Fix

Ajout d'une couche de synchro **bidirectionnelle additive** (le pull REST
historique `SyncService.syncAll` reste l'autorité de rafraîchissement) :

- **Outbox** (`lib/core/database/pending_change_entity.dart`, collection Isar
  `PendingChangeEntity`) : file d'attente des écritures locales. Champ nommé
  `syncCollection` et **non** `collection` — un champ `collection` casse le code
  généré par isar_plus (collision avec sa variable interne `collection`).
- **UUID côté client** (`lib/core/utils/id_generator.dart`, v4 sans dépendance).
- **DatabaseService** étendu : `enqueueLocalChange` (fusion outbox + fusion
  cache pour ne pas perdre de champs sur un PATCH ; renvoie l'enregistrement
  fusionné), `getPendingChanges`/`removePending`/`clearPending`, curseur
  `get/setSyncCursor`, `upsertItem`/`deleteItem` (upsert d'un seul
  enregistrement).
- **Transport** `lib/core/sync/sync_api.dart` (`POST /sync/` → `{server_time,
  results, changes}`), endpoint `ApiConstants.sync = '/sync/'`.
- **Moteur** `lib/core/sync/offline_sync_service.dart` (`pushPull`) : pousse
  l'outbox, traite `results` (applied → purge ; conflicts → la copie serveur
  écrase le cache ; errors → journalisé + purgé pour éviter une boucle
  d'empoisonnement), intègre `changes` dans le cache, avance le curseur. Table
  de correspondance collection `/sync/` → type de cache
  (`transactions`→`finances`, `articles`→`librairie`, etc.).
- **PeriodicSyncManager** : chaque passe fait `pushPull()` **puis** `syncAll()`
  (pousser avant rafraîchir). `forceSyncNow` fait les deux ; nouveau
  `pushLocalChanges()`.
- **Repositories** (membres/groupes/évènements/finances/librairie + sacrements,
  ventes) : `create/update/patch/delete` interceptent `NetworkException` et
  basculent sur `queueOfflineWrite` (`lib/core/sync/offline_write.dart`) —
  file d'attente + application optimiste au cache, retour d'un modèle local. Le
  comportement **en ligne est inchangé** (appel direct + `clearTable`).
- Correctif au passage : `createVente` vidait `clearTable('evenements')` (copié-
  collé erroné) → corrigé en `'librairie'` (une vente décrémente le stock).

### Files

- `lib/core/database/pending_change_entity.dart` (+ `.g.dart` régénéré),
  `database_service.dart`, `cached_entity.dart`
- `lib/core/utils/id_generator.dart`
- `lib/core/sync/sync_api.dart`, `offline_sync_service.dart`,
  `offline_write.dart`, `periodic_sync_manager.dart`
- `lib/core/constants/api_constants.dart`, `lib/core/di/injection.dart`
- `lib/data/repositories/{membre,groupe,evenement,finance,librairie}_repository.dart`

### Follow-up

- `flutter analyze` : 0 erreur (un `info` de style pré-existant demeure). Le test
  `widget_test.dart` « Counter increments smoke test » échoue mais c'est le
  boilerplate Flutter d'origine (aucun compteur dans l'app), pré-existant.
- **Limitations connues** : l'inscription à un évènement (`inscrire`,
  collection `participations`) et l'auto-modification de profil
  (`updateMyMembre`) restent en ligne uniquement. La pagination de `syncAll`
  (PAGE_SIZE 50) peut ne pas re-télécharger un élément au-delà de la 1re page
  juste après sa poussée — limitation pré-existante du pull REST.
- **À vérifier en conditions réelles** : un aller-retour hors ligne complet
  (créer/modifier/supprimer hors connexion, puis reconnecter et confirmer la
  poussée + la résolution de conflit) sur un appareil, non exécutable ici.

## 2026-07-15 — Alignement frontend sur les clés primaires UUID du backend

### Symptom

Le backend est passé de clés primaires entières auto-incrémentées à des UUID
(commit backend `feat: Implement UUID primary keys and offline sync
functionality`). Toutes les entités (`Membre`, `Groupe`, `Evenement`,
`Transaction`, `Article`, `Vente`, `Sacrement`, `UserActivity`, `User`)
renvoient désormais un `id` chaîne UUID, et les routes de détail attendent
`<uuid:pk>` au lieu de `<int:pk>`. Côté frontend, les `json['id'] as int?`
levaient une exception de cast à la désérialisation, et les URLs de détail /
mise à jour / suppression étaient malformées.

### Root cause

Le contrat d'API a changé de type d'identifiant (int → UUID string). Le
frontend typait tous les `id` et clés étrangères en `int`, aussi bien dans les
modèles que dans les helpers d'URL, les repositories, les BLoCs, les écrans et
le routeur. Le cache Isar indexait aussi les entités par `entityId` entier.

### Fix

Migration mécanique `int → String` de tous les identifiants et clés étrangères
(en conservant les compteurs : `nb_participants`, `stock_disponible`,
`seuil_alerte`, `quantite`, et les totaux du tableau de bord, en `int`) :

- **Modèles** (`lib/data/models/*.dart`) : `id` + FK (`user`, `groupe`,
  `responsable`, `createur`, `membre`, `officiant`, `article`,
  `enregistre_par`) passés en `String`/`String?`, désérialisation
  `as String? ?? ''` / `as String?`, `copyWith` et `props` mis à jour.
- **URLs** (`lib/core/constants/api_constants.dart`) : tous les helpers
  `xById(int id)` → `(String id)`.
- **Cache Isar** (`lib/core/database/cached_entity.dart` +
  `database_service.dart`) : `entityId` `int → String`, `_cachedId`,
  `saveItems`, `getItemById` réalignés ; `cached_entity.g.dart` régénéré via
  `dart run build_runner build --delete-conflicting-outputs`.
- **Repositories / BLoCs / écrans / routeur** : paramètres `int id` →
  `String id`, `int.parse(pathParameters['id'])` supprimé (les UUID sont déjà
  des chaînes), variables et dropdowns de sélection (`_selectedGroupe`,
  `_selectedMembre`, `DropdownButtonFormField<int?>`) retypés en `String?`.

Le préfixe `/api/v1/` était déjà en place dans `ApiConstants.baseUrl`.

### Files

- `lib/data/models/{membre,groupe,evenement,transaction,article,vente,sacrement,activity,auth}_model.dart`
- `lib/core/constants/api_constants.dart`
- `lib/core/database/cached_entity.dart`, `database_service.dart`, `cached_entity.g.dart`
- `lib/data/repositories/*.dart`
- `lib/presentation/blocs/{membres,groupes,evenements,finances,librairie}/*.dart`
- `lib/presentation/screens/**` (formulaires, détails, listes) et `lib/core/router/app_router.dart`

### Follow-up

- `flutter analyze` : aucune erreur (reste un seul `info` de style pré-existant
  sur un commentaire de doc).
- **Non fait — décision produit en attente** : le backend expose un nouvel
  endpoint `POST /api/v1/sync/` (push/pull bidirectionnel, last-write-wins via
  `updated_at`, soft-delete `is_deleted`, UUID générés côté client). Le
  frontend garde pour l'instant son cache Isar en lecture seule + pull
  périodique REST ; l'intégration de la synchro d'écritures hors ligne reste à
  planifier.

## 2026-07-06 — Tableau de bord, Finances et Librairie n'affichent plus rien hors ligne

### Symptom

Sans connexion réseau, les écrans Tableau de bord, Finances et Librairie
n'affichent plus aucune donnée (alors que Membres/Groupes/Événements
continuent de fonctionner grâce à leur cache).

### Root cause

Trois bugs distincts, chacun cassant une source de données différente :

- **Librairie** : `LibrairieRepository.getArticles()` n'avait **aucune**
  logique de cache — appel direct au serveur à chaque fois, sans repli. Pire,
  le repository était même enregistré dans le DI **sans** `DatabaseService`
  du tout, et `SyncService` ne connaissait pas `LibrairieRepository` : la
  table SQLite `librairie` (pourtant créée par le schéma) n'était donc jamais
  alimentée par la synchronisation périodique.
- **Finances** : `FinanceRepository.getRapport()` (utilisé par l'écran
  Finances ET par le Tableau de bord) tape un endpoint dédié
  (`/finances/rapport/`) sans aucun repli cache — hors ligne, il lève
  toujours une exception.
- **Tableau de bord** : `DashboardBloc._loadData()` charge 5 sources via
  `Future.wait([...])`. Dès qu'**une seule** échoue (typiquement
  `getRapport()`, cf. ci-dessus), `Future.wait` rejette immédiatement et
  **toutes** les données sont perdues — y compris membres/groupes/événements/
  transactions qui, eux, avaient un cache valide et auraient pu s'afficher.

Bonus (repéré en cours de route, corrigé au passage car directement dans le
code touché) : la réponse de `/finances/rapport/` renvoyait `solde` et
`par_categorie` sous forme de **liste** `[{"categorie":..,"total":..}]`,
alors que le modèle Flutter `RapportFinancier.fromJson` attend `balance` et
un **dict** `{categorie: total}` — la balance et la répartition par
catégorie étaient donc silencieusement toujours à zéro/vides, même en ligne.

### Fix

- `backend/finances/views.py` : `RapportFinancierView` renvoie désormais
  `balance` (au lieu de `solde`) et `par_categorie` sous forme de dict.
- `lib/data/repositories/finance_repository.dart` : `getRapport()` retombe,
  hors ligne et sans filtre de période, sur un rapport **recalculé
  localement** à partir des transactions déjà en cache (`_computeLocalRapport`).
  Une période filtrée reste, comme documenté, impossible à honorer hors ligne.
- `lib/data/repositories/librairie_repository.dart` : `getArticles()` suit
  désormais le même schéma cache-first que les autres repositories
  (`fetchArticles()` + cache SQLite `librairie` quand aucun filtre n'est
  actif).
- `lib/core/sync/sync_service.dart` : ajout de `_syncLibrairie()`, appelé
  dans `syncAll()` et `syncEntity('librairie')`.
- `lib/core/di/injection.dart` : `LibrairieRepository` reçoit enfin un
  `DatabaseService` ; `SyncService` reçoit `LibrairieRepository`.
- `lib/presentation/blocs/dashboard/dashboard_bloc.dart` : chaque source est
  désormais isolée via `_safeList`/`_safeRapport` (repli sur liste vide /
  rapport à zéro en cas d'échec individuel) avant le `Future.wait`, pour que
  l'échec d'une seule source n'efface plus les autres.

### Files touched

- `backend/finances/views.py`
- `lib/data/repositories/finance_repository.dart`
- `lib/data/repositories/librairie_repository.dart`
- `lib/core/sync/sync_service.dart`
- `lib/core/di/injection.dart`
- `lib/presentation/blocs/dashboard/dashboard_bloc.dart`

### Follow-up

- Le rapport recalculé localement (hors ligne) n'inclut pas de ventilation
  `par_mois` (le backend ne la calcule pas non plus — champ toujours vide,
  y compris en ligne). Fonctionnalité à ajouter séparément si le graphique
  mensuel doit réellement se remplir.
- Vérifié la transformation `par_categorie` liste→dict directement contre la
  base de données de dev (résultats corrects) ; pas de test end-to-end HTTP
  réel (même limitation que le fix précédent).

## 2026-07-06 — L'app éjecte vers /login quand le profil ne peut pas être rafraîchi hors connexion

### Symptom

En consultant l'écran Profil sans connexion réseau (ou serveur injoignable),
l'utilisateur est brutalement renvoyé à l'écran de connexion — alors que ses
jetons sont toujours valides. Perçu comme un crash de l'application.

### Root cause

`ProfileScreen` déclenche systématiquement `AuthUserProfileRefreshed` à
l'ouverture (GET `/user/profile/`), même quand un utilisateur est déjà
affiché. En cas d'échec réseau, `AuthBloc` émettait `AuthError`. Le guard de
`AppRouter` (`redirect`) considérait **tout état différent de
`AuthAuthenticated`** — y compris `AuthError`, qui est un état transitoire
sans rapport avec la validité de la session — comme "non authentifié", et
renvoyait donc immédiatement vers `/login` via `refreshListenable:
GoRouterRefreshStream(authBloc.stream)`.

Par ailleurs, rien n'était mis en cache localement pour le profil membre
(date de naissance/sexe/quartier ajoutés le 2026-07-04) : hors connexion,
`MembreRepository.getMyMembre()` remontait directement l'exception réseau.

### Fix

- `lib/core/router/app_router.dart` : le redirect ne force `/login` que sur
  un état explicitement déconnecté (`AuthUnauthenticated` — vraie
  déconnexion/session expirée), et ne quitte `/login` que sur un état
  confirmant l'authentification (`AuthAuthenticated`/`AuthLoginSuccess`).
  Tout état transitoire (`AuthError`, `AuthLoading`, states de succès d'une
  sous-action) laisse l'utilisateur sur l'écran courant.
- `lib/presentation/blocs/auth/auth_bloc.dart` : `AuthUserProfileRefreshed`
  retombe sur `AuthRepository.getCachedUser()` (déjà stocké en secure
  storage) en cas d'échec réseau, au lieu d'émettre `AuthError`.
- `lib/data/repositories/membre_repository.dart` : `getMyMembre()` /
  `updateMyMembre()` mettent désormais en cache la fiche membre personnelle
  (secure storage, nouvelle clé `membre_self_data`) et y retombent en cas
  d'échec réseau (`ApiException` non-404 ou `NetworkException`).
- La photo de profil elle-même reste mise en cache disque automatiquement via
  `CachedNetworkImage` (déjà utilisé par `UserAvatar` depuis le 2026-07-04) :
  une fois chargée en ligne au moins une fois, elle reste affichable hors
  connexion sans changement supplémentaire.

### Files touched

- `lib/core/router/app_router.dart`
- `lib/presentation/blocs/auth/auth_bloc.dart`
- `lib/data/repositories/membre_repository.dart`
- `lib/core/storage/secure_storage.dart`, `lib/core/constants/app_constants.dart`
  (clé `membre_self_data`)
- `lib/core/di/injection.dart` (injection de `SecureStorage` dans
  `MembreRepository`)

### Follow-up

- Ce même bug de redirect touchait potentiellement toute action émettant
  `AuthError` pendant une session déjà active (changement de mot de passe,
  mise à jour du profil, changement de photo, changement d'URL serveur) —
  le fix au niveau du router les corrige toutes en une fois, pas seulement le
  cas du profil.
- Pas de reproduction end-to-end (coupure réseau réelle dans l'app) faute
  d'environnement de test disponible ; à confirmer manuellement en coupant le
  réseau puis en ouvrant l'écran Profil.

---

## 2026-07-06 — Les filtres/tri des listes ne filtraient rien (Membres, Groupes, Finances, Librairie)

### Symptom

Sur l'écran Membres, changer le filtre Sexe (Masculin/Féminin) ou taper dans
la recherche ne changeait jamais la liste affichée. Constaté ensuite comme un
problème plus large touchant Groupes, Finances et Librairie.

### Root cause

Chaque module avait un bug différent, mais avec le même effet (le filtre est
un no-op) :

- **Membres** : `MembreRepository.getMembres()` avait toute sa logique de
  filtrage en commentaire — la méthode ignorait `search`/`groupe`/`sexe`/`page`
  et renvoyait toujours le cache ou la liste complète. Même corrigé côté app,
  le backend (`MembreService.search_membres`) ne connaissait pas du tout le
  paramètre `sexe`, et n'acceptait pas de recherche libre (seulement `nom`/
  `prenom` séparés, alors que l'app n'a qu'une seule boîte de recherche
  envoyant `search`).
- **Groupes** : l'app envoie `?search=`, mais `GroupeListView.get()` ne lisait
  que `?nom=` — mismatch de nom de paramètre, la recherche ne faisait rien.
- **Finances** (`TransactionListView`) et **Librairie**
  (`ArticleListView`) : ces vues ne lisaient **aucun** query param et
  renvoyaient systématiquement la liste complète, quels que soient les filtres
  envoyés par l'app (type/catégorie/dates/membre pour les transactions,
  recherche/catégorie/alerte stock pour les articles).
- **Événements** : cas à part, les filtres `type`/`upcoming` fonctionnaient
  déjà réellement ; seule la recherche libre (`search`, sur le titre) était
  ignorée côté backend.

### Fix

- `backend/membres/services.py` : `search_membres()` accepte désormais
  `sexe` et un paramètre `search` générique (nom OU prénom, prioritaire sur
  `nom`/`prenom` séparés).
- `backend/membres/views.py` : `MembreListView.get()` lit et transmet
  `search`/`sexe`.
- `backend/groupes/views.py` : `GroupeListView.get()` lit `search` (avec
  repli sur `nom` pour compatibilité).
- `backend/evenements/views.py` : `EvenementListView.get()` filtre désormais
  sur `search` (titre).
- `backend/finances/views.py` : `TransactionListView.get()` filtre
  maintenant réellement sur `type`/`categorie`/`date_debut`/`date_fin`/
  `membre`.
- `backend/librairie/views.py` : `ArticleListView.get()` filtre maintenant
  sur `search` (nom)/`categorie`/`en_alerte`.
- `lib/data/repositories/membre_repository.dart` : `getMembres()` — code de
  filtrage restauré (décommenté et corrigé), suit désormais le même schéma
  que les autres repositories (filtre présent → toujours serveur ; sinon
  cache-first).

### Files touched

- `backend/membres/services.py`, `backend/membres/views.py`
- `backend/groupes/views.py`
- `backend/evenements/views.py`
- `backend/finances/views.py`
- `backend/librairie/views.py`
- `lib/data/repositories/membre_repository.dart`

### Follow-up

- La pagination (`page`) envoyée par `MembreRepository.getMembres` et
  `FinanceRepository.getTransactions` n'est toujours pas appliquée côté
  backend (ces vues sont de simples `APIView`, pas des `ListAPIView` avec
  pagination DRF). Pas de bouton de pagination visible dans l'UI actuelle
  donc pas d'impact utilisateur constaté, mais à corriger si une pagination
  de liste est ajoutée plus tard.
- Vérifié uniquement au niveau ORM/service (requêtes exécutées directement
  contre la base de données de dev, résultats cohérents) — le test bout-en-bout
  via une requête HTTP authentifiée n'a pas pu être exécuté facilement depuis
  le shell (l'authentification JWT de l'app n'est pas trivialement simulable
  hors HTTP réel) ; à valider manuellement dans l'app sur les écrans Membres,
  Groupes, Finances et Librairie.

---

## 2026-07-04 — Auto-modification par un membre de sa date de naissance / sexe / quartier

### Symptom

Un utilisateur normal (rôle `fidele`) n'avait aucun moyen de modifier sa propre
date de naissance, son sexe ou son quartier. Ces champs existent bien sur le
modèle `Membre` et sont déjà éditables... mais uniquement par le personnel
(`IsSecretaryOrAbove`) via l'écran Membres, qui modifie n'importe quelle fiche,
pas la sienne. Aucun endpoint "self" n'existait.

### Root cause

`MembreDetailView` (PUT/PATCH `/api/membres/<pk>/`) est protégé par
`IsSecretaryOrAbove` : un compte `fidele` reçoit un 403 s'il tente de modifier
sa propre fiche membre.

### Fix

- Backend : nouvel endpoint `GET/PATCH /api/membres/me/` (`MembreMeView`),
  ouvert à tout utilisateur authentifié, qui résout `request.user.membre`
  (relation `OneToOne`) et n'autorise en écriture que `date_naissance`, `sexe`,
  `quartier` via un nouveau `MembreSelfSerializer` (identité, sacrements,
  groupe restent en lecture seule / réservés au personnel).
- Frontend : `MembreRepository.getMyMembre()` / `updateMyMembre()`,
  événements/états `LoadMyMembre` / `UpdateMyMembre` /
  `MyMembreLoaded` / `MyMembreUpdated` sur `MembresBloc`, et une nouvelle
  section "Informations paroissiales" sur l'écran Profil (sexe, date de
  naissance, quartier) — masquée si le compte n'a pas de fiche membre liée
  (ex : compte admin sans `Membre`).

### Files touched

- `backend/membres/serializers.py` (`MembreSelfSerializer`)
- `backend/membres/views.py` (`MembreMeView`)
- `backend/membres/urls.py`
- `lib/core/constants/api_constants.dart` (`membreMe`)
- `lib/data/repositories/membre_repository.dart`
- `lib/presentation/blocs/membres/membres_bloc.dart`
- `lib/presentation/screens/profile/profile_screen.dart`

### Follow-up

- Le modèle Flutter `Membre.telephone` lit la clé JSON `telephone`, mais aucun
  serializer backend (`MembreSerializer` ni `MembreSelfSerializer`) ne renvoie
  cette clé — c'est `phone_number` (issu de `user.phone_number`) qui est
  envoyé. Ce champ est donc toujours `null` côté app. Pas corrigé ici (hors
  périmètre de cette demande) ; à corriger si le téléphone du membre doit
  s'afficher quelque part.

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
