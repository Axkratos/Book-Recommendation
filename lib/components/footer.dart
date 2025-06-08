import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SimpleElegantVintageFooter extends StatelessWidget {
  const SimpleElegantVintageFooter({super.key});

  // Define Vintage Colors at class level for access in helper methods if needed
  static const Color vintageCream = Color(0xFFF5EFE6); // Soft, aged paper
  static const Color vintageBrown = Color(
    0xFF4A3B31,
  ); // Deep, warm brown for text
  static const Color vintageGoldAccent = Color(
    0xFFB08D57,
  ); // Muted gold for links/accents

  // Helper for clickable text links
  Widget _buildFooterLink(
    BuildContext context,
    String text,
    VoidCallback onPressed,
    TextStyle style,
  ) {
    return InkWell(
      onTap: onPressed,
      hoverColor: vintageGoldAccent.withOpacity(0.08), // Very subtle hover
      borderRadius: BorderRadius.circular(
        4,
      ), // Optional: for a softer hover shape
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Text(text, style: style),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Define Text Styles
    final TextStyle linkStyle = GoogleFonts.lora(
      // Lora is a classic serif font
      fontSize: screenWidth < 600 ? 13 : 15,
      color: vintageGoldAccent,
      fontWeight: FontWeight.w600, // Semi-bold for link prominence
    );

    final TextStyle copyrightStyle = GoogleFonts.lora(
      fontSize: screenWidth < 600 ? 11 : 12,
      color: vintageBrown.withOpacity(0.75), // Slightly lighter than main text
      height: 1.5, // Line height for readability
    );

    final TextStyle separatorStyle = GoogleFonts.lora(
      fontSize: screenWidth < 600 ? 13 : 15,
      color: vintageBrown.withOpacity(0.5), // Muted separator
    );

    return Container(
      height: screenHeight * 0.2, // Set height to 30% of screen height
      color: vintageCream, // Main background color for the footer
      padding: EdgeInsets.symmetric(
        vertical: 20.0, // Padding for top and bottom
        horizontal:
            screenWidth > 800
                ? screenWidth * 0.05
                : 20.0, // Responsive horizontal padding
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.center, // Center decorative line horizontally
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Center content vertically
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Center content horizontally
              children: <Widget>[
                // Optional: A very subtle brand name or monogram
                // Text(
                //   "YB", // Your Brand Initials or a small text logo
                //   style: GoogleFonts.playfairDisplay( // Or another elegant serif
                //     fontSize: 22,
                //     color: vintageBrown.withOpacity(0.8),
                //     fontWeight: FontWeight.w600,
                //   ),
                // ),
                // const SizedBox(height: 15), // If brand name is used

                // Links Section
                Wrap(
                  // Handles responsiveness for links if they overflow
                  alignment: WrapAlignment.center,
                  spacing:
                      0, // Links have their own padding; separators define visual space
                  runSpacing: 8.0, // Space between lines if links wrap
                  children: <Widget>[
                    _buildFooterLink(context, 'About Us', () {
                      /* TODO: Implement navigation */
                    }, linkStyle),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Text(
                        '•',
                        style: separatorStyle,
                      ), // Vintage-style separator
                    ),
                    _buildFooterLink(context, 'Contact', () {
                      /* TODO: Implement navigation */
                    }, linkStyle),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Text('•', style: separatorStyle),
                    ),
                    _buildFooterLink(context, 'Privacy Policy', () {
                      /* TODO: Implement navigation */
                    }, linkStyle),
                    // Add more links if necessary, but keep it concise for elegance
                  ],
                ),

                const SizedBox(height: 18), // Space between links and copyright
                // Copyright Text
                Text(
                  '© ${DateTime.now().year} Your Brand Name. All Rights Reserved.',
                  style: copyrightStyle,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Subtle Decorative Element at the bottom
          Container(
            height: 1.0,
            width:
                screenWidth * 0.25 > 120
                    ? 120
                    : screenWidth * 0.25, // Responsive width, max 120px
            color: vintageGoldAccent.withOpacity(0.4), // Muted accent line
            // No margin needed here, parent Container's padding handles space below
          ),
          // The main Container's bottom padding (20.0) provides space below this line
        ],
      ),
    );
  }
}

// How to use it in your Scaffold:
//
// class MyHomePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;
//     return Scaffold(
//       appBar: AppBar(title: Text("Vintage Website")),
//       body: ListView( // Or SingleChildScrollView / Column
//         children: [
//           // Your main page content here
//           Container(height: screenHeight * 1.5, color: Colors.blueGrey[100], child: Center(child: Text("Main Content Area"))), // Example content
//           // ... more content ...
//         ],
//       ),
//       bottomNavigationBar: SimpleElegantVintageFooter(), // Add the footer here
//     );
//   }
// }
