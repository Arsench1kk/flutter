import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../settings/settings_model.dart';
import '../settings/settings_screen.dart';
import 'new_user_screen.dart';
import 'user.dart';
import 'user_detail_screen.dart';
import 'users_model.dart';
import 'widgets/offline_banner.dart';
import 'widgets/users_body.dart';
import 'widgets/users_header.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<UsersModel>();
    final city = context.select((SettingsModel? settings) => settings?.city);
    final items = city == null
        ? model.items
        : model.items.where((user) => user.address.city == city).toList();

    return Scaffold(
      appBar: UsersHeader(
        onRefresh: model.loading ? null : model.load,
        onSettings: () => _openSettings(context, model),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            if (model.fromCache)
              OfflineBanner(loading: model.loading, onRetry: model.load),
            Expanded(
              child: UsersBody(
                loading: model.loading && !model.fromCache,
                error: model.error,
                items: items,
                city: city,
                onRefresh: model.load,
                onOpenUser: (user) => _openUser(context, user),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton:
          !model.loading && !model.fromCache && model.error == null
          ? FloatingActionButton.extended(
              onPressed: () => _openNewUser(context),
              icon: const Icon(Icons.person_add_outlined),
              label: const Text('New user'),
            )
          : null,
    );
  }

  Future<void> _openSettings(BuildContext context, UsersModel model) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: model,
          child: const SettingsScreen(),
        ),
      ),
    );
  }

  Future<void> _openUser(BuildContext context, User user) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => UserDetailScreen(user: user)),
    );
  }

  Future<void> _openNewUser(BuildContext context) async {
    await Navigator.of(context)
        .push<void>(MaterialPageRoute(builder: (_) => const NewUserScreen()));
  }
}
