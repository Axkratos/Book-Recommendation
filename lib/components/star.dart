// file: components/star.dart
import 'package:flutter/material.dart';

class StarRating extends StatefulWidget {
  final int initialRating;
  final ValueChanged<int> onRatingChanged;
  final double size;
  final Color color;

  const StarRating({
    super.key,
    this.initialRating = 0,
    required this.onRatingChanged,
    this.size = 30,
    this.color = Colors.amber,
  });

  @override
  State<StarRating> createState() => _StarRatingState();
}

class _StarRatingState extends State<StarRating> {
  late int _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
  }

  void _onTap(int index) {
    setState(() {
      _rating = index;
    });
    widget.onRatingChanged(_rating);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < _rating ? Icons.star : Icons.star_border,
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
}
