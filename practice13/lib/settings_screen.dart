import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'features/auth/auth_model.dart';
import 'profile_screen.dart';
import 'users_model.dart';
import 'settings_model.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _signingOut = false;

  Future<void> _signOut() async {
    if (_signingOut) return;
    final auth = context.read<AuthModel>();
    setState(() => _signingOut = true);
    try {
      await auth.logout();
    } on PlatformException {
      if (mounted) _showMessage('Could not remove your saved session.');
    } finally {
      if (mounted) setState(() => _signingOut = false);
    }
  }

  Future<void> _saveSetting(Future<void> write) async {
    try {
      await write;
    } on PlatformException {
      if (mounted) _showMessage('Could not save this setting on the device.');
    }
  }

  void _showMessage(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsModel>();
    final cities = context.watch<UsersModel>().cities;
    final currentCity = settings.city;
    if (currentCity != null && !cities.contains(currentCity)) {
      cities.add(currentCity);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark mode'),
            value: settings.dark,
            onChanged: (value) => _saveSetting(settings.setDark(value)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: DropdownButtonFormField<String>(
              initialValue: currentCity ?? '',
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'City filter'),
              items: [
                const DropdownMenuItem(value: '', child: Text('All cities')),
                for (final city in cities)
                  DropdownMenuItem(value: city, child: Text(city)),
              ],
              onChanged: (value) =>
                  _saveSetting(settings.setCity(value == '' ? null : value)),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.account_circle_outlined),
            title: const Text('Profile'),
            onTap: () async {
              await Navigator.of(context).push<void>(
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign out'),
            enabled: !_signingOut,
            onTap: _signingOut ? null : _signOut,
          ),
        ],
      ),
    );
  }
}
