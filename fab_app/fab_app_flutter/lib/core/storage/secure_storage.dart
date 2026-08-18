import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final secureStorageProvider = Provider((ref) => const FlutterSecureStorage());

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService(this._storage);

  static const _tokenKey = 'auth_token';
  static const _passwordKey = 'auth_password';

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  Future<void> savePassword(String password) async {
    await _storage.write(key: _passwordKey, value: password);
  }

  Future<String?> getPassword() async {
    return await _storage.read(key: _passwordKey);
  }

  Future<void> deletePassword() async {
    await _storage.delete(key: _passwordKey);
  }
}

final secureStorageServiceProvider = Provider((ref) {
  final storage = ref.watch(secureStorageProvider);
  return SecureStorageService(storage);
});
