class Book {
  final String id;
  final String title;
  final String authors;
  final String thumbnail;
  final int publishedYear;
  final double averageRating;
  final int ratingsCount;
  final String? description;
  final String? isbn;

  Book({
    required this.id,
    required this.title,
    required this.authors,
    required this.thumbnail,
    required this.publishedYear,
    required this.averageRating,
    required this.ratingsCount,
    required this.description,
    this.isbn,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      isbn: json['isbn10'] ?? '',
      // Ensure 'isbn' is optional, so it can be null
      id: json['_id'] ?? '',
      title: json['title'] ?? 'Unknown Title',
      authors: json['authors'] ?? 'Unknown Author',
      thumbnail: json['thumbnail'] ?? '',
      publishedYear: json['published_year'] ?? 0,
      averageRating: (json['average_rating'] ?? 0).toDouble(),
      ratingsCount: json['ratings_count'] ?? 0,
      description: json['description'],
    );
  }
}
