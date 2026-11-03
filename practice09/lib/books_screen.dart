import 'package:flutter/material.dart';

import 'book_row.dart';
import 'cart_badge.dart';
import 'models/book.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Book> get _visibleBooks {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return books;
    return books
        .where(
          (book) =>
              book.title.toLowerCase().contains(query) ||
              book.author.toLowerCase().contains(query),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('BooksScreen build');
    final visibleBooks = _visibleBooks;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Books'),
        actions: const [CartBadge()],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Search books or authors',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                        icon: const Icon(Icons.clear),
                      ),
                isDense: true,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
        ),
      ),
      body: visibleBooks.isEmpty
          ? const Center(child: Text('No books match your search'))
          : ListView(
              children: [
                for (final book in visibleBooks) ...[
                  BookRow(book: book),
                  const Divider(height: 1),
                ],
              ],
            ),
    );
  }
}
