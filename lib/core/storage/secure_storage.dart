import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class SecureStorageLockedException implements Exception {
  final String message;
  const SecureStorageLockedException([
    this.message =
        'Le trousseau système est verrouillé. Déverrouillez-le et réessayez.',
  ]);
  @override
  String toString() => 'SecureStorageLockedException: $message';
}

class SecureStorage {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  bool _lockedDetected = false;
  bool get isLocked => _lockedDetected;

  bool _isKeyringLocked(Object e) {
    if (e is! PlatformException) return false;
    return e.code == 'KeyringLocked' ||
        (e.message?.contains('KeyringLocked') ?? false);
  }

  Future<String?> _safeRead(String key) async {
    try {
      return await _storage.read(key: key);
    } on PlatformException catch (e) {
      if (_isKeyringLocked(e)) {
        _lockedDetected = true;
        return null;
      }
      rethrow;
    }
  }

  Future<void> _safeWrite(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } on PlatformException catch (e) {
      if (_isKeyringLocked(e)) {
        _lockedDetected = true;
        throw const SecureStorageLockedException();
      }
      rethrow;
    }
  }

  Future<void> _safeDelete(String key) async {
    try {
      await _storage.delete(key: key);
    } on PlatformException catch (e) {
      if (_isKeyringLocked(e)) {
        _lockedDetected = true;
        return;
      }
      rethrow;
    }
  }

  Future<bool> probe() async {
    try {
      await _storage.read(key: '__probe__');
      _lockedDetected = false;
      return true;
    } on PlatformException catch (e) {
      if (_isKeyringLocked(e)) {
        _lockedDetected = true;
        return false;
      }
      rethrow;
    }
  }

  Future<void> saveAccessToken(String token) =>
      _safeWrite(AppConstants.accessTokenKey, token);

  Future<void> saveRefreshToken(String token) =>
      _safeWrite(AppConstants.refreshTokenKey, token);

  Future<String?> getAccessToken() => _safeRead(AppConstants.accessTokenKey);

  Future<String?> getRefreshToken() => _safeRead(AppConstants.refreshTokenKey);

  Future<void> deleteAccessToken() => _safeDelete(AppConstants.accessTokenKey);

  Future<void> deleteRefreshToken() =>
      _safeDelete(AppConstants.refreshTokenKey);

  Future<void> deleteAllTokens() async {
    await _safeDelete(AppConstants.accessTokenKey);
    await _safeDelete(AppConstants.refreshTokenKey);
  }

  Future<void> saveUserData(String userData) =>
      _safeWrite(AppConstants.userKey, userData);

  Future<String?> getUserData() => _safeRead(AppConstants.userKey);

  Future<void> deleteUserData() => _safeDelete(AppConstants.userKey);

  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } on PlatformException catch (e) {
      if (_isKeyringLocked(e)) {
        _lockedDetected = true;
        return;
      }
      rethrow;
    }
  }
}
