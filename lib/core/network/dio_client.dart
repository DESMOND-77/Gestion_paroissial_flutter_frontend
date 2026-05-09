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

  DioClient(this._secureStorage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: AppConstants.connectTimeout),
        receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
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
          if (error.response?.statusCode == 401) {
            if (_isRefreshing) {
              _failedQueue.add(() async {
                final token = await _secureStorage.getAccessToken();
                error.requestOptions.headers['Authorization'] = 'Bearer $token';
                try {
                  final response = await _dio.fetch(error.requestOptions);
                  handler.resolve(response);
                } catch (e) {
                  handler.next(error);
                }
              });
              return;
            }

            _isRefreshing = true;
            final refreshToken = await _secureStorage.getRefreshToken();

            if (refreshToken == null || refreshToken.isEmpty) {
              await _secureStorage.clearAll();
              _isRefreshing = false;
              handler.next(error);
              return;
            }

            try {
              final refreshResponse = await _dio.post(
                ApiConstants.tokenRefresh,
                data: {'refresh': refreshToken},
                options: Options(headers: {'Authorization': null}),
              );

              final newAccessToken = refreshResponse.data['access'];
              await _secureStorage.saveAccessToken(newAccessToken);

              // Process queued requests
              for (final callback in _failedQueue) {
                callback();
              }
              _failedQueue.clear();

              // Retry original request
              error.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
              final response = await _dio.fetch(error.requestOptions);
              _isRefreshing = false;
              handler.resolve(response);
            } catch (e) {
              _failedQueue.clear();
              _isRefreshing = false;
              await _secureStorage.clearAll();
              handler.next(error);
            }
          } else {
            handler.next(error);
          }
        },
      ),
    );
  }

  Dio get dio => _dio;

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
      return const NetworkException(message: 'Délai de connexion dépassé. Vérifiez votre connexion internet.');
    }
    if (e.type == DioExceptionType.connectionError) {
      return const NetworkException(message: 'Impossible de se connecter au serveur. Vérifiez votre connexion internet.');
    }
    if (e.response != null) {
      return ApiException.fromStatusCode(
        e.response!.statusCode!,
        e.response!.data,
      );
    }
    return ApiException(message: e.message ?? 'Une erreur inattendue s\'est produite');
  }
}
