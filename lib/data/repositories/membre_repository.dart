import 'dart:convert';

import '../../core/network/api_exception.dart';
import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../../core/database/database_service.dart';
import '../../core/storage/secure_storage.dart';
import '../models/membre_model.dart';
import '../models/sacrement_model.dart';

class MembreRepository {
  final DioClient _dioClient;
  final DatabaseService? _databaseService;
  final SecureStorage? _secureStorage;

  MembreRepository({
    required DioClient dioClient,
    DatabaseService? databaseService,
    SecureStorage? secureStorage,
  })  : _dioClient = dioClient,
        _databaseService = databaseService,
        _secureStorage = secureStorage;

  // Récupère les membres depuis le serveur (pour la synchronisation)
  Future<List<Membre>> fetchMembers() async {
    final response = await _dioClient.get(ApiConstants.membres);

    final data = response.data["data"];
    List<dynamic> results;
    if (data is Map && data.containsKey('results')) {
      results = data['results'] as List<dynamic>;
    } else if (data is List) {
      results = data;
    } else {
      results = [];
    }

    if (_databaseService != null) {
      await _databaseService.saveItems(
          'membres', results.map((e) => e as Map<String, dynamic>).toList());
    }
    return results
        .map((e) => Membre.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Membre>> getMembres({
    String? search,
    String? groupe,
    String? sexe,
    int? page,
  }) async {
    // Si recherche, filtrage ou pagination: toujours du serveur
    if (search != null || groupe != null || sexe != null || page != null) {
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

    // Sinon, chercher en cache d'abord
    if (_databaseService != null) {
      final cached = await _databaseService.getItems('membres');
      if (cached.isNotEmpty) {
        return cached.map((e) => Membre.fromJson(e)).toList();
      }
    }

    // Pas de cache, requête au serveur
    return fetchMembers();
  }

  Future<MembreDetail> getMembreById(int id) async {
    final response = await _dioClient.get(ApiConstants.membreById(id));
    return MembreDetail.fromJson(response.data["data"] as Map<String, dynamic>);
  }

  Future<Membre> createMembre(Map<String, dynamic> data) async {
    final response = await _dioClient.post(ApiConstants.membres, data: data);
    await _databaseService?.clearTable('membres');
    return Membre.fromJson(response.data["data"] as Map<String, dynamic>);
  }

  Future<Membre> updateMembre(int id, Map<String, dynamic> data) async {
    final response =
        await _dioClient.put(ApiConstants.membreById(id), data: data);
    await _databaseService?.clearTable('membres');
    return Membre.fromJson(response.data["data"] as Map<String, dynamic>);
  }

  Future<Membre> patchMembre(int id, Map<String, dynamic> data) async {
    final response =
        await _dioClient.patch(ApiConstants.membreById(id), data: data);
    await _databaseService?.clearTable('membres');
    return Membre.fromJson(response.data["data"] as Map<String, dynamic>);
  }

  /// Profil membre lié au compte connecté, ou `null` si aucun membre n'est
  /// associé à ce compte (ex : compte administrateur sans fiche membre).
  ///
  /// Mis en cache localement pour rester consultable hors connexion ; en cas
  /// d'échec réseau on retombe sur la dernière copie connue plutôt que de
  /// remonter l'erreur.
  Future<Membre?> getMyMembre() async {
    try {
      final response = await _dioClient.get(ApiConstants.membreMe);
      final membre =
          Membre.fromJson(response.data["data"] as Map<String, dynamic>);
      await _secureStorage?.saveMembreSelfData(jsonEncode(membre.toJson()));
      return membre;
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        await _secureStorage?.deleteMembreSelfData();
        return null;
      }
      final cached = await _getCachedMyMembre();
      if (cached != null) return cached;
      rethrow;
    } on NetworkException {
      final cached = await _getCachedMyMembre();
      if (cached != null) return cached;
      rethrow;
    }
  }

  Future<Membre?> _getCachedMyMembre() async {
    final raw = await _secureStorage?.getMembreSelfData();
    if (raw == null) return null;
    try {
      return Membre.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Auto-modification limitée à date_naissance/sexe/quartier (voir
  /// `MembreSelfSerializer` côté backend).
  Future<Membre> updateMyMembre(Map<String, dynamic> data) async {
    final response = await _dioClient.patch(ApiConstants.membreMe, data: data);
    final membre =
        Membre.fromJson(response.data["data"] as Map<String, dynamic>);
    await _secureStorage?.saveMembreSelfData(jsonEncode(membre.toJson()));
    return membre;
  }

  Future<void> deleteMembre(int id) async {
    await _dioClient.delete(ApiConstants.membreById(id));
    await _databaseService?.clearTable('membres');
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

  Future<Sacrement> ajouterSacrement(
      int membreId, Map<String, dynamic> data) async {
    final response = await _dioClient.post(
      ApiConstants.membreAjouterSacrement(membreId),
      data: data,
    );
    return Sacrement.fromJson(response.data["data"] as Map<String, dynamic>);
  }
}
