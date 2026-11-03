import 'package:flutter/material.dart';

import 'models/book.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key, required this.items, required this.onRemove});

  final List<Book> items;
  final void Function(Book) onRemove;

  @override
  Widget build(BuildContext context) {
    final total = items.fold(0, (sum, book) => sum + book.price);
    return Scaffold(
      appBar: AppBar(title: const Text('Your cart')),
      body: Column(
        children: [
          Expanded(
            child: items.isEmpty
                ? const Center(child: Text('Your cart is empty'))
                : ListView(
                    children: [
                      for (final book in items)
                        ListTile(
                          title: Text(book.title),
                          subtitle: Text('${book.price} ₸'),
                          trailing: IconButton(
                            tooltip: 'Remove ${book.title}',
                            onPressed: () => onRemove(book),
                            icon: const Icon(Icons.close),
                          ),
                        ),
                    ],
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Total: $total ₸',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
