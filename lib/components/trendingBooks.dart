import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class trendingBook extends StatelessWidget {
  trendingBook({
    super.key,
    required this.isDesktop,
    required this.isMobile,
    required this.books,
  });

  bool isDesktop;
  bool isMobile;
  final List books;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth;
        if (width < 600) {
          // Mobile View
          isMobile = true;
          isDesktop = false;
        } else if (width < 1200) {
          // Tablet View
          isMobile = false;
          isDesktop = false;
        } else {
          // Desktop View
          isMobile = false;
          isDesktop = true;
        }
        // Define breakpoints

        if (isDesktop) {
          // Desktop View - Horizontal Scroll
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 8,
            itemBuilder: (context, index) {
              return Container(
                width: width * 0.2,
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: BookCard(
                  book: books[index],
                  width: width * 0.1,
                  isDesktop: true,
                ),
              );
            },
          );
        } else {
          // Mobile or Tablet View - Grid
          int crossAxisCount = isMobile ? 2 : 3;

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.7,
            ),
            itemCount: 10,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: BookCard(
                  book: books[index],
                  width:
                      (width - 40) /
                      crossAxisCount, // Adjust width based on count
                ),
              );
            },
          );
        }
      },
    );
  }
}

class BookCard extends StatelessWidget {
  final Map book;
  final double width;
  final bool isDesktop;
  final bool isMobile;

  const BookCard({
    super.key,
    required this.book,
    required this.width,
    this.isDesktop = false,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    double imageFlex = isDesktop ? 12 : (isMobile ? 5 : 7);
    double infoFlex = 11 - imageFlex;
    double titleFontSize = isDesktop ? 18 : (isMobile ? 14 : 16);
    double authorFontSize = isDesktop ? 15 : (isMobile ? 12 : 13);
    double ratingFontSize = isDesktop ? 16 : (isMobile ? 12 : 14);

    // --- Vintage Aesthetic Definitions ---
    const Color cardBackgroundColor = Color(0xFFF1EBE5); // Creamy, aged paper
    const Color textColor = Color(0xFF4E342E); // Dark brown
    const Color accentColor = Color(0xFF8D6E63); // Muted brown for accents
    final Color shadowColor = Colors.brown.withOpacity(0.4);

    // A subtle paper texture URL. You can replace this with a local asset.
    const String paperTextureUrl =
        'https://www.transparenttextures.com/patterns/paper-fibers.png';

    return Container(
      width: width,
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(
          isDesktop ? 8 : 4,
        ), // Sharper corners for a vintage feel
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 8,
            offset: const Offset(4, 4),
          ),
        ],
        // --- Applying the Paper Texture ---
        image: const DecorationImage(
          image: NetworkImage(paperTextureUrl),
          fit: BoxFit.cover,
          opacity: 0.6, // Make it subtle
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Book Cover Image ---
          Expanded(
            flex: imageFlex.toInt(),
            child: Container(
              // --- "Pasted-on" Photo Border ---
              decoration: BoxDecoration(
                border: Border.all(color: textColor.withOpacity(0.5), width: 3),
                image: DecorationImage(
                  image: NetworkImage(
                    book['thumbnail'] ?? 'https://via.placeholder.com/150',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child:
                  (book['thumbnail'] == null)
                      ? const Center(
                        child: Icon(Icons.book, color: Colors.grey, size: 50),
                      )
                      : null,
            ),
          ),

          // --- Book Info Section ---
          Expanded(
            flex: infoFlex.toInt(),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 16.0 : 12.0,
                vertical: isDesktop ? 12.0 : 8.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // --- Title ---
                  Text(
                    book['title'] ?? 'Unknown Title',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    // Using GoogleFonts for the vintage title
                    style: GoogleFonts.playfairDisplay(
                      fontWeight: FontWeight.w700, // Bold weight for Playfair
                      fontSize: titleFontSize,
                      color: textColor,
                    ),
                  ),

                  // --- Author ---
                  Text(
                    book['authors'] ?? 'Unknown Author',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    // Using GoogleFonts for the body text
                    style: GoogleFonts.lora(
                      fontSize: authorFontSize,
                      fontStyle: FontStyle.italic,
                      color: textColor.withOpacity(0.8),
                    ),
                  ),

                  // --- Decorative Divider ---
                  Divider(color: accentColor.withOpacity(0.5), thickness: 1),

                  // --- Rating ---
                  Row(
                    children: [
                      Icon(
                        Icons
                            .star_border, // An outlined star feels more classic
                        color: accentColor,
                        size: ratingFontSize + 2,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        book['average_rating']?.toString() ?? 'N/A',
                        style: GoogleFonts.lora(
                          fontWeight: FontWeight.bold,
                          fontSize: ratingFontSize,
                          color: textColor,
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
    );
  }
}
