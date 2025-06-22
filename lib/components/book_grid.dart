import 'dart:convert';
import 'dart:math';
import 'package:bookrec/services/booksapi.dart';

import 'package:bookrec/modals.dart/book_modal.dart';
import 'package:bookrec/provider/authprovider.dart';
import 'package:bookrec/theme/color.dart';
import 'package:bookrec/theme/texts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart'; // To make HTTP requests
import 'package:bookrec/components/star.dart'; // Add this import

const funkyTeal = Color(0xFF4DB6AC);

class BookSearchResultsPage extends StatefulWidget {
  final String prompt;

  const BookSearchResultsPage({Key? key, required this.prompt})
    : super(key: key);

  @override
  _BookSearchResultsPageState createState() => _BookSearchResultsPageState();
}

class _BookSearchResultsPageState extends State<BookSearchResultsPage> {
  bool _isLoading = true;
  List<Book> _foundBooks = [];
  final String baseUrl = dotenv.env['baseUrl']!;

  @override
  void initState() {
    super.initState();
    // Start fetching books as soon as the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final providerUser = Provider.of<UserProvider>(context, listen: false);
      setState(() {
        _fetchBooksBasedOnPrompt(providerUser.token);
      });
    });
  }

  // This is a FAKE API call to simulate fetching data

  Future<void> _fetchBooksBasedOnPrompt(String token) async {
    final uri = Uri.parse('${baseUrl}/api/v1/books/recommend/llm');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'text': widget.prompt,
          //'limit': 30, // Limit to 30 books
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        final List<Book> books =
            data
                .map(
                  (item) => Book(
                    id: item['isbn10'] ?? '',
                    title: item['title'] ?? '',
                    authors: item['authors'] ?? 'Unknown',
                    thumbnail: item['thumbnail'] ?? '',
                    description: item['description'] ?? '',
                    publishedYear: item['published_year'] ?? 0,
                    averageRating: (item['average_rating'] ?? 0).toDouble(),
                    ratingsCount: item['ratings_count'] ?? 0,
                  ),
                )
                .toList();

        if (mounted) {
          setState(() {
            _foundBooks = books;
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load books');
      }
    } catch (e) {
      print('Error fetching llm books: $e');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive breakpoints
    final bool isMobile = screenWidth < 500;
    final bool isTablet = screenWidth >= 500 && screenWidth < 900;
    final bool isLaptop = screenWidth >= 900 && screenWidth < 1200;
    final bool isDesktop = screenWidth >= 1200;

    // Responsive grid and sizing
    int crossAxisCount;
    double gridPadding;
    double crossSpacing;
    double mainSpacing;
    double childAspectRatio;

    if (isMobile) {
      crossAxisCount = 1;
      gridPadding = 8.0;
      crossSpacing = 8.0;
      mainSpacing = 8.0;
      childAspectRatio = 2.5;
    } else if (isTablet) {
      crossAxisCount = 2;
      gridPadding = 16.0;
      crossSpacing = 16.0;
      mainSpacing = 16.0;
      childAspectRatio = 1.1;
    } else if (isLaptop) {
      crossAxisCount = 3;
      gridPadding = 20.0;
      crossSpacing = 20.0;
      mainSpacing = 20.0;
      childAspectRatio = 1.5;
    } else {
      crossAxisCount = 4;
      gridPadding = 24.0;
      crossSpacing = 24.0;
      mainSpacing = 24.0;
      childAspectRatio = 1.5;
    }

    return Scaffold(
      backgroundColor: vintageCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.brown.shade800),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Conjuring results for...",
              style: vintageTextStyle.copyWith(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            Text(
              "'${widget.prompt}'",
              style: vintageTextStyle.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      body:
          _isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: funkyTeal),
                    const SizedBox(height: 20),
                    Text(
                      "Summoning books from the ether...",
                      style: vintageTextStyle,
                    ),
                  ],
                ),
              )
              : GridView.builder(
                padding: EdgeInsets.all(gridPadding),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: crossSpacing,
                  mainAxisSpacing: mainSpacing,
                  childAspectRatio: childAspectRatio,
                ),
                itemCount: _foundBooks.length,
                itemBuilder: (context, index) {
                  final book = _foundBooks[index];
                  return BookGridCard(
                    book: book,
                    rank: index + 1,
                    // Pass sizing info for card responsiveness
                    isSmallScreen: isMobile,
                    isTablet: isTablet,
                    isLaptop: isLaptop,
                    isDesktop: isDesktop,
                  );
                },
              ),
    );
  }
}

// A dedicated widget for the card in the grid for cleaner code
class BookGridCard extends StatelessWidget {
  final Book book;
  final int rank;
  final bool isSmallScreen;
  final bool isTablet;
  final bool isLaptop;
  final bool isDesktop;

  BookGridCard({
    Key? key,
    required this.book,
    required this.rank,
    this.isSmallScreen = false,
    this.isTablet = false,
    this.isLaptop = false,
    this.isDesktop = false,
  }) : super(key: key);

  // Add this function to fetch ratings count
  BooksInfo bookInfo = BooksInfo();

  @override
  Widget build(BuildContext context) {
    const primaryTextColor = Color(0xFF4A403A);
    const secondaryTextColor = Color(0xFF7B6F66);

    // Responsive sizing
    double coverWidth;
    double coverHeight;
    double titleFont;
    double authorFont;
    double starSize;
    double iconSize;
    double infoFont;
    double cardMargin;
    double cardPadding;
    double spacing;

    if (isSmallScreen) {
      coverWidth = 60;
      coverHeight = 90;
      titleFont = 15;
      authorFont = 12;
      starSize = 1;
      iconSize = 15;
      infoFont = 11;
      cardMargin = 8;
      cardPadding = 8;
      spacing = 8;
    } else if (isTablet) {
      coverWidth = 80;
      coverHeight = 120;
      titleFont = 17;
      authorFont = 14;
      starSize = 1;
      iconSize = 17;
      infoFont = 12;
      cardMargin = 14;
      cardPadding = 12;
      spacing = 12;
    } else if (isLaptop) {
      coverWidth = 100;
      coverHeight = 150;
      titleFont = 19;
      authorFont = 15;
      starSize = 17;
      iconSize = 19;
      infoFont = 13;
      cardMargin = 18;
      cardPadding = 16;
      spacing = 16;
    } else {
      coverWidth = 120;
      coverHeight = 180;
      titleFont = 21;
      authorFont = 16;
      starSize = 19;
      iconSize = 21;
      infoFont = 14;
      cardMargin = 22;
      cardPadding = 20;
      spacing = 20;
    }

    // Get token from Provider
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.token;
    Future<String> rate(String bookID, int value) async {
      final String response = await bookInfo.bookRatings(bookID, value, token);
      return response;
    }

    return GestureDetector(
      onTap: () {
        context.push('/book/${book.id}/${book.title}');
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: cardMargin,
          vertical: cardMargin / 2,
        ),
        padding: EdgeInsets.only(bottom: cardPadding),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0x334A403A), width: 1),
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book cover with rank overlay
              Stack(
                alignment: Alignment.topLeft,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: cardMargin / 2,
                      top: cardMargin / 2,
                    ),
                    child: _buildBookCover(
                      book.thumbnail,
                      coverWidth,
                      coverHeight,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: cardMargin / 2,
                      vertical: cardMargin / 4,
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
                        fontSize: infoFont + 1,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: spacing),
              // Book details
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
                        fontSize: titleFont,
                        color: primaryTextColor,
                      ),
                    ),
                    SizedBox(height: spacing / 4),
                    Text(
                      'by ${book.authors}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.lato(
                        fontSize: authorFont,
                        color: secondaryTextColor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: spacing / 4,
                        bottom: spacing / 4,
                      ),
                      child: StarRating(
                        token: token,
                        bookId: book.id!,
                        getRatingsCount: bookInfo.getRatingsCount,
                        size: starSize,
                        color: Colors.amber,
                        onRatingChanged: (value) async {
                          final String r = await rate(book.id!, value);
                          print('Rating response: $r');
                          if (r == 'sucess') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Rating submitted!'),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $r')),
                            );
                          }
                        },
                      ),
                    ),
                    const Spacer(),
                    Wrap(
                      spacing: spacing,
                      runSpacing: spacing / 2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: iconSize,
                            ),
                            SizedBox(width: spacing / 4),
                            Text(
                              book.averageRating.toString(),
                              style: GoogleFonts.lato(
                                fontWeight: FontWeight.bold,
                                color: primaryTextColor,
                                fontSize: infoFont,
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
                            SizedBox(width: spacing / 4),
                            Text(
                              book.publishedYear.toString(),
                              style: GoogleFonts.lato(
                                color: secondaryTextColor,
                                fontSize: infoFont,
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

  Widget _buildBookCover(String url, double width, double height) {
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
