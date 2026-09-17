import 'models.dart';

class Library {
  final List<LibraryItem> items;

  Library({
    List<LibraryItem>? items,
  }) : items = items ?? [];

  void add(LibraryItem item) {
    items.add(item);
  }

  Book? findByTitle(String title) {
    for (final item in items) {
      if (item is Book && item.title == title) {
        return item;
      }
    }

    return null;
  }

  String countryOf(String title) {
    return findByTitle(title)?.author.country ?? 'unknown';
  }

  late final DateTime openedAt;

  void open() {
    openedAt = DateTime.now();
  }

  String? _cachedReport;

  String get report {
    return _cachedReport ??= _buildReport();
  }

  String _buildReport() {
    return items.map((item) => item.describe()).join('\n');
  }

  List<String> get titles =>
      items.map((item) => item.title).toList();

  List<Book> get booksAfter2010 =>
      items.whereType<Book>().where((book) => book.year > 2010).toList();

  double get averagePageCount {
    final books = items.whereType<Book>().toList();

    if (books.isEmpty) {
      return 0;
    }

    final totalPages = books.fold(
      0,
          (total, book) => total + book.pages,
    );

    return totalPages / books.length;
  }

  Map<String, int> get booksByAuthor {
    return items.whereType<Book>().fold(
      <String, int>{},
          (result, book) {
        result[book.author.name] =
            (result[book.author.name] ?? 0) + 1;
        return result;
      },
    );
  }

  Set<String> get authorNames =>
      items.whereType<Book>().map((book) => book.author.name).toSet();

  Set<Genre> get genres =>
      items.whereType<Book>().map((book) => book.genre).toSet();

  List<String> get displayList => [
    'CATALOGUE',
    ...items.whereType<Book>().map(
          (book) => '${book.title} (${book.year})',
    ),
    ...authorNames,
    if (items.whereType<Book>().any((book) => book.pages == 0))
      '(incomplete data)',
  ];
}
