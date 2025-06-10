import 'dart:convert';
import 'package:bookrec/services/booksapi.dart';
import 'package:flutter/material.dart';
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
          return ElevatedButton(
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

                        return;
                      }
                    }
                    : null, // null disables the button
            child: Text(isClickable ? 'Add to Shelf' : 'Already Present'),
          );
        }
      },
    );
  }
}
