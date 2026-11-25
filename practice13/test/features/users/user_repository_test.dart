import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:where_things_go/core/api/api_client.dart';
import 'package:where_things_go/core/api/api_exception.dart';
import 'package:where_things_go/core/storage/secure_store.dart';
import 'package:where_things_go/features/users/http_user_repository.dart';
import 'package:where_things_go/features/users/user.dart';
import 'package:where_things_go/features/users/user_repository.dart';
import 'package:where_things_go/features/users/users_cache.dart';

import '../../fixtures/user_json.dart';

class _NoTokenStore extends Fake implements SecureStore {
  @override
  Future<String?> readToken() async => null;
}

class _MemoryUsersCache extends UsersCache {
  List<User>? saved;

  @override
  Future<List<User>?> load() async => saved;

  @override
  Future<void> save(List<User> users) async => saved = List.of(users);
}

void main() {
  UserRepository repository(MockClientHandler handler, {UsersCache? cache}) {
    final client = MockClient(handler);
    final repo = HttpUserRepository(
      ApiClient(client, _NoTokenStore()),
      cache ?? _MemoryUsersCache(),
    );
    addTearDown(repo.close);
    return repo;
  }

  group('HTTP response mapping', () {
    test('404 becomes NotFoundException', () async {
      final repo = repository(
        (request) async => http.Response('{"error":"gone"}', 404),
      );
      await expectLater(repo.getById(99), throwsA(isA<NotFoundException>()));
    });

    test('500 becomes ServerException with the original status', () async {
      final repo = repository((request) async => http.Response('{}', 500));
      await expectLater(
        repo.getById(99),
        throwsA(
          isA<ServerException>().having((error) => error.status, 'status', 500),
        ),
      );
    });

    test('SocketException becomes NoConnectionException', () async {
      final repo = repository(
        (request) async => throw const SocketException('down'),
      );
      await expectLater(
        repo.getById(99),
        throwsA(isA<NoConnectionException>()),
      );
    });
  });

  test('getAll reports a numeric latitude as a bad response', () async {
    final repo = repository(
      (request) async => http.Response('[$userWithNumericLatitudeJson]', 200),
    );

    await expectLater(
      repo.getAll(),
      throwsA(
        isA<BadResponseException>().having(
          (error) => error.detail,
          'detail',
          'users: lat is not a String',
        ),
      ),
    );
  });

  test(
    'getAll falls back to its last successful response when offline',
    () async {
      var online = true;
      final repo = repository((request) async {
        if (!online) throw const SocketException('down');
        return http.Response('[$userOneJson]', 200);
      });

      final fresh = await repo.getAll();
      online = false;
      final saved = await repo.getAll();

      expect(fresh.fromCache, isFalse);
      expect(saved.fromCache, isTrue);
      expect(saved.items.single.name, 'Leanne Graham');
    },
  );
}
