import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/article_model.dart';
import '../models/vente_model.dart';

class LibrairieRepository {
  final DioClient _dioClient;

  LibrairieRepository({required DioClient dioClient}) : _dioClient = dioClient;

  Future<List<Article>> getArticles({
    String? search,
    String? categorie,
    bool? enAlerte,
  }) async {
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

  Future<Article> getArticleById(int id) async {
    final response = await _dioClient.get(ApiConstants.articleById(id));
    return Article.fromJson(response.data["data"] as Map<String, dynamic>);
  }

  Future<Article> createArticle(Map<String, dynamic> data) async {
    final response = await _dioClient.post(ApiConstants.articles, data: data);
    return Article.fromJson(response.data["data"] as Map<String, dynamic>);
  }

  Future<Article> updateArticle(int id, Map<String, dynamic> data) async {
    final response = await _dioClient.put(ApiConstants.articleById(id), data: data);
    return Article.fromJson(response.data["data"] as Map<String, dynamic>);
  }

  Future<Article> patchArticle(int id, Map<String, dynamic> data) async {
    final response = await _dioClient.patch(ApiConstants.articleById(id), data: data);
    return Article.fromJson(response.data["data"] as Map<String, dynamic>);
  }

  Future<void> deleteArticle(int id) async {
    await _dioClient.delete(ApiConstants.articleById(id));
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

  Future<List<Vente>> getVentes({int? articleId, int? membreId}) async {
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

  Future<Vente> getVenteById(int id) async {
    final response = await _dioClient.get(ApiConstants.venteById(id));
    return Vente.fromJson(response.data["data"] as Map<String, dynamic>);
  }

  Future<Vente> createVente(Map<String, dynamic> data) async {
    final response = await _dioClient.post(ApiConstants.ventes, data: data);
    return Vente.fromJson(response.data["data"] as Map<String, dynamic>);
  }
}
