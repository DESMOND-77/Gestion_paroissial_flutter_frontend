# Base de données locale & synchronisation

L'application est **_offline-first_** : elle met en cache les données localement et synchronise avec le serveur. Le système est auto-initialisé dans `main.dart` via `PeriodicSyncManager.startPeriodicSync()`.

## Moteur : Isar (`isar_plus`)

- Base **NoSQL** locale (`lib/core/database/database_service.dart`), via le paquet `isar_plus`.
- Choisi car c'est le seul fork d'Isar supportant réellement les **six** plateformes cibles : Android, iOS, Linux, macOS, Windows **et** Web.
- Sur les plateformes natives, `isar_plus_flutter_libs` embarque le moteur automatiquement.
- Sur le **Web**, le moteur tourne en **WASM** et est chargé explicitement (`Isar.initialize('isar_plus.wasm')` dans `main.dart` quand `kIsWeb`). Les fichiers `web/isar_plus.{wasm,js}` sont auto-hébergés et doivent correspondre à la version épinglée dans `pubspec.yaml`.

## Collections

Définies dans `lib/core/database/cached_entity.dart` :

- **`CachedEntity`** - un blob JSON par couple `(entityType, entityId)`. Remplace les anciennes tables SQLite (`membres`, `groupes`, `evenements`, `finances`, `librairie`).
- **`SyncMetadataEntity`** - horodatage de dernière synchro par type d'entité.
- **`PendingChangeEntity`** - file d'attente (outbox) des écritures hors ligne. Le champ s'appelle `syncCollection` (et **non** `collection`, qui entre en collision avec le générateur `isar_plus`).

Les identifiants sont **déterministes** (`Isar.fastHash('$entityType|$entityId')`) : `getItemById` est une lecture O(1) par clé primaire.

> Après modification de `cached_entity.dart` / `pending_change_entity.dart`, régénérez :
> `dart run build_runner build --delete-conflicting-outputs`

## API publique de `DatabaseService`

`saveItems` · `getItems` · `getItemById` · `getLastSyncTime` · `isCacheValid` · `hasData` · `clearDatabase` · `clearTable` · `close` - inchangée depuis l'implémentation SQLite d'origine (seul le moteur de stockage a changé).

## Stratégie de synchronisation

Chaque cycle de **5 minutes** (`PeriodicSyncManager._syncCycle`) exécute deux étapes, dans l'ordre : **push puis pull**.

### 1. Push - écritures hors ligne

`OfflineSyncService.pushPull` (`lib/core/sync/offline_sync_service.dart`) :

1. Envoie l'outbox local à `POST /api/v1/sync/`.
2. Traite les `results` :
   - `applied` → retiré de la file
   - `conflicts` → la copie serveur écrase le cache (**last-write-wins** sur `updated_at`)
   - `errors` → journalisés puis retirés (évite la boucle « poison-pill »)
3. Fusionne les `changes` serveur dans le cache.
4. Avance le curseur de synchro (`server_time`).

Correspondance des noms de collections : `transactions`→`finances`, `articles`→`librairie`, etc. (`OfflineSyncService._cacheEntityType`).

### 2. Pull - rafraîchissement REST

`SyncService.syncAll` recharge les listes complètes des 5 types d'entités en lecture.

## Écritures hors ligne

Les méthodes `create`/`update`/`patch`/`delete` des repositories :

- **En ligne** → appellent l'API directement.
- **Sur `NetworkException`** → basculent vers `queueOfflineWrite` (`lib/core/sync/offline_write.dart`) : mise en file d'attente dans l'outbox `PendingChangeEntity` + écriture optimiste dans le cache.

Une ligne d'outbox contient les champs métier plus `updated_at` et `is_deleted` (une suppression est `is_deleted: true`, pas une ligne supprimée). Les UUID générés côté client (`lib/core/utils/id_generator.dart`) gardent les identifiants stables à travers la synchro.

**Non encore compatibles hors ligne** : l'inscription aux événements (`inscrire` / `participations`) et l'édition du profil personnel (`updateMyMembre`) restent en ligne uniquement.

## Règles de lecture

| Situation                                   | Comportement                           |
| ------------------------------------------- | -------------------------------------- |
| Requête sans filtre, cache valide (< 5 min) | Cache local                            |
| Cache absent ou expiré                      | Serveur, puis mise à jour du cache     |
| Requête avec filtre / pagination / dates    | **Toujours** le serveur (cache ignoré) |

La connectivité est détectée via `connectivity_plus` (synchro uniquement en ligne).

## Contrôle manuel

```dart
final syncManager = sl<PeriodicSyncManager>();
await syncManager.forceSyncNow();               // synchro immédiate
await syncManager.forceEntitySync('membres');   // une entité
await syncManager.clearCache();                 // vider le cache
final isOnline = await syncManager.isOnline();  // connectivité
```

## Dépannage

- **« Données anciennes »** - normal : le cache se rafraîchit toutes les 5 min, ou via `forceSyncNow()`.
- **« Mon élément créé n'apparaît pas »** - attendu : le cache se synchronise périodiquement.
- **`IsarNotReadyError` (Web)** - vérifiez `Isar.initialize('isar_plus.wasm')` dans `main.dart` et la présence de `web/isar_plus.{wasm,js}`.
- **Changements de schéma sans effet** - relancez `build_runner`.

Voir aussi le [guide pratique du cache](../CACHE_USAGE_GUIDE.md).
