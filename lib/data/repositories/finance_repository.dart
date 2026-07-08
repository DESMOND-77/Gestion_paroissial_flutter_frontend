import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../../core/database/database_service.dart';
import '../models/transaction_model.dart' show Transaction, RapportFinancier;

class FinanceRepository {
  final DioClient _dioClient;
  final DatabaseService? _databaseService;

  FinanceRepository({
    required DioClient dioClient,
    DatabaseService? databaseService,
  })  : _dioClient = dioClient,
        _databaseService = databaseService;

  // Récupère les transactions depuis le serveur (pour la synchronisation)
  Future<List<Transaction>> fetchTransactions() async {
    final response = await _dioClient.get(ApiConstants.transactions);

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
        .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Transaction>> getTransactions({
    String? type,
    String? categorie,
    String? dateDebut,
    String? dateFin,
    int? membreId,
    int? page,
  }) async {
    // Si paramètres de filtrage: toujours du serveur
    if (type != null ||
        categorie != null ||
        dateDebut != null ||
        dateFin != null ||
        membreId != null ||
        page != null) {
      final queryParams = <String, dynamic>{};
      if (type != null) queryParams['type'] = type;
      if (categorie != null) queryParams['categorie'] = categorie;
      if (dateDebut != null) queryParams['date_debut'] = dateDebut;
      if (dateFin != null) queryParams['date_fin'] = dateFin;
      if (membreId != null) queryParams['membre'] = membreId;
      if (page != null) queryParams['page'] = page;

      final response = await _dioClient.get(
        ApiConstants.transactions,
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
          .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // Chercher en cache d'abord
    if (_databaseService != null) {
      final cached = await _databaseService.getItems('finances');
      if (cached.isNotEmpty) {
        return cached.map((e) => Transaction.fromJson(e)).toList();
      }
    }

    // Pas de cache, requête au serveur
    return fetchTransactions();
  }

  Future<Transaction> getTransactionById(int id) async {
    final response = await _dioClient.get(ApiConstants.transactionById(id));
    return Transaction.fromJson(response.data["data"] as Map<String, dynamic>);
  }

  Future<Transaction> createTransaction(Map<String, dynamic> data) async {
    final response =
        await _dioClient.post(ApiConstants.transactions, data: data);
    await _databaseService?.clearTable('finances');
    return Transaction.fromJson(response.data["data"] as Map<String, dynamic>);
  }

  Future<Transaction> updateTransaction(
      int id, Map<String, dynamic> data) async {
    final response =
        await _dioClient.put(ApiConstants.transactionById(id), data: data);
    await _databaseService?.clearTable('finances');
    return Transaction.fromJson(response.data["data"] as Map<String, dynamic>);
  }

  Future<Transaction> patchTransaction(
      int id, Map<String, dynamic> data) async {
    final response =
        await _dioClient.patch(ApiConstants.transactionById(id), data: data);
    await _databaseService?.clearTable('finances');
    return Transaction.fromJson(response.data["data"] as Map<String, dynamic>);
  }

  Future<void> deleteTransaction(int id) async {
    await _dioClient.delete(ApiConstants.transactionById(id));
    await _databaseService?.clearTable('finances');
  }

  Future<RapportFinancier> getRapport({
    String? dateDebut,
    String? dateFin,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (dateDebut != null) queryParams['date_debut'] = dateDebut;
      if (dateFin != null) queryParams['date_fin'] = dateFin;

      final response = await _dioClient.get(
        ApiConstants.financesRapport,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      return RapportFinancier.fromJson(
          response.data["data"] as Map<String, dynamic>);
    } catch (e) {
      // Hors ligne / serveur injoignable : pas d'endpoint dédié à mettre en
      // cache pour un rapport (donnée calculée) — on le recalcule localement
      // à partir des transactions déjà en cache plutôt que de tout perdre.
      // Une période filtrée reste néanmoins impossible à honorer hors ligne.
      if (dateDebut != null || dateFin != null || _databaseService == null) {
        rethrow;
      }
      final cached = await _databaseService.getItems('finances');
      if (cached.isEmpty) rethrow;
      final transactions = cached.map((e) => Transaction.fromJson(e)).toList();
      return _computeLocalRapport(transactions);
    }
  }

  RapportFinancier _computeLocalRapport(List<Transaction> transactions) {
    double totalRecettes = 0;
    double totalDepenses = 0;
    final parCategorie = <String, double>{};
    for (final t in transactions) {
      parCategorie[t.categorie] = (parCategorie[t.categorie] ?? 0) + t.montant;
      if (t.type == 'recette') {
        totalRecettes += t.montant;
      } else if (t.type == 'depense') {
        totalDepenses += t.montant;
      }
    }
    return RapportFinancier(
      totalRecettes: totalRecettes,
      totalDepenses: totalDepenses,
      balance: totalRecettes - totalDepenses,
      parCategorie: parCategorie,
      parMois: const [],
    );
  }

  Future<List<Transaction>> getMembreDons(int membreId) async {
    final response = await _dioClient.get(ApiConstants.membreDons(membreId));
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
        .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
