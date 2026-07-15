import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/evenement_model.dart';
import '../../../data/repositories/evenement_repository.dart';

// Events
abstract class EvenementsEvent extends Equatable {
  const EvenementsEvent();
  @override
  List<Object?> get props => [];
}

class LoadEvenements extends EvenementsEvent {
  final String? search;
  final String? type;
  final bool? upcoming;
  const LoadEvenements({this.search, this.type, this.upcoming});
  @override
  List<Object?> get props => [search, type, upcoming];
}

class LoadEvenementDetail extends EvenementsEvent {
  final String id;
  const LoadEvenementDetail({required this.id});
  @override
  List<Object?> get props => [id];
}

class CreateEvenement extends EvenementsEvent {
  final Map<String, dynamic> data;
  const CreateEvenement({required this.data});
  @override
  List<Object?> get props => [data];
}

class UpdateEvenement extends EvenementsEvent {
  final String id;
  final Map<String, dynamic> data;
  const UpdateEvenement({required this.id, required this.data});
  @override
  List<Object?> get props => [id, data];
}

class DeleteEvenement extends EvenementsEvent {
  final String id;
  const DeleteEvenement({required this.id});
  @override
  List<Object?> get props => [id];
}

class InscrireEvenement extends EvenementsEvent {
  final String id;
  const InscrireEvenement({required this.id});
  @override
  List<Object?> get props => [id];
}

// States
abstract class EvenementsState extends Equatable {
  const EvenementsState();
  @override
  List<Object?> get props => [];
}

class EvenementsInitial extends EvenementsState {
  const EvenementsInitial();
}

class EvenementsLoading extends EvenementsState {
  const EvenementsLoading();
}

class EvenementsLoaded extends EvenementsState {
  final List<Evenement> evenements;
  const EvenementsLoaded({required this.evenements});
  @override
  List<Object?> get props => [evenements];
}

class EvenementDetailLoaded extends EvenementsState {
  final Evenement evenement;
  const EvenementDetailLoaded({required this.evenement});
  @override
  List<Object?> get props => [evenement];
}

class EvenementCreated extends EvenementsState {
  final Evenement evenement;
  const EvenementCreated({required this.evenement});
  @override
  List<Object?> get props => [evenement];
}

class EvenementUpdated extends EvenementsState {
  final Evenement evenement;
  const EvenementUpdated({required this.evenement});
  @override
  List<Object?> get props => [evenement];
}

class EvenementDeleted extends EvenementsState {
  final String id;
  const EvenementDeleted({required this.id});
  @override
  List<Object?> get props => [id];
}

class EvenementInscriptionSuccess extends EvenementsState {
  const EvenementInscriptionSuccess();
}

class EvenementsError extends EvenementsState {
  final String message;
  const EvenementsError({required this.message});
  @override
  List<Object?> get props => [message];
}

// BLoC
class EvenementsBloc extends Bloc<EvenementsEvent, EvenementsState> {
  final EvenementRepository _evenementRepository;

  EvenementsBloc({required EvenementRepository evenementRepository})
      : _evenementRepository = evenementRepository,
        super(const EvenementsInitial()) {
    on<LoadEvenements>(_onLoadEvenements);
    on<LoadEvenementDetail>(_onLoadEvenementDetail);
    on<CreateEvenement>(_onCreateEvenement);
    on<UpdateEvenement>(_onUpdateEvenement);
    on<DeleteEvenement>(_onDeleteEvenement);
    on<InscrireEvenement>(_onInscrireEvenement);
  }

  Future<void> _onLoadEvenements(
    LoadEvenements event,
    Emitter<EvenementsState> emit,
  ) async {
    emit(const EvenementsLoading());
    try {
      final evenements = await _evenementRepository.getEvenements(
        search: event.search,
        type: event.type,
        upcoming: event.upcoming,
      );
      emit(EvenementsLoaded(evenements: evenements));
    } catch (e) {
      emit(EvenementsError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLoadEvenementDetail(
    LoadEvenementDetail event,
    Emitter<EvenementsState> emit,
  ) async {
    emit(const EvenementsLoading());
    try {
      final evenement = await _evenementRepository.getEvenementById(event.id);
      emit(EvenementDetailLoaded(evenement: evenement));
    } catch (e) {
      emit(EvenementsError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCreateEvenement(
    CreateEvenement event,
    Emitter<EvenementsState> emit,
  ) async {
    emit(const EvenementsLoading());
    try {
      final evenement = await _evenementRepository.createEvenement(event.data);
      emit(EvenementCreated(evenement: evenement));
    } catch (e) {
      emit(EvenementsError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onUpdateEvenement(
    UpdateEvenement event,
    Emitter<EvenementsState> emit,
  ) async {
    emit(const EvenementsLoading());
    try {
      final evenement = await _evenementRepository.updateEvenement(event.id, event.data);
      emit(EvenementUpdated(evenement: evenement));
    } catch (e) {
      emit(EvenementsError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onDeleteEvenement(
    DeleteEvenement event,
    Emitter<EvenementsState> emit,
  ) async {
    emit(const EvenementsLoading());
    try {
      await _evenementRepository.deleteEvenement(event.id);
      emit(EvenementDeleted(id: event.id));
    } catch (e) {
      emit(EvenementsError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onInscrireEvenement(
    InscrireEvenement event,
    Emitter<EvenementsState> emit,
  ) async {
    emit(const EvenementsLoading());
    try {
      await _evenementRepository.inscrire(event.id);
      emit(const EvenementInscriptionSuccess());
    } catch (e) {
      emit(EvenementsError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }
}
