import 'dart:ui';
import 'package:bookrec/components/shelfIcon.dart';
import 'package:bookrec/components/star.dart';
import 'package:bookrec/provider/authprovider.dart';
import 'package:bookrec/services/booksapi.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:provider/provider.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:flutter_animate/flutter_animate.dart';

class Vintagebookcard extends StatefulWidget {
  final Map<String, dynamic> book;

  const Vintagebookcard({super.key, required this.book});

  @override
  State<Vintagebookcard> createState() => _VintageBookCardState();
}

class _VintageBookCardState extends State<Vintagebookcard> {
  // State variables for the dynamic gradient
  List<Color> _gradientColors = [
    const Color(0xFF2c3e50),
    const Color(0xFF161e28),
  ];
  bool _isPaletteLoading = true;

  @override
  void initState() {
    super.initState();
    _generatePalette();
  }

  // Generate the gradient from the cover image
  Future<void> _generatePalette() async {
    final String? coverImage = widget.book['thumbnail'] as String?;
    if (coverImage == null || coverImage.isEmpty) {
      if (mounted) setState(() => _isPaletteLoading = false);
      return;
    }

    try {
      final imageProvider = NetworkImage(coverImage);
      final PaletteGenerator palette = await PaletteGenerator.fromImageProvider(
        imageProvider,
        size: const Size(100, 150), // smaller size for faster processing
        maximumColorCount: 20,
      );

      Color dominantColor =
          palette.dominantColor?.color ?? const Color(0xFF2c3e50);
      Color vibrantColor =
          palette.vibrantColor?.color ??
          palette.lightVibrantColor?.color ??
          const Color(0xFF161e28);

      // Ensure colors are not too similar for a good gradient
      if (dominantColor == vibrantColor) {
        vibrantColor =
            HSLColor.fromColor(dominantColor)
                .withLightness(
                  (HSLColor.fromColor(dominantColor).lightness - 0.2).clamp(
                    0.0,
                    1.0,
                  ),
                )
                .toColor();
      }

      if (mounted) {
        setState(() {
          _gradientColors = [dominantColor, vibrantColor];
          _isPaletteLoading = false;
        });
      }
    } catch (e) {
      print("Error generating palette: $e");
      if (mounted) setState(() => _isPaletteLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Responsive layout break-point
    final bool isWideScreen = MediaQuery.of(context).size.width > 850;

    return Center(
      child: Container(
            width:
                isWideScreen
                    ? MediaQuery.of(context).size.width * 0.7
                    : MediaQuery.of(context).size.width * 0.9,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
              maxWidth: 1200, // Max width for large screens
            ),
            margin: const EdgeInsets.symmetric(
              vertical: 24.0,
              horizontal: 12.0,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 20.0,
                  spreadRadius: 2.0,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 700),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: const [0.0, 1.0],
                ),
              ),
              child:
                  _isPaletteLoading
                      ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                      : isWideScreen
                      ? _buildWideLayout()
                      : _buildNarrowLayout(),
            ),
          )
          .animate()
          .fadeIn(duration: 600.ms)
          .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
    );
  }

  // Layout for wide screens (Tablet/Desktop)
  Widget _buildWideLayout() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _BookCover(
            bookId: widget.book['isbn10'],
            imageUrl: widget.book['thumbnail'],
          ),
        ),
        Expanded(
          flex: 3,
          child: _BookDetails(
            book: widget.book,
            gradientColors: _gradientColors,
          ),
        ),
      ],
    );
  }

  // Layout for narrow screens (Mobile)
  Widget _buildNarrowLayout() {
    String? coverImage = widget.book['thumbnail'] as String?;

    return Stack(
      children: [
        // Blurred background image
        if (coverImage != null && coverImage.isNotEmpty)
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Image.network(
                coverImage,
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.3),
                colorBlendMode: BlendMode.darken,
              ),
            ),
          ),
        // Foreground Content
        ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.35,
              child: Center(
                child: _BookCover(
                  bookId: widget.book['isbn10'],
                  imageUrl: coverImage,
                  isNarrow: true,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // We pass the full book data here for consistency
            _BookDetails(
              book: widget.book,
              gradientColors: _gradientColors,
              isNarrow: true,
            ),
          ],
        ),
      ],
    );
  }
}

// --- SUB-WIDGETS FOR CLEANER STRUCTURE ---

class _BookCover extends StatelessWidget {
  final String? bookId;
  final String? imageUrl;
  final bool isNarrow;

  const _BookCover({this.bookId, this.imageUrl, this.isNarrow = false});

  @override
  Widget build(BuildContext context) {
    // Unique hero tag
    final heroTag = 'book_cover_${bookId ?? DateTime.now().toIso8601String()}';

    return Hero(
      tag: heroTag,
      child: Container(
        margin: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(4, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child:
            (imageUrl != null && imageUrl!.isNotEmpty)
                ? Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => _buildPlaceholder(),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white70),
                    );
                  },
                )
                : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey.shade800,
      child: const Center(
        child: Icon(Icons.book_outlined, size: 60, color: Colors.white54),
      ),
    );
  }
}

class _BookDetails extends StatelessWidget {
  final Map<String, dynamic> book;
  final List<Color> gradientColors;
  final bool isNarrow;

  _BookDetails({
    required this.book,
    required this.gradientColors,
    this.isNarrow = false,
  });

  @override
  Widget build(BuildContext context) {
    final ProviderUser = Provider.of<UserProvider>(context);
    final BooksInfo bookInfo = BooksInfo();

    // Responsive: check if mobile
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 500;

    // Responsive font and padding
    final double titleFont = isMobile ? 22 : 32;
    final double authorFont = isMobile ? 14 : 18;
    final double summaryFont = isMobile ? 13 : 16;
    final double chipFont = isMobile ? 12 : 15;
    final double chipPadding = isMobile ? 7 : 10;
    final double chipIcon = isMobile ? 15 : 18;
    final double starSize = isMobile ? 22 : 32;
    final double sectionHeaderFont = isMobile ? 16 : 22;
    final double detailsPadding = isMobile ? 12 : 24;
    final double spacing = isMobile ? 10 : 24;

    Future<String> rate(String bookID, int value) async {
      final String response = await bookInfo.bookRatings(
        bookID,
        value,
        ProviderUser.token,
      );
      return response;
    }

    final textColor = Colors.white;

    String title = book['title'] as String? ?? 'Unknown Title';
    String author = book['authors'] as String? ?? 'Unknown Author';
    int? publicationYear = book['published_year'] as int?;
    String genre = book['categories'] as String? ?? '';
    String summary = book['description'] as String? ?? 'No summary available.';
    double? rating = (book['average_rating'] as num?)?.toDouble();
    int? pages = book['pages'] as int?;

    final ValueNotifier<bool> expanded = ValueNotifier(false);

    return SingleChildScrollView(
      padding:
          isNarrow
              ? EdgeInsets.zero
              : EdgeInsets.fromLTRB(
                0,
                detailsPadding,
                detailsPadding,
                detailsPadding,
              ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // TITLE
          Text(
                title,
                style: GoogleFonts.lato(
                  color: textColor,
                  fontSize: titleFont,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                ),
              )
              .animate()
              .fadeIn(delay: 200.ms, duration: 400.ms)
              .slideX(begin: -0.2),

          SizedBox(height: isMobile ? 4 : 8),

          // AUTHOR
          Text(
            'by $author ${publicationYear != null ? "($publicationYear)" : ""}',
            style: GoogleFonts.lato(
              color: textColor.withOpacity(0.8),
              fontSize: authorFont,
              fontStyle: FontStyle.italic,
            ),
          ).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideX(begin: -0.2),

          SizedBox(height: spacing / 2),

          // ACTIONS (RATING & SHELF)
          Row(
            children: [
              StarRating(
                token: ProviderUser.token,
                bookId: book['isbn10'],
                getRatingsCount: bookInfo.getRatingsCount,
                size: starSize,
                color: Colors.amber,
                onRatingChanged: (value) async {
                  final String r = await rate(book['isbn10'], value);
                  print('Rating response: $r');
                  if (r == 'sucess') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Rating submitted!')),
                    );
                  } else {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $r')));
                  }
                },
              ),
              SizedBox(width: isMobile ? 8 : 16),
              ShelfButtonWidget(
                bookId: book['isbn10'],
                token: ProviderUser.token,
                bookData: book,
              ),
            ],
          ).animate().fadeIn(delay: 400.ms, duration: 400.ms),

          SizedBox(height: spacing),

          // INFO CHIPS
          Wrap(
            spacing: isMobile ? 5.0 : 8.0,
            runSpacing: isMobile ? 5.0 : 8.0,
            children: [
              if (genre.isNotEmpty)
                _buildInfoChip(
                  'Genre',
                  genre,
                  Icons.category_outlined,
                  chipFont,
                  chipPadding,
                  chipIcon,
                ),
              if (pages != null)
                _buildInfoChip(
                  'Pages',
                  pages.toString(),
                  Icons.pages_outlined,
                  chipFont,
                  chipPadding,
                  chipIcon,
                ),
              if (rating != null)
                _buildInfoChip(
                  'Rating',
                  '${rating.toStringAsFixed(1)}/5',
                  Icons.star_border,
                  chipFont,
                  chipPadding,
                  chipIcon,
                ),
            ],
          ).animate(delay: 500.ms).fadeIn(duration: 400.ms).slideY(begin: 0.2),

          SizedBox(height: spacing),

          // SYNOPSIS (Expandable)
          _buildSectionHeader('Synopsis', sectionHeaderFont),
          SizedBox(height: isMobile ? 4 : 8),
          ValueListenableBuilder<bool>(
            valueListenable: expanded,
            builder: (context, isExpanded, _) {
              return GestureDetector(
                onTap: () => expanded.value = !isExpanded,
                child: AnimatedCrossFade(
                  firstChild: Text(
                    summary,
                    style: GoogleFonts.lato(
                      color: textColor.withOpacity(0.85),
                      fontSize: summaryFont,
                      height: 1.5,
                    ),
                    maxLines: isMobile ? 5 : 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  secondChild: Text(
                    summary,
                    style: GoogleFonts.lato(
                      color: textColor.withOpacity(0.85),
                      fontSize: summaryFont,
                      height: 1.5,
                    ),
                  ),
                  crossFadeState:
                      isExpanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),
              );
            },
          ),
          ValueListenableBuilder<bool>(
            valueListenable: expanded,
            builder: (context, isExpanded, _) {
              return Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                  onPressed: () => expanded.value = !isExpanded,
                  icon: Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.white,
                  ),
                  label: Text(
                    isExpanded ? "Show less" : "Read more",
                    style: GoogleFonts.lato(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 13 : 15,
                    ),
                  ),
                ),
              );
            },
          ),
        ].animate(interval: 100.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1),
      ),
    );
  }

  // Responsive Chip
  Widget _buildInfoChip(
    String label,
    String value,
    IconData icon,
    double chipFont,
    double chipPadding,
    double chipIcon,
  ) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: Colors.white.withOpacity(0.85),
        child: Icon(icon, color: gradientColors.first, size: chipIcon),
      ),
      label: Text(
        '$label: $value',
        style: GoogleFonts.lato(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: chipFont,
          letterSpacing: 0.2,
        ),
      ),
      backgroundColor:
          gradientColors.length > 1
              ? Color.lerp(
                    gradientColors[0].withOpacity(0.85),
                    gradientColors[1].withOpacity(0.85),
                    0.5,
                  ) ??
                  Colors.black.withOpacity(0.25)
              : gradientColors[0].withOpacity(0.85),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.white.withOpacity(0.5), width: 1.2),
      ),
      elevation: 4,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: chipPadding),
    );
  }

  // Responsive section header
  Widget _buildSectionHeader(String title, double fontSize) {
    return Text(
      title,
      style: GoogleFonts.lato(
        color: Colors.white,
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
