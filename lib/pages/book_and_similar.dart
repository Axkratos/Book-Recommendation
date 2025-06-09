import 'package:bookrec/components/VintageBookCard.dart';
import 'package:bookrec/components/similarBooks/similarBookSection.dart';
import 'package:bookrec/dummy/book.dart';
import 'package:flutter/material.dart';

class BookAndSimilar extends StatelessWidget {
  final String bookId;
  const BookAndSimilar({
    super.key,
    //required this.screenHeight,
    required this.bookId,
  });


  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    return LayoutBuilder(
      builder: (context, constraints) {
        //double cardWidth = constraints.maxWidth;
        if (constraints.maxWidth > 900) {
          // Desktop
          return Container(
            height: screenHeight * 0.7,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                VintageBookCard(book: book),
                Expanded(
                  child: SimilarBooksSection(
                    similarBooks: similar_books,
                  ),
                ),
              ],
            ),
          );
        } else {
          return Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: VintageBookCard(book: book),
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
}