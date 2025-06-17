import 'dart:convert';
import 'dart:ui';
import 'package:bookrec/provider/authprovider.dart'; // Make sure this path is correct
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

// --- A Light, Warm & Positive Color Scheme ---
const Color kWarmBackground = Color(0xFFFFF8F0); // A soft, creamy background
const Color kWarmCardBackground = Colors.white; // Clean white for the cards
const Color kWarmPrimaryText = Color(
  0xFF3A3A3A,
); // Dark, warm gray for readability
const Color kWarmSecondaryText = Color(
  0xFF6F6F6F,
); // Lighter gray for less emphasis
const Color kWarmAccent = Color(0xFFFF7F50); // A vibrant, friendly Coral
const Color kWarmIconColor = Color(0xFF8D8D8D);
const Color kWarmComplement = Color(0xFF4CAF50); // A pleasant, earthy green
const Color kWarmPaperBackground = Color(0xFFF9F5EE); // For content areas

class ModernFeedCard extends StatefulWidget {
  final Map<String, dynamic> reviewData;

  const ModernFeedCard({super.key, required this.reviewData});

  @override
  State<ModernFeedCard> createState() => _ModernFeedCardState();
}

class _ModernFeedCardState extends State<ModernFeedCard>
    with SingleTickerProviderStateMixin {
  final String baseUrl = dotenv.env['baseUrl']!;

  late quill.QuillController _quillController;
  late AnimationController _heartAnimationController;

  bool _isLiked = false;
  int _likeCount = 0;
  bool _isLiking = false; // Prevents spamming the like button

  @override
  void initState() {
    super.initState();

    // Setup for Quill editor
    _quillController = quill.QuillController(
      document: quill.Document.fromJson(widget.reviewData['content']),
      selection: const TextSelection.collapsed(offset: 0),
    );

    // Setup for the heart "beat" animation
    _heartAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _likeCount = int.tryParse(widget.reviewData['upvotes'].toString()) ?? 0;

    // Fetch initial like status after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final providerUser = Provider.of<UserProvider>(context, listen: false);
        _fetchLikeStatus(providerUser.token);
      }
    });
  }

  // --- API LOGIC (Identical) ---
  Future<void> _fetchLikeStatus(String token) async {
    final String forumId = widget.reviewData['id'] ?? '';
    if (forumId.isEmpty) return;

    final String apiUrl = '${baseUrl}/api/v1/books/forum/like/status/$forumId';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (mounted && response.statusCode == 200) {
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
    if (_isLiking) return; // Prevent multiple requests
    setState(() => _isLiking = true);

    // Trigger the heart animation
    if (!_isLiked) {
      _heartAnimationController.forward().then(
        (_) => _heartAnimationController.reverse(),
      );
    }

    final String forumId = widget.reviewData['id'] ?? '';
    final String apiUrl = '${baseUrl}/api/v1/books/forum/like/$forumId';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (mounted && response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _isLiked = data['liked'];
          _likeCount = data['likeCount'];
        });
      }
    } catch (e) {
      debugPrint('Error toggling like: $e');
      // Optional: revert state on error
    } finally {
      if (mounted) {
        setState(() => _isLiking = false);
      }
    }
  }

  @override
  void dispose() {
    _quillController.dispose();
    _heartAnimationController.dispose();
    super.dispose();
  }

  // --- UI BUILD METHOD ---
  @override
  Widget build(BuildContext context) {
    // Animate the card's entrance
    return Animate(
      effects: [
        FadeEffect(duration: 500.ms),
        SlideEffect(begin: Offset(0, 0.2), curve: Curves.easeOut),
      ],
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: kWarmCardBackground,
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1.2,
          ), // subtle border for light theme
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildContentTitle(),
                    const SizedBox(height: 12),
                    _buildQuillContent(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              _buildActionBar(),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET BUILDER HELPERS ---

  Widget _buildHeader() {
    final String coverUrl = widget.reviewData['cover'] ?? '';
    final String bookTitle = widget.reviewData['book'] ?? 'Unknown Book';
    final String timeAgo = widget.reviewData['timeAgo'] ?? '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: Colors.grey.shade200,
              child: ClipOval(
                child: Image.network(
                  coverUrl,
                  fit: BoxFit.cover,
                  width: 44,
                  height: 44,
                  // Light theme loading builder with a shimmer effect
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: const CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.white,
                      ),
                    );
                  },
                  // Error builder using the new accent color
                  errorBuilder:
                      (context, error, stackTrace) =>
                          const Icon(Icons.book, color: kWarmAccent, size: 24),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bookTitle,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: kWarmPrimaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  timeAgo,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: kWarmSecondaryText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.more_vert, color: kWarmIconColor),
            onPressed: () {
              /* TODO: Implement more options */
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContentTitle() {
    final String postTitle = widget.reviewData['title'] ?? 'No Title';
    return Text(
      postTitle,
      style: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: kWarmPrimaryText,
      ),
    );
  }

  Widget _buildQuillContent() {
    // A clean "paper" like background for the content.
    return Container(
      decoration: BoxDecoration(
        color: kWarmPaperBackground,
        borderRadius: BorderRadius.circular(12.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: quill.QuillEditor.basic(
        controller: _quillController,
        config: quill.QuillEditorConfig(
          showCursor: false,
          customStyles: quill.DefaultStyles(
            paragraph: quill.DefaultTextBlockStyle(
              GoogleFonts.poppins(
                fontSize: 14.5,
                color: kWarmSecondaryText,
                height: 1.6,
              ),
              quill.HorizontalSpacing.zero,
              quill.VerticalSpacing.zero,
              quill.VerticalSpacing.zero,
              null,
            ),
          ),
          scrollable: false,
        ),
      ),
    );
  }

  Widget _buildActionBar() {
    final String commentsCount = widget.reviewData['comments'] ?? '0';
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.transparent, // Let the card color show through
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 1.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _actionButton(
                icon: _isLiked ? Icons.favorite : Icons.favorite_border,
                text: _likeCount.toString(),
                color: _isLiked ? kWarmAccent : kWarmIconColor,
                onPressed: () => _toggleLike(userProvider.token),
                animationController: _heartAnimationController,
              ),
              const SizedBox(width: 16),
              _actionButton(
                icon: Icons.mode_comment_outlined,
                text: commentsCount,
                onPressed: () {
                  /* TODO: Implement comments view */
                },
              ),
              const SizedBox(width: 16),
              _actionButton(
                icon: Icons.share_outlined,
                color: kWarmComplement, // Use the new complementary color
                onPressed: () {
                  /* TODO: Implement share */
                },
              ),
            ],
          ),
          _actionButton(
            icon: Icons.bookmark_border,
            onPressed: () {
              /* TODO: Implement save */
            },
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    String? text,
    required VoidCallback onPressed,
    Color? color,
    AnimationController? animationController,
  }) {
    // The main animated icon
    Widget iconWidget = Icon(icon, color: color ?? kWarmIconColor, size: 22);

    // If it's a heart button, wrap it in a ScaleTransition for the "beat"
    if (animationController != null) {
      iconWidget = ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 1.4).animate(
          CurvedAnimation(parent: animationController, curve: Curves.easeOut),
        ),
        child: iconWidget,
      );
    }

    // Smoothly animate the icon change (e.g., favorite to favorite_border)
    iconWidget = AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder:
          (child, animation) => ScaleTransition(scale: animation, child: child),
      child: Container(
        // The key is crucial for AnimatedSwitcher to detect a change
        key: ValueKey<IconData>(icon),
        child: iconWidget,
      ),
    );

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Row(
          children: [
            iconWidget,
            if (text != null) ...[
              const SizedBox(width: 8),
              // Animate the text counter change
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.5),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  text,
                  // Key is crucial here as well!
                  key: ValueKey<String>(text),
                  style: GoogleFonts.poppins(
                    color: color ?? kWarmSecondaryText,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
