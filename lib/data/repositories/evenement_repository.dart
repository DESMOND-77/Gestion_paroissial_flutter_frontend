import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/evenement_model.dart';
import '../models/membre_model.dart';

class EvenementRepository {
  final DioClient _dioClient;

  EvenementRepository({required DioClient dioClient}) : _dioClient = dioClient;

  Future<List<Evenement>> getEvenements({
    String? search,
    String? type,
    bool? upcoming,
  }) async {
    final queryParams = <String, dynamic>{};
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (type != null) queryParams['type'] = type;
    if (upcoming != null) queryParams['upcoming'] = upcoming;

    final response = await _dioClient.get(
      ApiConstants.evenements,
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
        .map((e) => Evenement.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Evenement> getEvenementById(int id) async {
    final response = await _dioClient.get(ApiConstants.evenementById(id));
    return Evenement.fromJson(response.data["data"] as Map<String, dynamic>);
  }

  Future<Evenement> createEvenement(Map<String, dynamic> data) async {
    final response = await _dioClient.post(ApiConstants.evenements, data: data);
    return Evenement.fromJson(response.data["data"] as Map<String, dynamic>);
  }

  Future<Evenement> updateEvenement(int id, Map<String, dynamic> data) async {
    final response = await _dioClient.put(ApiConstants.evenementById(id), data: data);
    return Evenement.fromJson(response.data["data"] as Map<String, dynamic>);
  }

  Future<Evenement> patchEvenement(int id, Map<String, dynamic> data) async {
    final response = await _dioClient.patch(ApiConstants.evenementById(id), data: data);
    return Evenement.fromJson(response.data["data"] as Map<String, dynamic>);
  }

  Future<void> deleteEvenement(int id) async {
    await _dioClient.delete(ApiConstants.evenementById(id));
  }

  Future<void> inscrire(int id) async {
    await _dioClient.post(ApiConstants.evenementInscrire(id));
  }

  Future<List<Membre>> getParticipants(int id) async {
    final response = await _dioClient.get(ApiConstants.evenementParticipants(id));
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
