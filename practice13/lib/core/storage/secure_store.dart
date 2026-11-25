import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStore {
  SecureStore()
    : _storage = Platform.isMacOS
          ? const FlutterSecureStorage(
              mOptions: MacOsOptions(usesDataProtectionKeychain: false),
            )
          : const FlutterSecureStorage();

  static const _tokenKey = 'practice13.auth_token';

  final FlutterSecureStorage _storage;

  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<String?> readToken() => _storage.read(key: _tokenKey);

  Future<void> clear() => _storage.delete(key: _tokenKey);
}
