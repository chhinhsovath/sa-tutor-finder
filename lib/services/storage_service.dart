import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Universal storage service that works on both web and mobile
/// Uses SharedPreferences for web and FlutterSecureStorage for mobile
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  SharedPreferences? _prefs;

  /// Initialize storage (call this before using)
  Future<void> init() async {
    if (kIsWeb) {
      _prefs = await SharedPreferences.getInstance();
    }
  }

  /// Save token to storage
  Future<void> saveToken(String token) async {
    if (kIsWeb) {
      await _prefs?.setString('auth_token', token);
    } else {
      await _secureStorage.write(key: 'auth_token', value: token);
    }
  }

  /// Get token from storage
  Future<String?> getToken() async {
    if (kIsWeb) {
      return _prefs?.getString('auth_token');
    } else {
      return await _secureStorage.read(key: 'auth_token');
    }
  }

  /// Clear token from storage
  Future<void> clearToken() async {
    if (kIsWeb) {
      await _prefs?.remove('auth_token');
    } else {
      await _secureStorage.delete(key: 'auth_token');
    }
  }

  /// Save any string value
  Future<void> saveString(String key, String value) async {
    if (kIsWeb) {
      await _prefs?.setString(key, value);
    } else {
      await _secureStorage.write(key: key, value: value);
    }
  }

  /// Get any string value
  Future<String?> getString(String key) async {
    if (kIsWeb) {
      return _prefs?.getString(key);
    } else {
      return await _secureStorage.read(key: key);
    }
  }

  /// Remove any value
  Future<void> remove(String key) async {
    if (kIsWeb) {
      await _prefs?.remove(key);
    } else {
      await _secureStorage.delete(key: key);
    }
  }

  /// Clear all storage
  Future<void> clearAll() async {
    if (kIsWeb) {
      await _prefs?.clear();
    } else {
      await _secureStorage.deleteAll();
    }
  }
}
