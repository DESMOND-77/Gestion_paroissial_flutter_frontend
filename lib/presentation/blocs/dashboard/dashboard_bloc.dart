import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/repositories/membre_repository.dart';
import '../../../data/repositories/groupe_repository.dart';
import '../../../data/repositories/evenement_repository.dart';
import '../../../data/repositories/finance_repository.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/evenement_model.dart';

// Events
abstract class DashboardEvent extends Equatable {
  const DashboardEvent();
  @override
  List<Object?> get props => [];
}

class LoadDashboard extends DashboardEvent {
  const LoadDashboard();
}

class RefreshDashboard extends DashboardEvent {
  const RefreshDashboard();
}

// States
abstract class DashboardState extends Equatable {
  const DashboardState();
  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends DashboardState {
  final int totalMembres;
  final int totalGroupes;
  final int evenementsAVenir;
  final double balanceFinanciere;
  final double totalRecettes;
  final double totalDepenses;
  final List<Transaction> recentTransactions;
  final List<Evenement> prochainEvenements;
  final Map<String, double> depensesParCategorie;
  final List<Map<String, dynamic>> recettesDepensesParMois;

  const DashboardLoaded({
    required this.totalMembres,
    required this.totalGroupes,
    required this.evenementsAVenir,
    required this.balanceFinanciere,
    required this.totalRecettes,
    required this.totalDepenses,
    required this.recentTransactions,
    required this.prochainEvenements,
    required this.depensesParCategorie,
    required this.recettesDepensesParMois,
  });

  @override
  List<Object?> get props => [
        totalMembres,
        totalGroupes,
        evenementsAVenir,
        balanceFinanciere,
        totalRecettes,
        totalDepenses,
        recentTransactions,
        prochainEvenements,
        depensesParCategorie,
        recettesDepensesParMois,
      ];
}

class DashboardError extends DashboardState {
  final String message;
  const DashboardError({required this.message});
  @override
  List<Object?> get props => [message];
}

// BLoC
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final MembreRepository _membreRepository;
  final GroupeRepository _groupeRepository;
  final EvenementRepository _evenementRepository;
  final FinanceRepository _financeRepository;

  DashboardBloc({
    required MembreRepository membreRepository,
    required GroupeRepository groupeRepository,
    required EvenementRepository evenementRepository,
    required FinanceRepository financeRepository,
  })  : _membreRepository = membreRepository,
        _groupeRepository = groupeRepository,
        _evenementRepository = evenementRepository,
        _financeRepository = financeRepository,
        super(const DashboardInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<RefreshDashboard>(_onRefreshDashboard);
  }

  Future<void> _onLoadDashboard(
    LoadDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());
    await _loadData(emit);
  }

  Future<void> _onRefreshDashboard(
    RefreshDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    await _loadData(emit);
  }

  Future<void> _loadData(Emitter<DashboardState> emit) async {
    try {
      // Chargées en parallèle, mais chacune est isolée : si l'une échoue
      // (ex: hors ligne et pas encore de cache pour cette source), les
      // autres restent affichées au lieu de faire échouer tout le tableau
      // de bord (Future.wait abandonnerait sinon dès la première erreur).
      final results = await Future.wait([
        _safeList(_membreRepository.getMembres),
        _safeList(_groupeRepository.getGroupes),
        _safeList(_evenementRepository.getEvenements),
        _safeList(_financeRepository.getTransactions),
        _safeRapport(_financeRepository.getRapport),
      ]);

      final membres = results[0] as List;
      final groupes = results[1] as List;
      final evenements = results[2] as List<Evenement>;
      final transactions = results[3] as List<Transaction>;
      final rapport = results[4] as RapportFinancier;

      final upcomingEvenements = evenements.where((e) => e.isUpcoming).toList()
        ..sort((a, b) => a.dateDebut.compareTo(b.dateDebut));

      final recentTrans = List<Transaction>.from(transactions)
        ..sort((a, b) => b.date.compareTo(a.date));

      emit(DashboardLoaded(
        totalMembres: membres.length,
        totalGroupes: groupes.length,
        evenementsAVenir: upcomingEvenements.length,
        balanceFinanciere: rapport.balance,
        totalRecettes: rapport.totalRecettes,
        totalDepenses: rapport.totalDepenses,
        recentTransactions: recentTrans.take(10).toList(),
        prochainEvenements: upcomingEvenements.take(5).toList(),
        depensesParCategorie: rapport.parCategorie,
        recettesDepensesParMois: rapport.parMois,
      ));
    } catch (e) {
      emit(DashboardError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<List<T>> _safeList<T>(Future<List<T>> Function() call) async {
    try {
      return await call();
    } catch (_) {
      return <T>[];
    }
  }

  Future<RapportFinancier> _safeRapport(
    Future<RapportFinancier> Function() call,
  ) async {
    try {
      return await call();
    } catch (_) {
      return const RapportFinancier(
        totalRecettes: 0,
        totalDepenses: 0,
        balance: 0,
        parCategorie: {},
        parMois: [],
      );
    }
  }
}
