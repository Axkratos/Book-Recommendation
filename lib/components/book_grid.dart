import 'dart:math';

import 'package:bookrec/modals.dart/book_modal.dart';
import 'package:bookrec/theme/color.dart';
import 'package:bookrec/theme/texts.dart';
import 'package:flutter/material.dart';

    const funkyTeal = Color(0xFF4DB6AC);


class BookSearchResultsPage extends StatefulWidget {
  final String prompt;

  const BookSearchResultsPage({
    Key? key,
    required this.prompt,
  }) : super(key: key);

  @override
  _BookSearchResultsPageState createState() => _BookSearchResultsPageState();
}

class _BookSearchResultsPageState extends State<BookSearchResultsPage> {
  bool _isLoading = true;
  List<Book> _foundBooks = [];

  @override
  void initState() {
    super.initState();
    // Start fetching books as soon as the page loads
    _fetchBooksBasedOnPrompt();
  }

  // This is a FAKE API call to simulate fetching data
  Future<void> _fetchBooksBasedOnPrompt() async {
    // Simulate a network delay of 1.5 seconds
    await Future.delayed(const Duration(milliseconds: 1500));

    // --- In a real app, you would make an HTTP request to your AI backend here ---
    // For now, let's generate some dummy data.
    final List<Book> dummyBooks = List.generate(12, (index) {
      return Book(

        title: 'Book Title Inspired by "${widget.prompt.substring(0, min(10, widget.prompt.length))}" #${index + 1}',
        authors: 'Author ${index + 1}',
        id: 'book-${index + 1}',
        thumbnail: 'https://picsum.photos/seed/${widget.prompt.hashCode + index}/200/300',
        publishedYear: 2023 - index,
        averageRating: 4.0 + (index % 5) * 0.2, // Varying ratings
        ratingsCount: 100 + index * 10, // Simulating ratings count
        description: 'A fascinating book that explores the themes of "${widget.prompt}". This is a placeholder description for book #${index + 1}.',
        
        // Using picsum.photos for random images. The seed ensures we get different images.
        //coverImageUrl: 'https://picsum.photos/seed/${widget.prompt.hashCode + index}/400/600',
      );
    });

    if (mounted) {
      setState(() {
        _foundBooks = dummyBooks;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: vintageCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Blends into the body
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.brown.shade800), // Dark back arrow
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Conjuring results for...",
              style: vintageTextStyle.copyWith(fontSize: 14, color: Colors.black54),
            ),
            Text(
              "'${widget.prompt}'",
              style: vintageTextStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: funkyTeal),
                  const SizedBox(height: 20),
                  Text("Summoning books from the ether...", style: vintageTextStyle)
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // Number of columns
                crossAxisSpacing: 16.0, // Horizontal space between cards
                mainAxisSpacing: 16.0, // Vertical space between cards
                childAspectRatio: 0.65, // Aspect ratio of items (Width / Height)
              ),
              itemCount: _foundBooks.length,
              itemBuilder: (context, index) {
                final book = _foundBooks[index];
                return BookGridCard(book: book);
              },
            ),
    );
  }
}

// A dedicated widget for the card in the grid for cleaner code
class BookGridCard extends StatelessWidget {
  final Book book;

  const BookGridCard({Key? key, required this.book}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Book Cover Image
            Expanded(
              flex: 4, // Give more space to the image
              child: Image.network(
                book.thumbnail,
                fit: BoxFit.cover,
                // A nice loading builder for network images
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator(strokeWidth: 2, color: funkyTeal,));
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: Icon(Icons.menu_book, color: Colors.grey.shade400, size: 40,),
                  );
                },
              ),
            ),
            // Book Title and Author
            Expanded(
              flex: 2, // Less space for text
              child: Container(
                padding: const EdgeInsets.all(8.0),
                color: const Color(0xFFFAF5E9), // A slightly different cream
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: vintageTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Text(
                      book.authors,
                      style: vintageTextStyle.copyWith(fontSize: 11, color: Colors.black54),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}