import 'package:flutter/material.dart';

import 'routes.dart';

void main() => runApp(const CampusEventsApp());

class CampusEventsApp extends StatefulWidget {
  const CampusEventsApp({super.key});

  @override
  State<CampusEventsApp> createState() => _CampusEventsAppState();
}

class _CampusEventsAppState extends State<CampusEventsApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _setThemeMode(ThemeMode value) => setState(() => _themeMode = value);

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Campus Events',
    debugShowCheckedModeBanner: false,
    themeMode: _themeMode,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const ColorScheme.light().primary,
      ),
      useMaterial3: true,
    ),
    darkTheme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const ColorScheme.dark().primary,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    ),
    routes: appRoutes(themeMode: _themeMode, onThemeModeChanged: _setThemeMode),
    onGenerateRoute: onGenerateAppRoute,
    onUnknownRoute: (_) => MaterialPageRoute<void>(
      builder: (_) => const Scaffold(body: Center(child: Text('Not found'))),
    ),
  );
}
