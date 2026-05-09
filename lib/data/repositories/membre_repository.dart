import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/membre_model.dart';
import '../models/sacrement_model.dart';

class MembreRepository {
  final DioClient _dioClient;

  MembreRepository({required DioClient dioClient}) : _dioClient = dioClient;

  Future<List<Membre>> getMembres({
    String? search,
    String? groupe,
    String? sexe,
    int? page,
  }) async {
    final queryParams = <String, dynamic>{};
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (groupe != null) queryParams['groupe'] = groupe;
    if (sexe != null) queryParams['sexe'] = sexe;
    if (page != null) queryParams['page'] = page;

    final response = await _dioClient.get(
      ApiConstants.membres,
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
        .map((e) => Membre.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<MembreDetail> getMembreById(int id) async {
    final response = await _dioClient.get(ApiConstants.membreById(id));
    return MembreDetail.fromJson(response.data["data"] as Map<String, dynamic>);
  }

  Future<Membre> createMembre(Map<String, dynamic> data) async {
    final response = await _dioClient.post(ApiConstants.membres, data: data);
    return Membre.fromJson(response.data["data"] as Map<String, dynamic>);
  }

  Future<Membre> updateMembre(int id, Map<String, dynamic> data) async {
    final response = await _dioClient.put(ApiConstants.membreById(id), data: data);
    return Membre.fromJson(response.data["data"] as Map<String, dynamic>);
  }

  Future<Membre> patchMembre(int id, Map<String, dynamic> data) async {
    final response = await _dioClient.patch(ApiConstants.membreById(id), data: data);
    return Membre.fromJson(response.data["data"] as Map<String, dynamic>);
  }

  Future<void> deleteMembre(int id) async {
    await _dioClient.delete(ApiConstants.membreById(id));
  }

  Future<List<Sacrement>> getMembreSacrements(int id) async {
    final response = await _dioClient.get(ApiConstants.membreSacrements(id));
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
        .map((e) => Sacrement.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Sacrement> ajouterSacrement(int membreId, Map<String, dynamic> data) async {
    final response = await _dioClient.post(
      ApiConstants.membreAjouterSacrement(membreId),
      data: data,
    );
    return Sacrement.fromJson(response.data["data"] as Map<String, dynamic>);
  }
}
