import 'package:bookrec/components/drop_down_menu.dart';
import 'package:bookrec/components/trendingBooks.dart';
import 'package:bookrec/modals.dart/book_modal.dart';
import 'package:bookrec/services/booksapi.dart';
import 'package:bookrec/theme/color.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardTrending extends StatefulWidget {
  const DashboardTrending({super.key});

  @override
  State<DashboardTrending> createState() => _DashboardTrendingState();
}

class _DashboardTrendingState extends State<DashboardTrending> {
  late Future<List<Book>> _trendingBooksFuture;
  List<Book> _books = [];
  String _selectedSort = 'Latest';

  @override
  void initState() {
    super.initState();
    _trendingBooksFuture = _fetchAndSortBooks();
  }

  Future<List<Book>> _fetchAndSortBooks() async {
    final booksInfo = BooksInfo();
    final rawBooks = await booksInfo.getTrendingBooks();
    final parsedBooks = rawBooks.map((book) => Book.fromJson(book)).toList();
    // Initially sort the books and update the state list
    _books = _sort(parsedBooks, _selectedSort);
    return _books;
  }

  List<Book> _sort(List<Book> books, String value) {
    // Return a new sorted list to ensure proper state updates
    final sortedBooks = List<Book>.from(books);
    if (value == 'Latest') {
      sortedBooks.sort((a, b) => b.publishedYear.compareTo(a.publishedYear));
    } else if (value == 'Alpabetical') {
      sortedBooks.sort((a, b) => a.title.compareTo(b.title));
    } else if (value == 'Rating') {
      sortedBooks.sort((a, b) => b.averageRating.compareTo(a.averageRating));
    }
    return sortedBooks;
  }

  void _onSortChanged(String value) {
    setState(() {
      _selectedSort = value;
      // Re-sort the existing list of books without another API call
      _books = _sort(_books, value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final sortOptions = ['Latest', 'Alpabetical', 'Rating'];

    return Scaffold(
      backgroundColor: vintageCream,
      body: SafeArea(
        child: FutureBuilder<List<Book>>(
          future: _trendingBooksFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No trending books found.'));
            } else {
              // The main content column
              return Column(
                children: [
                  // RESPONSIVE HEADER:
                  // Using a Wrap widget for the header. On small screens, the dropdown menu
                  // will wrap to the next line if there's not enough horizontal space.
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 16.0,
                    ),
                    child: Wrap(
                      spacing: 24.0, // Horizontal space between children
                      runSpacing: 16.0, // Vertical space if it wraps
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Trending Books',
                          style: GoogleFonts.lobster(
                            fontSize: 36,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF4A403A),
                          ),
                        ),
                        // Removed the fixed-width SizedBox to allow the dropdown to size itself.
                        // The Wrap widget will handle the alignment.
                        menu_drop(
                          type: sortOptions,
                          title: 'Sort by',
                          onChanged: _onSortChanged,
                        ),
                      ],
                    ),
                  ),
                  // The list of books, which expands to fill the remaining space.
                  Expanded(
                    child: ListView.builder(
                      itemCount: _books.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            context.push(
                              '/book/${_books[index].isbn}/${_books[index].title}',
                            );
                          },
                          child: VintageBookCard(
                            book: _books[index],
                            rank: index + 1,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}

// A fully responsive book card widget
class VintageBookCard extends StatelessWidget {
  final Book book;
  final int rank;

  const VintageBookCard({Key? key, required this.book, required this.rank})
    : super(key: key);

  // Define breakpoints for layout changes
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder provides the constraints of the parent widget, allowing us to
    // build different UIs for different available widths.
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth;

        if (maxWidth < mobileBreakpoint) {
          return _buildMobileLayout(context);
        } else if (maxWidth < tabletBreakpoint) {
          return _buildTabletLayout(context);
        } else {
          return _buildDesktopLayout(context);
        }
      },
    );
  }

  // DESKTOP LAYOUT (> 900px)
  // The full experience with all details laid out horizontally.
  Widget _buildDesktopLayout(BuildContext context) {
    const primaryTextColor = Color(0xFF4A403A);
    const rankColor = Color(0xFFE4DCD2);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.only(bottom: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0x334A403A), width: 1)),
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            // Rank
            SizedBox(
              width: 120,
              child: Text(
                '$rank',
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 90,
                  fontWeight: FontWeight.w900,
                  color: rankColor,
                ),
              ),
            ),
            // Book Cover
            _buildBookCover(width: 150, height: 220),
            const SizedBox(width: 32),
            // Book Details
            Expanded(
              flex: 2,
              child: _buildBookDetails(context, isMobile: false),
            ),
            const SizedBox(width: 24),
            // Description (only on desktop)
            Expanded(
              flex: 1,
              child: Text(
                book.description ?? 'No description available.',
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.lato(
                  fontSize: 22,
                  color: primaryTextColor,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(width: 24),
            // Chevron
            const Icon(Icons.chevron_right, color: primaryTextColor, size: 28),
          ],
        ),
      ),
    );
  }

  // TABLET LAYOUT (600px - 900px)
  // A slightly condensed version of the desktop layout, removing the description.
  Widget _buildTabletLayout(BuildContext context) {
    const primaryTextColor = Color(0xFF4A403A);
    const rankColor = Color(0xFFE4DCD2);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.only(bottom: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0x334A403A), width: 1)),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Rank
            SizedBox(
              width: 90,
              child: Text(
                '$rank',
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 70,
                  fontWeight: FontWeight.w900,
                  color: rankColor,
                ),
              ),
            ),
            // Book Cover
            _buildBookCover(width: 120, height: 180),
            const SizedBox(width: 24),
            // Book Details
            Expanded(child: _buildBookDetails(context, isMobile: false)),
            const SizedBox(width: 16),
            // Chevron
            const Icon(Icons.chevron_right, color: primaryTextColor, size: 24),
          ],
        ),
      ),
    );
  }

  // MOBILE LAYOUT (< 600px)
  // A compact layout with the image on the left and details on the right.
  Widget _buildMobileLayout(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.only(bottom: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0x334A403A), width: 1)),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book cover with rank on top
            Stack(
              alignment: Alignment.topLeft,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                  child: _buildBookCover(width: 90, height: 135),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A403A),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: Text(
                    '$rank',
                    style: GoogleFonts.lato(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            // Book Details
            Expanded(child: _buildBookDetails(context, isMobile: true)),
          ],
        ),
      ),
    );
  }

  // Helper widget for the book cover to avoid code duplication.
  Widget _buildBookCover({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      // The tilt effect
      child: Transform.rotate(
        angle: -0.08,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.network(
            book.thumbnail,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: const Color(0xFFD3C5B5),
                child: const Icon(Icons.book, color: Colors.white, size: 40),
              );
            },
          ),
        ),
      ),
    );
  }

  // Helper widget for book details to avoid duplication.
  // Font sizes are adjusted based on the layout (mobile vs. desktop/tablet).
  Widget _buildBookDetails(BuildContext context, {required bool isMobile}) {
    const primaryTextColor = Color(0xFF4A403A);
    const secondaryTextColor = Color(0xFF7B6F66);

    final double titleSize = isMobile ? 18 : 26;
    final double authorSize = isMobile ? 14 : 18;
    final double metaSize = isMobile ? 13 : 24;
    final double iconSize = isMobile ? 18 : 22;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          book.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.w700,
            fontSize: titleSize,
            color: primaryTextColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'by ${book.authors}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.lato(
            fontSize: authorSize,
            color: secondaryTextColor,
            fontStyle: FontStyle.italic,
          ),
        ),
        const Spacer(),
        // On mobile, rating and year can wrap to save horizontal space.
        Wrap(
          spacing: 12.0,
          runSpacing: 8.0,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, color: Colors.amber, size: iconSize),
                const SizedBox(width: 4),
                Text(
                  book.averageRating.toString(),
                  style: GoogleFonts.lato(
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                    fontSize: metaSize,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today,
                  color: secondaryTextColor,
                  size: iconSize - 2,
                ),
                const SizedBox(width: 4),
                Text(
                  book.publishedYear.toString(),
                  style: GoogleFonts.lato(
                    color: secondaryTextColor,
                    fontSize: metaSize,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
