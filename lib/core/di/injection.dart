import 'package:get_it/get_it.dart';
import '../network/dio_client.dart';
import '../storage/secure_storage.dart';
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

  // Network
  sl.registerLazySingleton<DioClient>(() => DioClient(sl<SecureStorage>()));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepository(
      dioClient: sl<DioClient>(),
      secureStorage: sl<SecureStorage>(),
    ),
  );

  sl.registerLazySingleton<MembreRepository>(
    () => MembreRepository(dioClient: sl<DioClient>()),
  );

  sl.registerLazySingleton<GroupeRepository>(
    () => GroupeRepository(dioClient: sl<DioClient>()),
  );

  sl.registerLazySingleton<EvenementRepository>(
    () => EvenementRepository(dioClient: sl<DioClient>()),
  );

  sl.registerLazySingleton<FinanceRepository>(
    () => FinanceRepository(dioClient: sl<DioClient>()),
  );

  sl.registerLazySingleton<LibrairieRepository>(
    () => LibrairieRepository(dioClient: sl<DioClient>()),
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
