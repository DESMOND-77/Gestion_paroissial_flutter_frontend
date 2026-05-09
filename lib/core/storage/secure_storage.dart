import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class SecureStorage {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: AppConstants.accessTokenKey, value: token);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: AppConstants.refreshTokenKey, value: token);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: AppConstants.accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: AppConstants.refreshTokenKey);
  }

  Future<void> deleteAccessToken() async {
    await _storage.delete(key: AppConstants.accessTokenKey);
  }

  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: AppConstants.refreshTokenKey);
  }

  Future<void> deleteAllTokens() async {
    await _storage.delete(key: AppConstants.accessTokenKey);
    await _storage.delete(key: AppConstants.refreshTokenKey);
  }

  Future<void> saveUserData(String userData) async {
    await _storage.write(key: AppConstants.userKey, value: userData);
  }

  Future<String?> getUserData() async {
    return await _storage.read(key: AppConstants.userKey);
  }

  Future<void> deleteUserData() async {
    await _storage.delete(key: AppConstants.userKey);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
