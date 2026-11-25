import 'package:flutter/material.dart';

class UserDetailField extends StatelessWidget {
  const UserDetailField(this.label, this.value, {super.key, this.onTap});

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    title: Text(label),
    subtitle: Text(value.isEmpty ? '—' : value),
    onTap: onTap,
    trailing: onTap == null ? null : const Icon(Icons.open_in_new),
  );
}
