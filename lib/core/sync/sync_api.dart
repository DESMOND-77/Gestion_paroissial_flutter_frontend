import '../constants/api_constants.dart';
import '../network/dio_client.dart';

/// Client de transport pour l'endpoint de synchronisation bidirectionnelle
/// `POST /api/v1/sync/` (voir `core.sync` côté backend).
class SyncApi {
  final DioClient _dioClient;

  SyncApi({required DioClient dioClient}) : _dioClient = dioClient;

  /// Pousse [changes] (modifications locales groupées par collection) et
  /// récupère tout ce qui a changé côté serveur depuis [since] (curseur ISO
  /// 8601, `null` au premier appel).
  ///
  /// Renvoie le bloc `data` de la réponse standardisée :
  /// `{ server_time, results, changes }`.
  Future<Map<String, dynamic>> push({
    required String? since,
    required Map<String, List<Map<String, dynamic>>> changes,
  }) async {
    final response = await _dioClient.post(
      ApiConstants.sync,
      data: {'since': since, 'changes': changes},
    );
    return (response.data['data'] as Map).cast<String, dynamic>();
  }
}
