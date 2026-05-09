import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../database/database_service.dart';
import '../../data/repositories/membre_repository.dart';
import '../../data/repositories/groupe_repository.dart';
import '../../data/repositories/evenement_repository.dart';
import '../../data/repositories/finance_repository.dart';

class SyncService {
  final DatabaseService _databaseService;
  final MembreRepository _membreRepository;
  final GroupeRepository _groupeRepository;
  final EvenementRepository _evenementRepository;
  final FinanceRepository _financeRepository;
  final Connectivity _connectivity;

  bool _isSyncing = false;

  SyncService({
    required DatabaseService databaseService,
    required MembreRepository membreRepository,
    required GroupeRepository groupeRepository,
    required EvenementRepository evenementRepository,
    required FinanceRepository financeRepository,
    required Connectivity connectivity,
  })  : _databaseService = databaseService,
        _membreRepository = membreRepository,
        _groupeRepository = groupeRepository,
        _evenementRepository = evenementRepository,
        _financeRepository = financeRepository,
        _connectivity = connectivity;

  bool get isSyncing => _isSyncing;

  // Vérifie la connectivité internet
  Future<bool> isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  // Synchronise toutes les données
  Future<void> syncAll() async {
    if (_isSyncing) return;
    if (!await isOnline()) return;

    _isSyncing = true;
    try {
      await Future.wait([
        _syncMembres(),
        _syncGroupes(),
        _syncEvenements(),
        _syncFinances(),
      ]);
    } catch (e) {
      if (kDebugMode) print('Erreur lors de la synchronisation: $e');
    } finally {
      _isSyncing = false;
    }
  }

  // Synchronise les membres
  Future<void> _syncMembres() async {
    try {
      final membres = await _membreRepository.fetchMembers();
      await _databaseService.saveItems(
        'membres',
        membres.map((m) => m.toJson()).toList(),
      );
    } catch (e) {
      if (kDebugMode) print('Erreur sync membres: $e');
    }
  }

  // Synchronise les groupes
  Future<void> _syncGroupes() async {
    try {
      final groupes = await _groupeRepository.fetchGroupes();
      await _databaseService.saveItems(
        'groupes',
        groupes.map((g) => g.toJson()).toList(),
      );
    } catch (e) {
      if (kDebugMode) print('Erreur sync groupes: $e');
    }
  }

  // Synchronise les événements
  Future<void> _syncEvenements() async {
    try {
      final evenements = await _evenementRepository.fetchEvenements();
      await _databaseService.saveItems(
        'evenements',
        evenements.map((e) => e.toJson()).toList(),
      );
    } catch (e) {
      if (kDebugMode) print('Erreur sync événements: $e');
    }
  }

  // Synchronise les finances
  Future<void> _syncFinances() async {
    try {
      final finances = await _financeRepository.fetchTransactions();
      await _databaseService.saveItems(
        'finances',
        finances.map((f) => f.toJson()).toList(),
      );
    } catch (e) {
      if (kDebugMode) print('Erreur sync finances: $e');
    }
  }

  // Synchronise une entité spécifique
  Future<void> syncEntity(String entityType) async {
    if (!await isOnline()) return;

    try {
      switch (entityType) {
        case 'membres':
          await _syncMembres();
          break;
        case 'groupes':
          await _syncGroupes();
          break;
        case 'evenements':
          await _syncEvenements();
          break;
        case 'finances':
          await _syncFinances();
          break;
      }
    } catch (e) {
      if (kDebugMode) print('Erreur sync $entityType: $e');
    }
  }

  // Efface le cache
  Future<void> clearCache() async {
    await _databaseService.clearDatabase();
  }
}
