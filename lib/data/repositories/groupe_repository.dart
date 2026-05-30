import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../../core/database/database_service.dart';
import '../models/groupe_model.dart';
import '../models/membre_model.dart';

class GroupeRepository {
  final DioClient _dioClient;
  final DatabaseService? _databaseService;

  GroupeRepository({
    required DioClient dioClient,
    DatabaseService? databaseService,
  })  : _dioClient = dioClient,
        _databaseService = databaseService;

  // Récupère les groupes depuis le serveur (pour la synchronisation)
  Future<List<Groupe>> fetchGroupes() async {
    final response = await _dioClient.get(ApiConstants.groupes);

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

  Future<List<Groupe>> getGroupes({String? search}) async {
    // Si recherche: toujours du serveur
    if (search != null && search.isNotEmpty) {
      final response = await _dioClient.get(
        ApiConstants.groupes,
        queryParameters: {'search': search},
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

    // Chercher en cache d'abord
    if (_databaseService != null) {
      final cached = await _databaseService.getItems('groupes');
      if (cached.isNotEmpty) {
        return cached
            .map((e) => Groupe.fromJson(e))
            .toList();
      }
    }

    // Pas de cache, requête au serveur
    return fetchGroupes();
  }

  Future<Groupe> getGroupeById(int id) async {
    final response = await _dioClient.get(ApiConstants.groupeById(id));
    return Groupe.fromJson(response.data["data"] as Map<String, dynamic>);
  }

  Future<Groupe> createGroupe(Map<String, dynamic> data) async {
    final response = await _dioClient.post(ApiConstants.groupes, data: data);
    await _databaseService?.clearTable('groupes');
    return Groupe.fromJson(response.data["data"] as Map<String, dynamic>);
  }

  Future<Groupe> updateGroupe(int id, Map<String, dynamic> data) async {
    final response = await _dioClient.put(ApiConstants.groupeById(id), data: data);
    await _databaseService?.clearTable('groupes');
    return Groupe.fromJson(response.data["data"] as Map<String, dynamic>);
  }

  Future<Groupe> patchGroupe(int id, Map<String, dynamic> data) async {
    final response = await _dioClient.patch(ApiConstants.groupeById(id), data: data);
    await _databaseService?.clearTable('groupes');
    return Groupe.fromJson(response.data["data"] as Map<String, dynamic>);
  }

  Future<void> deleteGroupe(int id) async {
    await _dioClient.delete(ApiConstants.groupeById(id));
    await _databaseService?.clearTable('groupes');
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
