import 'dart:async';
import 'sync_service.dart';
import 'offline_sync_service.dart';

class PeriodicSyncManager {
  final SyncService _syncService;
  final OfflineSyncService _offlineSyncService;
  Timer? _syncTimer;

  static const Duration _syncInterval = Duration(minutes: 5);

  PeriodicSyncManager({
    required SyncService syncService,
    required OfflineSyncService offlineSyncService,
  })  : _syncService = syncService,
        _offlineSyncService = offlineSyncService;

  // Une passe de synchronisation complète : d'abord pousser les écritures
  // locales en attente et intégrer les changements serveur via `/sync/`, puis
  // rafraîchir les listes de référence (pull REST). L'ordre importe : pousser
  // avant le rafraîchissement garantit qu'une création faite hors ligne
  // remonte au serveur avant d'être re-téléchargée.
  Future<void> _syncCycle() async {
    await _offlineSyncService.pushPull();
    await _syncService.syncAll();
  }

  // Démarre la synchronisation périodique
  void startPeriodicSync() {
    // Première sync au démarrage
    _syncCycle();

    // Ensuite, sync toutes les 5 minutes
    _syncTimer = Timer.periodic(_syncInterval, (_) {
      _syncCycle();
    });
  }

  // Arrête la synchronisation périodique
  void stopPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  // Force une synchronisation immédiate (push + pull)
  Future<void> forceSyncNow() async {
    await _syncCycle();
  }

  // Force une synchronisation d'une entité spécifique (pull REST ciblé)
  Future<void> forceEntitySync(String entityType) async {
    await _syncService.syncEntity(entityType);
  }

  // Pousse uniquement les écritures locales en attente vers le serveur.
  Future<void> pushLocalChanges() async {
    await _offlineSyncService.pushPull();
  }

  bool get isSyncing => _syncService.isSyncing || _offlineSyncService.isSyncing;

  Future<bool> isOnline() => _syncService.isOnline();

  Future<void> clearCache() => _syncService.clearCache();

  void dispose() {
    stopPeriodicSync();
  }
}
