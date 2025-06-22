import 'dart:convert';

import 'package:bookrec/components/VintageButton.dart';
import 'package:bookrec/components/footer.dart';
import 'package:bookrec/components/rules.dart';
import 'package:bookrec/components/text_form_field.dart';
import 'package:bookrec/components/title.dart';
import 'package:bookrec/provider/authprovider.dart';
import 'package:bookrec/services/discussApi.dart';
import 'package:bookrec/theme/color.dart';
import 'package:bookrec/theme/dashboard_title.dart';
import 'package:bookrec/theme/texts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:provider/provider.dart';

class WriteReview extends StatefulWidget {
  const WriteReview({super.key, required this.bookId, required this.title});
  final String bookId;
  final String title;

  @override
  State<WriteReview> createState() => _WriteReviewState();
}

class _WriteReviewState extends State<WriteReview> {
  final QuillController _quillController = QuillController.basic();
  final titleController = TextEditingController();
  final discuss = Discussapi();

  @override
  void dispose() {
    _quillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ProviderUser = Provider.of<UserProvider>(context);

    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    Widget editorColumn = Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            dashboard_title(title: 'Discussion'),
            VintageTextFormField(
              enable: false,
              screenWidth: screenWidth,
              icon: Icons.search,
              hintText: widget.title,
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.01),
        Container(
          width: double.infinity,
          child: VintageTextFormField(
            controller: titleController,
            screenWidth: screenWidth,
            icon: Icons.title,
            hintText: 'Title of the Review',
          ),
        ),
        SizedBox(height: screenHeight * 0.02),
        Container(
          width: double.infinity,
          height: screenHeight * 0.5,
          decoration: BoxDecoration(
            color: vintageCream,
            border: Border.all(color: vintageBorderColor, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                QuillSimpleToolbar(
                  controller: _quillController,
                  config: QuillSimpleToolbarConfig(
                    showAlignmentButtons: false,
                    showBackgroundColorButton: false,
                    showFontFamily: false,
                    showFontSize: false,
                    showInlineCode: false,
                    showColorButton: false,
                    showSearchButton: false,
                    showLink: false,
                    showListCheck: false,
                  ),
                ),
                Divider(color: vintageBorderColor, thickness: 1),
                Expanded(
                  child: QuillEditor.basic(
                    controller: _quillController,
                    config: const QuillEditorConfig(autoFocus: true),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.02),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            VintageButton(
              text: 'Submit',
              onPressed: () async {
                final response = await discuss.createDiscussion(
                  token: ProviderUser.token,
                  isbn: widget.bookId,
                  bookTitle: widget.title,
                  discussionTitle: titleController.text,
                  discussionBody:
                      jsonEncode(
                        _quillController.document.toDelta().toJson(),
                      ).toString(),
                );
                if (await response) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Discussion created successfully!')),
                  );
                  _quillController.clear();
                  titleController.clear();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to create discussion.')),
                  );
                }
              },
            ),
          ],
        ),
      ],
    );

    Widget rulesWidget = BookDiscussionRulesWidget();

    return Scaffold(
      backgroundColor: vintageCream,
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenHeight * 0.03,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              // Mobile: Stack vertically
              return ListView(
                children: [editorColumn, SizedBox(height: 24), rulesWidget],
              );
            } else if (constraints.maxWidth < 1024) {
              // Tablet: Side by side, but rules take less space
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: editorColumn),
                  SizedBox(width: 16),
                  Expanded(flex: 2, child: rulesWidget),
                ],
              );
            } else {
              // Laptop/Desktop: Side by side, rules take even less space
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 4, child: editorColumn),
                  SizedBox(width: 24),
                  Expanded(flex: 2, child: rulesWidget),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
