import 'package:flutter/material.dart';

class UsersEmptyView extends StatelessWidget {
  const UsersEmptyView({super.key, this.city});

  final String? city;

  @override
  Widget build(BuildContext context) => ListTile(
    title: Text(city == null ? 'No users yet.' : 'No users in $city.'),
  );
}
