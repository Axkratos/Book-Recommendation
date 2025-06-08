import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bookrec/theme/color.dart';

// --- VINTAGE COLOR CONSTANTS --- (ensure these are defined)

// ---

class VintageButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? iconData; // Optional icon
  final bool isPrimary; // To offer a slight variation

  const VintageButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.iconData,
    this.isPrimary = true,
  });

  @override
  Widget build(BuildContext context) {
    // Define base colors based on isPrimary
    final Color backgroundColor = isPrimary ? vintageCream : vintageBrown;
    final Color foregroundColor = isPrimary ? vintageDarkBrown : vintageCream;
    final Color borderColor =
        isPrimary
            ? vintageBrown.withOpacity(0.7)
            : vintageBorderColor.withOpacity(0.9);
    final Color hoverBorderColor =
        isPrimary ? vintageBrown : vintageBorderColor;
    final Color shadowColor = vintageBorderColor.withOpacity(0.5);

    // Define text style
    final TextStyle buttonTextStyle = GoogleFonts.ebGaramond(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5, // Slight letter spacing can look classic
    );

    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        // --- Background Color with Hover/Press States ---
        backgroundColor: MaterialStateProperty.resolveWith<Color>((
          Set<MaterialState> states,
        ) {
          if (states.contains(MaterialState.pressed)) {
            return backgroundColor.withOpacity(0.8); // Darken on press
          }
          if (states.contains(MaterialState.hovered)) {
            return backgroundColor.withOpacity(0.9); // Slightly change on hover
          }
          return backgroundColor; // Default
        }),
        // --- Foreground (Text & Icon) Color ---
        foregroundColor: MaterialStateProperty.all(foregroundColor),
        // --- Elevation & Shadow ---
        elevation: MaterialStateProperty.resolveWith<double>((
          Set<MaterialState> states,
        ) {
          if (states.contains(MaterialState.pressed))
            return 1.0; // Less elevation when pressed
          return 3.0; // Default elevation
        }),
        shadowColor: MaterialStateProperty.all(shadowColor),
        // --- Padding ---
        padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        ),
        // --- Shape & Border ---
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0), // Slightly rounded
          ),
        ),
        // --- Border (Side) with Hover State ---
        side: MaterialStateProperty.resolveWith<BorderSide>((
          Set<MaterialState> states,
        ) {
          if (states.contains(MaterialState.hovered) ||
              states.contains(MaterialState.focused)) {
            return BorderSide(color: hoverBorderColor, width: 1.5);
          }
          return BorderSide(color: borderColor, width: 1.0); // Default border
        }),
        // --- Text Style ---
        textStyle: MaterialStateProperty.all(buttonTextStyle),
        // --- Splash/Overlay Color on Press ---
        overlayColor: MaterialStateProperty.all(
          foregroundColor.withOpacity(0.1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // So the button doesn't take full width
        children: [
          if (iconData != null) ...[
            Icon(iconData, size: 20), // Icon size
            const SizedBox(width: 8), // Space between icon and text
          ],
          Text(text),
        ],
      ),
    );
  }
}
