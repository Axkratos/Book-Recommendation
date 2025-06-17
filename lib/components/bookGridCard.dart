import 'package:bookrec/modals.dart/book_modal.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class BookGridCard extends StatelessWidget {
  final Book book;
  final int rank;

  const BookGridCard({Key? key, required this.book, required this.rank})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    const primaryTextColor = Color(0xFF4A403A);
    const secondaryTextColor = Color(0xFF7B6F66);

    return GestureDetector(
      onTap: () {
        context.go('/book/${book.id}/${book.title}');
      },
      child: Container(
        padding: const EdgeInsets.only(bottom: 16),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0x334A403A), width: 1),
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.topLeft,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                    child: _buildBookCover(book.thumbnail),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: primaryTextColor,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                        fontSize: 14,
                        color: secondaryTextColor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const Spacer(),
                    Wrap(
                      spacing: 12.0,
                      runSpacing: 8.0,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
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
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
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
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookCover(String url) {
    return Container(
      width: 90,
      height: 135,
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
      child: Transform.rotate(
        angle: -0.08,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.network(
            url,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
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
}