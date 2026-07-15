import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../database/database_service.dart';
import '../storage/secure_storage.dart';
import 'sync_api.dart';

/// Synchronisation bidirectionnelle avec le serveur central via
/// `POST /api/v1/sync/`.
///
/// Complète la synchro « pull » historique (`SyncService`, qui recharge les
/// listes REST dans le cache) en ajoutant la brique manquante : **pousser les
/// écritures faites hors ligne**. À chaque passe [pushPull] :
///
/// 1. envoie la file d'attente locale (outbox) ;
/// 2. traite les résultats par enregistrement — `applied` (accepté),
///    `conflicts` (le serveur, plus récent, gagne → sa copie écrase le cache),
///    `errors` (rejet de validation → journalisé et retiré pour éviter une
///    boucle de reprise infinie) ;
/// 3. intègre les changements serveur (`changes`) dans le cache local ;
/// 4. avance le curseur (`server_time`) pour la prochaine passe incrémentale.
class OfflineSyncService {
  final DatabaseService _databaseService;
  final SyncApi _syncApi;
  final Connectivity _connectivity;
  final SecureStorage _secureStorage;

  bool _isSyncing = false;

  /// Correspondance collection `/sync/` (backend) → type d'entité du cache lu
  /// par les repositories. Les noms diffèrent pour finances/librairie ; les
  /// collections sans écran dédié (sacrements/participations/ventes) sont
  /// mises en cache sous leur propre nom.
  static const Map<String, String> _cacheEntityType = {
    'membres': 'membres',
    'groupes': 'groupes',
    'evenements': 'evenements',
    'transactions': 'finances',
    'articles': 'librairie',
    'sacrements': 'sacrements',
    'participations': 'participations',
    'ventes': 'ventes',
  };

  OfflineSyncService({
    required DatabaseService databaseService,
    required SyncApi syncApi,
    required Connectivity connectivity,
    required SecureStorage secureStorage,
  })  : _databaseService = databaseService,
        _syncApi = syncApi,
        _connectivity = connectivity,
        _secureStorage = secureStorage;

  bool get isSyncing => _isSyncing;

  Future<bool> isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<bool> _isAuthenticated() async {
    final token = await _secureStorage.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> pushPull() async {
    if (_isSyncing) return;
    if (!await _isAuthenticated()) return;
    if (!await isOnline()) return;

    _isSyncing = true;
    try {
      final pending = await _databaseService.getPendingChanges();
      final since =
          (await _databaseService.getSyncCursor())?.toUtc().toIso8601String();

      final data = await _syncApi.push(since: since, changes: pending);

      await _applyResults(data['results']);
      await _applyServerChanges(data['changes']);

      final serverTime = data['server_time'];
      if (serverTime is String) {
        final parsed = DateTime.tryParse(serverTime);
        if (parsed != null) await _databaseService.setSyncCursor(parsed);
      }
    } catch (e) {
      if (kDebugMode) print('Erreur pushPull /sync/: $e');
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _applyResults(dynamic results) async {
    if (results is! Map) return;
    for (final entry in results.entries) {
      final collection = entry.key as String;
      final res = entry.value;
      if (res is! Map) continue;
      final cacheType = _cacheEntityType[collection] ?? collection;

      // applied : ids acceptés par le serveur → retirer de la file.
      for (final id in (res['applied'] as List? ?? const [])) {
        await _databaseService.removePending(collection, id.toString());
      }

      // conflicts : le serveur a gagné → sa copie écrase le cache local.
      for (final record in (res['conflicts'] as List? ?? const [])) {
        if (record is! Map) continue;
        final r = record.cast<String, dynamic>();
        final id = r['id']?.toString();
        if (id == null) continue;
        if (r['is_deleted'] == true) {
          await _databaseService.deleteItem(cacheType, id);
        } else {
          await _databaseService.upsertItem(cacheType, r);
        }
        await _databaseService.removePending(collection, id);
      }

      // errors : rejet (validation) → journaliser et retirer pour ne pas
      // rejouer indéfiniment un enregistrement empoisonné.
      for (final err in (res['errors'] as List? ?? const [])) {
        if (err is! Map) continue;
        final id = err['id']?.toString();
        if (kDebugMode) {
          print('Sync rejeté [$collection] $id : ${err['errors']}');
        }
        if (id != null) await _databaseService.removePending(collection, id);
      }
    }
  }

  Future<void> _applyServerChanges(dynamic changes) async {
    if (changes is! Map) return;
    for (final entry in changes.entries) {
      final collection = entry.key as String;
      final records = entry.value;
      if (records is! List) continue;
      final cacheType = _cacheEntityType[collection] ?? collection;
      for (final record in records) {
        if (record is! Map) continue;
        final r = record.cast<String, dynamic>();
        final id = r['id']?.toString();
        if (id == null) continue;
        if (r['is_deleted'] == true) {
          await _databaseService.deleteItem(cacheType, id);
        } else {
          await _databaseService.upsertItem(cacheType, r);
        }
      }
    }
  }

  Future<void> clearCache() async {
    await _databaseService.clearDatabase();
  }
}
