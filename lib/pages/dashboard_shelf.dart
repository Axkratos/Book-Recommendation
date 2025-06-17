import 'package:bookrec/provider/authprovider.dart'; // Assuming these are correct
import 'package:bookrec/services/booksapi.dart'; // Assuming these are correct
import 'package:bookrec/theme/color.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// --- Modern Theme Colors & Styles ---
class ModernTheme {
  static const Color background = Color(0xFFF0F2F5); // Light Gray
  static const Color cardColor = Colors.white;
  static const Color primary = Color(0xFF673AB7); // Deep Purple
  static const Color accent = Color(0xFF009688); // Teal
  static const Color textColor = Color(0xFF333333);
  static const Color subtleTextColor = Color(0xFF666666);
  static const Color divider = Color(0xFFE0E0E0);

  static final TextStyle title = TextStyle(
    color: textColor,
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );

  static final TextStyle subtitle = TextStyle(
    color: textColor,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle bodyText = TextStyle(color: textColor, fontSize: 15);

  static final TextStyle subtleText = TextStyle(
    color: subtleTextColor,
    fontSize: 14,
  );
}
// --- End of Theme ---

class DashboardShelf extends StatefulWidget {
  const DashboardShelf({Key? key}) : super(key: key);

  @override
  State<DashboardShelf> createState() => _DashboardShelfState();
}

class _DashboardShelfState extends State<DashboardShelf> {
  late Future<List<Map<String, dynamic>>> _shelfFuture;
  List<Map<String, dynamic>> _allBooks = [];
  List<Map<String, dynamic>> _filteredBooks = [];
  String _currentSort = 'Latest';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Use a local variable to avoid late initialization issues
    final provider = Provider.of<UserProvider>(context, listen: false);
    _shelfFuture = BooksInfo().fetchBookShelf(provider.token).then((books) {
      setState(() {
        _allBooks = books;
        _filteredBooks = _sortAndFilterBooks();
      });
      return books;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSortChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        _currentSort = newValue;
        _filteredBooks = _sortAndFilterBooks();
      });
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _filteredBooks = _sortAndFilterBooks();
    });
  }

  List<Map<String, dynamic>> _sortAndFilterBooks() {
    List<Map<String, dynamic>> booksToShow = List.from(_allBooks);

    // Filter by search query
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      booksToShow =
          booksToShow.where((book) {
            final title = book['title']?.toString().toLowerCase() ?? '';
            final author = book['author']?.toString().toLowerCase() ?? '';
            return title.contains(query) || author.contains(query);
          }).toList();
    }

    // Sort the filtered list
    switch (_currentSort) {
      case 'Alphabetical':
        booksToShow.sort(
          (a, b) => a['title'].toString().compareTo(b['title'].toString()),
        );
        break;
      case 'Rating':
        booksToShow.sort(
          (a, b) => (b['rating'] ?? 0.0).compareTo(a['rating'] ?? 0.0),
        );
        break;
      case 'Latest':
      default:
        booksToShow.sort(
          (a, b) => (b['publication_year'] ?? 0).compareTo(
            a['publication_year'] ?? 0,
          ),
        );
        break;
    }
    return booksToShow;
  }

  Future<void> _removeBook(int index, Map<String, dynamic> book) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            title: const Text('Confirm Removal'),
            content: Text('Remove "${book['title']}" from your shelf?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Remove'),
              ),
            ],
          ),
    );

    if (confirm == true && mounted) {
      try {
        final providerUser = Provider.of<UserProvider>(context, listen: false);
        final success = await BooksInfo().removeBookFromShelf(
          providerUser.token,
          book['isbn10'],
        );

        if (success && mounted) {
          setState(() {
            _allBooks.removeWhere((b) => b['isbn10'] == book['isbn10']);
            _filteredBooks = _sortAndFilterBooks();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${book['title']} removed.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error removing book: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: vintageCream,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _shelfFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'Your shelf is empty. Go add some books!',
                style: ModernTheme.subtitle,
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              // Define breakpoints
              const double mobileBreakpoint = 600;
              const double tabletBreakpoint = 1100;

              bool isMobile = constraints.maxWidth < mobileBreakpoint;
              bool isTablet =
                  constraints.maxWidth >= mobileBreakpoint &&
                  constraints.maxWidth < tabletBreakpoint;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        final provider = Provider.of<UserProvider>(
                          context,
                          listen: false,
                        );
                        final newBooks = await BooksInfo().fetchBookShelf(
                          provider.token,
                        );
                        setState(() {
                          _allBooks = newBooks;
                          _filteredBooks = _sortAndFilterBooks();
                        });
                      },
                      child:
                          isMobile
                              ? ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                itemCount: _filteredBooks.length,
                                itemBuilder: (context, index) {
                                  final book = _filteredBooks[index];
                                  return Column(
                                    children: [
                                      _BookListItem(
                                        book: book,
                                        isMobile: isMobile,
                                        isTablet: isTablet,
                                        onRemove:
                                            () => _removeBook(index, book),
                                      ),
                                      Divider(
                                        color: ModernTheme.divider,
                                        height: 1.0,
                                        indent: isMobile ? 0 : 16.0,
                                        endIndent: isMobile ? 0 : 16.0,
                                      ),
                                    ],
                                  );
                                },
                              )
                              : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                itemCount:
                                    _filteredBooks.length + 1, // +1 for header
                                itemBuilder: (context, index) {
                                  if (index == 0) {
                                    // Desktop header row
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8.0,
                                      ),
                                      child: Row(
                                        children: [
                                          _HeaderCell(flex: 1, label: 'Cover'),
                                          _HeaderCell(flex: 3, label: 'Title'),
                                          _HeaderCell(flex: 2, label: 'Author'),
                                          _HeaderCell(flex: 1, label: 'Rating'),
                                          if (!isTablet)
                                            _HeaderCell(flex: 1, label: 'Year'),
                                          _HeaderCell(flex: 2, label: 'Review'),
                                          _HeaderCell(flex: 1, label: 'Remove'),
                                        ],
                                      ),
                                    );
                                  }
                                  final book = _filteredBooks[index - 1];
                                  return Column(
                                    children: [
                                      _BookListItem(
                                        book: book,
                                        isMobile: isMobile,
                                        isTablet: isTablet,
                                        onRemove:
                                            () => _removeBook(index - 1, book),
                                      ),
                                      Divider(
                                        color: ModernTheme.divider,
                                        height: 1.0,
                                        indent: 16.0,
                                        endIndent: 16.0,
                                      ),
                                    ],
                                  );
                                },
                              ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    final sortOptions = ['Latest', 'Alphabetical', 'Rating'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('My Shelf', style: ModernTheme.title),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16.0,
            runSpacing: 12.0,
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Search Field
              SizedBox(
                width: 250,
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search title or author...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true,
                    fillColor: ModernTheme.cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
              // Sort Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                decoration: BoxDecoration(
                  color: ModernTheme.cardColor,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _currentSort,
                    onChanged: _onSortChanged,
                    items:
                        sortOptions.map<DropdownMenuItem<String>>((
                          String value,
                        ) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: ModernTheme.bodyText),
                          );
                        }).toList(),
                    icon: const Icon(Icons.sort, color: ModernTheme.primary),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _BookListItem extends StatelessWidget {
  final Map<String, dynamic> book;
  final bool isMobile;
  final bool isTablet;
  final VoidCallback onRemove;

  const _BookListItem({
    Key? key,
    required this.book,
    required this.isMobile,
    required this.isTablet,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return _buildMobileLayout(context);
    }
    return _buildDesktopLayout(context);
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.1),
      child: InkWell(
        onTap: () => context.go('/book/${book['isbn10']}/${book['title']}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Book Cover
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      book['cover'] ?? '',
                      width: 80,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            width: 80,
                            height: 120,
                            color: Colors.grey[200],
                            child: const Icon(Icons.book, color: Colors.grey),
                          ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Book Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book['title'] ?? 'No Title',
                          style: ModernTheme.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          book['author'] ?? 'Unknown Author',
                          style: ModernTheme.subtleText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              (book['rating'] ?? 0.0).toStringAsFixed(1),
                              style: ModernTheme.bodyText,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: ModernTheme.divider),
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton.icon(
                    onPressed:
                        () => context.go(
                          '/writereview/${book['isbn10']}/${book['title']}',
                        ),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Write Review'),
                    style: TextButton.styleFrom(
                      foregroundColor: ModernTheme.accent,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: onRemove,
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Remove'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Card(
      color: vintageCream,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.05),
      child: InkWell(
        onTap: () => context.go('/book/${book['isbn10']}/${book['title']}'),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Container(
            height: 100,
            child: Row(
              children: [
                _buildCell(
                  flex: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4.0),
                    child: Image.network(
                      book['cover'] ?? '',
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey[200],
                            child: const Icon(Icons.book, color: Colors.grey),
                          ),
                    ),
                  ),
                ),
                _buildCell(
                  flex: 3,
                  child: Text(
                    book['title'] ?? '',
                    style: ModernTheme.bodyText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildCell(
                  flex: 2,
                  child: Text(
                    book['author'] ?? '',
                    style: ModernTheme.subtleText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildCell(
                  flex: 1,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        (book['rating'] ?? 0.0).toStringAsFixed(1),
                        style: ModernTheme.bodyText,
                      ),
                    ],
                  ),
                ),
                if (!isTablet)
                  _buildCell(
                    flex: 1,
                    child: Text(
                      book['publication_year']?.toString() ?? '',
                      style: ModernTheme.subtleText,
                    ),
                  ),
                _buildCell(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed:
                        () => context.go(
                          '/writereview/${book['isbn10']}/${book['title']}',
                        ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ModernTheme.accent.withOpacity(0.1),
                      foregroundColor: ModernTheme.accent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Review'),
                  ),
                ),
                _buildCell(
                  flex: 1,
                  child: IconButton(
                    onPressed: onRemove,
                    icon: const Icon(
                      FontAwesomeIcons.trashCan,
                      color: Colors.redAccent,
                      size: 18,
                    ),
                    tooltip: 'Remove from shelf',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCell({required int flex, required Widget child}) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        alignment: Alignment.centerLeft,
        child: child,
      ),
    );
  }
}

// Add this widget at the end of the file:
class _HeaderCell extends StatelessWidget {
  final int flex;
  final String label;
  const _HeaderCell({required this.flex, required this.label});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(
          label,
          style: ModernTheme.subtitle.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
