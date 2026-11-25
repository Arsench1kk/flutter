import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import '../../core/storage/secure_store.dart';
import 'user.dart';
import 'users_cache.dart';

typedef UsersResult = ({List<User> items, bool fromCache});

class UserRepository {
  UserRepository(this._api, this._cache);

  factory UserRepository.connect(SecureStore store, {http.Client? client}) =>
      UserRepository(
        ApiClient(client ?? http.Client(), store),
        const UsersCache(),
      );

  final ApiClient _api;
  final UsersCache _cache;

  Future<List<User>?> readCached() => _cache.load();

  Future<UsersResult> getAll() async {
    try {
      final fresh = await _fetch();
      await _saveCache(fresh);
      return (items: fresh, fromCache: false);
    } on NoConnectionException {
      final saved = await readCached();
      if (saved == null) rethrow;
      return (items: saved, fromCache: true);
    }
  }

  Future<void> _saveCache(List<User> fresh) async {
    try {
      await _cache.save(fresh);
    } on FileSystemException {
      // Display the live response even if the device cannot write the cache.
    } on MissingPlatformDirectoryException {
      // A documents directory is required only to persist the response.
    }
  }

  Future<List<User>> _fetch() async {
    final body = await _api.get('/users');
    if (body is! List) {
      throw const BadResponseException('users: expected an array');
    }
    return [
      for (var index = 0; index < body.length; index++)
        _parseUser(body[index], 'users[$index]'),
    ];
  }

  Future<User> getById(int id) async {
    final body = await _api.get('/users/$id');
    return _parseUser(body, 'users/$id');
  }

  Future<User> create(User draft) async {
    final body = await _api.post('/users', draft.toJson()..remove('id'));
    return _parseUser(body, 'POST users');
  }

  User _parseUser(Object? body, String source) {
    try {
      return User.fromJson(body as Map<String, dynamic>);
    } on TypeError catch (error) {
      throw BadResponseException('$source: $error');
    } on FormatException catch (error) {
      throw BadResponseException('$source: ${error.message}');
    }
  }

  void close() => _api.close();
}
