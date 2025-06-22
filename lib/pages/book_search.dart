import 'dart:convert';
import 'package:bookrec/components/book_grid.dart';
import 'package:bookrec/dummy/book.dart';
import 'package:bookrec/modals.dart/book_modal.dart';
import 'package:bookrec/provider/authprovider.dart';
import 'package:bookrec/theme/color.dart';
import 'package:bookrec/theme/texts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

const funkyTeal = Color(0xFF4DB6AC);

class SearchResultsPage extends StatefulWidget {
  final String prompt;

  const SearchResultsPage({Key? key, required this.prompt}) : super(key: key);

  @override
  _BookSearchResultsPageState createState() => _BookSearchResultsPageState();
}

class _BookSearchResultsPageState extends State<SearchResultsPage> {
  final String baseUrl = dotenv.env['baseUrl']!;

  double? _selectedRating;
  String? _selectedGenre;
  String? _selectedYear;

  int _currentPage = 1;
  int _totalItems = 0;
  final int _itemsPerPage = 20;

  final List<double> _ratingOptions = [5.0, 4.0, 3.0, 2.0];
  final List<String> _genreOptions = [
    'Fantasy',
    'Sci-Fi',
    'Mystery',
    'Romance',
    'History',
  ];
  final List<String> _yearOptions = ['desc', 'asc'];

  late Future<List<Book>> _futureBooks;

  @override
  void initState() {
    super.initState();
    _futureBooks = fetchBooks();
  }

  @override
  void didUpdateWidget(covariant SearchResultsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.prompt != widget.prompt) {
      setState(() {
        _currentPage = 1;
        _futureBooks = fetchBooks();
      });
    }
  }

  Future<List<Book>> fetchBooks() async {
    final providerUser = Provider.of<UserProvider>(context, listen: false);

    final Map<String, String> queryParams = {
      'search': widget.prompt,
      'page': _currentPage.toString(),
      'limit': _itemsPerPage.toString(),
      //'sortByYear': 'desc',
    };

    // ✅ Add filters based on dropdown selections
    if (_selectedGenre != null) {
      queryParams['categories'] = _selectedGenre!;
    } else {
      queryParams['categories'] = 'fiction,fantasy'; // fallback default
    }

    if (_selectedRating != null) {
      queryParams['minRating'] = _selectedRating!.toString();
    }

    if (_selectedYear != null) {
      queryParams['sortByYear'] = _selectedYear.toString();
    }

    final uri = Uri.https(
      Uri.parse(baseUrl).host,
      '/api/v1/users/books',
      queryParams,
    );

    print('URI: $uri');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${providerUser.token}',
        },
      );

      if (response.statusCode == 200) {
        print('Fetching books from: $uri');
        print('Success Status Code: ${response.statusCode}');

        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> bookList = jsonData['data'];
        final int totalMatches = jsonData['pagination']['totalMatches'];

        // Ensure UI updates when _totalItems changes
        if (mounted) {
          setState(() {
            _totalItems = totalMatches;
          });
        }

        return bookList.map((item) {
          return Book(
            id: item['isbn10'],
            title: item['title'],
            authors: item['authors'],
            thumbnail: item['thumbnail'],
            description: item['description'],
            publishedYear: item['published_year'] ?? 0,
            averageRating: (item['average_rating'] ?? 0).toDouble(),
            ratingsCount: item['ratings_count'] ?? 0,
          );
        }).toList();
      } else {
        throw Exception('Failed to load books: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching books: $e');
      throw Exception('Error fetching books: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: vintageCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.brown.shade800),
        title: Row(
          children: [
            Expanded(
              child: Column(
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
            Row(
              children: [
                _buildVintageDropdown<double>(
                  hint: "Rating",
                  value: _selectedRating,
                  items:
                      _ratingOptions
                          .map(
                            (rating) => DropdownMenuItem(
                              value: rating,
                              child: Text('>$rating ★'),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRating = value;
                      _currentPage = 1;
                      _futureBooks = fetchBooks();
                    });
                  },
                ),
                const SizedBox(width: 8),
                _buildVintageDropdown<String>(
                  hint: "Genre",
                  value: _selectedGenre,
                  items:
                      _genreOptions
                          .map(
                            (genre) => DropdownMenuItem(
                              value: genre,
                              child: Text(genre),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedGenre = value;
                      _currentPage = 1;
                      _futureBooks = fetchBooks();
                    });
                  },
                ),
                const SizedBox(width: 8),
                _buildVintageDropdown<String>(
                  hint: "Year",
                  value: _selectedYear,
                  items:
                      _yearOptions
                          .map(
                            (year) => DropdownMenuItem(
                              value: year,
                              child: Text(year),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedYear = value;
                      _currentPage = 1;
                      _futureBooks = fetchBooks();
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Book>>(
              future: _futureBooks,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
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
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Something went wrong: ${snapshot.error}',
                      style: vintageTextStyle,
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      "No books found matching your criteria.\nTry adjusting the filters!",
                      textAlign: TextAlign.center,
                      style: vintageTextStyle.copyWith(color: Colors.black54),
                    ),
                  );
                }

                final books = snapshot.data!;
                return LayoutBuilder(
                  builder: (context, constraints) {
                    double width = constraints.maxWidth;
                    int crossAxisCount;
                    double childAspectRatio;

                    if (width >= 1300) {
                      // Large Desktop
                      crossAxisCount = 5;
                      childAspectRatio = 1.7;
                    } else if (width >= 1000) {
                      // Desktop
                      crossAxisCount = 3;
                      childAspectRatio = 2;
                    } else if (width >= 700) {
                      // Tablet
                      crossAxisCount = 3;
                      childAspectRatio = 1.3;
                    } else if (width >= 500) {
                      // Mobile
                      crossAxisCount = 1;
                      childAspectRatio = 3.5;
                    } else {
                      // Small Mobile
                      crossAxisCount = 1;
                      childAspectRatio = 1.1;
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(16.0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                        childAspectRatio: childAspectRatio,
                      ),
                      itemCount: books.length,
                      itemBuilder: (context, index) {
                        final book = books[index];
                        final rank =
                            index + 1 + ((_currentPage - 1) * _itemsPerPage);
                        return BookGridCard(book: book, rank: rank);
                      },
                    );
                  },
                );
              },
            ),
          ),
          if (_totalItems > _itemsPerPage) _buildPaginationControls(),
        ],
      ),
    );
  }

  Widget _buildVintageDropdown<T>({
    required String hint,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      height: 38,
      width: 90,
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      decoration: BoxDecoration(
        color: vintageCream.withOpacity(0.6),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.brown.shade200, width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          hint: Text(
            hint,
            style: vintageTextStyle.copyWith(
              fontSize: 13,
              color: Colors.black.withOpacity(0.7),
            ),
            overflow: TextOverflow.ellipsis,
          ),
          style: vintageTextStyle.copyWith(
            fontSize: 13,
            color: Colors.brown.shade900,
          ),
          icon: Icon(Icons.expand_more, color: Colors.brown.shade800, size: 20),
          dropdownColor: vintageCream,
          isExpanded: true,
        ),
      ),
    );
  }

  Widget _buildPaginationControls() {
    final int totalPages = (_totalItems / _itemsPerPage).ceil();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed:
                _currentPage > 1
                    ? () {
                      setState(() {
                        _currentPage--;
                        _futureBooks = fetchBooks();
                      });
                    }
                    : null,
            child: Text(
              "« Prev",
              style: vintageTextStyle.copyWith(
                color: _currentPage > 1 ? Colors.brown.shade800 : Colors.grey,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Page $_currentPage of $totalPages",
              style: vintageTextStyle.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed:
                _currentPage < totalPages
                    ? () {
                      setState(() {
                        _currentPage++;
                        _futureBooks = fetchBooks();
                      });
                    }
                    : null,
            child: Text(
              "Next »",
              style: vintageTextStyle.copyWith(
                color:
                    _currentPage < totalPages
                        ? Colors.brown.shade800
                        : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// The BookGridCard widget remains unchanged.
