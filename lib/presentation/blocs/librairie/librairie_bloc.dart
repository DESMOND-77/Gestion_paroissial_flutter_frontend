import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/article_model.dart';
import '../../../data/models/vente_model.dart';
import '../../../data/repositories/librairie_repository.dart';

// Events
abstract class LibrairieEvent extends Equatable {
  const LibrairieEvent();
  @override
  List<Object?> get props => [];
}

class LoadArticles extends LibrairieEvent {
  final String? search;
  final String? categorie;
  final bool? enAlerte;
  const LoadArticles({this.search, this.categorie, this.enAlerte});
  @override
  List<Object?> get props => [search, categorie, enAlerte];
}

class LoadVentes extends LibrairieEvent {
  final String? articleId;
  final String? membreId;
  const LoadVentes({this.articleId, this.membreId});
  @override
  List<Object?> get props => [articleId, membreId];
}

class LoadAlertes extends LibrairieEvent {
  const LoadAlertes();
}

class CreateArticle extends LibrairieEvent {
  final Map<String, dynamic> data;
  const CreateArticle({required this.data});
  @override
  List<Object?> get props => [data];
}

class UpdateArticle extends LibrairieEvent {
  final String id;
  final Map<String, dynamic> data;
  const UpdateArticle({required this.id, required this.data});
  @override
  List<Object?> get props => [id, data];
}

class DeleteArticle extends LibrairieEvent {
  final String id;
  const DeleteArticle({required this.id});
  @override
  List<Object?> get props => [id];
}

class CreateVente extends LibrairieEvent {
  final Map<String, dynamic> data;
  const CreateVente({required this.data});
  @override
  List<Object?> get props => [data];
}

// States
abstract class LibrairieState extends Equatable {
  const LibrairieState();
  @override
  List<Object?> get props => [];
}

class LibrairieInitial extends LibrairieState {
  const LibrairieInitial();
}

class LibrairieLoading extends LibrairieState {
  const LibrairieLoading();
}

class ArticlesLoaded extends LibrairieState {
  final List<Article> articles;
  const ArticlesLoaded({required this.articles});
  @override
  List<Object?> get props => [articles];
}

class VentesLoaded extends LibrairieState {
  final List<Vente> ventes;
  const VentesLoaded({required this.ventes});
  @override
  List<Object?> get props => [ventes];
}

class AlertesLoaded extends LibrairieState {
  final List<Article> articles;
  const AlertesLoaded({required this.articles});
  @override
  List<Object?> get props => [articles];
}

class ArticleCreated extends LibrairieState {
  final Article article;
  const ArticleCreated({required this.article});
  @override
  List<Object?> get props => [article];
}

class ArticleUpdated extends LibrairieState {
  final Article article;
  const ArticleUpdated({required this.article});
  @override
  List<Object?> get props => [article];
}

class ArticleDeleted extends LibrairieState {
  final String id;
  const ArticleDeleted({required this.id});
  @override
  List<Object?> get props => [id];
}

class VenteCreated extends LibrairieState {
  final Vente vente;
  const VenteCreated({required this.vente});
  @override
  List<Object?> get props => [vente];
}

class LibrairieError extends LibrairieState {
  final String message;
  const LibrairieError({required this.message});
  @override
  List<Object?> get props => [message];
}

// BLoC
class LibrairieBloc extends Bloc<LibrairieEvent, LibrairieState> {
  final LibrairieRepository _librairieRepository;

  LibrairieBloc({required LibrairieRepository librairieRepository})
      : _librairieRepository = librairieRepository,
        super(const LibrairieInitial()) {
    on<LoadArticles>(_onLoadArticles);
    on<LoadVentes>(_onLoadVentes);
    on<LoadAlertes>(_onLoadAlertes);
    on<CreateArticle>(_onCreateArticle);
    on<UpdateArticle>(_onUpdateArticle);
    on<DeleteArticle>(_onDeleteArticle);
    on<CreateVente>(_onCreateVente);
  }

  Future<void> _onLoadArticles(
    LoadArticles event,
    Emitter<LibrairieState> emit,
  ) async {
    emit(const LibrairieLoading());
    try {
      final articles = await _librairieRepository.getArticles(
        search: event.search,
        categorie: event.categorie,
        enAlerte: event.enAlerte,
      );
      emit(ArticlesLoaded(articles: articles));
    } catch (e) {
      emit(LibrairieError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLoadVentes(
    LoadVentes event,
    Emitter<LibrairieState> emit,
  ) async {
    emit(const LibrairieLoading());
    try {
      final ventes = await _librairieRepository.getVentes(
        articleId: event.articleId,
        membreId: event.membreId,
      );
      emit(VentesLoaded(ventes: ventes));
    } catch (e) {
      emit(LibrairieError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLoadAlertes(
    LoadAlertes event,
    Emitter<LibrairieState> emit,
  ) async {
    emit(const LibrairieLoading());
    try {
      final articles = await _librairieRepository.getAlertes();
      emit(AlertesLoaded(articles: articles));
    } catch (e) {
      emit(LibrairieError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCreateArticle(
    CreateArticle event,
    Emitter<LibrairieState> emit,
  ) async {
    emit(const LibrairieLoading());
    try {
      final article = await _librairieRepository.createArticle(event.data);
      emit(ArticleCreated(article: article));
    } catch (e) {
      emit(LibrairieError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onUpdateArticle(
    UpdateArticle event,
    Emitter<LibrairieState> emit,
  ) async {
    emit(const LibrairieLoading());
    try {
      final article = await _librairieRepository.updateArticle(event.id, event.data);
      emit(ArticleUpdated(article: article));
    } catch (e) {
      emit(LibrairieError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onDeleteArticle(
    DeleteArticle event,
    Emitter<LibrairieState> emit,
  ) async {
    emit(const LibrairieLoading());
    try {
      await _librairieRepository.deleteArticle(event.id);
      emit(ArticleDeleted(id: event.id));
    } catch (e) {
      emit(LibrairieError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCreateVente(
    CreateVente event,
    Emitter<LibrairieState> emit,
  ) async {
    emit(const LibrairieLoading());
    try {
      final vente = await _librairieRepository.createVente(event.data);
      emit(VenteCreated(vente: vente));
    } catch (e) {
      emit(LibrairieError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }
}
