import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'secure_store.dart';
import 'user.dart';

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({super.key, required this.user});

  final User user;

  Future<void> _openLink(BuildContext context, Uri uri) async {
    try {
      if (await launchUrl(uri)) return;
    } on PlatformException {
      // Some platform launchers throw when no handler is available.
    }
    if (context.mounted) _showMessage(context, 'No app can open this');
  }

  Future<void> _copyToken(BuildContext context) async {
    try {
      final token = await context.read<SecureStore>().readToken();
      if (!context.mounted) return;
      if (token == null) {
        _showMessage(context, 'No saved token.');
        return;
      }
      await Clipboard.setData(ClipboardData(text: token));
      if (context.mounted) _showMessage(context, 'Token copied.');
    } on PlatformException {
      if (context.mounted) _showMessage(context, 'Could not copy the token.');
    }
  }

  void _showMessage(BuildContext context, String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) {
    final address = user.address;
    final company = user.company;
    final email = user.email.trim();
    final phone = user.phoneDigits;
    final website = user.website?.trim() ?? '';
    final domain = website.replaceFirst(
      RegExp(r'^https?://', caseSensitive: false),
      '',
    );
    final websiteUri = Uri.tryParse('https://$domain');

    return Scaffold(
      appBar: AppBar(title: const Text('User details')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _field('Name', user.name),
          _field('ID', '${user.id}'),
          _field('Username', user.username),
          _field(
            'Email',
            user.email,
            onTap: email.isEmpty
                ? null
                : () => _openLink(context, Uri(scheme: 'mailto', path: email)),
          ),
          _field(
            'Phone',
            user.phone,
            onTap: phone.isEmpty
                ? null
                : () => _openLink(context, Uri(scheme: 'tel', path: phone)),
          ),
          _field(
            'Website',
            website,
            onTap: websiteUri == null || websiteUri.host.isEmpty
                ? null
                : () => _openLink(context, websiteUri),
          ),
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
          if (kDebugMode)
            Center(
              child: OutlinedButton.icon(
                onPressed: () => _copyToken(context),
                icon: const Icon(Icons.copy_outlined),
                label: const Text('Copy token to clipboard'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _field(String label, String value, {VoidCallback? onTap}) => ListTile(
    title: Text(label),
    subtitle: Text(value.isEmpty ? '—' : value),
    onTap: onTap,
    trailing: onTap == null ? null : const Icon(Icons.open_in_new),
  );
}
