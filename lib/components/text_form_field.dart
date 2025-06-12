import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VintageTextFormField extends StatelessWidget {
  const VintageTextFormField({
    super.key,
    required this.screenWidth,
    required this.icon,
    required this.hintText,
    this.onChanged,
    this.enable = true,
    this.controller,
  });
  final bool enable;
  final IconData icon;
  final String hintText;
  final TextEditingController? controller;

  final double screenWidth;
  final Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: screenWidth * 0.2,
      child: TextFormField(
        controller: controller,
        enabled: enable,
        style: GoogleFonts.literata(fontSize: 16, color: Colors.black87),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.literata(
            fontSize: 16,
            color: Colors.grey[600],
          ),
          prefixIcon: Icon(icon, color: Colors.grey[700]),
          filled: true,
          fillColor: Colors.white.withOpacity(0.8),
          contentPadding: EdgeInsets.symmetric(horizontal: 15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) {
          onChanged!(value);
        },
      ),
    );
  }
}
