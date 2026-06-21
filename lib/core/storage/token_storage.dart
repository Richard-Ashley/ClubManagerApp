import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageKeys {
  StorageKeys._();
  static const String token    = 'auth_token';
  static const String userEmail = 'user_email';
  static const String userRole  = 'user_role';
  static const String userName  = 'user_name';
}

class TokenStorage {
  const TokenStorage(this._storage);

  final FlutterSecureStorage _storage;

  Future<void> saveToken(String token) =>
      _storage.write(key: StorageKeys.token, value: token);

  Future<String?> getToken() =>
      _storage.read(key: StorageKeys.token);

  Future<void> saveUserInfo({
    required String email,
    required String name,
    required String role,
  }) async {
    await _storage.write(key: StorageKeys.userEmail, value: email);
    await _storage.write(key: StorageKeys.userName,  value: name);
    await _storage.write(key: StorageKeys.userRole,  value: role);
  }

  Future<Map<String, String?>> getUserInfo() async => {
    'email': await _storage.read(key: StorageKeys.userEmail),
    'name':  await _storage.read(key: StorageKeys.userName),
    'role':  await _storage.read(key: StorageKeys.userRole),
  };

  Future<void> clearAll() => _storage.deleteAll();
}
