import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';

class AddToShelfButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;

  const AddToShelfButton({
    super.key,
    required this.onPressed,
    this.label = 'Add to Shelf',
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: Colors.brown[800],
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        backgroundColor: Colors.brown[100],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.brown[300]!),
        ),
      ),
      icon: const FaIcon(FontAwesomeIcons.circlePlus, size: 16),
      label: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
  }
}
