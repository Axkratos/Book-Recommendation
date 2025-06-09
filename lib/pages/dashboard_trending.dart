import 'package:bookrec/components/trendingBooks.dart';
import 'package:bookrec/modals.dart/book_modal.dart';
import 'package:bookrec/services/booksapi.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardTrending extends StatefulWidget {
  const DashboardTrending({super.key});

  @override
  State<DashboardTrending> createState() => _DashboardTrendingState();
}

class _DashboardTrendingState extends State<DashboardTrending> {
  @override
  Widget build(BuildContext context) {
    BooksInfo booksInfo = BooksInfo();
    Future<List> trendingBooks = booksInfo.getTrendingBooks();

    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6), // Vintage background color
      body: FutureBuilder<List>(
        future: trendingBooks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No trending books found.'));
          } else {
            List books = snapshot.data!;

            return ListView.builder(
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = Book.fromJson(books[index]);
                return VintageBookCard(book: book, rank: index + 1);
              },
            );
          }
        },
      ),
    );
  }
}

class VintageBookCard extends StatelessWidget {
  final Book book;
  final int rank;

  const VintageBookCard({Key? key, required this.book, required this.rank})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Vintage color palette
    const cardBackgroundColor = Color(0xFFF5EFE6);
    const primaryTextColor = Color(0xFF4A403A);
    const secondaryTextColor = Color(0xFF7B6F66);
    const rankColor = Color(0xFFE4DCD2);

    return Container(
      height: 160,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Stack(
        children: [
          // The background card with book details
          Container(
            // Start the card after the number's space
            margin: const EdgeInsets.only(left: 48),
            decoration: BoxDecoration(
              color: cardBackgroundColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Spacer for the book cover image, which will be in the Stack
                const SizedBox(width: 82),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          book.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.playfairDisplay(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: primaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'by ${book.authors}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.lato(
                            fontSize: 13,
                            color: secondaryTextColor,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              book.averageRating.toString(),
                              style: GoogleFonts.lato(
                                fontWeight: FontWeight.bold,
                                color: primaryTextColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(
                              Icons.calendar_today,
                              color: secondaryTextColor,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              book.publishedYear.toString(),
                              style: GoogleFonts.lato(
                                color: secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // The large, overlapping rank number
          Positioned(
            //left: -1,
            bottom: -3,
            child: Text(
              '$rank',
              style: GoogleFonts.playfairDisplay(
                fontSize: 110,
                fontWeight: FontWeight.w900,
                color: rankColor,
              ),
            ),
          ),

          // The book cover image
          Positioned(
            top: 10,
            bottom: 10,
            left: 600,
            child: Container(
              width: 90,
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  book.thumbnail,
                  fit: BoxFit.cover,
                  // Show a placeholder while loading
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  // Show a vintage-style placeholder on error
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFFD3C5B5),
                      child: const Icon(
                        Icons.book,
                        color: Colors.white,
                        size: 40,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
