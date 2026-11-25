import 'package:flutter/material.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({
    super.key,
    required this.loading,
    required this.onRetry,
  });

  final bool loading;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => MaterialBanner(
    leading: const Icon(Icons.cloud_off_outlined),
    content: Text(
      loading
          ? 'Saved data · checking connection'
          : 'Saved data · no connection',
    ),
    actions: [
      TextButton(
        onPressed: loading ? null : onRetry,
        child: const Text('Retry'),
      ),
    ],
  );
}
