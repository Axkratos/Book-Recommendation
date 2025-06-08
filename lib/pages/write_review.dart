import 'dart:convert';

import 'package:bookrec/components/VintageButton.dart';
import 'package:bookrec/components/footer.dart';
import 'package:bookrec/components/rules.dart';
import 'package:bookrec/components/text_form_field.dart';
import 'package:bookrec/theme/color.dart';
import 'package:bookrec/theme/dashboard_title.dart';
import 'package:bookrec/theme/texts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class WriteReview extends StatefulWidget {
  const WriteReview({super.key});

  @override
  State<WriteReview> createState() => _WriteReviewState();
}

class _WriteReviewState extends State<WriteReview> {
  final QuillController _quillController = QuillController.basic();

  @override
  void dispose() {
    _quillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: vintageCream,
      body: Padding(
        padding: EdgeInsets.only(top: screenHeight * 0.04),
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
                            screenWidth: screenWidth,
                            icon: Icons.search,
                            hintText: 'Search for a book...',
                          ),
                        ],
                      ),
                      SizedBox(
                        height: screenHeight * 0.01,
                      ), // Spacing between title and form

                      Container(
                        width: double.infinity,
                        child: VintageTextFormField(
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
                            onPressed: () {
                              final String json = jsonEncode(
                                _quillController.document.toDelta().toJson(),
                              );
                              print('Submitted Review: $json');
                              _quillController
                                  .clear(); 
                                  
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
            SimpleElegantVintageFooter(),
          ],
        ),
      ),
    );
  }
}
