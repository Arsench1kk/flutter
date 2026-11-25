import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/storage/secure_store.dart';
import 'features/auth/auth_model.dart';
import 'features/auth/login_screen.dart';
import 'features/profile/avatar_store.dart';
import 'features/settings/settings_model.dart';
import 'features/users/user_repository.dart';
import 'features/users/users_model.dart';
import 'users_screen.dart';

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
      child: App(storageUnavailable: storageUnavailable),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key, this.storageUnavailable = false});

  final bool storageUnavailable;

  @override
  Widget build(BuildContext context) {
    final dark = context.select((SettingsModel settings) => settings.dark);
    final signedIn = context.select((AuthModel auth) => auth.signedIn);
    const seedColor = Colors.deepPurple;
    return MaterialApp(
      key: ValueKey(signedIn),
      title: 'Survive a Restart',
      debugShowCheckedModeBanner: false,
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: seedColor)),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        ),
      ),
      home: signedIn
          ? ChangeNotifierProvider(
              create: (context) {
                final repository = UserRepository.connect(
                  context.read<SecureStore>(),
                );
                final model = UsersModel(repository);
                unawaited(model.load());
                return model;
              },
              child: const UsersScreen(),
            )
          : LoginScreen(storageUnavailable: storageUnavailable),
    );
  }
}
