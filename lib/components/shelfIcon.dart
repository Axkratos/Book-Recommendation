import 'dart:convert';
import 'package:bookrec/services/booksapi.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class ShelfButtonWidget extends StatefulWidget {
  final String bookId;
  final String token;
  const ShelfButtonWidget({
    super.key,
    required this.bookId,
    required this.token,
    required this.bookData,
  });
  final Map<String, dynamic> bookData;

  @override
  State<ShelfButtonWidget> createState() => _ShelfButtonWidgetState();
}

class _ShelfButtonWidgetState extends State<ShelfButtonWidget> {
  Color parchmentColor = Color(0xFFF5EFE6);
  Color darkBrownColor = Color(0xFF4E342E);
  Color fadedBrownColor = Color(0xFF795548);
  Color disabledParchmentColor = Color(0xFFEAE5E0);
  final bookInfo = BooksInfo();

  late Future<String> _shelfStatusFuture;

  @override
  void initState() {
    super.initState();
    _shelfStatusFuture = bookInfo.checkShelfStatus(widget.bookId, widget.token);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _shelfStatusFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final status = snapshot.data ?? 'unknown';
          final isClickable = status == 'absent';
          print("Shelf Status: $status");
          return ElevatedButton.icon(
            icon: Icon(
              // Use a different icon for each state for better UX
              isClickable ? Icons.add_circle_outline : Icons.check_circle,
              color: isClickable ? darkBrownColor : fadedBrownColor,
            ),
            label: Text(
              isClickable ? 'Add to Shelf' : 'On Your Shelf',
              style: GoogleFonts.ebGaramond(
                // A classic, elegant serif font
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            onPressed:
                isClickable
                    ? () async {
                      try {
                        final response = await bookInfo.addToShelf(
                          widget.bookData,
                          widget.token,
                        );
                        print('Response from addToShelf: $response');
                        if (response == 'success') {
                          setState(() {
                            _shelfStatusFuture = bookInfo.checkShelfStatus(
                              widget.bookId,
                              widget.token,
                            );
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to add book to shelf'),
                            ),
                          );
                        }
                      } catch (e) {
                        print('Error adding book to shelf: $e');
                        // Optionally show a snackbar on error too
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'An error occurred. Please try again.',
                            ),
                          ),
                        );
                      }
                    }
                    : null, // This disables the button
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color>((
                Set<MaterialState> states,
              ) {
                if (states.contains(MaterialState.disabled)) {
                  return disabledParchmentColor; // Color when disabled
                }
                return parchmentColor; // Color when enabled
              }),
              foregroundColor: MaterialStateProperty.resolveWith<Color>((
                Set<MaterialState> states,
              ) {
                if (states.contains(MaterialState.disabled)) {
                  return fadedBrownColor; // Text color when disabled
                }
                return darkBrownColor; // Text color when enabled
              }),
              elevation: MaterialStateProperty.all<double>(
                2,
              ), // A subtle shadow
              padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  side: BorderSide(
                    color:
                        isClickable
                            ? darkBrownColor.withOpacity(0.5)
                            : fadedBrownColor.withOpacity(0.5),
                    width: 1,
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
