import '../database/database_service.dart';
import '../network/api_exception.dart';
import '../utils/id_generator.dart';

/// Repli hors ligne pour une écriture (création / mise à jour / suppression).
///
/// Appelé par les repositories quand l'appel réseau échoue faute de connexion
/// (`NetworkException`) : l'écriture est mise en file d'attente (outbox) et
/// appliquée de façon optimiste au cache, puis poussée à la prochaine passe de
/// [OfflineSyncService.pushPull]. Renvoie l'enregistrement fusionné (incluant
/// l'`id`), avec lequel le repository reconstruit le modèle rendu à l'UI.
///
/// [id] `null` ⇒ création : un UUID v4 est généré côté client (le backend
/// accepte les UUID fournis par le client). Sinon l'`id` existant est réutilisé.
Future<Map<String, dynamic>> queueOfflineWrite({
  required DatabaseService? db,
  required String collection,
  required String cacheEntityType,
  Map<String, dynamic> data = const {},
  String? id,
  bool isDeleted = false,
}) async {
  if (db == null) {
    // Pas de stockage local : impossible de mettre en attente, on remonte
    // l'échec réseau d'origine.
    throw const NetworkException(
        message: 'Hors ligne : stockage local indisponible.');
  }
  final record = <String, dynamic>{
    ...data,
    'id': id ?? generateUuidV4(),
    if (isDeleted) 'is_deleted': true,
  };
  return db.enqueueLocalChange(
    collection: collection,
    cacheEntityType: cacheEntityType,
    record: record,
  );
}
