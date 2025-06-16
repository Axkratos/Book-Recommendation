class Forum {
  final String id;
  final String userId;
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
    return Forum(
      id: json['_id'],
      userId: json['userId']['_id'],
      isbn: json['ISBN'],
      bookTitle: json['bookTitle'],
      discussionTitle: json['discussionTitle'],
      discussionBody: json['discussionBody'],
      likeCount: json['likeCount'],
      createdAt: json['createdAt'],
    );
  }
}
