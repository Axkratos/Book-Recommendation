import 'package:bookrec/dummy/book.dart';

List book = books_profile;

List sortBooks(List books) {
  book.sort((a, b) => a['publication_year'].compareTo(b['publication_year']));
  return book;
}
