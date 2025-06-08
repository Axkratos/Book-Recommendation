import 'package:bookrec/theme/color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SimilarBookListItem extends StatelessWidget {
  final Map<String, dynamic> book;

  const SimilarBookListItem({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    String title = book['title'] as String? ?? 'Unknown Title';
    String author = book['author'] as String? ?? 'Unknown Author';
    String? imageUrl = book['image'] as String?;

    final TextStyle itemTitleStyle = GoogleFonts.ebGaramond(
      color: vintageDarkBrown,
      fontSize: 15,
      fontWeight: FontWeight.w600,
    );
    final TextStyle itemAuthorStyle = GoogleFonts.ebGaramond(
      color: vintageBrown,
      fontSize: 13,
      fontStyle: FontStyle.italic,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: vintageListItemBg.withOpacity(
            0.1,
          ), // Slightly transparent or distinct
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: vintageBorderColor.withOpacity(0.6),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: vintageBorderColor.withOpacity(0.2),
              blurRadius: 3,
              offset: const Offset(1, 1),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null && imageUrl.isNotEmpty)
              SizedBox(
                width: 55, // Adjusted size
                height: 80, // Adjusted size
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          color: vintageCream.withOpacity(0.5),
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: vintageBrown.withOpacity(0.7),
                            size: 30,
                          ),
                        ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: vintageCream.withOpacity(0.5),
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              vintageBrown,
                            ),
                            value:
                                loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              )
            else
              Container(
                width: 55,
                height: 80,
                decoration: BoxDecoration(
                  color: vintageCream.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Icon(
                  Icons.book_outlined,
                  color: vintageBrown.withOpacity(0.7),
                  size: 30,
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment:
                    MainAxisAlignment.center, // Vertically center text
                children: [
                  Text(
                    title,
                    style: itemTitleStyle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "by $author",
                    style: itemAuthorStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
