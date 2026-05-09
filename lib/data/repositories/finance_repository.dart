import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/transaction_model.dart';

class FinanceRepository {
  final DioClient _dioClient;

  FinanceRepository({required DioClient dioClient}) : _dioClient = dioClient;

  Future<List<Transaction>> getTransactions({
    String? type,
    String? categorie,
    String? dateDebut,
    String? dateFin,
    int? membreId,
    int? page,
  }) async {
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

  Future<Transaction> getTransactionById(int id) async {
    final response = await _dioClient.get(ApiConstants.transactionById(id));
    return Transaction.fromJson(response.data["data"] as Map<String, dynamic>);
  }

  Future<Transaction> createTransaction(Map<String, dynamic> data) async {
    final response = await _dioClient.post(ApiConstants.transactions, data: data);
    return Transaction.fromJson(response.data["data"] as Map<String, dynamic>);
  }

  Future<Transaction> updateTransaction(int id, Map<String, dynamic> data) async {
    final response = await _dioClient.put(ApiConstants.transactionById(id), data: data);
    return Transaction.fromJson(response.data["data"] as Map<String, dynamic>);
  }

  Future<Transaction> patchTransaction(int id, Map<String, dynamic> data) async {
    final response = await _dioClient.patch(ApiConstants.transactionById(id), data: data);
    return Transaction.fromJson(response.data["data"] as Map<String, dynamic>);
  }

  Future<void> deleteTransaction(int id) async {
    await _dioClient.delete(ApiConstants.transactionById(id));
  }

  Future<RapportFinancier> getRapport({
    String? dateDebut,
    String? dateFin,
  }) async {
    final queryParams = <String, dynamic>{};
    if (dateDebut != null) queryParams['date_debut'] = dateDebut;
    if (dateFin != null) queryParams['date_fin'] = dateFin;

    final response = await _dioClient.get(
      ApiConstants.financesRapport,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    return RapportFinancier.fromJson(response.data["data"] as Map<String, dynamic>);
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
