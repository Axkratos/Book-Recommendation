// lib/pages/search_results_page.dart

import 'dart:async';
import 'package:bookrec/modals.dart/book_modal.dart';
import 'package:bookrec/services/booksapi.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchResultsPage extends StatefulWidget {
  const SearchResultsPage({super.key});

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  // Controllers
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  // State Management
  List<Book> _books = [];
  int _currentPage = 1;
  bool _isLoading = false; // For initial load and re-fetches
  bool _isLoadingMore = false; // For lazy loading
  bool _hasMore = true; // To know when to stop fetching
  Timer? _debounce;

  // Filter State
  List<String> _selectedCategories = [];
  final List<String> _availableCategories = [
    'Fiction',
    'Art',
    'History',
    'Bibles',
    'Comics & Graphic Novels',
    'Literary Criticism',
  ];
      final bookInfo = BooksInfo();


  @override
  void initState() {
    super.initState();
    // Initial fetch of books
    _resetAndFetch();

    // Listener for lazy loading
    _scrollController.addListener(() {
      // If we are at the end of the scroll and there is more data, and not already loading
      if (_scrollController.position.maxScrollExtent ==
              _scrollController.position.pixels &&
          _hasMore &&
          !_isLoadingMore) {
        _fetchMoreBooks();
      }
    });

    // Debounce for search input to avoid API spam
    _searchController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 700), () {
        _resetAndFetch();
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  /// Clears current data and fetches page 1 with new filters
  Future<void> _resetAndFetch() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _books.clear();
      _currentPage = 1;
      _hasMore = true;
    });
    try {
      final newBooks = await bookInfo.fetchSearchBooks(
        searchTerm: _searchController.text,
        categories: _selectedCategories,
        page: _currentPage,
      );

      setState(() {
        _books = newBooks;
        if (newBooks.length < 20) {
          // Assuming page limit is 20
          _hasMore = false;
        }
        _currentPage++;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Fetches the next page and appends it to the list
  Future<void> _fetchMoreBooks() async {
    setState(() => _isLoadingMore = true);

    final newBooks = await bookInfo.fetchSearchBooks(
      searchTerm: _searchController.text,
      categories: _selectedCategories,
      page: _currentPage,
    );

    if (newBooks.isEmpty) {
      setState(() => _hasMore = false);
    } else {
      setState(() {
        _books.addAll(newBooks);
        _currentPage++;
      });
    }

    setState(() => _isLoadingMore = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F2EA),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(),
          // Initial Loading Indicator
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
          // No results message
          if (!_isLoading && _books.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Text(
                  "No books found. Try adjusting your search.",
                  style: GoogleFonts.literata(),
                ),
              ),
            ),
          // The responsive grid of books
          if (!_isLoading && _books.isNotEmpty) _buildSliverResponsiveGrid(),

          // Lazy loading indicator at the bottom
          if (_isLoadingMore)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      title: Text('Explore Books', style: GoogleFonts.literata()),
      backgroundColor: const Color(0xFFF6F2EA),
      floating: true, // App bar becomes visible as soon as you scroll up
      pinned: true, // Filters stay visible
      snap: true,
      elevation: 1,
      forceElevated: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(110.0),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            children: [
              // Search Field
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by title or author...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                ),
              ),
              const SizedBox(height: 12),
              // Filter Chips
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children:
                      _availableCategories.map((category) {
                        final isSelected = _selectedCategories.contains(
                          category,
                        );
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            label: Text(category),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedCategories.add(category);
                                } else {
                                  _selectedCategories.remove(category);
                                }
                              });
                              _resetAndFetch(); // Trigger a refetch
                            },
                            labelStyle: GoogleFonts.lato(
                              color:
                                  isSelected
                                      ? Colors.white
                                      : Colors.purple[800],
                            ),
                            selectedColor: Colors.purple[700],
                            backgroundColor: Colors.white,
                            checkmarkColor: Colors.white,
                            shape: StadiumBorder(
                              side: BorderSide(color: Colors.purple[200]!),
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverResponsiveGrid() {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount;
          double childAspectRatio;

          if (constraints.maxWidth > 1200) {
            crossAxisCount = 5;
            childAspectRatio = 0.65;
          } else if (constraints.maxWidth > 800) {
            crossAxisCount = 4;
            childAspectRatio = 0.7;
          } else if (constraints.maxWidth > 500) {
            crossAxisCount = 3;
            childAspectRatio = 0.75;
          } else {
            crossAxisCount = 2;
            childAspectRatio = 0.7;
          }

          return SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: childAspectRatio,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => BookCard(book: _books[index]),
              childCount: _books.length,
            ),
          );
        },
      ),
    );
  }
}

// lib/widgets/book_card.dart



class BookCard extends StatelessWidget {
  final Book book;

  const BookCard({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Card(
      // Modern: Clean elevation and rounded shape
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      // Vintage: Off-white background color
      color: const Color(0xFFFDFCF7), 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Image.network(
                book.thumbnail,
                fit: BoxFit.cover,
                width: double.infinity,
                // Placeholder and error widgets for a better user experience
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  );
                },
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Vintage: Serif font for title
                  Text(
                    book.title,
                    style: GoogleFonts.literata(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    book.authors.split(';').first, // Show only the first author
                    style: GoogleFonts.lato(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber[700], size: 18),
                      const SizedBox(width: 4),
                      Text(
                        book.averageRating.toString(),
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 2),
                       Text(
                        '(${book.ratingsCount})',
                        style: GoogleFonts.lato(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
