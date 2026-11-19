import 'package:http/http.dart' as http;

import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import 'user.dart';

class UserRepository {
  UserRepository(this._api);

  factory UserRepository.connect({http.Client? client}) =>
      UserRepository(ApiClient(client ?? http.Client()));

  final ApiClient _api;

  Future<List<User>> getAll() async {
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
