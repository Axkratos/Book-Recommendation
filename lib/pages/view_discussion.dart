import 'dart:convert';
import 'package:bookrec/provider/authprovider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart'; // To make HTTP requests

// --- Mock Data and Models (for demonstration) ---
// In your real app, these would come from your API services (like Discussapi)
// and modal files.

class Comment {
  final String id;
  final String authorName;
  final String avatarUrl;
  final String content;
  final String timeAgo;

  Comment({
    required this.id,
    required this.authorName,
    required this.avatarUrl,
    required this.content,
    required this.timeAgo,
  });
}

dynamic safeDecode(dynamic body) {
  try {
    // Keep decoding if it's a string
    while (body is String) {
      body = jsonDecode(body);
    }

    if (body is List) {
      return body;
    }
  } catch (e) {
    debugPrint("Failed to decode discussionBody: $e");
  }

  // Fallback: return default Quill delta
  return [
    {"insert": "Invalid or no content\n"},
  ];
}

// Mock API call to fetch comments for a forum post
Future<List<Comment>> fetchCommentsForForum(String forumId) async {
  // Simulate network delay
  await Future.delayed(const Duration(milliseconds: 800));
  // In a real app, you'd make an HTTP request here using forumId
  return [
    Comment(
      id: 'c1',
      authorName: 'Eleanor Vance',
      avatarUrl: 'https://i.pravatar.cc/150?u=a042581f4e29026704d',
      content:
          'A truly insightful point! I had a similar interpretation, especially regarding the protagonist\'s motivations in the third act. It changes how you see the entire narrative.',
      timeAgo: '2h ago',
    ),
    Comment(
      id: 'c2',
      authorName: 'Jasper Finch',
      avatarUrl: 'https://i.pravatar.cc/150?u=a042581f4e29026704e',
      content:
          'I disagree slightly. I believe the author was aiming for ambiguity. Have you considered the symbolism of the recurring raven motif?',
      timeAgo: '1h ago',
    ),
    Comment(
      id: 'c3',
      authorName: 'Seraphina Moon',
      avatarUrl: 'https://i.pravatar.cc/150?u=a042581f4e29026704f',
      content:
          'This discussion is fantastic. Adding this book to my list immediately!',
      timeAgo: '30m ago',
    ),
  ];
}

final String baseUrl = dotenv.env['baseUrl']!;

// Mock API call to fetch the full forum data.
// In a real app, you'd use your existing `Discussapi` and `Forum` modal.
Future<Map<String, dynamic>> fetchForumDetails(
  String forumId,
  String token,
) async {
  final String url =
      '${baseUrl}/api/v1/users/forums/$forumId'; // Replace with actual base URL
  print('Fetching forum details from: $url');
  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'Bearer ${token}', // Replace with actual token if required
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      final data = json['data'];
      final content = safeDecode(data['discussionBody']);

      // Build the required format
      return {
        'id': data['_id'],
        'title': data['discussionTitle'],
        'book': data['bookTitle'],
        'author': 'Anonymous', // You can adjust if user info is needed
        'cover': 'https://covers.openlibrary.org/b/isbn/${data["ISBN"]}-M.jpg',
        'content': content,
        'upvotes': data['likeCount'].toString(),
        'timeAgo': timeAgoFromIso(data['createdAt']), // Helper for formatting
      };
    } else {
      throw Exception('Failed to load forum details');
    }
  } catch (e) {
    debugPrint('Error fetching forum details: $e');
    rethrow;
  }
}

String timeAgoFromIso(String isoDate) {
  final date = DateTime.parse(isoDate);
  final diff = DateTime.now().difference(date);

  if (diff.inDays >= 1)
    return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
  if (diff.inHours >= 1)
    return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
  if (diff.inMinutes >= 1)
    return '${diff.inMinutes} minute${diff.inMinutes > 1 ? 's' : ''} ago';
  return 'just now';
}

// --- End of Mock Data ---

// --- UI Colors and Styles (you can move these to a theme file) ---
const Color vintagePrimaryText = Color(0xFF5D4037);
const Color vintageBackground = Color(0xFFF5EFE6);
const Color vintageCardBackground = Color(0xFFFEFDF9);
const Color vintageSecondaryText = Color(0xFF8D6E63);
const Color vintageAccent = Color(0xFFBF896F);
const Color vintageDivider = Color(0xFFD7CCC8);

// --- The Detail Page Widget ---

class ForumDetailPage extends StatefulWidget {
  final String forumId;
  const ForumDetailPage({Key? key, required this.forumId}) : super(key: key);

  @override
  State<ForumDetailPage> createState() => _ForumDetailPageState();
}

class _ForumDetailPageState extends State<ForumDetailPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _forumData;
  List<Comment> _comments = [];

  final _commentController = TextEditingController();
  late final quill.QuillController _quillController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final providerUser = Provider.of<UserProvider>(context, listen: false);
      setState(() {
        _loadData(providerUser.token);
      });
    });
    //_loadData();
  }

  Future<void> _loadData(String token) async {
    setState(() => _isLoading = true);
    // Fetch forum details and comments in parallel
    final results = await Future.wait([
      fetchForumDetails(
        widget.forumId,
        token,
      ), // Replace with your real API call
      fetchCommentsForForum(widget.forumId), // Replace with your real API call
    ]);

    _forumData = results[0] as Map<String, dynamic>;
    _quillController = quill.QuillController(
      document: quill.Document.fromJson(_forumData!['content']),
      selection: const TextSelection.collapsed(offset: 0),
    );

    if (mounted) {
      setState(() {
        _comments = results[1] as List<Comment>;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _quillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: vintageBackground,
      // Using a custom scroll view for more complex layouts if needed
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: vintagePrimaryText),
              )
              : CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    backgroundColor: vintageBackground,
                    elevation: 1,
                    shadowColor: vintageDivider,
                    leading: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: vintagePrimaryText,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    title: Text(
                      _forumData?['book'] ?? 'Discussion',
                      style: GoogleFonts.montserrat(
                        color: vintagePrimaryText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Center(
                      // This is the key to responsiveness. It centers the content
                      // and gives it a max width on larger screens.
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 900),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24.0,
                            vertical: 20.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildForumHeader(),
                              const SizedBox(height: 20),
                              _buildQuillContent(),
                              const SizedBox(height: 30),
                              const VintageDivider(),
                              _buildCommentInputField(),
                              const SizedBox(height: 30),
                              const VintageDivider(),
                              _buildCommentsSection(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildForumHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _forumData?['title'] ?? 'No Title',
          style: GoogleFonts.merriweather(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: vintagePrimaryText,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundColor: vintageAccent,
              child: Icon(Icons.person, size: 20, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Text(
              'Posted by ${_forumData?['author'] ?? 'Unknown'} • ${_forumData?['timeAgo'] ?? ''}',
              style: GoogleFonts.montserrat(
                color: vintageSecondaryText,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuillContent() {
    return quill.QuillEditor.basic(
      controller: _quillController,
      config: quill.QuillEditorConfig(
        showCursor: false,
        customStyles: quill.DefaultStyles(
          paragraph: quill.DefaultTextBlockStyle(
            GoogleFonts.merriweather(
              fontSize: 14,
              color: vintagePrimaryText,
              height: 1.5,
            ),
            quill.HorizontalSpacing.zero,
            quill.VerticalSpacing.zero,
            quill.VerticalSpacing.zero,
            null,
          ),
        ),
        scrollable: false,
      ),
    );
  }

  Widget _buildCommentInputField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Leave a Comment',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: vintagePrimaryText,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _commentController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Share your thoughts...',
              hintStyle: GoogleFonts.merriweather(
                color: vintageSecondaryText.withOpacity(0.7),
              ),
              filled: true,
              fillColor: vintageCardBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: vintageDivider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: vintageDivider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: vintageAccent, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Implement comment posting logic
                debugPrint('Posting comment: ${_commentController.text}');
                _commentController.clear();
                // Show a snackbar or refresh comments list
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: vintagePrimaryText,
                    content: Text(
                      'Comment posted!',
                      style: GoogleFonts.montserrat(color: Colors.white),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: vintagePrimaryText,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                textStyle: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Post Comment'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Comments (${_comments.length})',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: vintagePrimaryText,
            ),
          ),
          const SizedBox(height: 20),
          // Using ListView.separated for dividers between comments
          ListView.separated(
            itemCount: _comments.length,
            shrinkWrap: true, // Important inside a CustomScrollView
            physics: const NeverScrollableScrollPhysics(), // Also important
            itemBuilder: (context, index) {
              final comment = _comments[index];
              return CommentWidget(comment: comment);
            },
            separatorBuilder:
                (context, index) => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: VintageDivider(),
                ),
          ),
        ],
      ),
    );
  }
}

// A dedicated widget for a single comment
class CommentWidget extends StatelessWidget {
  final Comment comment;
  const CommentWidget({Key? key, required this.comment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage(comment.avatarUrl),
          backgroundColor: vintageDivider,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    comment.authorName,
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      color: vintagePrimaryText,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '• ${comment.timeAgo}',
                    style: GoogleFonts.montserrat(
                      color: vintageSecondaryText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                comment.content,
                style: GoogleFonts.merriweather(
                  color: vintagePrimaryText.withOpacity(0.9),
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// A custom divider with vintage style
class VintageDivider extends StatelessWidget {
  const VintageDivider({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Divider(color: vintageDivider.withOpacity(0.7), height: 1);
  }
}
