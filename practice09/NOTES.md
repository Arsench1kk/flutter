# Practice 09 notes

## Level 1 — lifted

To pass the total price down to the cart badge, I added a `total` parameter to two constructors: `BooksScreen` in `lib/books_screen.dart` and `CartBadge` in `lib/cart_badge.dart`. `lib/main.dart` calculates the total in `Shell` and passes it through `BooksScreen` to `CartBadge`.

After one Add tap, BooksScreen builds once and the six book rows are built again: 7 debug lines total (`BooksScreen build` plus six `row ...` lines). This shows the cost of lifting the cart to `Shell`: the owner rebuild marks the whole screen dirty.
