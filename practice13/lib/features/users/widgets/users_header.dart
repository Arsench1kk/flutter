import 'package:flutter/material.dart';

class UsersHeader extends StatelessWidget implements PreferredSizeWidget {
  const UsersHeader({
    super.key,
    required this.onRefresh,
    required this.onSettings,
  });

  final VoidCallback? onRefresh;
  final VoidCallback onSettings;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) => AppBar(
    title: const Text('Users'),
    actions: [
      IconButton(
        tooltip: 'Refresh users',
        onPressed: onRefresh,
        icon: const Icon(Icons.refresh),
      ),
      IconButton(
        tooltip: 'Settings',
        onPressed: onSettings,
        icon: const Icon(Icons.settings_outlined),
      ),
    ],
  );
}
