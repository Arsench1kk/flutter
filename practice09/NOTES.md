# Practice 09 notes

## Level 1 — lifted

To pass the total price down to the cart badge, I added a `total` parameter to two constructors: `BooksScreen` in `lib/books_screen.dart` and `CartBadge` in `lib/cart_badge.dart`. `lib/main.dart` calculates the total in `Shell` and passes it through `BooksScreen` to `CartBadge`.

After one Add tap, BooksScreen builds once and the six book rows are built again: 7 debug lines total (`BooksScreen build` plus six `row ...` lines). This shows the cost of lifting the cart to `Shell`: the owner rebuild marks the whole screen dirty.

## Level 2 — model without widgets

`Book` and the seed list now live in `lib/models/book.dart`. `Cart` lives in `lib/models/cart.dart` and imports only `package:flutter/foundation.dart`; it owns a private list, rejects duplicates, exposes an unmodifiable view and notifies listeners after mutations. Before the first frame, `main()` added two different books, tried the first one again, removed it, and printed `1 items, 3100 ₸`. The model needs no screen or `BuildContext` to enforce its rule.

## Level 3 — Provider

`ChangeNotifierProvider` creates one `Cart` above `MaterialApp`. The screens receive no cart parameters. `BookRow` watches whether its own book is in the cart; its Add callback uses `read`. The cart list uses `Consumer<Cart>`, where the model is already supplied to the builder. The badge watched the model at this level and showed the count and total.

Provider's loud failure when `watch` is used in an event callback is: `Tried to listen to a value exposed with provider, from outside of the widget tree.` Using `read` in the badge's build method instead gives no exception, but leaves its displayed count stale because it did not subscribe.

## Level 4 — narrow subscriptions

The cart stores quantities in a private `Map<Book, int>`. Three presses on `+` changed one book from ×1 to ×4 without changing the distinct-book count. With `watch`, the badge receives all three notifications and rebuilds three times. With `select<Cart, int>((cart) => cart.count)`, the same three quantity changes rebuild the badge zero times; removing a book changes the selected count and rebuilds it once. The cart total's `Consumer` receives a constant `Total` child, so only the changing amount is rebuilt. The cart screen keeps its show/hide-total choice locally.

## Level 5 — side effects and state placement

`BooksScreen` owns the search query because it is temporary UI state used only by that screen. The cart remains above `MaterialApp` because the book list, badge, and cart route all need the same data. The show/hide-total choice belongs to `CartScreen` because no other screen needs it. A theme mode would belong above `MaterialApp` if the whole app needed to change themes.

The Add callback uses `read` to change the cart, then shows `Added` only when `Cart.add` returns `true`. A duplicate add returns `false`, so it does not show a misleading snackbar. Clear cart first awaits a confirmation dialog; after the `await`, it checks the State's `mounted` property before using its context and clearing the model.

Two Provider mistakes have different outcomes: `watch` inside an event callback throws `Tried to listen to a value exposed with provider, from outside of the widget tree.` Using `read` in a build method does not throw, but it does not subscribe, so the badge can stay stale after the cart changes.

## Screenshots

- `screenshot_books.png` shows two distinct books added and the badge count.
- `screenshot_cart.png` shows a book quantity of 2 and its calculated total.
