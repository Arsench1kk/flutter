import 'package:flutter/material.dart';

import 'user.dart';

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final address = user.address;
    final company = user.company;
    final website = user.website ?? '';
    return Scaffold(
      appBar: AppBar(title: const Text('User details')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _field('Name', user.name),
          _field('ID', '${user.id}'),
          _field('Username', user.username),
          _field('Email', user.email),
          _field('Phone', user.phone, onTap: user.phone.isEmpty ? null : () {}),
          _field('Website', website, onTap: website.isEmpty ? null : () {}),
          const Divider(),
          _field(
            'Address',
            [
              address.street,
              address.suite,
              address.city,
              address.zipcode,
            ].where((value) => value.isNotEmpty).join(', '),
          ),
          _field(
            'Coordinates',
            address.city.isEmpty
                ? ''
                : '${address.geo.lat}, ${address.geo.lng}',
          ),
          const Divider(),
          _field('Company', company.name),
          _field('Catchphrase', company.catchPhrase),
          _field('Business', user.companyBusiness),
        ],
      ),
    );
  }

  Widget _field(String label, String value, {VoidCallback? onTap}) => ListTile(
    title: Text(label),
    subtitle: Text(value.isEmpty ? '—' : value),
    onTap: onTap,
  );
}
