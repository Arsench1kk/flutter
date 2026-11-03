import 'package:flutter/material.dart';

import 'book_row.dart';
import 'cart_badge.dart';
import 'models/book.dart';

class BooksScreen extends StatelessWidget {
  const BooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('BooksScreen build');
    return Scaffold(
      appBar: AppBar(title: const Text('Books'), actions: const [CartBadge()]),
      body: ListView(
        children: [
          for (final book in books) ...[
            BookRow(book: book),
            const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}
