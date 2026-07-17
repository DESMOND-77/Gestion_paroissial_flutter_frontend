import 'package:isar_plus/isar_plus.dart';

part 'cached_entity.g.dart';

/// Ligne générique de cache hors ligne : un blob JSON par (type d'entité,
/// id serveur). Remplace l'ancien schéma sqflite `CREATE TABLE `<`entity`>` (id,
/// data, syncedAt)` - une seule collection Isar joue le rôle de toutes les
/// anciennes tables (membres, groupes, evenements, finances, librairie).
///
/// L'id Isar est dérivé de façon déterministe de "entityType|entityId" (via
/// `Isar.fastHash`, voir `_entityId` dans database_service.dart) plutôt
/// qu'auto-incrémenté : cela tient lieu de contrainte d'unicité (entityType,
/// entityId) sans index composite, et rend `getItemById` une lecture directe
/// par clé primaire (O(1)) au lieu d'une requête filtrée.
@collection
class CachedEntity {
  // Toujours affecté explicitement (voir database_service.dart) via
  // Isar.fastHash - pas d'auto-incrément : isar_plus n'assigne pas
  // automatiquement d'id sur put(), il faut l'appeler soi-même.
  int id = 0;

  @Index()
  late String entityType;

  // Id serveur de l'entité (UUID depuis la migration backend vers des clés
  // primaires UUID). Auparavant un entier auto-incrémenté.
  late String entityId;

  late String dataJson;

  late DateTime syncedAt;
}

/// Horodatage de dernière synchronisation par type d'entité - remplace
/// l'ancienne table sqflite `sync_metadata`.
@collection
class SyncMetadataEntity {
  // Toujours affecté explicitement (voir database_service.dart) via
  // Isar.fastHash - pas d'auto-incrément : isar_plus n'assigne pas
  // automatiquement d'id sur put(), il faut l'appeler soi-même.
  int id = 0;

  @Index(unique: true)
  late String entityType;

  late DateTime lastSyncAt;
}
