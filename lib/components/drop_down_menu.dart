import 'package:bookrec/theme/color.dart';
import 'package:bookrec/theme/texts.dart';
import 'package:flutter/material.dart';

class menu_drop extends StatelessWidget {
  const menu_drop({
    super.key,
    required this.type,
    required this.title,
    required this.onChanged,
  });

  final void Function(String) onChanged;
  final List<dynamic> type;
  final String title;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      constraints: BoxConstraints(minWidth: 120, maxWidth: 200),
      child: DropdownMenu<String>(
        width: double.infinity,
        onSelected: (value) => onChanged(value!),
        label: Text(title, style: vintageLabelStyle),
        textStyle: vintageTextStyle,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: vintageCream,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15.0,
            horizontal: 20.0,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: vintageBorderColor, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(
              color: vintageBorderColor.withOpacity(0.7),
              width: 1.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: vintageBrown, width: 2.0),
          ),
          labelStyle: vintageLabelStyle,
        ),
        menuStyle: MenuStyle(
          backgroundColor: MaterialStateProperty.all(vintageCream),
          elevation: MaterialStateProperty.all(3.0),
          shadowColor: MaterialStateProperty.all(
            vintageBorderColor.withOpacity(0.5),
          ),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: BorderSide(
                color: vintageBorderColor.withOpacity(0.5),
                width: 1.0,
              ),
            ),
          ),
          padding: MaterialStateProperty.all(
            const EdgeInsets.symmetric(vertical: 8.0),
          ),
        ),
        dropdownMenuEntries:
            type
                .map(
                  (m) => DropdownMenuEntry<String>(
                    value: m,
                    label: m,
                    style: MenuItemButton.styleFrom(
                      textStyle: vintageMenuTextStyle,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                )
                .toList(),
        trailingIcon: Icon(
          Icons.unfold_more_rounded,
          color: vintageBrown.withOpacity(0.8),
        ),
        selectedTrailingIcon: Icon(
          Icons.expand_less_rounded,
          color: vintageBrown,
        ),
      ),
    );
  }
}
