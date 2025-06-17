import 'dart:convert';

import 'package:bookrec/components/VintageButton.dart';
import 'package:bookrec/components/book_grid.dart';
import 'package:bookrec/components/chat_ai.dart';
import 'package:bookrec/components/llmRec.dart';
import 'package:bookrec/dummy/book.dart';
import 'package:bookrec/modals.dart/book_modal.dart';
import 'package:bookrec/pages/FeaturedPage.dart';
import 'package:bookrec/provider/authprovider.dart';
import 'package:bookrec/services/booksapi.dart';
import 'package:bookrec/theme/color.dart';
import 'package:bookrec/theme/dashboard_title.dart';
import 'package:bookrec/theme/texts.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

const kBackgroundColor = Color(0xFFF7F2E9); // Warm, parchment-like off-white
const kPrimaryTextColor = Color(
  0xFF4A403A,
); // Deep, warm brown instead of black
const kCardBackgroundColor = Color(0xFFFFFFFF); // Clean white for cards
const kGoldAccent = Color(0xFFC0A063); // Muted, elegant gold
const kRedAccent = Color(0xFFC62828); // A deep, classic red

// Text Styles (Fusion of Classical and Modern)
final TextStyle kHeadingStyle = GoogleFonts.playfairDisplay(
  color: kPrimaryTextColor,
  fontWeight: FontWeight.w700,
);
final TextStyle kBodyTextStyle = GoogleFonts.lato(
  color: kPrimaryTextColor,
  height: 1.5, // Modern line spacing
);

class DashboardHome extends StatelessWidget {
  const DashboardHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        body: Center(
          // Constraining the width on larger screens for better readability
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: 40.0,
                vertical: 50.0,
              ),
              children: [
                SectionHeader(title: 'Recommended For You'),
                const SizedBox(height: 12),
                Text(
                  'Here are some books we think you will love based on your past reads, preferences, and interests.',
                  style: kBodyTextStyle.copyWith(
                    fontSize: 18,
                    color: kPrimaryTextColor.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 30),
                BookCardSection(type: 'item'),
                const SizedBox(height: 50),

                // We will use your *original* AIPromptSection component, lightly styled to fit.
                AIPromptSection(), // Assuming you have refactored your original AIPromptSection

                const SizedBox(height: 50),
                SectionHeader(title: 'From The Community'),
                const SizedBox(height: 12),
                Text(
                  'Here are some books that people with similar interests to you have read and loved.',
                  style: kBodyTextStyle.copyWith(
                    fontSize: 18,
                    color: kPrimaryTextColor.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 30),
                BookCardSection(type: 'user'),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// A new header widget that blends classical fonts with modern layout.
class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: kHeadingStyle.copyWith(fontSize: 32)),
        const SizedBox(height: 8),
        Container(height: 3, width: 60, color: kGoldAccent.withOpacity(0.8)),
      ],
    );
  }
}

class BookCardSection extends StatelessWidget {
  const BookCardSection({super.key, required this.type});
  final String type;

  @override
  Widget build(BuildContext context) {
    final providerUser = Provider.of<UserProvider>(context);

    return FutureBuilder<List<Book>>(
      future:
          type == 'item'
              ? BooksInfo().fetchBooks(providerUser.token)
              : BooksInfo().fetchBooksUser(providerUser.token),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: kPrimaryTextColor),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: kBodyTextStyle.copyWith(color: kRedAccent),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No books found'));
        }

        final books = snapshot.data!;

        // This container gives the grid section a modern, lifted look.
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: kCardBackgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: GridView.builder(
            // Important properties for a GridView inside a ListView
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, // Keep your original layout
              childAspectRatio: 0.8, // Adjust aspect ratio for your card design
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
            ),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              final rank = index + 1;

              // Using your UNCHANGED BookGridCard widget here.
              // It will automatically pick up the new theme variables.
              return BookGridCard(book: book, rank: rank);
            },
          ),
        );
      },
    );
  }
}

// YOUR ORIGINAL WIDGET - UNCHANGED IN STRUCTURE.
// We are only redefining the theme variables it consumes.
final TextStyle vintageTextStyle = GoogleFonts.lato(
  color: kPrimaryTextColor,
); // Modernized font
final Color vintageBorderColor = kGoldAccent.withOpacity(
  0.5,
); // Modernized color
const vintageRed = kRedAccent;

class BookGridCard extends StatefulWidget {
  const BookGridCard({super.key, required this.book, required this.rank});

  final Book book;
  final int rank;

  @override
  State<BookGridCard> createState() => _BookGridCardState();
}

class _BookGridCardState extends State<BookGridCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: () {
          // Navigate to book details page
          context.go(
            '/book/${widget.book.id}/${Uri.encodeComponent(widget.book.title)}',
          );
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(width: 1.5, color: vintageBorderColor),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: [
              // Thumbnail image
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    widget.book.thumbnail,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (ctx, err, st) => Container(
                          color: Colors.grey.shade200,
                          child: Icon(
                            Icons.book_outlined,
                            color: Colors.grey.shade400,
                          ),
                        ),
                  ),
                ),
              ),
              // Rank badge (always visible)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: kCardBackgroundColor.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '#${widget.rank}',
                    style: vintageTextStyle.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryTextColor.withOpacity(0.7),
                    ),
                  ),
                ),
              ),
              // Info overlay (only on hover)
              if (_hovering)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.book.title,
                          style: vintageTextStyle.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'by ${widget.book.authors}',
                          style: vintageTextStyle.copyWith(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (widget.book.ratingsCount != null)
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    widget.book.ratingsCount.toString(),
                                    style: vintageTextStyle.copyWith(
                                      fontSize: 13,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            if (widget.book.ratingsCount != null &&
                                widget.book.publishedYear != null)
                              const SizedBox(width: 10),
                            if (widget.book.publishedYear != null)
                              Text(
                                '${widget.book.publishedYear}',
                                style: vintageTextStyle.copyWith(
                                  fontSize: 13,
                                  color: Colors.white70,
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
      ),
    );
  }
}
