import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class title extends StatelessWidget {
  const title({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.bookmark, size: 30, color: Color(0xFFE0BBE4)),
        SizedBox(width: 8),
        Text(
          'BookRec',
          style: GoogleFonts.playfairDisplay(
            fontSize: 28,
            color: Colors.brown[900],
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}
