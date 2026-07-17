import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import '../storage/secure_storage.dart';
import 'api_exception.dart';

class DioClient {
  late final Dio _dio;
  final SecureStorage _secureStorage;
  bool _isRefreshing = false;
  final List<Function> _failedQueue = [];

  /// Nombre maximum de tentatives de renouvellement du jeton avant d'abandonner
  /// la session (effacement des jetons + redirection vers l'écran de connexion).
  static const int _maxRefreshAttempts = 3;

  /// Callback invoqué lorsque la session expire définitivement (après
  /// [_maxRefreshAttempts] échecs de renouvellement). Câblé dans `App` pour
  /// notifier l'`AuthBloc` et déclencher la redirection vers `/login`.
  void Function()? onSessionExpired;

  DioClient(this._secureStorage) {
    _dio = Dio(
      BaseOptions(
        baseUrl:  ApiConstants.baseUrl,
        connectTimeout:
            const Duration(milliseconds: AppConstants.connectTimeout),
        receiveTimeout:
            const Duration(milliseconds: AppConstants.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          // Ne jamais attacher l'access token aux endpoints d'authentification :
          // le refresh doit partir SANS en-tête (sinon BaseAPIView authentifie
          // l'access token périmé et renvoie 401 avant d'exécuter la vue), et
          // login/register sont publics.
          if (_isAuthEndpoint(options.path)) {
            options.headers.remove('Authorization');
            handler.next(options);
            return;
          }
          final token = await _secureStorage.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          handler.next(response);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode != 401 ||
              _isAuthEndpoint(error.requestOptions.path)) {
            handler.next(error);
            return;
          }

          // Garde anti-boucle : une requête déjà rejouée après un refresh ne
          // redéclenche pas un nouveau cycle de renouvellement.
          if (error.requestOptions.extra['__retried__'] == true) {
            handler.next(error);
            return;
          }

          // Si le jeton a déjà été renouvelé entre-temps (par une autre requête
          // concurrente), on rejoue directement avec le jeton courant sans
          // relancer de refresh - évite de faire tourner la rotation des
          // refresh tokens et les 401/500 en cascade.
          final usedAuth =
              error.requestOptions.headers['Authorization'] as String?;
          final currentToken = await _secureStorage.getAccessToken();
          if (currentToken != null &&
              currentToken.isNotEmpty &&
              usedAuth != 'Bearer $currentToken') {
            await _retryOriginal(error, currentToken, handler);
            return;
          }

          if (_isRefreshing) {
            _failedQueue.add(() async {
              final token = await _secureStorage.getAccessToken();
              await _retryOriginal(error, token, handler);
            });
            return;
          }

          _isRefreshing = true;
          final refreshToken = await _secureStorage.getRefreshToken();

          if (refreshToken == null || refreshToken.isEmpty) {
            _failedQueue.clear();
            _isRefreshing = false;
            await _expireSession();
            handler.next(error);
            return;
          }

          // Tente de renouveler le jeton jusqu'à [_maxRefreshAttempts] fois.
          String? newAccessToken;
          String? newRefreshToken;
          for (var attempt = 1;
              attempt <= _maxRefreshAttempts && newAccessToken == null;
              attempt++) {
            try {
              final refreshResponse = await _dio.post(
                ApiConstants.tokenRefresh,
                data: {'refresh_token': refreshToken},
                options: Options(headers: {'Authorization': null}),
              );
              newAccessToken = _extractAccessToken(refreshResponse.data);
              newRefreshToken = _extractRefreshToken(refreshResponse.data);
            } catch (_) {
              // Échec de cette tentative : on réessaie tant que la limite
              // n'est pas atteinte.
            }
          }

          if (newAccessToken == null || newAccessToken.isEmpty) {
            // Les trois tentatives ont échoué : on abandonne la session.
            _failedQueue.clear();
            _isRefreshing = false;
            await _expireSession();
            handler.next(error);
            return;
          }

          await _secureStorage.saveAccessToken(newAccessToken);
          // La rotation des refresh tokens (ROTATE_REFRESH_TOKENS) invalide
          // l'ancien : on DOIT persister le nouveau, sinon le prochain refresh
          // échouera (token blacklisté).
          if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
            await _secureStorage.saveRefreshToken(newRefreshToken);
          }

          _isRefreshing = false;

          // Rejoue les requêtes mises en file d'attente pendant le refresh.
          final queued = List<Function>.from(_failedQueue);
          _failedQueue.clear();
          for (final callback in queued) {
            callback();
          }

          // Rejoue la requête d'origine avec le nouveau jeton.
          await _retryOriginal(error, newAccessToken, handler);
        },
      ),
    );
  }

  Dio get dio => _dio;

  String get baseUrl => _dio.options.baseUrl;

  /// Change l'URL du serveur utilisée pour toutes les requêtes suivantes,
  /// sans nécessiter de redémarrage de l'application.
  void updateBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
  }

  /// Recharge, au démarrage de l'app, une URL de serveur précédemment
  /// enregistrée par l'utilisateur (sinon on conserve [ApiConstants.baseUrl]).
  Future<void> loadPersistedBaseUrl() async {
    final saved = await _secureStorage.getBaseUrl();
    if (saved != null && saved.trim().isNotEmpty) {
      _dio.options.baseUrl = saved.trim();
    }
  }

  /// Endpoints d'authentification qui ne doivent jamais recevoir l'en-tête
  /// Authorization (publics ou dédiés au renouvellement du jeton).
  static bool _isAuthEndpoint(String path) {
    return path.contains(ApiConstants.tokenRefresh) ||
        path.contains(ApiConstants.login) ||
        path.contains(ApiConstants.register);
  }

  /// Rejoue la requête initiale avec [token] après un renouvellement réussi.
  /// Marque la requête (`__retried__`) pour éviter toute boucle de refresh si
  /// elle échoue de nouveau en 401.
  Future<void> _retryOriginal(
    DioException error,
    String? token,
    ErrorInterceptorHandler handler,
  ) async {
    final options = error.requestOptions;
    options.extra['__retried__'] = true;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    try {
      final response = await _dio.fetch(options);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    } catch (_) {
      handler.next(error);
    }
  }

  /// Efface tous les jetons et notifie l'application que la session a expiré
  /// afin de rediriger l'utilisateur vers l'écran de connexion.
  Future<void> _expireSession() async {
    await _secureStorage.clearAll();
    onSessionExpired?.call();
  }

  /// Extrait un jeton de la réponse de renouvellement, en tolérant les
  /// différentes formes d'enveloppe renvoyées par le serveur
  /// (`{access}`, `{data:{access}}`, `{tokens:{access}}`,
  /// `{success:{data:{tokens:{access}}}}`). [fieldNames] liste les clés
  /// possibles (ex. `access`/`access_token`).
  String? _extractToken(dynamic data, List<String> fieldNames) {
    if (data is! Map) return null;
    for (final field in fieldNames) {
      final direct = data[field];
      if (direct is String && direct.isNotEmpty) return direct;
    }
    for (final key in ['success', 'data', 'tokens']) {
      final nested = _extractToken(data[key], fieldNames);
      if (nested != null) return nested;
    }
    return null;
  }

  String? _extractAccessToken(dynamic data) =>
      _extractToken(data, const ['access', 'access_token']);

  String? _extractRefreshToken(dynamic data) =>
      _extractToken(data, const ['refresh', 'refresh_token']);

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return const NetworkException(
          message:
              'Délai de connexion dépassé. Vérifiez votre connexion internet.');
    }
    if (e.type == DioExceptionType.connectionError) {
      return const NetworkException(
          message:
              'Impossible de se connecter au serveur. Vérifiez votre connexion internet.');
    }
    if (e.response != null) {
      return ApiException.fromStatusCode(
        e.response!.statusCode!,
        e.response!.data,
      );
    }
    return ApiException(
        message: e.message ?? 'Une erreur inattendue s\'est produite');
  }
}
