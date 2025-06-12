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
    return Scaffold(
      backgroundColor: vintageCream,
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.08,
          vertical: screenHeight * 0.05,
        ),
        child: ListView(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
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
                      SizedBox(
                        height: screenHeight * 0.01,
                      ), // Spacing between title and form

                      Container(
                        width: double.infinity,
                        child: VintageTextFormField(
                          controller: titleController,
                          screenWidth: screenWidth,
                          icon: Icons.title,
                          hintText: 'Title of the Review',
                        ),
                      ),
                      SizedBox(
                        height: screenHeight * 0.02,
                      ), // Spacing between title and form

                      Column(
                        children: [
                          Container(
                            width: screenWidth * 0.6,
                            height: screenHeight * 0.5,
                            decoration: BoxDecoration(
                              color: vintageCream,
                              border: Border.all(
                                color: vintageBorderColor,
                                width: 1,
                              ),
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
                                      //showHeaderStyle: false,
                                      showFontFamily: false,
                                      showFontSize: false,
                                      showInlineCode: false,
                                      showColorButton: false,
                                      showSearchButton: false,

                                      showLink: false,
                                      //showListBullets: false,
                                      showListCheck: false,
                                      //showListNumbers: false,
                                      //showQuote: false,
                                    ),
                                  ),
                                  Divider(
                                    color: vintageBorderColor,
                                    thickness: 1,
                                  ),
                                  Expanded(
                                    child: QuillEditor.basic(
                                      controller: _quillController,
                                      config: const QuillEditorConfig(
                                        autoFocus: true,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          VintageButton(
                            text: 'Submit',
                            onPressed: () async {
                              /*
                              final String json = jsonEncode(
                                _quillController.document.toDelta().toJson(),
                              );*/
                              final response = await discuss.createDiscussion(
                                token:
                                    ProviderUser
                                        .token, // Replace with actual token
                                isbn: widget.bookId,
                                bookTitle: widget.title,
                                discussionTitle:
                                    titleController
                                        .text, // Replace with actual title
                                discussionBody: jsonEncode(
                                  _quillController.document
                                      .toDelta()
                                      .toJson()
                                      .toString(),
                                ),
                              );
                              if (await response) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Discussion created successfully!',
                                    ),
                                  ),
                                );
                                _quillController.clear();
                                titleController.clear();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Failed to create discussion.',
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ), // Spacing between editor and submit button
                    ],
                  ),
                ),
                SizedBox(width: screenWidth * 0.03), // Spacing between columns
                Expanded(
                  child: Container(child: BookDiscussionRulesWidget()),
                ), // Placeholder for the right side
              ],
            ),
            // SimpleElegantVintageFooter(),
          ],
        ),
      ),
    );
  }
}
