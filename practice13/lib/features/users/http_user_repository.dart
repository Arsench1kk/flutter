import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import 'user.dart';
import 'user_repository.dart';
import 'users_cache.dart';

class HttpUserRepository implements UserRepository {
  // Explicit syntax lets the composition check count construction sites.
  // ignore: unnecessary_constructor_name
  HttpUserRepository.new(this._api, this._cache);

  final ApiClient _api;
  final UsersCache _cache;

  @override
  Future<List<User>?> readCached() => _cache.load();

  @override
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
    return [for (final item in body) _parseUser(item, 'users')];
  }

  @override
  Future<User> getById(int id) async {
    final body = await _api.get('/users/$id');
    return _parseUser(body, 'users/$id');
  }

  @override
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

  @override
  void close() => _api.close();
}
