import 'package:bookrec/components/shelfIcon.dart';
import 'package:bookrec/components/star.dart';
import 'package:bookrec/provider/authprovider.dart';
import 'package:bookrec/theme/color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bookrec/services/booksapi.dart';
import 'package:provider/provider.dart';

// --- VINTAGE COLOR CONSTANTS (as defined above) ---

class VintageBookCard extends StatefulWidget {
  final Map<String, dynamic> book;

  const VintageBookCard({super.key, required this.book});

  @override
  State<VintageBookCard> createState() => _VintageBookCardState();
}

class _VintageBookCardState extends State<VintageBookCard> {
  Widget _buildDetailRow(String label, String? value, {double fontSize = 15}) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return SelectionArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3.0),
        child: SelectableText.rich(
          TextSpan(
            style: GoogleFonts.ebGaramond(
              color: vintageBrown,
              fontSize: fontSize,
            ),
            children: <TextSpan>[
              TextSpan(
                text: '$label: ',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              TextSpan(text: value),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionText(
    String title,
    String? content,
    TextStyle baseStyle, {
    double topMargin = 12,
  }) {
    if (content == null || content.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: topMargin),
        Text(
          title,
          style: GoogleFonts.ebGaramond(
            color: vintageDarkBrown,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
            decorationColor: vintageBorderColor.withOpacity(0.7),
            decorationThickness: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        Text(content, style: baseStyle),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Text Styles
    final TextStyle titleStyle = GoogleFonts.ebGaramond(
      color: vintageDarkBrown,
      fontSize: 28, // Adjusted for potentially less horizontal space
      fontWeight: FontWeight.bold,
      letterSpacing: 0.3,
    );
    final TextStyle authorStyle = GoogleFonts.ebGaramond(
      color: vintageBrown,
      fontSize: 20,
      fontStyle: FontStyle.italic,
      fontWeight: FontWeight.w500,
    );
    final TextStyle bodyTextStyle = GoogleFonts.ebGaramond(
      color: vintageDarkBrown.withOpacity(0.85),
      fontSize: 18,
      height: 1.4,
    );
    final TextStyle smallDetailStyle = GoogleFonts.ebGaramond(
      color: vintageBrown,
      fontSize: 16,
    );

    // Extracting data safely
    String title = widget.book['title'] as String? ?? 'Unknown Title';
    String author = widget.book['authors'] as String? ?? 'Unknown Author';
    int? publicationYear = widget.book['published_year'] as int?;
    String genre = widget.book['categories'] as String? ?? 'N/A';
    String summary =
        widget.book['description'] as String? ?? 'No summary available.';
    String? coverImage = widget.book['thumbnail'] as String?;
    //'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1650033243i/41733839.jpg';
    double? rating = (widget.book['average_rating'] as num?)?.toDouble();
    int? pages = widget.book['pages'] as int?;
    String publisher = widget.book['publisher'] as String? ?? '';
    List<String> characters = List<String>.from(
      widget.book['characters'] as List? ?? [],
    );
    String aboutAuthor = widget.book['about_author'] as String? ?? '';
    String theme = widget.book['theme'] as String? ?? '';
    String isbn = widget.book['isbn10'] as String? ?? '';
    String language = widget.book['language'] as String? ?? '';
    String setting = widget.book['setting'] as String? ?? '';
    List<String> adaptations = List<String>.from(
      widget.book['adaptations'] as List? ?? [],
    );

    // Define a width for the image part and a height for the card.
    // Image width could be a percentage of the card's total width.
    final double cardWidth = MediaQuery.of(context).size.width * 0.65;
    final double imageWidth = cardWidth * 0.35; // Image takes 35% of card width
    // Define a max height for the card to keep it manageable
    final double cardMaxHeight = MediaQuery.of(context).size.height * 0.75;

    print('📚 DEBUG inside VintageBookCard:');
    print('Title: ${widget.book['title']}');
    print('cover image: ${coverImage ?? 'No image available'}');

    print('All book data: ${widget.book}');

    final bookInfo = BooksInfo();
    final ProviderUser = Provider.of<UserProvider>(context);
    Future<String> rate(String bookID, int value) async {
      final String response = await bookInfo.bookRatings(
        bookID,
        value,
        ProviderUser.token,
      );
      return response;
    }

    return Container(
      width: cardWidth,
      constraints: BoxConstraints(
        maxHeight: cardMaxHeight,
      ), // Constrain card height
      margin: const EdgeInsets.all(16.0),
      child: Card(
        color: vintagePaper,
        elevation: 6.0,
        shadowColor: vintageBorderColor.withOpacity(0.7),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(
            color: vintageBorderColor.withOpacity(0.9),
            width: 1.8,
          ),
        ),
        clipBehavior:
            Clip.antiAlias, // Ensures children (image) respect border radius
        child:
            MediaQuery.of(context).size.width < 1000
                ? ListView(
                  // Align children to the top
                  children: <Widget>[
                    // --- Left Side: Image ---
                    SizedBox(
                      //height: 250,
                      width: imageWidth,
                      // The height will be determined by the Row's height, which is constrained by cardMaxHeight.
                      // BoxFit.cover will fill this space.
                      child:
                          (coverImage != null && coverImage.isNotEmpty)
                              ? Image.network(
                                coverImage,
                                fit: BoxFit.cover,
                                height: 250,
                                alignment: Alignment.center,
                                // Stretch to fill the allocated height of the Row
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: vintageCream,
                                    child: Center(
                                      child: Icon(
                                        Icons.image_not_supported_outlined,
                                        size: 50,
                                        color: vintageBrown.withOpacity(0.7),
                                      ),
                                    ),
                                  );
                                },
                                loadingBuilder: (
                                  BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress,
                                ) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    color: vintageCream,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              vintageBrown,
                                            ),
                                        value:
                                            loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                      ),
                                    ),
                                  );
                                },
                              )
                              : Container(
                                // Placeholder if no image
                                color: vintageCream,
                                child: Center(
                                  child: Icon(
                                    Icons.book_outlined,
                                    size: 50,
                                    color: vintageBrown.withOpacity(0.7),
                                  ),
                                ),
                              ),
                    ),

                    // --- Right Side: Text Content ---
                    SingleChildScrollView(
                      // Makes the text content scrollable
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(title, style: titleStyle),
                          const SizedBox(height: 3),
                          Text('by $author', style: authorStyle),
                          if (publicationYear != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 3.0),
                              child: Text(
                                'Published: $publicationYear',
                                style: smallDetailStyle,
                              ),
                            ),
                          Row(
                            children: [
                              StarRating(onRatingChanged: (value) {}),
                              const SizedBox(width: 8),
                              ShelfButtonWidget(
                                bookId: widget.book['isbn10'],
                                token: ProviderUser.token,
                                bookData: widget.book,
                              ),
                            ],
                          ),
                          Divider(
                            color: vintageBorderColor.withOpacity(0.6),
                            height: 20,
                            thickness: 1.0,
                          ),

                          _buildDetailRow('Genre', genre, fontSize: 30),
                          _buildDetailRow('Theme', theme, fontSize: 18),
                          if (pages != null)
                            _buildDetailRow(
                              'Pages',
                              pages.toString(),
                              fontSize: 24,
                            ),
                          if (rating != null)
                            _buildDetailRow(
                              'Rating',
                              '${rating.toStringAsFixed(1)} / 5.0',
                              fontSize: 30,
                            ),
                          _buildDetailRow('Publisher', publisher, fontSize: 30),
                          _buildDetailRow('Language', language, fontSize: 18),
                          _buildDetailRow('ISBN', isbn, fontSize: 30),
                          _buildDetailRow('Setting', setting, fontSize: 18),

                          _buildSectionText('Synopsis', summary, bodyTextStyle),
                          _buildSectionText(
                            'About the Author',
                            aboutAuthor,
                            bodyTextStyle,
                          ),

                          if (characters.isNotEmpty)
                            _buildSectionText(
                              'Notable Characters',
                              characters.join(', '),
                              bodyTextStyle.copyWith(fontSize: 18, height: 1.3),
                            ),

                          if (adaptations.isNotEmpty)
                            _buildSectionText(
                              'Adaptations',
                              adaptations.join('; '),
                              bodyTextStyle.copyWith(fontSize: 18, height: 1.3),
                            ),
                          const SizedBox(height: 10),
                          //AddToShelfButton(onPressed: () {}),
                          // Some bottom padding within scroll view
                        ],
                      ),
                    ),
                  ],
                )
                : Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Align children to the top
                  children: <Widget>[
                    // --- Left Side: Image ---
                    Container(
                      width: imageWidth,
                      // The height will be determined by the Row's height, which is constrained by cardMaxHeight.
                      // BoxFit.cover will fill this space.
                      child:
                          (coverImage != null && coverImage.isNotEmpty)
                              ? Image.network(
                                coverImage,
                                fit: BoxFit.cover,
                                height:
                                    double
                                        .infinity, // Stretch to fill the allocated height of the Row
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: vintageCream,
                                    child: Center(
                                      child: Icon(
                                        Icons.image_not_supported_outlined,
                                        size: 50,
                                        color: vintageBrown.withOpacity(0.7),
                                      ),
                                    ),
                                  );
                                },
                                loadingBuilder: (
                                  BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress,
                                ) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    color: vintageCream,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              vintageBrown,
                                            ),
                                        value:
                                            loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                      ),
                                    ),
                                  );
                                },
                              )
                              : Container(
                                // Placeholder if no image
                                color: vintageCream,
                                child: Center(
                                  child: Icon(
                                    Icons.book_outlined,
                                    size: 50,
                                    color: vintageBrown.withOpacity(0.7),
                                  ),
                                ),
                              ),
                    ),

                    // --- Right Side: Text Content ---
                    Expanded(
                      child: SingleChildScrollView(
                        // Makes the text content scrollable
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(title, style: titleStyle),
                            const SizedBox(height: 3),
                            Text('by $author', style: authorStyle),
                            if (publicationYear != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 3.0),
                                child: Text(
                                  'Published: $publicationYear',
                                  style: smallDetailStyle,
                                ),
                              ),
                            Row(
                              children: [
                                StarRating(
                                  onRatingChanged: (value) async {
                                    final String r = await rate(
                                      widget.book['isbn10'],
                                      value,
                                    );
                                    print('Rating response: $r');
                                    if (r == 'sucess') {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Rating submitted!'),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text('Error: $r')),
                                      );
                                    }
                                  },
                                ),
                                const SizedBox(width: 8),
                                ShelfButtonWidget(
                                  bookId: widget.book['isbn10'],
                                  token: ProviderUser.token,
                                  bookData: widget.book,
                                ),
                              ],
                            ),
                            Divider(
                              color: vintageBorderColor.withOpacity(0.6),
                              height: 20,
                              thickness: 1.0,
                            ),

                            _buildDetailRow('Genre', genre, fontSize: 18),
                            _buildDetailRow('Theme', theme, fontSize: 18),
                            if (pages != null)
                              _buildDetailRow(
                                'Pages',
                                pages.toString(),
                                fontSize: 18,
                              ),
                            if (rating != null)
                              _buildDetailRow(
                                'Rating',
                                '${rating.toStringAsFixed(1)} / 5.0',
                                fontSize: 14,
                              ),
                            _buildDetailRow(
                              'Publisher',
                              publisher,
                              fontSize: 18,
                            ),
                            _buildDetailRow('Language', language, fontSize: 18),
                            _buildDetailRow('ISBN', isbn, fontSize: 18),
                            _buildDetailRow('Setting', setting, fontSize: 18),

                            _buildSectionText(
                              'Synopsis',
                              summary,
                              bodyTextStyle,
                            ),
                            _buildSectionText(
                              'About the Author',
                              aboutAuthor,
                              bodyTextStyle,
                            ),

                            if (characters.isNotEmpty)
                              _buildSectionText(
                                'Notable Characters',
                                characters.join(', '),
                                bodyTextStyle.copyWith(
                                  fontSize: 18,
                                  height: 1.3,
                                ),
                              ),

                            if (adaptations.isNotEmpty)
                              _buildSectionText(
                                'Adaptations',
                                adaptations.join('; '),
                                bodyTextStyle.copyWith(
                                  fontSize: 18,
                                  height: 1.3,
                                ),
                              ),
                            const SizedBox(height: 10),
                            // Some bottom padding within scroll view
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
