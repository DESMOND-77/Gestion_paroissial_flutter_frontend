import 'package:isar_plus/isar_plus.dart';

part 'pending_change_entity.g.dart';

/// File d'attente locale (« outbox ») des écritures effectuées hors ligne.
///
/// Chaque ligne représente le dernier état local d'un enregistrement à
/// pousser vers le serveur central via `POST /api/v1/sync/`. Le format suit le
/// contrat de `core.sync` côté backend : le blob JSON (`dataJson`) transporte
/// les champs métier **plus** les métadonnées de synchro `updated_at` (ISO
/// 8601) et `is_deleted` (une suppression est un enregistrement marqué
/// `is_deleted: true`, pas une ligne retirée).
///
/// L'id Isar est dérivé de `Isar.fastHash('collection|entityId')` (voir
/// `database_service.dart`) : un upsert par (collection, id) - plusieurs
/// modifications successives du même enregistrement hors ligne fusionnent en
/// une seule ligne à pousser.
@collection
class PendingChangeEntity {
  // Toujours affecté explicitement via Isar.fastHash (pas d'auto-incrément).
  int id = 0;

  // NB : ne pas nommer ce champ `collection` - le générateur isar_plus utilise
  // en interne une variable `collection` (l'IsarCollection) et un champ
  // homonyme casse le code généré (`collection.updateProperties` mal résolu).
  @Index()
  late String syncCollection;

  late String entityId;

  late String dataJson;

  late DateTime queuedAt;
}
