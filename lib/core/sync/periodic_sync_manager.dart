import 'dart:async';
import 'sync_service.dart';

class PeriodicSyncManager {
  final SyncService _syncService;
  Timer? _syncTimer;

  static const Duration _syncInterval = Duration(minutes: 5);

  PeriodicSyncManager({required SyncService syncService})
      : _syncService = syncService;

  // Démarre la synchronisation périodique
  void startPeriodicSync() {
    // Première sync au démarrage
    _syncService.syncAll();

    // Ensuite, sync toutes les 5 minutes
    _syncTimer = Timer.periodic(_syncInterval, (_) {
      _syncService.syncAll();
    });
  }

  // Arrête la synchronisation périodique
  void stopPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  // Force une synchronisation immédiate
  Future<void> forceSyncNow() async {
    await _syncService.syncAll();
  }

  // Force une synchronisation d'une entité spécifique
  Future<void> forceEntitySync(String entityType) async {
    await _syncService.syncEntity(entityType);
  }

  bool get isSyncing => _syncService.isSyncing;

  Future<bool> isOnline() => _syncService.isOnline();

  Future<void> clearCache() => _syncService.clearCache();

  void dispose() {
    stopPeriodicSync();
  }
}
