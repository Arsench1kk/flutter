import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/auth/auth_model.dart';
import 'features/auth/login_screen.dart';
import 'features/settings/settings_model.dart';
import 'features/users/users_model.dart';
import 'features/users/users_screen.dart';

class App extends StatelessWidget {
  const App({
    super.key,
    required this.createUsers,
    this.storageUnavailable = false,
  });

  final UsersModel Function() createUsers;
  final bool storageUnavailable;

  @override
  Widget build(BuildContext context) {
    final dark = context.select((SettingsModel settings) => settings.dark);
    final signedIn = context.select((AuthModel auth) => auth.signedIn);
    const seedColor = Colors.deepPurple;
    return MaterialApp(
      key: ValueKey(signedIn),
      title: 'Where Things Go',
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
              create: (_) => createUsers(),
              child: const UsersScreen(),
            )
          : LoginScreen(storageUnavailable: storageUnavailable),
    );
  }
}
