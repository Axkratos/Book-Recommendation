import 'package:bookrec/components/VintageBookCard.dart' as VintageBookCard;
import 'package:bookrec/components/similarBooks/similarBookSection.dart';
//import 'package:bookrec/dummy/book.dart';
import 'package:bookrec/provider/authprovider.dart';
import 'package:bookrec/services/booksapi.dart';
import 'package:bookrec/services/discussApi.dart'; // <-- Add this import
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BookAndSimilar extends StatefulWidget {
  final String bookId;
  final String title;
  const BookAndSimilar({super.key, required this.bookId, required this.title});

  @override
  State<BookAndSimilar> createState() => _BookAndSimilarState();
}

class _BookAndSimilarState extends State<BookAndSimilar> {
  BooksInfo booksInfo = BooksInfo();
  late Future<Map<String, dynamic>> bookDetails;

  @override
  void initState() {
    super.initState();
    bookDetails = fetchBookDetails(widget.bookId);
    print('Book ID: ${widget.bookId}');
  }

  @override
  void didUpdateWidget(covariant BookAndSimilar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bookId != widget.bookId) {
      setState(() {
        bookDetails = fetchBookDetails(widget.bookId);
      });
    }
  }

  Future<Map<String, dynamic>> fetchBookDetails(String bookId) async {
    final data = await booksInfo.getSingleBook(bookId);
    return data['book'];
  }

  Future<List<Map<String, dynamic>>> similar_books(
    String title,
    String token,
  ) async {
    final similarBook = await booksInfo.getSimilarBook(title, token);
    print('Similar books fetched: ${similarBook[1]}');
    return similarBook;
  }

  @override
  Widget build(BuildContext context) {
    final ProviderUser = Provider.of<UserProvider>(context);

    return FutureBuilder<Map<String, dynamic>>(
      future: bookDetails,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('No book details found.'));
        } else {
          final book_info = snapshot.data!;
          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 900) {
                // Desktop Layout
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 100),
                  child: ListView(
                    children: [
                      Container(
                        //height: 1100,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Flexible ensures the Vintage card doesn't cause overflow
                            Flexible(
                              flex: 5, // Give more space to the book card
                              child: VintageBookCard.Vintagebookcard(
                                book: Map<String, dynamic>.from(book_info),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              flex: 2, // Less space for the similar books list
                              child: FutureBuilder<List<Map<String, dynamic>>>(
                                future: similar_books(
                                  widget.title,
                                  ProviderUser.token,
                                ),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  } else if (snapshot.hasData &&
                                      snapshot.data!.isNotEmpty) {
                                    return Container(
                                      height: 700, // Fixed height for desktop
                                      child: SimilarBooksSection(
                                        isSmallScreen: false,
                                        similarBooks: snapshot.data ?? [],
                                      ),
                                    );
                                  }
                                  // Gracefully handle error or no data
                                  return const Center(
                                    child: Text('No similar books found.'),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      // --- 2. ADD COMMENTS SECTION for desktop ---
                      CommentsSection(bookId: widget.bookId),
                      const SizedBox(height: 50), // Bottom padding
                    ],
                  ),
                );
              } else {
                // Mobile Layout
                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  children: [
                    VintageBookCard.Vintagebookcard(
                      book: Map<String, dynamic>.from(book_info),
                    ),
                    const SizedBox(height: 30),
                    // Fetch and display similar books for mobile as well
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: similar_books(widget.title, ProviderUser.token),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                          return SimilarBooksSection(
                            isSmallScreen: true,
                            similarBooks: snapshot.data ?? [],
                          );
                        }
                        return const SizedBox.shrink(); // Don't show if empty or error
                      },
                    ),
                    const SizedBox(height: 30),
                    // --- 3. ADD COMMENTS SECTION for mobile ---
                    CommentsSection(bookId: widget.bookId),
                    const SizedBox(height: 30), // Bottom padding
                  ],
                );
              }
            },
          );
        }
      },
    );
  }
}

class Comment {
  final String avatarUrl;
  final String username;
  final String text;
  final String timestamp;
  final String id;
  final bool reviewed;

  Comment({
    required this.id,
    required this.avatarUrl,
    required this.username,
    required this.text,
    required this.timestamp,
    required this.reviewed,
  });
}

class CommentsSection extends StatefulWidget {
  final String bookId;

  const CommentsSection({super.key, required this.bookId});

  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  final TextEditingController _commentController = TextEditingController();

  List<Comment> _comments = [];
  final String baseUrl = dotenv.env['baseUrl']!;

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.token;
    final url = Uri.parse(
      '$baseUrl/api/v1/books/review/book/${widget.bookId}?page=1&limit=10',
    );
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        print('Fetch comments response: ${response.body}');
        print('response: ${response.body}');
        final data = jsonDecode(response.body);
        final reviews = data['data']['reviews'] as List;
        setState(() {
          _comments =
              reviews.map((review) {
                print('reviewed?: ${review['reviewed']}');
                return Comment(
                  id: review['_id'] ?? '',
                  reviewed: review['reviewed'] ?? false,
                  avatarUrl:
                      'https://i.pravatar.cc/150?u=${review['userName']}',
                  username: review['userName'] ?? 'Anonymous',
                  text: review['review'] ?? '',
                  timestamp: _formatTimestamp(review['createdAt']),
                );
              }).toList();
        });
      }
    } catch (e) {
      // Optionally handle error
    }
  }

  String _formatTimestamp(String isoString) {
    final date = DateTime.tryParse(isoString);
    if (date == null) return '';
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays > 0)
      return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    if (diff.inHours > 0)
      return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    if (diff.inMinutes > 0)
      return '${diff.inMinutes} minute${diff.inMinutes > 1 ? 's' : ''} ago';
    return 'Just now';
  }

  Future<void> _addComment() async {
    final reviewText = _commentController.text.trim();
    if (reviewText.isEmpty) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.token;
    final isbn = widget.bookId;

    final url = Uri.parse('$baseUrl/api/v1/books/review');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'isbn': isbn, 'review': reviewText}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _commentController.clear();
        FocusScope.of(context).unfocus();
        await _fetchComments(); // Refresh comments after posting
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your comment has been posted!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to post comment.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deleteComment(String commentId) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.token;
    final url = Uri.parse('$baseUrl/api/v1/books/review/$commentId');
    try {
      final response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      print('Delete response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 204) {
        await _fetchComments();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comment deleted.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete comment.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // Add this helper to show the report dialog and call the API
  Future<void> _reportComment(String commentId) async {
    final TextEditingController _reasonController = TextEditingController();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.token;

    final reason = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Report Comment'),
            content: TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                hintText: 'Enter reason for reporting',
              ),
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed:
                    () => Navigator.pop(context, _reasonController.text.trim()),
                child: const Text(
                  'Report',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (reason != null && reason.isNotEmpty) {
      try {
        final response = await Discussapi().report(
          forumId: commentId, // Use commentId as targetId
          reporterId: '6846b8f560df1b854262a69c',
          token: token,
          content: reason,
          type: 'review', // Indicate this is a review/report
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reported successfully.'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Text(
            'Reader Reviews & Comments',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),

          // "Add a comment" input field
          _buildAddCommentField(),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24.0),
            child: Divider(),
          ),

          // List of comments
          ListView.separated(
            shrinkWrap: true, // Crucial for nesting in another scroll view
            physics:
                const NeverScrollableScrollPhysics(), // Disables this ListView's scrolling
            itemCount: _comments.length,
            itemBuilder: (context, index) {
              final comment = _comments[index];
              return Stack(
                children: [
                  _CommentTile(
                    comment: comment,
                    onReport: () => _reportComment(comment.id), // Pass callback
                  ),
                  if (comment.reviewed)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                          size: 20,
                        ),
                        tooltip: 'Delete your comment',
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: const Text('Delete Comment'),
                                  content: const Text(
                                    'Are you sure you want to delete this comment?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(context, true),
                                      child: const Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                          );
                          if (confirm == true) {
                            await _deleteComment(comment.id);
                          }
                        },
                      ),
                    ),
                ],
              );
            },
            separatorBuilder: (context, index) => const Divider(height: 32),
          ),
        ],
      ),
    );
  }

  // Helper widget for the text input field and submit button
  Widget _buildAddCommentField() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(
          child: Icon(Icons.person_outline),
          backgroundColor: Color.fromARGB(255, 230, 230, 230),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: _commentController,
            maxLines: null, // Makes the text field expandable
            decoration: InputDecoration(
              hintText: 'Share your thoughts on this book...',
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.send_rounded),
          onPressed: _addComment,
          tooltip: 'Submit Comment',
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

// Helper widget to display a single comment cleanly
class _CommentTile extends StatelessWidget {
  final Comment comment;
  final VoidCallback? onReport;
  const _CommentTile({required this.comment, this.onReport});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(backgroundImage: NetworkImage(comment.avatarUrl)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    comment.username,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '• ${comment.timestamp}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const Spacer(),
                  if (onReport != null)
                    IconButton(
                      icon: const Icon(
                        Icons.flag,
                        color: Colors.orange,
                        size: 20,
                      ),
                      tooltip: 'Report comment',
                      onPressed: onReport,
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                comment.text,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
