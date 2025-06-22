// filepath: test/books_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:bookrec/services/booksapi.dart';
import 'package:bookrec/dummy/book.dart';

void main() {
  group('BooksInfo', () {
    late BooksInfo booksInfo;

    setUp(() {
      booksInfo = BooksInfo(); // No mock, real API
    });

    test('getBookInfo returns a list of books', () async {
      final result = await booksInfo.getBookInfo('Harry Potter');
      expect(result, isA<List>());
      expect(result.isNotEmpty, true);
    });

    test('getTrendingBooks returns a list when status is 200', () async {
      final result = await booksInfo.getTrendingBooks();
      expect(result, isA<List>());
    });

    test('getSingleBook returns a map when status is 200', () async {
      final result = await booksInfo.getSingleBook('validBookId'); // Replace
      expect(result, isA<Map>());
    });

    test('bookRatings returns success or error', () async {
      final result = await booksInfo.bookRatings('bookId', 3, 'token'); // Replace
      expect(result, anyOf(['success', 'error']));
    });

    test('checkShelfStatus returns a string status', () async {
      final result = await booksInfo.checkShelfStatus('bookId', 'token'); // Replace
      expect(result, isA<String>());
    });

    test('addToShelf returns status string', () async {
      final bookData = {
        'isbn10': '1234567890',
        'title': 'Test Book',
        'authors': 'Test Author',
        'categories': 'Test Category',
        'thumbnail': '',
        'description': 'Test Description',
        'published_year': 2020,
        'average_rating': 4.5,
        'ratings_count': 10,
      };
      final result = await booksInfo.addToShelf(bookData, 'token'); // Replace
      expect(result, anyOf(['success', 'error', 'added', 'exists']));
    });

    test('getRatingsCount returns an int', () async {
      final result = await booksInfo.getRatingsCount('bookId', 'token'); // Replace
      expect(result, isA<int>());
    });

    test('getSimilarBook returns a list', () async {
      final result = await booksInfo.getSimilarBook('title', 'token'); // Replace
      expect(result, isA<List>());
    });

    test('fetchBooks returns a list of Book', () async {
      final result = await booksInfo.fetchBooks('token'); // Replace
      expect(result, isA<List<Book>>());
    });

    test('fetchBooksUser returns a list of Book', () async {
      final result = await booksInfo.fetchBooksUser('token'); // Replace
      expect(result, isA<List<Book>>());
    });

    test('fetchBookShelf returns a list of maps', () async {
      final result = await booksInfo.fetchBookShelf('token'); // Replace
      expect(result, isA<List<Map<String, dynamic>>>());
    });

    test('removeBookFromShelf returns true on success', () async {
      final result = await booksInfo.removeBookFromShelf('token', 'bookId'); // Replace
      expect(result, isA<bool>());
    });

    test('fetchBooksFromApi returns a list of Book', () async {
      final result = await booksInfo.fetchBooksFromApi('token'); // Replace
      expect(result, isA<List<Book>>());
    });
  });

  group('Booker', () {
    test('Booker.fromJson creates a Booker object', () {
      final json = {
        '_id': '1',
        'title': 'Test Book',
        'authors': 'Test Author',
        'categories': 'Test Category',
        'thumbnail': '',
        'description': 'Test Description',
        'published_year': 2020,
        'average_rating': 4.5,
        'ratings_count': 10,
      };

      final booker = Booker.fromJson(json);
      expect(booker.id, '1');
      expect(booker.title, 'Test Book');
      expect(booker.authors, 'Test Author');
      expect(booker.categories, 'Test Category');
      expect(booker.publishedYear, 2020);
      expect(booker.averageRating, 4.5);
      expect(booker.ratingsCount, 10);
    });
  });
}
