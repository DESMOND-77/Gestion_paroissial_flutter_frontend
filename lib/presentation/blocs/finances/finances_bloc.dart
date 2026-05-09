import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/repositories/finance_repository.dart';

// Events
abstract class FinancesEvent extends Equatable {
  const FinancesEvent();
  @override
  List<Object?> get props => [];
}

class LoadTransactions extends FinancesEvent {
  final String? type;
  final String? categorie;
  final String? dateDebut;
  final String? dateFin;
  final int? membreId;
  const LoadTransactions({
    this.type,
    this.categorie,
    this.dateDebut,
    this.dateFin,
    this.membreId,
  });
  @override
  List<Object?> get props => [type, categorie, dateDebut, dateFin, membreId];
}

class LoadRapportFinancier extends FinancesEvent {
  final String? dateDebut;
  final String? dateFin;
  const LoadRapportFinancier({this.dateDebut, this.dateFin});
  @override
  List<Object?> get props => [dateDebut, dateFin];
}

class CreateTransaction extends FinancesEvent {
  final Map<String, dynamic> data;
  const CreateTransaction({required this.data});
  @override
  List<Object?> get props => [data];
}

class UpdateTransaction extends FinancesEvent {
  final int id;
  final Map<String, dynamic> data;
  const UpdateTransaction({required this.id, required this.data});
  @override
  List<Object?> get props => [id, data];
}

class DeleteTransaction extends FinancesEvent {
  final int id;
  const DeleteTransaction({required this.id});
  @override
  List<Object?> get props => [id];
}

// States
abstract class FinancesState extends Equatable {
  const FinancesState();
  @override
  List<Object?> get props => [];
}

class FinancesInitial extends FinancesState {
  const FinancesInitial();
}

class FinancesLoading extends FinancesState {
  const FinancesLoading();
}

class TransactionsLoaded extends FinancesState {
  final List<Transaction> transactions;
  const TransactionsLoaded({required this.transactions});
  @override
  List<Object?> get props => [transactions];
}

class RapportFinancierLoaded extends FinancesState {
  final RapportFinancier rapport;
  final List<Transaction> transactions;
  const RapportFinancierLoaded({required this.rapport, required this.transactions});
  @override
  List<Object?> get props => [rapport, transactions];
}

class TransactionCreated extends FinancesState {
  final Transaction transaction;
  const TransactionCreated({required this.transaction});
  @override
  List<Object?> get props => [transaction];
}

class TransactionUpdated extends FinancesState {
  final Transaction transaction;
  const TransactionUpdated({required this.transaction});
  @override
  List<Object?> get props => [transaction];
}

class TransactionDeleted extends FinancesState {
  final int id;
  const TransactionDeleted({required this.id});
  @override
  List<Object?> get props => [id];
}

class FinancesError extends FinancesState {
  final String message;
  const FinancesError({required this.message});
  @override
  List<Object?> get props => [message];
}

// BLoC
class FinancesBloc extends Bloc<FinancesEvent, FinancesState> {
  final FinanceRepository _financeRepository;

  FinancesBloc({required FinanceRepository financeRepository})
      : _financeRepository = financeRepository,
        super(const FinancesInitial()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<LoadRapportFinancier>(_onLoadRapportFinancier);
    on<CreateTransaction>(_onCreateTransaction);
    on<UpdateTransaction>(_onUpdateTransaction);
    on<DeleteTransaction>(_onDeleteTransaction);
  }

  Future<void> _onLoadTransactions(
    LoadTransactions event,
    Emitter<FinancesState> emit,
  ) async {
    emit(const FinancesLoading());
    try {
      final transactions = await _financeRepository.getTransactions(
        type: event.type,
        categorie: event.categorie,
        dateDebut: event.dateDebut,
        dateFin: event.dateFin,
        membreId: event.membreId,
      );
      emit(TransactionsLoaded(transactions: transactions));
    } catch (e) {
      emit(FinancesError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLoadRapportFinancier(
    LoadRapportFinancier event,
    Emitter<FinancesState> emit,
  ) async {
    emit(const FinancesLoading());
    try {
      final rapport = await _financeRepository.getRapport(
        dateDebut: event.dateDebut,
        dateFin: event.dateFin,
      );
      final transactions = await _financeRepository.getTransactions(
        dateDebut: event.dateDebut,
        dateFin: event.dateFin,
      );
      emit(RapportFinancierLoaded(rapport: rapport, transactions: transactions));
    } catch (e) {
      emit(FinancesError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCreateTransaction(
    CreateTransaction event,
    Emitter<FinancesState> emit,
  ) async {
    emit(const FinancesLoading());
    try {
      final transaction = await _financeRepository.createTransaction(event.data);
      emit(TransactionCreated(transaction: transaction));
    } catch (e) {
      emit(FinancesError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onUpdateTransaction(
    UpdateTransaction event,
    Emitter<FinancesState> emit,
  ) async {
    emit(const FinancesLoading());
    try {
      final transaction = await _financeRepository.updateTransaction(event.id, event.data);
      emit(TransactionUpdated(transaction: transaction));
    } catch (e) {
      emit(FinancesError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onDeleteTransaction(
    DeleteTransaction event,
    Emitter<FinancesState> emit,
  ) async {
    emit(const FinancesLoading());
    try {
      await _financeRepository.deleteTransaction(event.id);
      emit(TransactionDeleted(id: event.id));
    } catch (e) {
      emit(FinancesError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }
}
