import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/storage/file_storage_service.dart';
import '../models/auth_model.dart';

class AuthRepository {
  static const _profilePictureCategory = 'profile_pictures';

  final DioClient _dioClient;
  final SecureStorage _secureStorage;
  final FileStorageService _fileStorage;

  AuthRepository({
    required DioClient dioClient,
    required SecureStorage secureStorage,
    required FileStorageService fileStorage,
  })  : _dioClient = dioClient,
        _secureStorage = secureStorage,
        _fileStorage = fileStorage;

  String _profilePictureFileName(String userId) => 'user_$userId';

  /// Fichier local mis en cache pour cet utilisateur, s'il existe — utilisé
  /// pour afficher la photo de profil sans réseau.
  File? getCachedProfilePicture(String userId) {
    return _fileStorage.getCachedFile(
      _profilePictureCategory,
      _profilePictureFileName(userId),
    );
  }

  /// Télécharge la photo de profil distante et la met en cache localement
  /// (accès hors ligne). Les échecs sont ignorés : l'avatar retombe sur le
  /// cache déjà présent ou sur les initiales.
  Future<void> _cacheProfilePicture(AuthUser user) async {
    if (user.profilePictureUrl.isEmpty) return;
    await _fileStorage.downloadAndCache(
      user.profilePictureUrl,
      _profilePictureCategory,
      _profilePictureFileName(user.id),
    );
  }

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
    await _cacheProfilePicture(loginResponse.user);
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
    final user =
        AuthUser.fromJson(response.data["data"] as Map<String, dynamic>);
    await _cacheProfilePicture(user);
    return user;
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
    // Le serializer backend exige confirm_password en plus de new_password ;
    // le formulaire valide déjà l'égalité des deux avant l'appel.
    await _dioClient.post(
      ApiConstants.changePassword,
      data: {
        'old_password': oldPassword,
        'new_password': newPassword,
        'confirm_password': newPassword,
      },
    );
  }

  Future<AuthUser> getUserProfile() async {
    final response = await _dioClient.get(ApiConstants.userProfile);
    final user =
        AuthUser.fromJson(response.data["data"] as Map<String, dynamic>);
    await _secureStorage.saveUserData(jsonEncode(user.toJson()));
    await _cacheProfilePicture(user);
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

  Future<AuthUser> updateProfilePicture(String filePath) async {
    final formData = FormData.fromMap({
      'profile_picture': await MultipartFile.fromFile(filePath),
    });
    final response =
        await _dioClient.patch(ApiConstants.userProfile, data: formData);
    final user =
        AuthUser.fromJson(response.data["data"] as Map<String, dynamic>);
    await _secureStorage.saveUserData(jsonEncode(user.toJson()));
    await _cacheProfilePicture(user);
    return user;
  }

  Future<void> setBaseUrl(String baseUrl) async {
    await _secureStorage.saveBaseUrl(baseUrl);
    _dioClient.updateBaseUrl(baseUrl);
  }

  Future<String?> getBaseUrl() async {
    return await _secureStorage.getBaseUrl();
  }
}
