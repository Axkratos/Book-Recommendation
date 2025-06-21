import 'dart:convert';
import 'dart:async'; // Import for Timer
import 'dart:math';

import 'package:bookrec/components/VintageButton.dart';
import 'package:bookrec/components/book_grid.dart';
import 'package:bookrec/components/chat_ai.dart';
import 'package:bookrec/components/llmRec.dart';
import 'package:bookrec/dummy/book.dart';
import 'package:bookrec/modals.dart/book_modal.dart';
import 'package:bookrec/pages/FeaturedPage.dart';
import 'package:bookrec/provider/authprovider.dart';
import 'package:bookrec/provider/bookprovider.dart';
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

                // We will use your *original* AIPromptSection component, lightly styled to fit.
                AIPromptSection(), // Assuming you have refactored your original AIPromptSection

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

                // =============================================================
                // ================== NEW EXPLORE SECTION ======================
                // =============================================================
                BookExploreSection(),
                const SizedBox(height: 50),

                // =============================================================
                // ================== NEW AUTHORS SECTION ======================
                // =============================================================
                ExploreAuthorsSection(),
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

// =================================================================
// ========= Data Models & Widgets for Explore Sections ============
// =================================================================

// -------- Genre Explore Section --------

class GenreCategory {
  final String name;
  final List<Color> gradientColors;
  GenreCategory({required this.name, required this.gradientColors});
}

final List<GenreCategory> bookGenres = [
  GenreCategory(
    name: 'Fantasy',
    gradientColors: [Color(0xff6a11cb), Color(0xff2575fc)],
  ),
  GenreCategory(
    name: 'Science Fiction',
    gradientColors: [Color(0xff00c6ff), Color(0xff0072ff)],
  ),
  GenreCategory(
    name: 'Mystery & Thriller',
    gradientColors: [Color(0xff304352), Color(0xffd7d2cc)],
  ),
  GenreCategory(
    name: 'Biography',
    gradientColors: [Color(0xffd38312), Color(0xffa83279)],
  ),
  GenreCategory(
    name: 'Historical Fiction',
    gradientColors: [Color(0xff434343), Color(0xff000000)],
  ),
  GenreCategory(
    name: 'Romance',
    gradientColors: [Color(0xffc31432), Color(0xff240b36)],
  ),
  GenreCategory(
    name: 'Horror',
    gradientColors: [Color(0xffB20a2c), Color(0xff100c08)],
  ),
  GenreCategory(
    name: 'Philosophy',
    gradientColors: [Color(0xffa8c0ff), Color(0xff3f2b96)],
  ),
];

class BookExploreSection extends StatefulWidget {
  const BookExploreSection({Key? key}) : super(key: key);
  @override
  State<BookExploreSection> createState() => _BookExploreSectionState();
}

class _BookExploreSectionState extends State<BookExploreSection> {
  late List<bool> _isCardVisible;
  @override
  void initState() {
    super.initState();
    _isCardVisible = List.generate(bookGenres.length, (_) => false);
    _triggerStaggeredAnimation();
  }

  void _triggerStaggeredAnimation() async {
    for (int i = 0; i < bookGenres.length; i++) {
      await Future.delayed(const Duration(milliseconds: 90));
      if (mounted) setState(() => _isCardVisible[i] = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Explore Genres'),
        const SizedBox(height: 12),
        Text(
          'Browse by your favorite genres and discover new worlds to dive into.',
          style: kBodyTextStyle.copyWith(
            fontSize: 18,
            color: kPrimaryTextColor.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 30),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 280,
            childAspectRatio: 1.8,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
          ),
          itemCount: bookGenres.length,
          itemBuilder: (context, index) {
            final genre = bookGenres[index];
            return AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: _isCardVisible[index] ? 1.0 : 0.0,
              curve: Curves.easeIn,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 400),
                offset:
                    _isCardVisible[index] ? Offset.zero : const Offset(0, 0.4),
                curve: Curves.easeOut,
                child: ExploreGenreCard(
                  genre: genre.name,
                  gradientColors: genre.gradientColors,
                  onTap: () {
                    context.go('/search/${Uri.encodeComponent(genre.name)}');
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class ExploreGenreCard extends StatefulWidget {
  final String genre;
  final List<Color> gradientColors;
  final VoidCallback onTap;
  const ExploreGenreCard({
    Key? key,
    required this.genre,
    required this.gradientColors,
    required this.onTap,
  }) : super(key: key);
  @override
  State<ExploreGenreCard> createState() => _ExploreGenreCardState();
}

class _ExploreGenreCardState extends State<ExploreGenreCard> {
  bool _isHovering = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovering ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: widget.gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow:
                  _isHovering
                      ? [
                        BoxShadow(
                          color: widget.gradientColors[1].withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ]
                      : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
            ),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                widget.genre,
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// -------- Author Explore Section --------

class Author {
  final String name;
  final String portraitUrl;
  final String tagline;
  final List<String> knownFor;
  final List<String> backgroundCoverUrls;
  Author({
    required this.name,
    required this.portraitUrl,
    required this.tagline,
    required this.knownFor,
    required this.backgroundCoverUrls,
  });
}

final List<Author> sampleAuthors = [
  Author(
    name: 'J.R.R. Tolkien',
    tagline: 'Father of Modern Fantasy',
    portraitUrl:
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSaZOhEQxOJbiDFktRVYAY10KUFqgoK36YdYA&s',
    knownFor: ['The Hobbit', 'The Lord of the Rings', 'The Silmarillion'],
    backgroundCoverUrls: [
      'https://covers.openlibrary.org/b/id/12810557-L.jpg',
      'https://covers.openlibrary.org/b/id/10523338-L.jpg',
    ],
  ),
  Author(
    name: 'Stephen King',
    tagline: 'The King of Horror',
    portraitUrl:
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS7fPAygwjZNL3-rt0VdIffNrUljbdD7EqZG-lk66WL6wVE6MToHUTH_hg&s',
    knownFor: ['The Shining', 'It', 'The Stand'],
    backgroundCoverUrls: [
      'https://covers.openlibrary.org/b/id/12693824-L.jpg',
      'https://covers.openlibrary.org/b/id/12711397-L.jpg',
    ],
  ),
  Author(
    name: 'Jane Austen',
    tagline: 'A Pioneer of the Novel',
    portraitUrl:
        'https://upload.wikimedia.org/wikipedia/commons/1/1b/Jane_Austen.jpg',
    knownFor: ['Pride and Prejudice', 'Sense and Sensibility', 'Emma'],
    backgroundCoverUrls: [
      'https://covers.openlibrary.org/b/id/11181829-L.jpg',
      'https://covers.openlibrary.org/b/id/8440316-L.jpg',
    ],
  ),
  Author(
    name: 'Haruki Murakami',
    tagline: 'Master of Magical Realism',
    portraitUrl:
        'https://upload.wikimedia.org/wikipedia/commons/6/6c/Photo_signed_by_Haruki_Murakami.jpg',
    knownFor: ['Norwegian Wood', 'Kafka on the Shore', '1Q84'],
    backgroundCoverUrls: [
      'https://covers.openlibrary.org/b/id/10041267-L.jpg',
      'https://covers.openlibrary.org/b/id/10298642-L.jpg',
    ],
  ),
  Author(
    name: 'Agatha Christie',
    tagline: 'Queen of Mystery',
    portraitUrl:
        'https://upload.wikimedia.org/wikipedia/commons/1/1f/Agatha_Christie.png',
    knownFor: [
      'Murder on the Orient Express',
      'And Then There Were None',
      'The Murder of Roger Ackroyd',
    ],
    backgroundCoverUrls: [
      'https://covers.openlibrary.org/b/id/8231856-L.jpg',
      'https://covers.openlibrary.org/b/id/10523338-L.jpg',
    ],
  ),
  Author(
    name: 'George Orwell',
    tagline: 'Visionary of Dystopia',
    portraitUrl:
        'https://upload.wikimedia.org/wikipedia/commons/9/9e/George_Orwell_press_photo.jpg',
    knownFor: ['1984', 'Animal Farm', 'Homage to Catalonia'],
    backgroundCoverUrls: [
      'https://covers.openlibrary.org/b/id/11153234-L.jpg',
      'https://covers.openlibrary.org/b/id/10958354-L.jpg',
    ],
  ),
  Author(
    name: 'Maya Angelou',
    tagline: 'Voice of Resilience',
    portraitUrl:
        'https://upload.wikimedia.org/wikipedia/commons/b/b4/Angelou_at_Clinton_inauguration.jpg',
    knownFor: [
      'I Know Why the Caged Bird Sings',
      'Gather Together in My Name',
      'And Still I Rise',
    ],
    backgroundCoverUrls: [
      'https://covers.openlibrary.org/b/id/10498765-L.jpg',
      'https://covers.openlibrary.org/b/id/10523338-L.jpg',
    ],
  ),
  Author(
    name: 'Gabriel García Márquez',
    tagline: 'Master of Magical Realism',
    portraitUrl:
        'https://upload.wikimedia.org/wikipedia/commons/1/1e/Gabriel_Garcia_Marquez.jpg',
    knownFor: [
      'One Hundred Years of Solitude',
      'Love in the Time of Cholera',
      'Chronicle of a Death Foretold',
    ],
    backgroundCoverUrls: [
      'https://covers.openlibrary.org/b/id/11181829-L.jpg',
      'https://covers.openlibrary.org/b/id/10041267-L.jpg',
    ],
  ),
];

class ExploreAuthorsSection extends StatefulWidget {
  const ExploreAuthorsSection({Key? key}) : super(key: key);

  @override
  State<ExploreAuthorsSection> createState() => _ExploreAuthorsSectionState();
}

class _ExploreAuthorsSectionState extends State<ExploreAuthorsSection> {
  final ScrollController _scrollController = ScrollController();

  void _scrollLeft() {
    _scrollController.animateTo(
      (_scrollController.offset - 300).clamp(
        0,
        _scrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      (_scrollController.offset + 300).clamp(
        0,
        _scrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Author Spotlights'),
        const SizedBox(height: 12),
        Text(
          'Discover the minds behind the masterpieces. Explore collections from legendary authors.',
          style: kBodyTextStyle.copyWith(
            fontSize: 18,
            color: kPrimaryTextColor.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 30),
        SizedBox(
          height: 320,
          child: Stack(
            children: [
              ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: sampleAuthors.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(left: index == 0 ? 0 : 20),
                    child: AuthorCard(author: sampleAuthors[index]),
                  );
                },
              ),
              // Left button
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Center(
                  child: IconButton(
                    icon: const Icon(
                      Icons.chevron_left,
                      size: 36,
                      color: kGoldAccent,
                    ),
                    onPressed: _scrollLeft,
                    splashRadius: 24,
                    tooltip: 'Scroll left',
                  ),
                ),
              ),
              // Right button
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: Center(
                  child: IconButton(
                    icon: const Icon(
                      Icons.chevron_right,
                      size: 36,
                      color: kGoldAccent,
                    ),
                    onPressed: _scrollRight,
                    splashRadius: 24,
                    tooltip: 'Scroll right',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AuthorCard extends StatefulWidget {
  final Author author;
  const AuthorCard({Key? key, required this.author}) : super(key: key);

  @override
  _AuthorCardState createState() => _AuthorCardState();
}

class _AuthorCardState extends State<AuthorCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          // Navigate to search page with author name as prompt
          context.go('/search/${Uri.encodeComponent(widget.author.name)}');
        },
        child: SizedBox(
          width: 260, // Fixed width for each card
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Layer 1: Tiled background of book covers
                ..._buildTiledBackground(),

                // Layer 2: Darkening gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.2),
                        Colors.black.withOpacity(0.9),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.0, 0.7],
                    ),
                  ),
                ),

                // Layer 3: Author info (Portrait, Name, Tagline)
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Spacer(),
                      Center(
                        child: AnimatedScale(
                          scale: _isHovering ? 1.1 : 1.0,
                          duration: const Duration(milliseconds: 250),
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: kGoldAccent.withOpacity(0.8),
                                width: 3,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.network(
                                widget.author.portraitUrl,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) => const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.white,
                                    ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        widget.author.name,
                        style: kHeadingStyle.copyWith(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.author.tagline,
                        style: kBodyTextStyle.copyWith(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),

                // Layer 4: Hover reveal of "Known For" books
                _buildHoverOverlay(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper to build the tiled background
  List<Widget> _buildTiledBackground() {
    // Repeat the list to ensure there's enough to fill the background
    final covers = [
      ...widget.author.backgroundCoverUrls,
      ...widget.author.backgroundCoverUrls.reversed,
    ];
    return List.generate(
      4, // Create a 2x2 grid
      (index) => Positioned(
        left: (index % 2) * 130.0, // 260 / 2
        top: (index ~/ 2) * 160.0, // 320 / 2
        width: 130,
        height: 160,
        child: Opacity(
          opacity: 0.3,
          child: Image.network(
            covers[index % covers.length], // loop through covers
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: Colors.grey),
          ),
        ),
      ),
    );
  }

  // Helper to build the overlay shown on hover
  Widget _buildHoverOverlay() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: _isHovering ? 1.0 : 0.0,
      child: Container(
        color: kPrimaryTextColor.withOpacity(0.9),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Known For",
                style: kBodyTextStyle.copyWith(
                  color: kGoldAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...widget.author.knownFor
                  .map(
                    (title) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        '“$title”',
                        style: kBodyTextStyle.copyWith(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================
// ============ Your Existing Book Sections Below ===============
// =============================================================

class BookCardSection extends StatefulWidget {
  const BookCardSection({super.key, required this.type});
  final String type;

  @override
  State<BookCardSection> createState() => _BookCardSectionState();
}

class _BookCardSectionState extends State<BookCardSection> {
  late Future<void> _booksFuture;

  @override
  void initState() {
    super.initState();
    _booksFuture = _fetchBooksIfNeeded();
  }

  Future<void> _fetchBooksIfNeeded() async {
    final providerUser = Provider.of<UserProvider>(context, listen: false);
    final bookProvider = Provider.of<Bookprovider>(context, listen: false);

    if (widget.type == 'item') {
      if (bookProvider.itemBook.isEmpty) {
        final books = await BooksInfo().fetchBooks(providerUser.token);
        bookProvider.itemBook = books;
      }
    } else {
      if (bookProvider.books.isEmpty) {
        final books = await BooksInfo().fetchBooksUser(providerUser.token);
        bookProvider.books = books;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<Bookprovider>(context);
    final books =
        widget.type == 'item' ? bookProvider.itemBook : bookProvider.books;

    return FutureBuilder<void>(
      future: _booksFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: kPrimaryTextColor),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Like at least five books to see recommendations',
              style: kBodyTextStyle.copyWith(color: kRedAccent),
            ),
          );
        } else if (books.isEmpty) {
          return const Center(child: Text('No books found'));
        }

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
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.8,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
            ),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              final rank = index + 1;
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
                    errorBuilder: (ctx, err, st) {
                      final random = Random();
                      final randomImage =
                          sampleBookImages[random.nextInt(
                            sampleBookImages.length,
                          )];
                      return Image.network(randomImage, fit: BoxFit.cover);
                    },
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
                                    (widget.book.averageRating).toString(),
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

final List<String> sampleBookImages = [
  'https://covers.openlibrary.org/b/id/10523338-L.jpg',
  'https://covers.openlibrary.org/b/id/11153234-L.jpg',
  'https://covers.openlibrary.org/b/id/10958354-L.jpg',
  'https://covers.openlibrary.org/b/id/10498765-L.jpg',
  // Add more URLs as you like
];
