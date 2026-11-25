import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/storage/secure_store.dart';
import 'user.dart';
import 'widgets/user_contact_fields.dart';
import 'widgets/user_detail_field.dart';

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({super.key, required this.user});

  final User user;

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
    return Scaffold(
      appBar: AppBar(title: const Text('User details')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          UserDetailField('Name', user.name),
          UserDetailField('ID', '${user.id}'),
          UserDetailField('Username', user.username),
          UserContactFields(user: user),
          const Divider(),
          UserDetailField(
            'Address',
            [
              address.street,
              address.suite,
              address.city,
              address.zipcode,
            ].where((value) => value.isNotEmpty).join(', '),
          ),
          UserDetailField(
            'Coordinates',
            address.city.isEmpty
                ? ''
                : '${address.geo.lat}, ${address.geo.lng}',
          ),
          const Divider(),
          UserDetailField('Company', company.name),
          UserDetailField('Catchphrase', company.catchPhrase),
          UserDetailField('Business', user.companyBusiness),
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
}
