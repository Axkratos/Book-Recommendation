import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:bookrec/provider/authprovider.dart';

// A simple data model for a book
class Book {
  final String id;
  final String title;
  final String author;
  final String coverUrl;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.coverUrl,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      author: json['authors'] ?? '',
      coverUrl: json['thumbnail'] ?? '',
    );
  }
}

class BookSelectionPage extends StatefulWidget {
  const BookSelectionPage({super.key});

  @override
  State<BookSelectionPage> createState() => _BookSelectionPageState();
}

class _BookSelectionPageState extends State<BookSelectionPage> {
  final int _minSelectionCount = 10;
  final Set<String> _selectedBookIds = {};
  late Future<List<Book>> _booksFuture;

  @override
  void initState() {
    super.initState();
    _booksFuture = fetchBooks();
  }

  Future<List<Book>> fetchBooks() async {
    final String baseUrl = dotenv.env['baseUrl']!;
    final String token =
        Provider.of<UserProvider>(context, listen: false).token;
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/books/random/unrated'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    print('Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List booksJson = data['data']['books'];
      return booksJson.map((json) => Book.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load books');
    }
  }

  void _toggleBookSelection(String bookId) {
    setState(() {
      if (_selectedBookIds.contains(bookId)) {
        _selectedBookIds.remove(bookId);
      } else {
        _selectedBookIds.add(bookId);
      }
    });
  }

  bool get _isSelectionComplete =>
      _selectedBookIds.length >= _minSelectionCount;

  Future<void> likeBooks() async {
    final String baseUrl = dotenv.env['baseUrl']!;
    final String token =
        Provider.of<UserProvider>(context, listen: false).token;

    // Get the selected book titles
    final books = await _booksFuture;
    final likedBooks =
        books
            .where((book) => _selectedBookIds.contains(book.id))
            .map((book) => book.title)
            .toList();

    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/books/like'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'liked_books': likedBooks}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Liked books response: $data');
      // You can show a success message or navigate to another page here
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Books liked successfully!')),
      );
    } else {
      print('Failed to like books: ${response.body}');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to like books')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header section
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'Select at least $_minSelectionCount books to continue your journey.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontSize: 24),
            ),
          ),
          // Responsive Book Grid
          Expanded(
            child: FutureBuilder<List<Book>>(
              future: _booksFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No books found.'));
                }
                final books = snapshot.data!;
                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    childAspectRatio: 2 / 3,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                  ),
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];
                    final isSelected = _selectedBookIds.contains(book.id);
                    return BookGridItem(
                      book: book,
                      isSelected: isSelected,
                      onTap: () => _toggleBookSelection(book.id),
                    );
                  },
                );
              },
            ),
          ),
          // Bottom action bar
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: Theme.of(context).primaryColor.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Selection counter
          Text(
            '${_selectedBookIds.length} / $_minSelectionCount Selected',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          // Proceed Button
          ElevatedButton(
            onPressed:
                _isSelectionComplete
                    ? () {
                      likeBooks();
                      context.go('/dashboard/home');
                    }
                    : null,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  _isSelectionComplete
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade400,
            ),
            child: const Text('Proceed'),
          ),
        ],
      ),
    );
  }
}

class BookGridItem extends StatelessWidget {
  final Book book;
  final bool isSelected;
  final VoidCallback onTap;

  const BookGridItem({
    super.key,
    required this.book,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: GridTile(
          footer: Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.black.withOpacity(0.6),
            child: Text(
              book.title,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Book Cover Image
              Image.network(
                book.coverUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).primaryColor,
                    ),
                  );
                },
                errorBuilder:
                    (context, error, stackTrace) =>
                        const Icon(Icons.book, size: 50, color: Colors.grey),
              ),
              // Selection Overlay
              if (isSelected)
                Container(
                  color: Theme.of(context).primaryColor.withOpacity(0.5),
                  child: Icon(
                    Icons.check_circle,
                    size: 50,
                    color: Theme.of(context).colorScheme.background,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
