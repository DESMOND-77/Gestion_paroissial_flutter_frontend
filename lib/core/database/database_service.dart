import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:isar_plus/isar_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'cached_entity.dart';
import 'pending_change_entity.dart';

/// Cache local hors ligne, sur Isar (remplace l'ancien moteur sqflite).
///
/// Conserve volontairement la même API publique que l'ancienne implémentation
/// SQLite (saveItems/getItems/getItemById/getLastSyncTime/isCacheValid/
/// hasData/clearDatabase/clearTable/close) : `SyncService` et les 5
/// repositories (membres, groupes, evenements, finances, librairie)
/// continuent d'appeler ces méthodes sans aucune modification — seul le
/// moteur de stockage change.
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Isar? _isar;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Isar> get database async {
    _isar ??= await _openIsar();
    return _isar!;
  }

  Future<Isar> _openIsar() async {
    // Web : le moteur Isar tourne en WASM (chargé via Isar.initialize dans
    // main.dart) et persiste dans IndexedDB — pas de répertoire de fichiers.
    // Natif (Android/iOS/Linux/macOS/Windows) : répertoire applicatif privé,
    // cohérent avec FileStorageService (pas le dossier "Documents" visible).
    final directory = kIsWeb
        ? ''
        : (await getApplicationSupportDirectory()).path;

    return Isar.openAsync(
      schemas: [
        CachedEntitySchema,
        SyncMetadataEntitySchema,
        PendingChangeEntitySchema,
      ],
      directory: directory,
      name: 'gestiparr',
    );
  }

  // Curseur de synchronisation `/sync/` (dernier `server_time` renvoyé par le
  // serveur), stocké comme une ligne SyncMetadataEntity à clé réservée.
  static const String _syncCursorKey = '__sync_cursor__';

  int _cachedId(String entityType, String entityId) =>
      Isar.fastHash('$entityType|$entityId');

  int _pendingId(String collection, String entityId) =>
      Isar.fastHash('pending|$collection|$entityId');

  int _syncMetadataId(String entityType) => Isar.fastHash(entityType);

  // Sauvegarde une liste d'éléments pour un type d'entité (remplace le
  // contenu existant de ce type, comme l'ancien "DELETE puis INSERT" sqflite).
  Future<void> saveItems(
    String entityType,
    List<Map<String, dynamic>> items,
  ) async {
    final isar = await database;
    final now = DateTime.now();

    final entities = items.map((item) {
      return CachedEntity()
        ..id = _cachedId(entityType, item['id'] as String)
        ..entityType = entityType
        ..entityId = item['id'] as String
        ..dataJson = jsonEncode(item)
        ..syncedAt = now;
    }).toList();

    final syncMetadata = SyncMetadataEntity()
      ..id = _syncMetadataId(entityType)
      ..entityType = entityType
      ..lastSyncAt = now;

    await isar.writeAsync((isar) {
      isar.cachedEntitys
          .where()
          .entityTypeEqualTo(entityType)
          .deleteAll();
      isar.cachedEntitys.putAll(entities);
      isar.syncMetadataEntitys.put(syncMetadata);
    });
  }

  // Récupère tous les éléments d'un type d'entité
  Future<List<Map<String, dynamic>>> getItems(String entityType) async {
    final isar = await database;
    final rows = await isar.cachedEntitys
        .where()
        .entityTypeEqualTo(entityType)
        .findAllAsync();
    return rows
        .map((row) => jsonDecode(row.dataJson) as Map<String, dynamic>)
        .toList();
  }

  // Récupère un élément par ID
  Future<Map<String, dynamic>?> getItemById(
    String entityType,
    String id,
  ) async {
    final isar = await database;
    final row = await isar.cachedEntitys.getAsync(_cachedId(entityType, id));
    if (row == null) return null;
    return jsonDecode(row.dataJson) as Map<String, dynamic>;
  }

  // Récupère la dernière synchronisation pour une entité
  Future<DateTime?> getLastSyncTime(String entityType) async {
    final isar = await database;
    final row = await isar.syncMetadataEntitys.getAsync(
      _syncMetadataId(entityType),
    );
    return row?.lastSyncAt;
  }

  // Vérifie si le cache est valide (moins de 5 minutes)
  Future<bool> isCacheValid(String entityType) async {
    final lastSync = await getLastSyncTime(entityType);
    if (lastSync == null) return false;
    final now = DateTime.now();
    final difference = now.difference(lastSync);
    return difference.inMinutes < 5;
  }

  // Vérifie si un type d'entité a du contenu
  Future<bool> hasData(String entityType) async {
    final isar = await database;
    final count = await isar.cachedEntitys
        .where()
        .entityTypeEqualTo(entityType)
        .countAsync();
    return count > 0;
  }

  // Efface toutes les données
  Future<void> clearDatabase() async {
    final isar = await database;
    await isar.writeAsync((isar) {
      isar.cachedEntitys.clear();
      isar.syncMetadataEntitys.clear();
      isar.pendingChangeEntitys.clear();
    });
  }

  // Efface un type d'entité spécifique
  Future<void> clearTable(String entityType) async {
    final isar = await database;
    await isar.writeAsync((isar) {
      isar.cachedEntitys.where().entityTypeEqualTo(entityType).deleteAll();
    });
  }

  // ---------------------------------------------------------------------------
  // Upsert / suppression d'un seul enregistrement (fusion incrémentale : sert à
  // intégrer les résultats de conflit renvoyés par `/sync/`, sans remplacer
  // toute la liste comme `saveItems`).
  // ---------------------------------------------------------------------------

  Future<void> upsertItem(String entityType, Map<String, dynamic> item) async {
    final isar = await database;
    final entity = CachedEntity()
      ..id = _cachedId(entityType, item['id'] as String)
      ..entityType = entityType
      ..entityId = item['id'] as String
      ..dataJson = jsonEncode(item)
      ..syncedAt = DateTime.now();
    await isar.writeAsync((isar) {
      isar.cachedEntitys.put(entity);
    });
  }

  Future<void> deleteItem(String entityType, String entityId) async {
    final isar = await database;
    await isar.writeAsync((isar) {
      isar.cachedEntitys.delete(_cachedId(entityType, entityId));
    });
  }

  // ---------------------------------------------------------------------------
  // Curseur de synchronisation `/sync/`.
  // ---------------------------------------------------------------------------

  Future<DateTime?> getSyncCursor() => getLastSyncTime(_syncCursorKey);

  Future<void> setSyncCursor(DateTime cursor) async {
    final isar = await database;
    final row = SyncMetadataEntity()
      ..id = _syncMetadataId(_syncCursorKey)
      ..entityType = _syncCursorKey
      ..lastSyncAt = cursor;
    await isar.writeAsync((isar) {
      isar.syncMetadataEntitys.put(row);
    });
  }

  // ---------------------------------------------------------------------------
  // Outbox : file d'attente des écritures hors ligne à pousser via `/sync/`.
  // ---------------------------------------------------------------------------

  /// Met en file d'attente une écriture locale et l'applique de façon optimiste
  /// au cache (pour un affichage immédiat, y compris hors ligne).
  ///
  /// [record] doit contenir `id`. `updated_at` est estampillé si absent.
  ///
  /// Deux fusions distinctes ont lieu :
  /// - **outbox** : avec l'éventuel enregistrement déjà en attente pour ce
  ///   (collection, id) — une création puis des modifications successives ne
  ///   forment qu'une seule ligne à pousser (le serveur applique un upsert).
  /// - **cache** : avec l'enregistrement déjà en cache — une modification
  ///   partielle (PATCH) ne doit pas écraser les champs absents à l'affichage.
  ///
  /// Renvoie l'enregistrement fusionné tel qu'appliqué au cache (utile pour
  /// reconstruire le modèle rendu à l'UI).
  Future<Map<String, dynamic>> enqueueLocalChange({
    required String collection,
    required String cacheEntityType,
    required Map<String, dynamic> record,
  }) async {
    final isar = await database;
    final entityId = record['id'] as String;
    record.putIfAbsent(
        'updated_at', () => DateTime.now().toUtc().toIso8601String());
    final isDeleted = record['is_deleted'] == true;

    final pendingId = _pendingId(collection, entityId);
    final existingPending = await isar.pendingChangeEntitys.getAsync(pendingId);
    final outboxMerged = <String, dynamic>{
      if (existingPending != null)
        ...jsonDecode(existingPending.dataJson) as Map<String, dynamic>,
      ...record,
    };

    final existingCache =
        await getItemById(cacheEntityType, entityId) ?? const {};
    final cacheMerged = <String, dynamic>{...existingCache, ...outboxMerged};

    final pending = PendingChangeEntity()
      ..id = pendingId
      ..syncCollection = collection
      ..entityId = entityId
      ..dataJson = jsonEncode(outboxMerged)
      ..queuedAt = DateTime.now();

    final cacheId = _cachedId(cacheEntityType, entityId);
    final cacheRow = CachedEntity()
      ..id = cacheId
      ..entityType = cacheEntityType
      ..entityId = entityId
      ..dataJson = jsonEncode(cacheMerged)
      ..syncedAt = DateTime.now();

    await isar.writeAsync((isar) {
      isar.pendingChangeEntitys.put(pending);
      if (isDeleted) {
        isar.cachedEntitys.delete(cacheId);
      } else {
        isar.cachedEntitys.put(cacheRow);
      }
    });

    return cacheMerged;
  }

  /// Renvoie les changements en attente groupés par collection (au format
  /// attendu par le corps `changes` de `POST /sync/`).
  Future<Map<String, List<Map<String, dynamic>>>> getPendingChanges() async {
    final isar = await database;
    final rows = await isar.pendingChangeEntitys.where().findAllAsync();
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final row in rows) {
      grouped
          .putIfAbsent(row.syncCollection, () => [])
          .add(jsonDecode(row.dataJson) as Map<String, dynamic>);
    }
    return grouped;
  }

  Future<void> removePending(String collection, String entityId) async {
    final isar = await database;
    await isar.writeAsync((isar) {
      isar.pendingChangeEntitys.delete(_pendingId(collection, entityId));
    });
  }

  Future<void> clearPending() async {
    final isar = await database;
    await isar.writeAsync((isar) {
      isar.pendingChangeEntitys.clear();
    });
  }

  // Ferme la base de données
  Future<void> close() async {
    final isar = await database;
    isar.close();
    _isar = null;
  }
}
