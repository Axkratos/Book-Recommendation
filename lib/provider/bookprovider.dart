import 'package:bookrec/modals.dart/book_modal.dart';
import 'package:flutter/material.dart';

class Bookprovider extends ChangeNotifier {
  List<Book> _books = [];
  List<Book> get books => _books;
  set books(List<Book> newBooks) {
    _books = newBooks;
    notifyListeners();
  }
}
