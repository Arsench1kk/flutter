import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/api/api_client.dart';
import 'core/storage/secure_store.dart';
import 'features/auth/auth_model.dart';
import 'features/profile/avatar_store.dart';
import 'features/settings/settings_model.dart';
// import 'features/users/fake_user_repository.dart';
import 'features/users/http_user_repository.dart';
import 'features/users/user_repository.dart';
import 'features/users/users_cache.dart';
import 'features/users/users_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = SharedPreferencesAsync();
  final dark = await prefs.getBool(SettingsModel.darkKey) ?? false;
  final city = await prefs.getString(SettingsModel.cityKey) ?? '';
  final avatarStore = AvatarStore(prefs);
  final secureStore = SecureStore();
  String? token;
  var storageUnavailable = false;
  try {
    token = await secureStore.readToken();
  } on PlatformException {
    storageUnavailable = true;
  }

  try {
    await avatarStore.recoverAndroidPhoto();
  } on PlatformException {
    // A failed picker recovery leaves the existing avatar intact.
  } on FileSystemException {
    // The profile is still usable if an interrupted pick cannot be saved.
  } on MissingPlatformDirectoryException {
    // A documents directory is required only to save the photo.
  }

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: secureStore),
        Provider.value(value: avatarStore),
        ChangeNotifierProvider(
          create: (_) => SettingsModel(
            prefs,
            dark: dark,
            city: city.isEmpty ? null : city,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthModel(secureStore, token: token),
        ),
      ],
      child: App(
        storageUnavailable: storageUnavailable,
        createUsers: () {
          // final UserRepository repo = FakeUserRepository();
          final UserRepository repo = HttpUserRepository(
            ApiClient.connect(secureStore),
            const UsersCache(),
          );
          final model = UsersModel(repo);
          unawaited(model.load());
          return model;
        },
      ),
    ),
  );
}
