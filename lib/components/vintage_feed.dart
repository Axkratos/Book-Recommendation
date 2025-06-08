import 'package:bookrec/dummy/reviews.dart';
import 'package:bookrec/theme/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:google_fonts/google_fonts.dart';

// Define the missing color if not imported from theme/color.dart
const Color vintagePrimaryText = Color(0xFF5D4037);
const Color vintageBackground = Color(0xFFF5EFE6);
const Color vintageCardBackground = Colors.white;

class VintageFeedCard extends StatefulWidget {
  final Map<String, dynamic> reviewData;

  const VintageFeedCard({super.key, required this.reviewData});

  @override
  State<VintageFeedCard> createState() => _VintageFeedCardState();
}

class _VintageFeedCardState extends State<VintageFeedCard> {
  late quill.QuillController _quillController;

  @override
  void initState() {
    super.initState();
    _quillController = quill.QuillController(
      document: quill.Document.fromJson(widget.reviewData['content']),
      selection: const TextSelection.collapsed(offset: 0),
    );
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
    final String upvotes = widget.reviewData['upvotes'] ?? '0';
    final String commentsCount = widget.reviewData['comment'] ?? '0';
    // const Color vintageCardBackground = Colors.white;
    const Color vintagePrimaryText = Color(0xFF5D4037);

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
            // The original screenshot shows a URL for the article,
            // we don't have that in your data, so I'll skip it.
            // If you had one, it would go here:
            // Text(
            //   "https://www.reuters.com/...",
            //   style: GoogleFonts.montserrat(color: vintageAccent, fontSize: 12),
            //   overflow: TextOverflow.ellipsis,
            // ),
            // const SizedBox(height: 8),
            _buildQuillContent(),
            const SizedBox(height: 12),
            _buildActionBar(upvotes, commentsCount),
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
        // Book Cover
        SizedBox(
          width: 30, // Adjusted size to be smaller, like subreddit icon
          height: 30,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4.0), // Slightly rounded
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
        // Book Title and Metadata
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                bookTitle, // Changed from r/worldnews
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
        // Join Button
        ElevatedButton(
          onPressed: () {
            // Join action
          },
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
        // More Options
        SizedBox(
          width: 30,
          child: IconButton(
            icon: const Icon(Icons.more_horiz, color: vintageIconColor),
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              // More options action
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuillContent() {
    // To make QuillEditor look like static text, we use Basic variant
    // and ensure it's read-only and has no toolbar.
    // We might need to constrain its height or make it scrollable if content is too long.
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
          bold: GoogleFonts.merriweather(fontWeight: FontWeight.bold),
          italic: GoogleFonts.merriweather(fontStyle: FontStyle.italic),
          underline: GoogleFonts.merriweather(
            decoration: TextDecoration.underline,
          ),
          // You can customize h1, h2, h3, link, etc. if your delta uses them
        ),
        //embedBuilders: quill.FlutterQuillEmbeds.editorBuilders(),
        scrollable:
            false, // Important for it to take natural height in a Column
      ),
    );
  }

  Widget _buildActionBar(String upvotes, String commentsCount) {
    return Row(
      children: [
        _actionButton(Icons.arrow_upward_outlined, upvotes, () {}),
        const SizedBox(width: 4),
        _actionButton(
          Icons.arrow_downward_outlined,
          null,
          () {},
          iconSize: 20,
        ), // No count for downvote usually
        const SizedBox(width: 12),
        _actionButton(Icons.mode_comment_outlined, commentsCount, () {}),
        const SizedBox(width: 12),
        _actionButton(
          Icons.bookmark_border_outlined,
          'Save',
          () {},
          isSave: true,
        ), // 'Save' instead of generic 'Share' icon
        const SizedBox(width: 12),
        _actionButton(Icons.share_outlined, 'Share', () {}),
        // The original has a gift icon too, we can add it if needed.
        // _actionButton(Icons.card_giftcard_outlined, 'Award', () {}),
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

// --- EXAMPLE USAGE ---
class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: vintageBackground,
      appBar: AppBar(
        title: Text(
          'Vintage Book Feed',
          style: GoogleFonts.playfairDisplay(
            color: vintagePrimaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: vintageCardBackground,
        elevation: 1,
        iconTheme: const IconThemeData(color: vintagePrimaryText),
      ),
      body: ListView.builder(
        itemCount: reviews.length,
        itemBuilder: (context, index) {
          return VintageFeedCard(reviewData: reviews[index]);
        },
      ),
    );
  }
}
