import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/groupe_model.dart';
import '../models/membre_model.dart';

class GroupeRepository {
  final DioClient _dioClient;

  GroupeRepository({required DioClient dioClient}) : _dioClient = dioClient;

  Future<List<Groupe>> getGroupes({String? search}) async {
    final queryParams = <String, dynamic>{};
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final response = await _dioClient.get(
      ApiConstants.groupes,
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
        .map((e) => Groupe.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Groupe> getGroupeById(int id) async {
    final response = await _dioClient.get(ApiConstants.groupeById(id));
    return Groupe.fromJson(response.data["data"] as Map<String, dynamic>);
  }

  Future<Groupe> createGroupe(Map<String, dynamic> data) async {
    final response = await _dioClient.post(ApiConstants.groupes, data: data);
    return Groupe.fromJson(response.data["data"] as Map<String, dynamic>);
  }

  Future<Groupe> updateGroupe(int id, Map<String, dynamic> data) async {
    final response = await _dioClient.put(ApiConstants.groupeById(id), data: data);
    return Groupe.fromJson(response.data["data"] as Map<String, dynamic>);
  }

  Future<Groupe> patchGroupe(int id, Map<String, dynamic> data) async {
    final response = await _dioClient.patch(ApiConstants.groupeById(id), data: data);
    return Groupe.fromJson(response.data["data"] as Map<String, dynamic>);
  }

  Future<void> deleteGroupe(int id) async {
    await _dioClient.delete(ApiConstants.groupeById(id));
  }

  Future<List<Membre>> getGroupeMembres(int id) async {
    final response = await _dioClient.get(ApiConstants.groupeMembres(id));
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
        .map((e) => Membre.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
