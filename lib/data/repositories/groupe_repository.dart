import '../../core/network/dio_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/constants/api_constants.dart';
import '../../core/database/database_service.dart';
import '../../core/sync/offline_write.dart';
import '../models/groupe_model.dart';
import '../models/membre_model.dart';
import '../models/auth_model.dart';

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

  Future<Groupe> getGroupeById(String id) async {
    final response = await _dioClient.get(ApiConstants.groupeById(id));
    return Groupe.fromJson(response.data["data"] as Map<String, dynamic>);
  }

  Future<Groupe> createGroupe(Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.post(ApiConstants.groupes, data: data);
      await _databaseService?.clearTable('groupes');
      return Groupe.fromJson(response.data["data"] as Map<String, dynamic>);
    } on NetworkException {
      final record = await queueOfflineWrite(
        db: _databaseService,
        collection: 'groupes',
        cacheEntityType: 'groupes',
        data: data,
      );
      return Groupe.fromJson(record);
    }
  }

  Future<Groupe> updateGroupe(String id, Map<String, dynamic> data) async {
    try {
      final response =
          await _dioClient.put(ApiConstants.groupeById(id), data: data);
      await _databaseService?.clearTable('groupes');
      return Groupe.fromJson(response.data["data"] as Map<String, dynamic>);
    } on NetworkException {
      final record = await queueOfflineWrite(
        db: _databaseService,
        collection: 'groupes',
        cacheEntityType: 'groupes',
        id: id,
        data: data,
      );
      return Groupe.fromJson(record);
    }
  }

  Future<Groupe> patchGroupe(String id, Map<String, dynamic> data) async {
    try {
      final response =
          await _dioClient.patch(ApiConstants.groupeById(id), data: data);
      await _databaseService?.clearTable('groupes');
      return Groupe.fromJson(response.data["data"] as Map<String, dynamic>);
    } on NetworkException {
      final record = await queueOfflineWrite(
        db: _databaseService,
        collection: 'groupes',
        cacheEntityType: 'groupes',
        id: id,
        data: data,
      );
      return Groupe.fromJson(record);
    }
  }

  Future<void> deleteGroupe(String id) async {
    try {
      await _dioClient.delete(ApiConstants.groupeById(id));
      await _databaseService?.clearTable('groupes');
    } on NetworkException {
      await queueOfflineWrite(
        db: _databaseService,
        collection: 'groupes',
        cacheEntityType: 'groupes',
        id: id,
        isDeleted: true,
      );
    }
  }

  Future<List<Membre>> getGroupeMembres(String id) async {
    final response = await _dioClient.get(ApiConstants.groupeMembres(id));
    final data = response.data["data"];
    List<dynamic> results;
    if (data is List) {
      results = data;
    } else if (data is Map && data.containsKey('membres')) {
      // Réponse backend : { groupe, total_membres, membres: [...] }.
      results = data['membres'] as List<dynamic>;
    } else if (data is Map && data.containsKey('results')) {
      results = data['results'] as List<dynamic>;
    } else {
      results = [];
    }
    return results
        .map((e) => Membre.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Liste des comptes utilisateurs (pour choisir les responsables d'un groupe).
  Future<List<AuthUser>> getUsers() async {
    final response = await _dioClient.get(ApiConstants.users);
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
        .map((e) => AuthUser.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Assigne l'ensemble des responsables d'un groupe (remplace la liste).
  Future<Groupe> assignResponsables(
      String groupeId, List<String> userIds) async {
    final response = await _dioClient.patch(
      ApiConstants.groupeById(groupeId),
      data: {'responsables': userIds},
    );
    await _databaseService?.clearTable('groupes');
    return Groupe.fromJson(response.data["data"] as Map<String, dynamic>);
  }

  // Ajoute un membre existant au groupe (affecte son champ `groupe`).
  Future<void> addMembreToGroupe(String groupeId, String membreId) async {
    await _dioClient.post(
      ApiConstants.groupeMembres(groupeId),
      data: {'membre': membreId},
    );
    await _databaseService?.clearTable('membres');
  }

  // Retire un membre du groupe.
  Future<void> removeMembreFromGroupe(String groupeId, String membreId) async {
    await _dioClient.delete(
      ApiConstants.groupeMembres(groupeId),
      data: {'membre': membreId},
    );
    await _databaseService?.clearTable('membres');
  }
}
