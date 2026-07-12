import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:isar_plus/isar_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'cached_entity.dart';

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
      schemas: [CachedEntitySchema, SyncMetadataEntitySchema],
      directory: directory,
      name: 'paroissiale',
    );
  }

  int _cachedId(String entityType, int entityId) =>
      Isar.fastHash('$entityType|$entityId');

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
        ..id = _cachedId(entityType, item['id'] as int)
        ..entityType = entityType
        ..entityId = item['id'] as int
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
    int id,
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
    });
  }

  // Efface un type d'entité spécifique
  Future<void> clearTable(String entityType) async {
    final isar = await database;
    await isar.writeAsync((isar) {
      isar.cachedEntitys.where().entityTypeEqualTo(entityType).deleteAll();
    });
  }

  // Ferme la base de données
  Future<void> close() async {
    final isar = await database;
    isar.close();
    _isar = null;
  }
}
