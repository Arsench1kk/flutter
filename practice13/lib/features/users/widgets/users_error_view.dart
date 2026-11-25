import 'package:flutter/material.dart';

import '../../../core/api/api_exception.dart';

class UsersErrorView extends StatelessWidget {
  const UsersErrorView({super.key, required this.error, required this.onRetry});

  final ApiException error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final (icon, message, canRetry) = switch (error) {
      NoConnectionException() => (
        Icons.cloud_off_outlined,
        'No connection',
        true,
      ),
      NotFoundException() => (
        Icons.search_off,
        'The requested resource was not found.',
        false,
      ),
      UnauthorizedException() => (
        Icons.lock_outline,
        'This request is not authorized.',
        false,
      ),
      ServerException(:final status) => (
        Icons.warning_amber,
        'The server could not load users (HTTP $status).',
        true,
      ),
      BadResponseException() => (
        Icons.error_outline,
        'The server returned an unexpected response.',
        false,
      ),
    };
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            if (canRetry) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ],
        ),
      ),
    );
  }
}
