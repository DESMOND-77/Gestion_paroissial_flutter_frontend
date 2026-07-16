import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/groupe_model.dart';
import '../../../data/models/membre_model.dart';
import '../../../data/repositories/groupe_repository.dart';

// Events
abstract class GroupesEvent extends Equatable {
  const GroupesEvent();
  @override
  List<Object?> get props => [];
}

class LoadGroupes extends GroupesEvent {
  final String? search;
  const LoadGroupes({this.search});
  @override
  List<Object?> get props => [search];
}

class LoadGroupeDetail extends GroupesEvent {
  final String id;
  const LoadGroupeDetail({required this.id});
  @override
  List<Object?> get props => [id];
}

class LoadGroupeMembres extends GroupesEvent {
  final String id;
  const LoadGroupeMembres({required this.id});
  @override
  List<Object?> get props => [id];
}

class CreateGroupe extends GroupesEvent {
  final Map<String, dynamic> data;
  const CreateGroupe({required this.data});
  @override
  List<Object?> get props => [data];
}

class UpdateGroupe extends GroupesEvent {
  final String id;
  final Map<String, dynamic> data;
  const UpdateGroupe({required this.id, required this.data});
  @override
  List<Object?> get props => [id, data];
}

class DeleteGroupe extends GroupesEvent {
  final String id;
  const DeleteGroupe({required this.id});
  @override
  List<Object?> get props => [id];
}

class AssignResponsables extends GroupesEvent {
  final String groupeId;
  final List<String> userIds;
  const AssignResponsables({required this.groupeId, required this.userIds});
  @override
  List<Object?> get props => [groupeId, userIds];
}

class AddMembreToGroupe extends GroupesEvent {
  final String groupeId;
  final String membreId;
  const AddMembreToGroupe({required this.groupeId, required this.membreId});
  @override
  List<Object?> get props => [groupeId, membreId];
}

class RemoveMembreFromGroupe extends GroupesEvent {
  final String groupeId;
  final String membreId;
  const RemoveMembreFromGroupe(
      {required this.groupeId, required this.membreId});
  @override
  List<Object?> get props => [groupeId, membreId];
}

// States
abstract class GroupesState extends Equatable {
  const GroupesState();
  @override
  List<Object?> get props => [];
}

class GroupesInitial extends GroupesState {
  const GroupesInitial();
}

class GroupesLoading extends GroupesState {
  const GroupesLoading();
}

class GroupesLoaded extends GroupesState {
  final List<Groupe> groupes;
  const GroupesLoaded({required this.groupes});
  @override
  List<Object?> get props => [groupes];
}

class GroupeDetailLoaded extends GroupesState {
  final Groupe groupe;
  final List<Membre>? membres;
  const GroupeDetailLoaded({required this.groupe, this.membres});
  @override
  List<Object?> get props => [groupe, membres];
}

class GroupeMembresLoaded extends GroupesState {
  final String groupeId;
  final List<Membre> membres;
  const GroupeMembresLoaded({required this.groupeId, required this.membres});
  @override
  List<Object?> get props => [groupeId, membres];
}

class GroupeCreated extends GroupesState {
  final Groupe groupe;
  const GroupeCreated({required this.groupe});
  @override
  List<Object?> get props => [groupe];
}

class GroupeUpdated extends GroupesState {
  final Groupe groupe;
  const GroupeUpdated({required this.groupe});
  @override
  List<Object?> get props => [groupe];
}

class GroupeDeleted extends GroupesState {
  final String id;
  const GroupeDeleted({required this.id});
  @override
  List<Object?> get props => [id];
}

/// Succès transitoire d'une action sur le détail (assignation / ajout membre).
/// Suivi immédiatement d'un rechargement `GroupeDetailLoaded`.
class GroupeActionSuccess extends GroupesState {
  final String message;
  const GroupeActionSuccess({required this.message});
  @override
  List<Object?> get props => [message];
}

class GroupesError extends GroupesState {
  final String message;
  const GroupesError({required this.message});
  @override
  List<Object?> get props => [message];
}

// BLoC
class GroupesBloc extends Bloc<GroupesEvent, GroupesState> {
  final GroupeRepository _groupeRepository;

  GroupesBloc({required GroupeRepository groupeRepository})
      : _groupeRepository = groupeRepository,
        super(const GroupesInitial()) {
    on<LoadGroupes>(_onLoadGroupes);
    on<LoadGroupeDetail>(_onLoadGroupeDetail);
    on<LoadGroupeMembres>(_onLoadGroupeMembres);
    on<CreateGroupe>(_onCreateGroupe);
    on<UpdateGroupe>(_onUpdateGroupe);
    on<DeleteGroupe>(_onDeleteGroupe);
    on<AssignResponsables>(_onAssignResponsables);
    on<AddMembreToGroupe>(_onAddMembreToGroupe);
    on<RemoveMembreFromGroupe>(_onRemoveMembreFromGroupe);
  }

  // Charge groupe + membres et émet GroupeDetailLoaded.
  Future<void> _emitDetail(String groupeId, Emitter<GroupesState> emit) async {
    final results = await Future.wait([
      _groupeRepository.getGroupeById(groupeId),
      _groupeRepository.getGroupeMembres(groupeId),
    ]);
    emit(GroupeDetailLoaded(
      groupe: results[0] as Groupe,
      membres: results[1] as List<Membre>,
    ));
  }

  Future<void> _onLoadGroupes(
    LoadGroupes event,
    Emitter<GroupesState> emit,
  ) async {
    emit(const GroupesLoading());
    try {
      final groupes = await _groupeRepository.getGroupes(search: event.search);
      emit(GroupesLoaded(groupes: groupes));
    } catch (e) {
      emit(GroupesError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLoadGroupeDetail(
    LoadGroupeDetail event,
    Emitter<GroupesState> emit,
  ) async {
    emit(const GroupesLoading());
    try {
      // Détail = infos du groupe (dont les responsables) + ses membres.
      await _emitDetail(event.id, emit);
    } catch (e) {
      emit(GroupesError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onAssignResponsables(
    AssignResponsables event,
    Emitter<GroupesState> emit,
  ) async {
    try {
      await _groupeRepository.assignResponsables(event.groupeId, event.userIds);
      emit(const GroupeActionSuccess(message: 'Responsables mis à jour'));
      await _emitDetail(event.groupeId, emit);
    } catch (e) {
      emit(GroupesError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onAddMembreToGroupe(
    AddMembreToGroupe event,
    Emitter<GroupesState> emit,
  ) async {
    try {
      await _groupeRepository.addMembreToGroupe(event.groupeId, event.membreId);
      emit(const GroupeActionSuccess(message: 'Membre ajouté au groupe'));
      await _emitDetail(event.groupeId, emit);
    } catch (e) {
      emit(GroupesError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onRemoveMembreFromGroupe(
    RemoveMembreFromGroupe event,
    Emitter<GroupesState> emit,
  ) async {
    try {
      await _groupeRepository.removeMembreFromGroupe(
          event.groupeId, event.membreId);
      emit(const GroupeActionSuccess(message: 'Membre retiré du groupe'));
      await _emitDetail(event.groupeId, emit);
    } catch (e) {
      emit(GroupesError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLoadGroupeMembres(
    LoadGroupeMembres event,
    Emitter<GroupesState> emit,
  ) async {
    emit(const GroupesLoading());
    try {
      final membres = await _groupeRepository.getGroupeMembres(event.id);
      emit(GroupeMembresLoaded(groupeId: event.id, membres: membres));
    } catch (e) {
      emit(GroupesError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCreateGroupe(
    CreateGroupe event,
    Emitter<GroupesState> emit,
  ) async {
    emit(const GroupesLoading());
    try {
      final groupe = await _groupeRepository.createGroupe(event.data);
      emit(GroupeCreated(groupe: groupe));
    } catch (e) {
      emit(GroupesError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onUpdateGroupe(
    UpdateGroupe event,
    Emitter<GroupesState> emit,
  ) async {
    emit(const GroupesLoading());
    try {
      final groupe = await _groupeRepository.updateGroupe(event.id, event.data);
      emit(GroupeUpdated(groupe: groupe));
    } catch (e) {
      emit(GroupesError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onDeleteGroupe(
    DeleteGroupe event,
    Emitter<GroupesState> emit,
  ) async {
    emit(const GroupesLoading());
    try {
      await _groupeRepository.deleteGroupe(event.id);
      emit(GroupeDeleted(id: event.id));
    } catch (e) {
      emit(GroupesError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }
}
