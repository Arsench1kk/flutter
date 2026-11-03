import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/cart.dart';

class CartBadge extends StatelessWidget {
  const CartBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<Cart>();
    return IconButton(
      tooltip: '${cart.total} ₸ in cart',
      onPressed: () => Navigator.of(context).pushNamed('/cart'),
      icon: Badge(
        label: Text('${cart.count} · ${cart.total} ₸'),
        child: const Icon(Icons.shopping_cart_outlined),
      ),
    );
  }
}
