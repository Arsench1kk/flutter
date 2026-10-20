import 'package:flutter/material.dart';

import '../data/seed_events.dart';
import '../models/event.dart';
import '../models/profile.dart';
import '../routes.dart';
import 'event_list_tab.dart';
import 'favorites_tab.dart';
import 'profile_tab.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late List<Event> _events;
  Profile _profile = const Profile.empty();
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _events = seedEvents(DateTime.now());
  }

  void _replaceEvent(Event changed) {
    setState(() {
      _events = [
        for (final event in _events)
          if (event.id == changed.id) changed else event,
      ];
    });
  }

  Future<void> _openEvent(Event event) async {
    final result = await Navigator.pushNamed<Event>(
      context,
      Routes.detail,
      arguments: DetailRouteArgs(
        event: event,
        profile: _profile,
        onEventChanged: _replaceEvent,
        onDelete: (id) => setState(
          () => _events = _events.where((item) => item.id != id).toList(),
        ),
        onSwitchTab: _switchTab,
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      _events = [
        for (final current in _events)
          if (current.id == result.id) result else current,
      ];
    });
  }

  Future<void> _openForm([Event? event]) async {
    final result = await Navigator.pushNamed<Event>(
      context,
      Routes.form,
      arguments: FormRouteArgs(event: event, profile: _profile),
    );
    if (result == null || !mounted) return;
    setState(() {
      final existing = _events.any((current) => current.id == result.id);
      _events = existing
          ? [
              for (final current in _events)
                if (current.id == result.id) result else current,
            ]
          : [..._events, result];
    });
  }

  void _saveProfile(Profile value) => setState(() => _profile = value);

  void _switchTab(int index) {
    if (index < 0 || index >= 3) return;
    setState(() => _selectedTab = index);
  }

  Future<void> _showAbout() => showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('About Campus Events'),
      content: const Text(
        'Browse student events, check available places and register with your profile. All information is kept in memory for this demo.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Close'),
        ),
      ],
    ),
  );

  Future<void> _confirmReset() async {
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset data?'),
        content: const Text(
          'The seed events will be restored and your profile will be cleared.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (shouldReset != true || !mounted) return;
    setState(() {
      _events = seedEvents(DateTime.now());
      _profile = const Profile.empty();
    });
  }

  Widget _currentTab() => switch (_selectedTab) {
    0 => EventListTab(
      events: _events,
      onOpen: _openEvent,
      onCreate: () => _openForm(),
      onToggleFavorite: (event) =>
          _replaceEvent(event.copyWith(favorite: !event.favorite)),
    ),
    1 => FavoritesTab(
      events: _events.where((event) => event.favorite).toList(),
      onOpen: _openEvent,
      onToggleFavorite: (event) =>
          _replaceEvent(event.copyWith(favorite: !event.favorite)),
    ),
    _ => ProfileTab(
      profile: _profile,
      events: _events,
      onSave: _saveProfile,
      themeMode: widget.themeMode,
      onThemeModeChanged: widget.onThemeModeChanged,
    ),
  };

  @override
  Widget build(BuildContext context) => Scaffold(
    drawer: Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const DrawerHeader(
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.event_available_outlined, size: 40),
                    SizedBox(height: 12),
                    Text('Campus Events'),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context);
                _showAbout();
              },
            ),
            ListTile(
              leading: const Icon(Icons.restart_alt),
              title: const Text('Reset data'),
              onTap: () {
                Navigator.pop(context);
                _confirmReset();
              },
            ),
          ],
        ),
      ),
    ),
    appBar: AppBar(
      automaticallyImplyLeading: false,
      title: Text(switch (_selectedTab) {
        0 => 'Campus events',
        1 => 'Favourites',
        _ => 'Profile',
      }),
    ),
    body: _currentTab(),
    floatingActionButton: _selectedTab == 0
        ? FloatingActionButton.extended(
            onPressed: () => _openForm(),
            icon: const Icon(Icons.add),
            label: const Text('Add event'),
          )
        : null,
    bottomNavigationBar: NavigationBar(
      selectedIndex: _selectedTab,
      onDestinationSelected: _switchTab,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.event_note_outlined),
          selectedIcon: Icon(Icons.event_note),
          label: 'Events',
        ),
        NavigationDestination(
          icon: Icon(Icons.favorite_border),
          selectedIcon: Icon(Icons.favorite),
          label: 'Favourites',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    ),
  );
}
