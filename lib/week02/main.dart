import 'catalogue.dart';
import 'data.dart';
import 'models.dart';
import 'shelf_state.dart';

void main() {
  final books = rawBooks
      .map(Book.fromJson)
      .toList();

  final library = Library();

  for (final book in books) {
    library.add(book);
  }

  print('=== REPORT ===');
  print(library.report);

  print('\n=== TITLES ===');
  print(library.titles);

  print('\n=== BOOKS AFTER 2010 ===');
  print(
    library.booksAfter2010
        .map((book) => book.title)
        .toList(),
  );

  print('\n=== AVERAGE PAGES ===');
  print(library.averagePageCount);

  print('\n=== BOOKS BY AUTHOR ===');
  print(library.booksByAuthor);

  print('\n=== AUTHORS ===');
  print(library.authorNames);

  print('\n=== GENRES ===');
  print(
    library.genres
        .map((genre) => genre.label)
        .toSet(),
  );

  print('\n=== DISPLAY LIST ===');
  for (final line in library.displayList) {
    print(line);
  }

  print('\n=== COUNTRY ===');
  print('Clean Code: ${library.countryOf('Clean Code')}');
  print('Design Patterns: ${library.countryOf('Design Patterns')}');
  print('Unknown Book: ${library.countryOf('Unknown Book')}');

  print('\n=== RECORD ===');
  final stats = statsOf(books);
  print('Count: ${stats.count}');
  print('Average pages: ${stats.avgPages}');

  print('\n=== SHELF STATES ===');

  final states = <ShelfState>[
    Empty(),
    Ready(books),
    Broken('Catalogue file is corrupted'),
  ];

  for (final state in states) {
    print(describe(state));
  }
}
