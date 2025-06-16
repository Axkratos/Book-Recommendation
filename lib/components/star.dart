// file: components/star.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class StarRating extends StatefulWidget {
  final String bookId;
  final String token;
  final Future<int> Function(String, String) getRatingsCount;
  final ValueChanged<int> onRatingChanged;
  final double size;
  final Color color;

  const StarRating({
    super.key,
    required this.bookId,
    required this.token,
    required this.getRatingsCount,
    required this.onRatingChanged,
    this.size = 30,
    this.color = Colors.amber,
  });

  @override
  State<StarRating> createState() => _StarRatingState();
}

class _StarRatingState extends State<StarRating> {
  late Future<int> _futureRating;
  int _currentRating = 0;

  @override
  void initState() {
    super.initState();
    _futureRating = widget.getRatingsCount(widget.bookId, widget.token);
  }

  void _onTap(int index) {
    setState(() {
      _currentRating = index;
    });
    widget.onRatingChanged(_currentRating);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: _futureRating,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Text("Failed to load rating");
        } else {
          int initial = (snapshot.data ?? 0) ~/ 2;
          _currentRating = _currentRating == 0 ? initial : _currentRating;

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index < _currentRating ? Icons.star : Icons.star_border,
                  color: widget.color,
                  size: widget.size,
                ),
                onPressed: () => _onTap(index + 1),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              );
            }),
          );
        }
      },
    );
  }
}
