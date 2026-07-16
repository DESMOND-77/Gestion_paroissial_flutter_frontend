class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  factory ApiException.fromStatusCode(int statusCode, [dynamic data]) {
    String message;
    switch (statusCode) {
      case 400:
        message = _extractMessage(data) ?? 'Requête invalide';
        break;
      case 401:
        message = 'Non authorisé.';
        break;
      case 403:
        message = 'Accès refusé. Vous n\'avez pas les droits nécessaires.';
        break;
      case 404:
        message = 'Ressource introuvable.';
        break;
      case 409:
        message = _extractMessage(data) ?? 'Conflit de données.';
        break;
      case 422:
        message = _extractMessage(data) ?? 'Données invalides.';
        break;
      case 500:
        message = 'Erreur interne du serveur.';
        break;
      case 502:
        message = 'Serveur indisponible (Bad Gateway).';
        break;
      case 503:
        message = 'Service temporairement indisponible.';
        break;
      default:
        message = 'Erreur HTTP $statusCode';
    }
    return ApiException(message: message, statusCode: statusCode, data: data);
  }

  static String? _extractMessage(dynamic data) {
    if (data == null) return null;
    if (data is String) return data.trim().isEmpty ? null : data;
    if (data is List) {
      for (final item in data) {
        final m = _extractMessage(item);
        if (m != null) return m;
      }
      return null;
    }
    if (data is Map) {
      // Enveloppe standardisée du backend : { success, error, message, ... }.
      // `error` peut être une chaîne ("Mot de passe actuel incorrect") ou un
      // dictionnaire d'erreurs de validation DRF ({ "new_password": [...] }) :
      // on descend récursivement pour en extraire un message lisible.
      for (final key in const ['error', 'detail', 'message', 'non_field_errors']) {
        if (data[key] != null) {
          final m = _extractMessage(data[key]);
          if (m != null) return m;
        }
      }
      // Erreurs par champ (serializer DRF) : "champ : message".
      final fieldErrors = <String>[];
      data.forEach((key, value) {
        if (key == 'success' ||
            key == 'error' ||
            key == 'message' ||
            key == 'detail' ||
            key == 'non_field_errors') {
          return;
        }
        final m = _extractMessage(value);
        if (m != null) fieldErrors.add('$key : $m');
      });
      if (fieldErrors.isNotEmpty) return fieldErrors.join('\n');
    }
    return null;
  }

  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}

class NetworkException implements Exception {
  final String message;
  const NetworkException({required this.message});

  @override
  String toString() => 'NetworkException: $message';
}
