import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bookrec/theme/color.dart';

final TextStyle vintageLabelStyle = GoogleFonts.ebGaramond(
  color: vintageBrown.withOpacity(0.9),
  fontSize: 18,
  fontWeight: FontWeight.w500,
);
final TextStyle vintageTextStyle = GoogleFonts.ebGaramond(
  color: vintageDarkBrown,
  fontSize: 16,
);
final TextStyle vintageMenuTextStyle = GoogleFonts.ebGaramond(
  color: vintageDarkBrown,
  fontSize: 16,
);
final TextStyle vintageHeadlineStyle = vintageTextStyle.copyWith(
  fontSize: 32, // Adjusted for better fit
  fontWeight: FontWeight.w600, // Garamond can look good semi-bold
  color: vintageDarkBrown,
  height: 1.3,
  letterSpacing: 0.5, // A touch of letter spacing for headings
);
final TextStyle vintageBodyTextStyle = vintageTextStyle.copyWith(fontSize: 16);
final TextStyle vintageLinkStyle = vintageTextStyle.copyWith(
  fontSize: 15,
  color: vintageRed,
  // decoration: TextDecoration.underline, // Optional: for a classic link feel
  // decorationColor: vintageRed.withOpacity(0.7),
  fontWeight: FontWeight.w500, // Make it slightly bolder than body
);
TextStyle get vintageBaseTextStyle => GoogleFonts.ebGaramond(
  // Or GoogleFonts.lora(), GoogleFonts.ptSerif()
  color: vintageDarkBrown,
);
final TextStyle vintageSubtitleStyle = GoogleFonts.cinzel(
  fontSize: 20,
  fontWeight: FontWeight.w600,
  letterSpacing: 2,
  color: Colors.brown[800],
);
