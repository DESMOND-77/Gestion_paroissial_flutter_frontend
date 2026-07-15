import 'package:get_it/get_it.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../network/dio_client.dart';
import '../storage/secure_storage.dart';
import '../storage/file_storage_service.dart';
import '../database/database_service.dart';
import '../sync/sync_service.dart';
import '../sync/sync_api.dart';
import '../sync/offline_sync_service.dart';
import '../sync/periodic_sync_manager.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/membre_repository.dart';
import '../../data/repositories/groupe_repository.dart';
import '../../data/repositories/evenement_repository.dart';
import '../../data/repositories/finance_repository.dart';
import '../../data/repositories/librairie_repository.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/membres/membres_bloc.dart';
import '../../presentation/blocs/groupes/groupes_bloc.dart';
import '../../presentation/blocs/evenements/evenements_bloc.dart';
import '../../presentation/blocs/finances/finances_bloc.dart';
import '../../presentation/blocs/librairie/librairie_bloc.dart';
import '../../presentation/blocs/dashboard/dashboard_bloc.dart';

final GetIt sl = GetIt.instance;

Future<void> setupDependencies() async {
  // Storage
  sl.registerLazySingleton<SecureStorage>(() => SecureStorage());
  sl.registerLazySingleton<FileStorageService>(() => FileStorageService());
  // Répertoire applicatif résolu une fois ; nécessaire avant tout accès
  // synchrone à FileStorageService (ex: affichage d'un avatar en cache).
  await sl<FileStorageService>().init();

  // Database & Sync
  sl.registerLazySingleton<DatabaseService>(() => DatabaseService());
  sl.registerLazySingleton<Connectivity>(() => Connectivity());

  // Network
  sl.registerLazySingleton<DioClient>(() => DioClient(sl<SecureStorage>()));
  // Note : DioClient ne dépend pas d'AuthRepository (dépendance circulaire) ;
  // la fin de session est signalée via le callback onSessionExpired câblé
  // dans App.

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepository(
      dioClient: sl<DioClient>(),
      secureStorage: sl<SecureStorage>(),
      fileStorage: sl<FileStorageService>(),
    ),
  );

  sl.registerLazySingleton<MembreRepository>(
    () => MembreRepository(
      dioClient: sl<DioClient>(),
      databaseService: sl<DatabaseService>(),
      secureStorage: sl<SecureStorage>(),
    ),
  );

  sl.registerLazySingleton<GroupeRepository>(
    () => GroupeRepository(
      dioClient: sl<DioClient>(),
      databaseService: sl<DatabaseService>(),
    ),
  );

  sl.registerLazySingleton<EvenementRepository>(
    () => EvenementRepository(
      dioClient: sl<DioClient>(),
      databaseService: sl<DatabaseService>(),
    ),
  );

  sl.registerLazySingleton<FinanceRepository>(
    () => FinanceRepository(
      dioClient: sl<DioClient>(),
      databaseService: sl<DatabaseService>(),
    ),
  );

  sl.registerLazySingleton<LibrairieRepository>(
    () => LibrairieRepository(
      dioClient: sl<DioClient>(),
      databaseService: sl<DatabaseService>(),
    ),
  );

  // Sync Service
  sl.registerLazySingleton<SyncService>(
    () => SyncService(
      databaseService: sl<DatabaseService>(),
      membreRepository: sl<MembreRepository>(),
      groupeRepository: sl<GroupeRepository>(),
      evenementRepository: sl<EvenementRepository>(),
      financeRepository: sl<FinanceRepository>(),
      librairieRepository: sl<LibrairieRepository>(),
      connectivity: sl<Connectivity>(),
      secureStorage: sl<SecureStorage>(),
    ),
  );

  // Offline Sync (push/pull bidirectionnel via /api/v1/sync/)
  sl.registerLazySingleton<SyncApi>(
    () => SyncApi(dioClient: sl<DioClient>()),
  );
  sl.registerLazySingleton<OfflineSyncService>(
    () => OfflineSyncService(
      databaseService: sl<DatabaseService>(),
      syncApi: sl<SyncApi>(),
      connectivity: sl<Connectivity>(),
      secureStorage: sl<SecureStorage>(),
    ),
  );

  // Periodic Sync Manager
  sl.registerLazySingleton<PeriodicSyncManager>(
    () => PeriodicSyncManager(
      syncService: sl<SyncService>(),
      offlineSyncService: sl<OfflineSyncService>(),
    ),
  );

  // BLoCs (factories so each screen gets fresh instance)
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(authRepository: sl<AuthRepository>()),
  );

  sl.registerFactory<MembresBloc>(
    () => MembresBloc(membreRepository: sl<MembreRepository>()),
  );

  sl.registerFactory<GroupesBloc>(
    () => GroupesBloc(groupeRepository: sl<GroupeRepository>()),
  );

  sl.registerFactory<EvenementsBloc>(
    () => EvenementsBloc(evenementRepository: sl<EvenementRepository>()),
  );

  sl.registerFactory<FinancesBloc>(
    () => FinancesBloc(financeRepository: sl<FinanceRepository>()),
  );

  sl.registerFactory<LibrairieBloc>(
    () => LibrairieBloc(librairieRepository: sl<LibrairieRepository>()),
  );

  sl.registerFactory<DashboardBloc>(
    () => DashboardBloc(
      membreRepository: sl<MembreRepository>(),
      groupeRepository: sl<GroupeRepository>(),
      evenementRepository: sl<EvenementRepository>(),
      financeRepository: sl<FinanceRepository>(),
    ),
  );
}
