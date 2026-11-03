# Practice 09 notes

## Level 1 — lifted

To pass the total price down to the cart badge, I added a `total` parameter to two constructors: `BooksScreen` in `lib/books_screen.dart` and `CartBadge` in `lib/cart_badge.dart`. `lib/main.dart` calculates the total in `Shell` and passes it through `BooksScreen` to `CartBadge`.

After one Add tap, BooksScreen builds once and the six book rows are built again: 7 debug lines total (`BooksScreen build` plus six `row ...` lines). This shows the cost of lifting the cart to `Shell`: the owner rebuild marks the whole screen dirty.

## Level 2 — model without widgets

`Book` and the seed list now live in `lib/models/book.dart`. `Cart` lives in `lib/models/cart.dart` and imports only `package:flutter/foundation.dart`; it owns a private list, rejects duplicates, exposes an unmodifiable view and notifies listeners after mutations. Before the first frame, `main()` added two different books, tried the first one again, removed it, and printed `1 items, 3100 ₸`. The model needs no screen or `BuildContext` to enforce its rule.
