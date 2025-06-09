class Book {
  final String id;
  final String title;
  final String authors;
  final String thumbnail;
  final int publishedYear;
  final double averageRating;
  final int ratingsCount;
  final String? description;

  Book({
    required this.id,
    required this.title,
    required this.authors,
    required this.thumbnail,
    required this.publishedYear,
    required this.averageRating,
    required this.ratingsCount,
    required this.description,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['_id'],
      title: json['title'],
      authors: json['authors'],
      thumbnail: json['thumbnail'],
      publishedYear: json['published_year'],
      averageRating: (json['average_rating'] as num).toDouble(),
      ratingsCount: json['ratings_count'],
      description: json['description'],
    );
  }
}