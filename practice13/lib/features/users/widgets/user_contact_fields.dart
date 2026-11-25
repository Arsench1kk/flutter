import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../user.dart';
import 'user_detail_field.dart';

class UserContactFields extends StatelessWidget {
  const UserContactFields({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final email = user.email.trim();
    final phone = user.phoneDigits;
    final website = user.website?.trim() ?? '';
    final domain = website.replaceFirst(
      RegExp(r'^https?://', caseSensitive: false),
      '',
    );
    final websiteUri = Uri.tryParse('https://$domain');
    return Column(
      children: [
        UserDetailField(
          'Email',
          user.email,
          onTap: email.isEmpty
              ? null
              : () => _openLink(context, Uri(scheme: 'mailto', path: email)),
        ),
        UserDetailField(
          'Phone',
          user.phone,
          onTap: phone.isEmpty
              ? null
              : () => _openLink(context, Uri(scheme: 'tel', path: phone)),
        ),
        UserDetailField(
          'Website',
          website,
          onTap: websiteUri == null || websiteUri.host.isEmpty
              ? null
              : () => _openLink(context, websiteUri),
        ),
      ],
    );
  }

  Future<void> _openLink(BuildContext context, Uri uri) async {
    try {
      if (await launchUrl(uri)) return;
    } on PlatformException {
      // Some platform launchers throw when no handler is available.
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No app can open this')));
    }
  }
}
