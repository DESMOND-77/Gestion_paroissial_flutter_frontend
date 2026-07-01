import 'dart:convert';
import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../../core/storage/secure_storage.dart';
import '../models/auth_model.dart';

class AuthRepository {
  final DioClient _dioClient;
  final SecureStorage _secureStorage;

  AuthRepository({
    required DioClient dioClient,
    required SecureStorage secureStorage,
  })  : _dioClient = dioClient,
        _secureStorage = secureStorage;

  Future<AuthUser> register(Map<String, dynamic> data) async {
    final response = await _dioClient.post(ApiConstants.register, data: data);
    // Réponse attendue : {"success": true, "data": {"user": {...}, ...}}.
    // On déballe étape par étape en ne descendant que si la valeur est un Map,
    // pour rester tolérant à l'ancienne enveloppe buguée
    // ({"success": {"success": true, "data": {...}}}) où "success" était un objet.
    var payload = response.data as Map<String, dynamic>;
    if (payload['success'] is Map) {
      payload = (payload['success'] as Map).cast<String, dynamic>();
    }
    if (payload['data'] is Map) {
      payload = (payload['data'] as Map).cast<String, dynamic>();
    }
    final userJson = payload['user'] is Map
        ? (payload['user'] as Map).cast<String, dynamic>()
        : payload;
    return AuthUser.fromJson(userJson);
  }

  Future<LoginResponse> login(String email, String password) async {
    final response = await _dioClient.post(
      ApiConstants.login,
      data: {'email': email, 'password': password},
    );
    final loginResponse =
        LoginResponse.fromJson(response.data["data"] as Map<String, dynamic>);
    await _secureStorage.saveAccessToken(loginResponse.access);
    await _secureStorage.saveRefreshToken(loginResponse.refresh);
    await _secureStorage.saveUserData(jsonEncode(loginResponse.user.toJson()));
    return loginResponse;
  }

  Future<void> logout() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      await _dioClient.post(
        ApiConstants.logout,
        data: {'refresh_token': refreshToken},
      );
    } finally {
      await _secureStorage.clearAll();
    }
  }

  Future<AuthUser> getCurrentUser() async {
    final response = await _dioClient.get(ApiConstants.me);
    return AuthUser.fromJson(response.data["data"] as Map<String, dynamic>);
  }

  Future<AuthUser?> getCachedUser() async {
    final userData = await _secureStorage.getUserData();
    if (userData == null) return null;
    try {
      return AuthUser.fromJson(jsonDecode(userData) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<bool> isAuthenticated() async {
    final token = await _secureStorage.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> requestPasswordReset(String email) async {
    await _dioClient.post(
      ApiConstants.passwordReset,
      data: {'email': email},
    );
  }

  Future<void> confirmPasswordReset(String token, String password) async {
    await _dioClient.post(
      ApiConstants.passwordResetConfirm,
      data: {'token': token, 'password': password},
    );
  }

  Future<void> sendVerificationEmail() async {
    await _dioClient.post(ApiConstants.sendVerification);
  }

  Future<Map<String, dynamic>> getVerificationStatus() async {
    final response = await _dioClient.get(ApiConstants.verificationStatus);
    return response.data["data"] as Map<String, dynamic>;
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    await _dioClient.post(
      ApiConstants.changePassword,
      data: {'old_password': oldPassword, 'new_password': newPassword},
    );
  }

  Future<AuthUser> getUserProfile() async {
    final response = await _dioClient.get(ApiConstants.userProfile);
    final user =
        AuthUser.fromJson(response.data["data"] as Map<String, dynamic>);
    await _secureStorage.saveUserData(jsonEncode(user.toJson()));
    return user;
  }

  Future<AuthUser> updateUserProfile(Map<String, dynamic> data) async {
    final response =
        await _dioClient.patch(ApiConstants.userProfile, data: data);
    final user =
        AuthUser.fromJson(response.data["data"] as Map<String, dynamic>);
    await _secureStorage.saveUserData(jsonEncode(user.toJson()));
    return user;
  }

  Future<void> setBaseUrl(String baseUrl) async {
    await _secureStorage.saveBaseUrl(baseUrl);
  }

  Future<String?> getBaseUrl() async {
    return await _secureStorage.getBaseUrl();
  }
}
