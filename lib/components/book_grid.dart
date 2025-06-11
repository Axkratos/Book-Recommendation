import 'dart:convert';
import 'dart:math';

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
    return Scaffold(
      backgroundColor: vintageCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Blends into the body
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.brown.shade800,
        ), // Dark back arrow
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
                padding: const EdgeInsets.all(16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // Number of columns
                  crossAxisSpacing: 16.0, // Horizontal space between cards
                  mainAxisSpacing: 16.0, // Vertical space between cards
                  childAspectRatio: 3, // Aspect ratio of items (Width / Height)
                ),
                itemCount: _foundBooks.length,
                itemBuilder: (context, index) {
                  final book = _foundBooks[index];
                  return BookGridCard(book: book, rank: index + 1);
                },
              ),
    );
  }
}

// A dedicated widget for the card in the grid for cleaner code
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
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              // Book cover with rank overlay
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
