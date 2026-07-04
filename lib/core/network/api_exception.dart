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
    if (data is Map<String, dynamic>) {
      if (data.containsKey('detail')) return data['detail'].toString();
      if (data.containsKey('message')) return data['message'].toString();
      if (data.containsKey('non_field_errors')) {
        final errors = data['non_field_errors'];
        if (errors is List && errors.isNotEmpty) return errors.first.toString();
      }
      // Collect field errors
      final fieldErrors = <String>[];
      data.forEach((key, value) {
        if (value is List) {
          fieldErrors.add('$key: ${value.join(', ')}');
        } else if (value is String) {
          fieldErrors.add('$key: $value');
        }
      });
      if (fieldErrors.isNotEmpty) return fieldErrors.join('\n');
    }
    if (data is String) return data;
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
