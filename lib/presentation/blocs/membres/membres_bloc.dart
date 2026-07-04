import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/membre_model.dart';
import '../../../data/models/sacrement_model.dart';
import '../../../data/repositories/membre_repository.dart';

// Events
abstract class MembresEvent extends Equatable {
  const MembresEvent();
  @override
  List<Object?> get props => [];
}

class LoadMembres extends MembresEvent {
  final String? search;
  final String? groupe;
  final String? sexe;
  const LoadMembres({this.search, this.groupe, this.sexe});
  @override
  List<Object?> get props => [search, groupe, sexe];
}

class LoadMembreDetail extends MembresEvent {
  final int id;
  const LoadMembreDetail({required this.id});
  @override
  List<Object?> get props => [id];
}

class CreateMembre extends MembresEvent {
  final Map<String, dynamic> data;
  const CreateMembre({required this.data});
  @override
  List<Object?> get props => [data];
}

class UpdateMembre extends MembresEvent {
  final int id;
  final Map<String, dynamic> data;
  const UpdateMembre({required this.id, required this.data});
  @override
  List<Object?> get props => [id, data];
}

class LoadMyMembre extends MembresEvent {
  const LoadMyMembre();
}

class UpdateMyMembre extends MembresEvent {
  final Map<String, dynamic> data;
  const UpdateMyMembre({required this.data});
  @override
  List<Object?> get props => [data];
}

class DeleteMembre extends MembresEvent {
  final int id;
  const DeleteMembre({required this.id});
  @override
  List<Object?> get props => [id];
}

class AjouterSacrement extends MembresEvent {
  final int membreId;
  final Map<String, dynamic> data;
  const AjouterSacrement({required this.membreId, required this.data});
  @override
  List<Object?> get props => [membreId, data];
}

// States
abstract class MembresState extends Equatable {
  const MembresState();
  @override
  List<Object?> get props => [];
}

class MembresInitial extends MembresState {
  const MembresInitial();
}

class MembresLoading extends MembresState {
  const MembresLoading();
}

class MembresLoaded extends MembresState {
  final List<Membre> membres;
  const MembresLoaded({required this.membres});
  @override
  List<Object?> get props => [membres];
}

class MembreDetailLoaded extends MembresState {
  final MembreDetail membre;
  const MembreDetailLoaded({required this.membre});
  @override
  List<Object?> get props => [membre];
}

class MembreCreated extends MembresState {
  final Membre membre;
  const MembreCreated({required this.membre});
  @override
  List<Object?> get props => [membre];
}

class MembreUpdated extends MembresState {
  final Membre membre;
  const MembreUpdated({required this.membre});
  @override
  List<Object?> get props => [membre];
}

class MyMembreLoaded extends MembresState {
  final Membre? membre;
  const MyMembreLoaded({required this.membre});
  @override
  List<Object?> get props => [membre];
}

class MyMembreUpdated extends MembresState {
  final Membre membre;
  const MyMembreUpdated({required this.membre});
  @override
  List<Object?> get props => [membre];
}

class MembreDeleted extends MembresState {
  final int id;
  const MembreDeleted({required this.id});
  @override
  List<Object?> get props => [id];
}

class SacrementAjoute extends MembresState {
  final Sacrement sacrement;
  const SacrementAjoute({required this.sacrement});
  @override
  List<Object?> get props => [sacrement];
}

class MembresError extends MembresState {
  final String message;
  const MembresError({required this.message});
  @override
  List<Object?> get props => [message];
}

// BLoC
class MembresBloc extends Bloc<MembresEvent, MembresState> {
  final MembreRepository _membreRepository;

  MembresBloc({required MembreRepository membreRepository})
      : _membreRepository = membreRepository,
        super(const MembresInitial()) {
    on<LoadMembres>(_onLoadMembres);
    on<LoadMembreDetail>(_onLoadMembreDetail);
    on<CreateMembre>(_onCreateMembre);
    on<UpdateMembre>(_onUpdateMembre);
    on<LoadMyMembre>(_onLoadMyMembre);
    on<UpdateMyMembre>(_onUpdateMyMembre);
    on<DeleteMembre>(_onDeleteMembre);
    on<AjouterSacrement>(_onAjouterSacrement);
  }

  Future<void> _onLoadMembres(
    LoadMembres event,
    Emitter<MembresState> emit,
  ) async {
    emit(const MembresLoading());
    try {
      final membres = await _membreRepository.getMembres(
        search: event.search,
        groupe: event.groupe,
        sexe: event.sexe,
      );
      emit(MembresLoaded(membres: membres));
    } catch (e) {
      emit(MembresError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLoadMembreDetail(
    LoadMembreDetail event,
    Emitter<MembresState> emit,
  ) async {
    emit(const MembresLoading());
    try {
      final membre = await _membreRepository.getMembreById(event.id);
      emit(MembreDetailLoaded(membre: membre));
    } catch (e) {
      emit(MembresError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCreateMembre(
    CreateMembre event,
    Emitter<MembresState> emit,
  ) async {
    emit(const MembresLoading());
    try {
      final membre = await _membreRepository.createMembre(event.data);
      emit(MembreCreated(membre: membre));
    } catch (e) {
      emit(MembresError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onUpdateMembre(
    UpdateMembre event,
    Emitter<MembresState> emit,
  ) async {
    emit(const MembresLoading());
    try {
      final membre = await _membreRepository.updateMembre(event.id, event.data);
      emit(MembreUpdated(membre: membre));
    } catch (e) {
      emit(MembresError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLoadMyMembre(
    LoadMyMembre event,
    Emitter<MembresState> emit,
  ) async {
    emit(const MembresLoading());
    try {
      final membre = await _membreRepository.getMyMembre();
      emit(MyMembreLoaded(membre: membre));
    } catch (e) {
      emit(MembresError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onUpdateMyMembre(
    UpdateMyMembre event,
    Emitter<MembresState> emit,
  ) async {
    emit(const MembresLoading());
    try {
      final membre = await _membreRepository.updateMyMembre(event.data);
      emit(MyMembreUpdated(membre: membre));
    } catch (e) {
      emit(MembresError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onDeleteMembre(
    DeleteMembre event,
    Emitter<MembresState> emit,
  ) async {
    emit(const MembresLoading());
    try {
      await _membreRepository.deleteMembre(event.id);
      emit(MembreDeleted(id: event.id));
    } catch (e) {
      emit(MembresError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onAjouterSacrement(
    AjouterSacrement event,
    Emitter<MembresState> emit,
  ) async {
    emit(const MembresLoading());
    try {
      final sacrement =
          await _membreRepository.ajouterSacrement(event.membreId, event.data);
      emit(SacrementAjoute(sacrement: sacrement));
    } catch (e) {
      emit(MembresError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }
}
