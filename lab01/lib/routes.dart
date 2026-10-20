import 'package:flutter/material.dart';

import 'models/event.dart';
import 'models/profile.dart';
import 'screens/app_shell.dart';
import 'screens/event_detail_screen.dart';
import 'screens/event_form_screen.dart';

class Routes {
  const Routes._();

  static const home = '/';
  static const detail = '/event';
  static const form = '/event/form';
}

class DetailRouteArgs {
  const DetailRouteArgs({
    required this.event,
    required this.profile,
    required this.onEventChanged,
    required this.onDelete,
    required this.onSwitchTab,
  });

  final Event event;
  final Profile profile;
  final ValueChanged<Event> onEventChanged;
  final ValueChanged<String> onDelete;
  final ValueChanged<int> onSwitchTab;
}

class FormRouteArgs {
  const FormRouteArgs({required this.event, required this.profile});

  final Event? event;
  final Profile profile;
}

Route<dynamic>? onGenerateAppRoute(RouteSettings settings) {
  switch (settings.name) {
    case Routes.detail:
      final args = settings.arguments;
      if (args is! DetailRouteArgs) return _notFoundRoute();
      return MaterialPageRoute<Event>(
        settings: settings,
        builder: (_) => EventDetailScreen(args: args),
      );
    case Routes.form:
      final args = settings.arguments;
      if (args is! FormRouteArgs) return _notFoundRoute();
      return MaterialPageRoute<Event>(
        settings: settings,
        builder: (_) => EventFormScreen(args: args),
      );
    default:
      return null;
  }
}

Route<dynamic> _notFoundRoute() => MaterialPageRoute<void>(
  builder: (_) => const Scaffold(body: Center(child: Text('Not found'))),
);

Map<String, WidgetBuilder> appRoutes({
  required ThemeMode themeMode,
  required ValueChanged<ThemeMode> onThemeModeChanged,
}) => {
  Routes.home: (_) =>
      AppShell(themeMode: themeMode, onThemeModeChanged: onThemeModeChanged),
};
