import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/users/user_repository.dart';
import 'features/users/users_model.dart';
import 'features/users/users_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) {
        final users = UsersModel(UserRepository.connect());
        unawaited(users.load());
        return users;
      },
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Users',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorSchemeSeed: Colors.indigo),
    home: const UsersScreen(),
  );
}
