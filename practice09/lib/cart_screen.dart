import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/cart.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Your cart')),
    body: Consumer<Cart>(
      builder: (context, cart, _) => Column(
        children: [
          Expanded(
            child: cart.items.isEmpty
                ? const Center(child: Text('Your cart is empty'))
                : ListView(
                    children: [
                      for (final book in cart.items)
                        ListTile(
                          title: Text(book.title),
                          subtitle: Text('${book.price} ₸'),
                          trailing: IconButton(
                            tooltip: 'Remove ${book.title}',
                            onPressed: () => cart.remove(book),
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
                  'Total: ${cart.total} ₸',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
