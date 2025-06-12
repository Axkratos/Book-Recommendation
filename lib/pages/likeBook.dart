import 'package:flutter/material.dart';

// A simple data model for a book
class Book {
  final int id;
  final String title;
  final String author;
  final String coverUrl;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.coverUrl,
  });
}

class BookSelectionPage extends StatefulWidget {
  const BookSelectionPage({super.key});

  @override
  State<BookSelectionPage> createState() => _BookSelectionPageState();
}

class _BookSelectionPageState extends State<BookSelectionPage> {
  final int _minSelectionCount = 10;
  final Set<int> _selectedBookIds = {};

  // Generate a list of 30 dummy books
  final List<Book> _books = List.generate(
    30,
    (index) => Book(
      id: index,
      title: 'Classic Tale ${index + 1}',
      author: 'Author ${index + 1}',
      // Using picsum.photos with a grayscale filter for a vintage feel
      // The seed ensures we get the same image for the same book every time
      coverUrl: 'https://picsum.photos/seed/${index + 10}/200/300?grayscale',
    ),
  );

  void _toggleBookSelection(int bookId) {
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
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              // This is the key to responsiveness!
              // It creates as many columns as can fit, with each column having a max width.
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200, // Max width for each grid item
                childAspectRatio: 2 / 3, // Aspect ratio for book covers
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              itemCount: _books.length,
              itemBuilder: (context, index) {
                final book = _books[index];
                final isSelected = _selectedBookIds.contains(book.id);
                return BookGridItem(
                  book: book,
                  isSelected: isSelected,
                  onTap: () => _toggleBookSelection(book.id),
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
                    ? () =>
                        print('Proceed with selected books: $_selectedBookIds')
                    : null, // Button is disabled if condition is not met
            style: ElevatedButton.styleFrom(
              // Visually indicate if the button is disabled
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
        clipBehavior:
            Clip.antiAlias, // Ensures the content respects the card's border radius
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
                // Show a loading indicator while the image is fetching
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
