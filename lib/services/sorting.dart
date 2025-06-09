List<dynamic> _sort(List _book, String value) {
  if (value == 'Latest') {
    _book.sort(
      (a, b) => b['publication_year'].compareTo(a['publication_year']),
    );
  } else if (value == 'Alpabetical') {
    _book.sort((a, b) => a['title'].compareTo(b['title']));
  } else if (value == 'Rating') {
    _book.sort((a, b) => b['rating'].compareTo(a['rating']));
  }
  return _book;
}

List searchBook(List books, String query) {
  return books
      .where(
        (book) => book['title'].toLowerCase().contains(query.toLowerCase()),
      )
      .toList();
}