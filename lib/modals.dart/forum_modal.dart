class Forum {
  final String id;
  final String? userId;
  final String isbn;
  final String bookTitle;
  final String discussionTitle;
  final String discussionBody;
  final int likeCount;
  final String createdAt;

  Forum({
    required this.id,
    required this.userId,
    required this.isbn,
    required this.bookTitle,
    required this.discussionTitle,
    required this.discussionBody,
    required this.likeCount,
    required this.createdAt,
  });

  factory Forum.fromJson(Map<String, dynamic> json) {
    final userJson = json['userId'];
    final extractedUserId =
        userJson != null && userJson is Map<String, dynamic>
            ? userJson['_id'] ?? 'Unknown Author'
            : 'Unknown Author';

    return Forum(
      id: json['_id'] ?? '',
      userId: extractedUserId,
      isbn: json['ISBN'] ?? '',
      bookTitle: json['bookTitle'] ?? '',
      discussionTitle: json['discussionTitle'] ?? '',
      discussionBody: json['discussionBody'] ?? '',
      likeCount: json['likeCount'] ?? 0,
      createdAt: json['createdAt'] ?? '',
    );
  }
}
