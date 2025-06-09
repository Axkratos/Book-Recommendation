import 'package:bookrec/components/VintageBookCard.dart';
import 'package:bookrec/components/similarBooks/similarBookSection.dart';
import 'package:bookrec/dummy/book.dart';
import 'package:bookrec/services/booksapi.dart';
import 'package:flutter/material.dart';

class BookAndSimilar extends StatefulWidget {
  final String bookId;
  BookAndSimilar({
    super.key,
    //required this.screenHeight,
    required this.bookId,
  });

  @override
  State<BookAndSimilar> createState() => _BookAndSimilarState();
}

class _BookAndSimilarState extends State<BookAndSimilar> {
  BooksInfo booksInfo = BooksInfo();

  late Future<Map> bookDetails;
  Future<Map<String, dynamic>> fetchBookDetails(String bookId) async {
    // Simulate a network call to fetch book details
    final data = await booksInfo.getSingleBook(bookId);
    final book = data['book'];
    print('Book Details Future: $book');

    return book; // Replace with actual API call
  }

  @override
  void initState() {
    super.initState();
    bookDetails = fetchBookDetails(widget.bookId);
    print('Book ID: ${widget.bookId}');
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    return FutureBuilder(
      future: bookDetails,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data == null) {
          return Center(child: Text('No book details found.'));
        } else {
          final book_info = snapshot.data!;
          return LayoutBuilder(
            builder: (context, constraints) {
              //double cardWidth = constraints.maxWidth;
              if (constraints.maxWidth > 900) {
                // Desktop
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 100),
                  child: ListView(
                    children: [
                      SizedBox(
                        height: screenHeight * 0.8,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            VintageBookCard(
                              book: Map<String, dynamic>.from(book_info),
                            ),
                            Expanded(
                              child: SimilarBooksSection(
                                similarBooks: similar_books,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return ListView(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: VintageBookCard(
                        book: Map<String, dynamic>.from(book_info),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 200,
                      child: SimilarBooksSection(
                        isSmallScreen: true,
                        similarBooks: similar_books,
                      ),
                    ),
                  ],
                );
              }
            },
          );
        }

        //final similar_books = bookDetails['similar_books'] ?? [];
      },
    );
  }
}
