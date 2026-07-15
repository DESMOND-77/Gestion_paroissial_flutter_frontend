import 'package:paroisse_gest/core/database/database_service.dart';

import '../../core/network/dio_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/constants/api_constants.dart';
import '../../core/sync/offline_write.dart';
import '../models/article_model.dart';
import '../models/vente_model.dart';

class LibrairieRepository {
  final DioClient _dioClient;
  final DatabaseService? _databaseService;

  LibrairieRepository(
      {required DioClient dioClient, DatabaseService? databaseService})
      : _dioClient = dioClient,
        _databaseService = databaseService;

  // Récupère les articles depuis le serveur (pour la synchronisation)
  Future<List<Article>> fetchArticles() async {
    final response = await _dioClient.get(ApiConstants.articles);

    final data = response.data["data"];
    List<dynamic> results;
    if (data is Map && data.containsKey('results')) {
      results = data['results'] as List<dynamic>;
    } else if (data is List) {
      results = data;
    } else {
      results = [];
    }

    return results
        .map((e) => Article.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Article>> getArticles({
    String? search,
    String? categorie,
    bool? enAlerte,
  }) async {
    // Si recherche ou filtrage: toujours du serveur
    if (search != null || categorie != null || enAlerte != null) {
      final queryParams = <String, dynamic>{};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (categorie != null) queryParams['categorie'] = categorie;
      if (enAlerte != null) queryParams['en_alerte'] = enAlerte;

      final response = await _dioClient.get(
        ApiConstants.articles,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final data = response.data["data"];
      List<dynamic> results;
      if (data is Map && data.containsKey('results')) {
        results = data['results'] as List<dynamic>;
      } else if (data is List) {
        results = data;
      } else {
        results = [];
      }

      return results
          .map((e) => Article.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // Sinon, chercher en cache d'abord
    if (_databaseService != null) {
      final cached = await _databaseService.getItems('librairie');
      if (cached.isNotEmpty) {
        return cached.map((e) => Article.fromJson(e)).toList();
      }
    }

    // Pas de cache, requête au serveur
    return fetchArticles();
  }

  Future<Article> getArticleById(String id) async {
    final response = await _dioClient.get(ApiConstants.articleById(id));
    return Article.fromJson(response.data["data"] as Map<String, dynamic>);
  }

  Future<Article> createArticle(Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.post(ApiConstants.articles, data: data);
      await _databaseService?.clearTable('librairie');
      return Article.fromJson(response.data["data"] as Map<String, dynamic>);
    } on NetworkException {
      final record = await queueOfflineWrite(
        db: _databaseService,
        collection: 'articles',
        cacheEntityType: 'librairie',
        data: data,
      );
      return Article.fromJson(record);
    }
  }

  Future<Article> updateArticle(String id, Map<String, dynamic> data) async {
    try {
      final response =
          await _dioClient.put(ApiConstants.articleById(id), data: data);
      await _databaseService?.clearTable('librairie');
      return Article.fromJson(response.data["data"] as Map<String, dynamic>);
    } on NetworkException {
      final record = await queueOfflineWrite(
        db: _databaseService,
        collection: 'articles',
        cacheEntityType: 'librairie',
        id: id,
        data: data,
      );
      return Article.fromJson(record);
    }
  }

  Future<Article> patchArticle(String id, Map<String, dynamic> data) async {
    try {
      final response =
          await _dioClient.patch(ApiConstants.articleById(id), data: data);
      await _databaseService?.clearTable('librairie');
      return Article.fromJson(response.data["data"] as Map<String, dynamic>);
    } on NetworkException {
      final record = await queueOfflineWrite(
        db: _databaseService,
        collection: 'articles',
        cacheEntityType: 'librairie',
        id: id,
        data: data,
      );
      return Article.fromJson(record);
    }
  }

  Future<void> deleteArticle(String id) async {
    try {
      await _dioClient.delete(ApiConstants.articleById(id));
      await _databaseService?.clearTable('librairie');
    } on NetworkException {
      await queueOfflineWrite(
        db: _databaseService,
        collection: 'articles',
        cacheEntityType: 'librairie',
        id: id,
        isDeleted: true,
      );
    }
  }

  Future<List<Article>> getAlertes() async {
    final response = await _dioClient.get(ApiConstants.librairieAlertes);
    final data = response.data["data"];
    List<dynamic> results;
    if (data is List) {
      results = data;
    } else if (data is Map && data.containsKey('results')) {
      results = data['results'] as List<dynamic>;
    } else {
      results = [];
    }
    return results
        .map((e) => Article.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Vente>> getVentes({String? articleId, String? membreId}) async {
    final queryParams = <String, dynamic>{};
    if (articleId != null) queryParams['article'] = articleId;
    if (membreId != null) queryParams['membre'] = membreId;

    final response = await _dioClient.get(
      ApiConstants.ventes,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    final data = response.data["data"];
    List<dynamic> results;
    if (data is Map && data.containsKey('results')) {
      results = data['results'] as List<dynamic>;
    } else if (data is List) {
      results = data;
    } else {
      results = [];
    }

    return results
        .map((e) => Vente.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Vente> getVenteById(String id) async {
    final response = await _dioClient.get(ApiConstants.venteById(id));
    return Vente.fromJson(response.data["data"] as Map<String, dynamic>);
  }

  Future<Vente> createVente(Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.post(ApiConstants.ventes, data: data);
      // Une vente décrémente le stock d'un article : le cache librairie doit
      // être rafraîchi à la prochaine synchro.
      await _databaseService?.clearTable('librairie');
      return Vente.fromJson(response.data["data"] as Map<String, dynamic>);
    } on NetworkException {
      final record = await queueOfflineWrite(
        db: _databaseService,
        collection: 'ventes',
        cacheEntityType: 'ventes',
        data: data,
      );
      return Vente.fromJson(record);
    }
  }
}
