import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:survive_restart/core/api/api_client.dart';
import 'package:survive_restart/core/api/api_exception.dart';
import 'package:survive_restart/features/profile/avatar_store.dart';
import 'package:survive_restart/features/profile/profile_screen.dart';
import 'package:survive_restart/features/settings/settings_model.dart';
import 'package:survive_restart/features/users/user.dart';
import 'package:survive_restart/features/users/user_repository.dart';
import 'package:survive_restart/features/users/users_cache.dart';
import 'package:survive_restart/features/users/users_model.dart';
import 'package:survive_restart/features/users/users_screen.dart';

class _StubApi extends Fake implements ApiClient {
  _StubApi(this.body);

  Object? body;
  ApiException? error;

  @override
  Future<Object?> get(String path) async {
    expect(path, '/users');
    if (error case final error?) throw error;
    return body;
  }

  @override
  void close() {}
}

class _OfflineRepository extends Fake implements UserRepository {
  @override
  Future<List<User>?> readCached() async => _savedUsers;

  @override
  Future<UsersResult> getAll() async => (items: _savedUsers, fromCache: true);

  @override
  void close() {}
}

class _EmptyAvatarStore extends Fake implements AvatarStore {
  @override
  Future<File?> load() async => null;
}

class _UnusedPreferences extends Fake implements SharedPreferencesAsync {}

class _AvatarPreferences extends Fake implements SharedPreferencesAsync {
  @override
  Future<String?> getString(String key) async =>
      '/old-container/Documents/avatar.jpg';
}

const _savedUsers = [
  User.draft(
    name: 'Leanne Graham',
    username: 'Bret',
    email: 'demo@example.com',
  ),
];

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  test('the saved photo resolves inside the current app container', () async {
    final documents = await Directory.systemTemp.createTemp(
      'practice12-avatar-',
    );
    addTearDown(() => documents.delete(recursive: true));
    final file = File.fromUri(documents.uri.resolve('avatar.jpg'));
    await file.writeAsString('saved photo');

    const channel = MethodChannel('plugins.flutter.io/path_provider');
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (call) async => documents.path,
    );
    addTearDown(
      () => binding.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        null,
      ),
    );
    final restored = await AvatarStore(_AvatarPreferences()).load();
    expect(restored?.path, file.path);
  });

  test(
    'a fresh repository reads last good data only for connection errors',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'practice12-test-',
      );
      addTearDown(() => directory.delete(recursive: true));

      const channel = MethodChannel('plugins.flutter.io/path_provider');
      binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
        call,
      ) async {
        expect(call.method, 'getApplicationDocumentsDirectory');
        return directory.path;
      });
      addTearDown(
        () => binding.defaultBinaryMessenger.setMockMethodCallHandler(
          channel,
          null,
        ),
      );

      const cache = UsersCache();
      final api = _StubApi([for (final user in _savedUsers) user.toJson()]);
      var repo = UserRepository(api, cache);
      api.error = const NoConnectionException();
      await expectLater(repo.getAll(), throwsA(isA<NoConnectionException>()));

      api.error = null;
      final live = await repo.getAll();
      expect(live.fromCache, isFalse);
      expect(live.items.single.name, 'Leanne Graham');

      api.error = const NoConnectionException();
      repo = UserRepository(api, const UsersCache());
      final saved = await repo.getAll();
      expect(saved.fromCache, isTrue);
      expect(saved.items.single.toJson(), live.items.single.toJson());

      api.error = const ServerException(503);
      await expectLater(repo.getAll(), throwsA(isA<ServerException>()));

      api.error = null;
      api.body = [];
      expect((await repo.getAll()).fromCache, isFalse);
      api.error = const NoConnectionException();
      final emptySaved = await repo.getAll();
      expect(emptySaved.fromCache, isTrue);
      expect(emptySaved.items, isEmpty);
    },
  );

  testWidgets('the offline banner stays visible after Retry', (tester) async {
    final model = UsersModel(_OfflineRepository());
    addTearDown(model.dispose);
    await model.load();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: model),
          ChangeNotifierProvider(
            create: (_) =>
                SettingsModel(_UnusedPreferences(), dark: false, city: null),
          ),
        ],
        child: const MaterialApp(home: UsersScreen()),
      ),
    );
    expect(find.text('Saved data · no connection'), findsOneWidget);
    expect(find.text('Leanne Graham'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Saved data · no connection'), findsOneWidget);
  });

  testWidgets('a permanent camera denial offers to open settings', (
    tester,
  ) async {
    const permissions = MethodChannel(
      'flutter.baseflow.com/permissions/methods',
    );
    var status = PermissionStatus.denied;
    var openedSettings = false;
    binding.defaultBinaryMessenger.setMockMethodCallHandler(permissions, (
      call,
    ) async {
      if (call.method == 'requestPermissions') {
        return {Permission.camera.value: status.index};
      }
      expect(call.method, 'openAppSettings');
      openedSettings = true;
      return true;
    });
    addTearDown(
      () => binding.defaultBinaryMessenger.setMockMethodCallHandler(
        permissions,
        null,
      ),
    );

    await tester.pumpWidget(
      Provider<AvatarStore>.value(
        value: _EmptyAvatarStore(),
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );
    await tester.tap(find.text('Take photo'));
    await tester.pumpAndSettle();
    expect(
      find.text('Allow camera access to take a profile photo.'),
      findsOneWidget,
    );
    expect(find.byType(AlertDialog), findsNothing);

    status = PermissionStatus.permanentlyDenied;
    await tester.tap(find.text('Take photo'));
    await tester.pumpAndSettle();
    expect(find.text('Camera access is blocked'), findsOneWidget);
    await tester.tap(find.text('Open settings'));
    await tester.pumpAndSettle();
    expect(openedSettings, isTrue);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));
}
