import 'package:flutter/material.dart';

import '../../../core/api/api_exception.dart';
import '../user.dart';
import 'user_tile.dart';
import 'users_empty_view.dart';
import 'users_error_view.dart';

class UsersBody extends StatelessWidget {
  const UsersBody({
    super.key,
    required this.loading,
    required this.error,
    required this.items,
    required this.city,
    required this.onRefresh,
    required this.onOpenUser,
  });

  final bool loading;
  final ApiException? error;
  final List<User> items;
  final String? city;
  final Future<void> Function() onRefresh;
  final ValueChanged<User> onOpenUser;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading users…'),
          ],
        ),
      );
    }
    if (error case final error?) {
      return UsersErrorView(error: error, onRetry: onRefresh);
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 88),
        itemCount: items.isEmpty ? 1 : items.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (_, index) {
          if (items.isEmpty) return UsersEmptyView(city: city);
          final user = items[index];
          return UserTile(user: user, onTap: () => onOpenUser(user));
        },
      ),
    );
  }
}
