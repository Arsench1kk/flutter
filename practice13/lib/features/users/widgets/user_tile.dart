import 'package:flutter/material.dart';

import '../user.dart';

class UserTile extends StatelessWidget {
  const UserTile({super.key, required this.user, required this.onTap});

  final User user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final initial = user.name.characters.firstOrNull?.toUpperCase() ?? '?';
    return ListTile(
      leading: CircleAvatar(child: Text(initial)),
      title: Text(user.name),
      subtitle: Text(
        [
          user.email,
          user.address.city,
        ].where((value) => value.isNotEmpty).join(' · '),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
