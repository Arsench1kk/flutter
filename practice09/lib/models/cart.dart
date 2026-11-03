import 'package:flutter/foundation.dart';

import 'book.dart';

class Cart extends ChangeNotifier {
  final Map<Book, int> _qty = {};

  List<Book> get items => List.unmodifiable(_qty.keys);

  int get count => _qty.length;

  int get total =>
      _qty.entries.fold(0, (sum, entry) => sum + entry.key.price * entry.value);

  int qtyOf(Book book) => _qty[book] ?? 0;

  bool add(Book book) {
    if (_qty.containsKey(book)) return false;
    _qty[book] = 1;
    notifyListeners();
    return true;
  }

  void remove(Book book) {
    _qty.remove(book);
    notifyListeners();
  }

  void increment(Book book) {
    final quantity = _qty[book];
    if (quantity == null) return;
    _qty[book] = quantity + 1;
    notifyListeners();
  }

  void clear() {
    _qty.clear();
    notifyListeners();
  }
}
