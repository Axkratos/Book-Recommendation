import 'package:bookrec/theme/color.dart';
import 'package:bookrec/theme/texts.dart';
import 'package:flutter/material.dart';

class dashboard_title extends StatelessWidget {
  const dashboard_title({
    super.key,
    required this.title,
  });
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: vintageTextStyle.copyWith(
        fontSize: 40,
        height: 1,
        fontWeight: FontWeight.bold,
        color: vintageDarkBrown,
      ),
    );
  }
}