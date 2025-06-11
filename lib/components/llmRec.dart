import 'package:bookrec/components/book_grid.dart';
import 'package:bookrec/theme/color.dart';
import 'package:bookrec/theme/texts.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Assuming you have these constants defined somewhere
//const vintageCream = Color(0xFFF5F5DC);
//const vintageTextStyle = TextStyle(fontFamily: 'PlayfairDisplay', color: Color(0xFF4E342E)); // Example

class AIPromptSection extends StatefulWidget {
  const AIPromptSection({Key? key}) : super(key: key);

  @override
  _AIPromptSectionState createState() => _AIPromptSectionState();
}

class _AIPromptSectionState extends State<AIPromptSection> {
  final _promptController = TextEditingController();

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // A funky accent color that complements the vintage theme
    const funkyTeal = Color(0xFF4DB6AC);

    return Container(
      width: double.infinity,
      //height: 400,
      padding: const EdgeInsets.all(24.0),
      margin: const EdgeInsets.symmetric(
        horizontal: 16.0,
      ), // Margin for spacing
      decoration: BoxDecoration(
        // The Vintage Foundation
        image: const DecorationImage(
          image: AssetImage('assets/images/paper_texture.png'), // The texture
          fit: BoxFit.cover,
          opacity: 0.4, // Blend the texture subtly
        ),
        gradient: LinearGradient(
          colors: [
            Color(0xFFD7CCC8).withOpacity(0.8), // Muted brownish tone
            Color(0xFFA1887F).withOpacity(0.9), // Deeper muted tone
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(
          color: Colors.brown.shade700.withOpacity(0.6),
          width: 2,
        ),
        boxShadow: [
          // The Modern Lift
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Conjure a Book with AI",
            style: vintageTextStyle.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.5),
                  offset: Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),

          // The Modern Text Field
          TextField(
            controller: _promptController,
            style: vintageTextStyle.copyWith(
              fontSize: 16,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              hintText:
                  "e.g., 'a sci-fi epic on a desert planet with giant worms'...",
              hintStyle: vintageTextStyle.copyWith(
                color: Colors.black.withOpacity(0.4),
                fontSize: 14,
              ),
              filled: true,
              fillColor: vintageCream.withOpacity(0.85),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide.none, // Clean, modern, no-border look
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: funkyTeal, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 15,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // The Funky Button
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () {
                  final prompt = _promptController.text;

                  // Simple validation: don't navigate if the prompt is empty.
                  if (prompt.trim().isNotEmpty) {
                    context.go('/dashboard/home/book/$prompt');

                    /*
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        // We are creating a new page and passing the prompt to it
                        builder:
                            (context) => BookSearchResultsPage(prompt: prompt),
                      ),
                    );*/
                  } else {
                    // Optional: Show a little feedback message if the field is empty
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.redAccent.withOpacity(0.8),
                        content: Text(
                          'Please enter a prompt to summon a book!',
                          style: vintageTextStyle.copyWith(color: Colors.white),
                        ),
                      ),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: funkyTeal,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "Summon Book",
                    style: vintageTextStyle.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
