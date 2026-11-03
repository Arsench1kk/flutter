import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/book.dart';
import 'models/cart.dart';

class BookRow extends StatelessWidget {
  const BookRow({super.key, required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    debugPrint('row ${book.title}');
    final isAdded = context.watch<Cart>().items.contains(book);
    return ListTile(
      leading: CircleAvatar(child: Text(book.title.characters.first)),
      title: Text(book.title),
      subtitle: Text('${book.author} · ${book.price} ₸'),
      trailing: isAdded
          ? const Text('Added')
          : OutlinedButton(
              onPressed: () => context.read<Cart>().add(book),
              child: const Text('Add'),
            ),
    );
  }
}
