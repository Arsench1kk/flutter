import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import 'new_user_screen.dart';
import 'user.dart';
import 'user_detail_screen.dart';
import 'users_model.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<UsersModel>();
    final body = model.loading
        ? const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading users…'),
              ],
            ),
          )
        : switch (model.error) {
            null => UserList(users: model.items, onRefresh: model.load),
            NoConnectionException() => _ErrorView(
              icon: Icons.cloud_off_outlined,
              message: 'You appear to be offline.',
              retry: model.load,
            ),
            NotFoundException() => const _ErrorView(
              icon: Icons.search_off,
              message: 'The requested resource was not found.',
            ),
            UnauthorizedException() => const _ErrorView(
              icon: Icons.lock_outline,
              message: 'This request is not authorized.',
            ),
            ServerException(:final status) => _ErrorView(
              icon: Icons.warning_amber,
              message: 'The server could not load users (HTTP $status).',
              retry: model.load,
            ),
            BadResponseException() => const _ErrorView(
              icon: Icons.error_outline,
              message: 'The server returned an unexpected response.',
            ),
          };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        actions: [
          IconButton(
            tooltip: 'Refresh users',
            onPressed: model.loading ? null : model.load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: body,
      floatingActionButton: !model.loading && model.error == null
          ? FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.of(context).push<void>(
                  MaterialPageRoute(builder: (_) => const NewUserScreen()),
                );
              },
              icon: const Icon(Icons.person_add_outlined),
              label: const Text('New user'),
            )
          : null,
    );
  }
}

class UserList extends StatelessWidget {
  const UserList({super.key, required this.users, required this.onRefresh});

  final List<User> users;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: onRefresh,
    child: ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 88),
      itemCount: users.isEmpty ? 1 : users.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        if (users.isEmpty) {
          return const ListTile(title: Text('No users yet.'));
        }
        final user = users[index];
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
          onTap: () async {
            await Navigator.of(context).push<void>(
              MaterialPageRoute(builder: (_) => UserDetailScreen(user: user)),
            );
          },
        );
      },
    ),
  );
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.icon, required this.message, this.retry});

  final IconData icon;
  final String message;
  final Future<void> Function()? retry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          if (retry case final retry?) ...[
            const SizedBox(height: 16),
            FilledButton(onPressed: retry, child: const Text('Retry')),
          ],
        ],
      ),
    ),
  );
}
