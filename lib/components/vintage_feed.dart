import 'dart:convert';
import 'package:bookrec/provider/authprovider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

const Color vintagePrimaryText = Color(0xFF5D4037);
const Color vintageBackground = Color(0xFFF5EFE6);
const Color vintageCardBackground = Colors.white;
const Color vintageSecondaryText = Colors.brown;
const Color vintageIconColor = Colors.brown;
const Color vintageAccent = Colors.orange;

class VintageFeedCard extends StatefulWidget {
  final Map<String, dynamic> reviewData;

  const VintageFeedCard({super.key, required this.reviewData});

  @override
  State<VintageFeedCard> createState() => _VintageFeedCardState();
}

class _VintageFeedCardState extends State<VintageFeedCard> {
  final String baseUrl = dotenv.env['baseUrl']!;

  late quill.QuillController _quillController;
  bool _isLiked = false;
  int _likeCount = 0;
  bool _isLiking = false;

  @override
  void initState() {
    super.initState();
    _quillController = quill.QuillController(
      document: quill.Document.fromJson(widget.reviewData['content']),
      selection: const TextSelection.collapsed(offset: 0),
    );
    _likeCount =
        int.tryParse(widget.reviewData['upvotes'].replaceAll('K', '000')) ?? 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final providerUser = Provider.of<UserProvider>(context, listen: false);
      setState(() {
        _fetchLikeStatus(providerUser.token);
      });
    });
  }

  Future<void> _fetchLikeStatus(String token) async {
    final String forumId = widget.reviewData['id'] ?? '';
    final String apiUrl = '${baseUrl}/api/v1/books/forum/like/status/$forumId';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'content-type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _isLiked = data['liked'] ?? false;
          _likeCount = data['likeCount'] ?? _likeCount;
        });
      }
    } catch (e) {
      debugPrint('Error fetching like status: $e');
    }
  }

  Future<void> _toggleLike(String token) async {
    if (_isLiking) return; // Prevent spamming
    setState(() => _isLiking = true);

    final String forumId = widget.reviewData['id'] ?? '';
    final String apiUrl = '${baseUrl}/api/v1/books/forum/like/$forumId';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'content-type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _isLiked = data['liked'];
          _likeCount = data['likeCount'];
        });
      }
    } catch (e) {
      debugPrint('Error toggling like: $e');
    } finally {
      setState(() => _isLiking = false);
    }
  }

  @override
  void dispose() {
    _quillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String bookTitle = widget.reviewData['book'] ?? 'Unknown Book';
    final String coverUrl = widget.reviewData['cover'] ?? '';
    final String postTitle = widget.reviewData['title'] ?? 'No Title';
    final String timeAgo = widget.reviewData['timeAgo'] ?? '';
    final String reason = widget.reviewData['reason'] ?? '';
    final String commentsCount = widget.reviewData['comments'] ?? '0';

    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      color: vintageCardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBar(coverUrl, bookTitle, timeAgo, reason),
            const SizedBox(height: 10),
            Text(
              postTitle,
              style: GoogleFonts.merriweather(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: vintagePrimaryText,
              ),
            ),
            const SizedBox(height: 8),
            _buildQuillContent(),
            const SizedBox(height: 12),
            _buildActionBar(commentsCount),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(
    String coverUrl,
    String bookTitle,
    String timeAgo,
    String reason,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 30,
          height: 30,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4.0),
            child: Image.network(
              coverUrl,
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) =>
                      const Icon(Icons.book, color: vintageAccent),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(color: Colors.grey[300]);
              },
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                bookTitle,
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: vintagePrimaryText,
                ),
              ),
              if (timeAgo.isNotEmpty || reason.isNotEmpty)
                Text(
                  (timeAgo.isNotEmpty ? '$timeAgo • ' : '') + reason,
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    color: vintageSecondaryText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: vintageAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            textStyle: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            minimumSize: const Size(60, 30),
          ),
          child: const Text('Join'),
        ),
        SizedBox(
          width: 30,
          child: IconButton(
            icon: const Icon(Icons.more_horiz, color: vintageIconColor),
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {},
          ),
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

  Widget _buildActionBar(String commentsCount) {
    final ProviderUser = Provider.of<UserProvider>(context);

    return Row(
      children: [
        _actionButton(
          _isLiked ? Icons.favorite : Icons.favorite_border,
          _likeCount.toString(),
          () => _toggleLike(ProviderUser.token),
        ),
        const SizedBox(width: 4),
        _actionButton(Icons.arrow_downward_outlined, null, () {}, iconSize: 20),
        const SizedBox(width: 12),
        _actionButton(Icons.mode_comment_outlined, commentsCount, () {}),
        const SizedBox(width: 12),
        _actionButton(
          Icons.bookmark_border_outlined,
          'Save',
          () {},
          isSave: true,
        ),
        const SizedBox(width: 12),
        _actionButton(Icons.share_outlined, 'Share', () {}),
      ],
    );
  }

  Widget _actionButton(
    IconData icon,
    String? text,
    VoidCallback onPressed, {
    double iconSize = 22,
    bool isSave = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: iconSize, color: vintageIconColor),
              if (text != null) ...[
                const SizedBox(width: 5),
                Text(
                  text,
                  style: GoogleFonts.montserrat(
                    color: vintageSecondaryText,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
