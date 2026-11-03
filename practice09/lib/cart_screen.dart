import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/cart.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _showTotal = true;

  Future<void> _confirmClear() async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear cart?'),
        content: const Text('All books will be removed from your cart.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Clear cart'),
          ),
        ],
      ),
    );
    if (!mounted || shouldClear != true) return;
    context.read<Cart>().clear();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Your cart'),
      actions: [
        IconButton(
          tooltip: 'Clear cart',
          onPressed: _confirmClear,
          icon: const Icon(Icons.delete_sweep_outlined),
        ),
        IconButton(
          tooltip: _showTotal ? 'Hide total' : 'Show total',
          onPressed: () => setState(() => _showTotal = !_showTotal),
          icon: Icon(_showTotal ? Icons.visibility_off : Icons.visibility),
        ),
      ],
    ),
    body: Column(
      children: [
        Expanded(
          child: Consumer<Cart>(
            builder: (context, cart, _) => cart.items.isEmpty
                ? const Center(child: Text('Your cart is empty'))
                : ListView(
                    children: [
                      for (final book in cart.items)
                        ListTile(
                          title: Text(book.title),
                          subtitle: Text('${book.price} ₸'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('×${cart.qtyOf(book)}'),
                              IconButton(
                                tooltip: 'Add one ${book.title}',
                                onPressed: () => cart.increment(book),
                                icon: const Icon(Icons.add_circle_outline),
                              ),
                              IconButton(
                                tooltip: 'Remove ${book.title}',
                                onPressed: () => cart.remove(book),
                                icon: const Icon(Icons.close),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
          ),
        ),
        if (_showTotal)
          Consumer<Cart>(
            child: const Text('Total'),
            builder: (context, cart, child) => SafeArea(
              top: false,
              child: ListTile(
                leading: const Icon(Icons.receipt_long_outlined),
                title: child!,
                trailing: Text('${cart.total} ₸'),
              ),
            ),
          )
        else
          const SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('Total hidden'),
            ),
          ),
      ],
    ),
  );
}
