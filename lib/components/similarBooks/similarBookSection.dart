import 'package:bookrec/components/similarBooks/similarBookItems.dart';
import 'package:bookrec/theme/color.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class SimilarBooksSection extends StatelessWidget {
  final List<Map<String, dynamic>> similarBooks;
  final bool isSmallScreen;

  const SimilarBooksSection({
    super.key,
    required this.similarBooks,
    this.isSmallScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    final TextStyle sectionTitleStyle = GoogleFonts.ebGaramond(
      color: vintageDarkBrown,
      fontSize: 20,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.5,
    );

    if (similarBooks.isEmpty) {
      return Center(
        child: Text(
          "No similar books found.",
          style: GoogleFonts.ebGaramond(color: vintageBrown, fontSize: 16),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 10.0, top: 5.0),
          child: Text("You Might Also Like", style: sectionTitleStyle),
        ),
        Divider(thickness: 1),

        if (isSmallScreen)
          SizedBox(
            height: 120, // Fixed height for horizontal scroll items
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: similarBooks.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: SizedBox(
                    width: 300, // Width of each item in horizontal layout
                    child: ModernBookListItem(
                      book: similarBooks[index],
                      style: ModernStyle.glassmorphism,
                      animationDelay: Duration(milliseconds: index * 100),
                    ),
                  ),
                );
              },
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              //physics: const NeverScrollableScrollPhysics(),
              itemCount: similarBooks.length,
              itemBuilder: (context, index) {
                return ModernBookListItem(
                  book: similarBooks[index],
                  style: ModernStyle.glassmorphism,
                );
              },
            ),
          ),
      ],
    );
  }
}
