import 'package:bookrec/components/VintageButton.dart';
import 'package:bookrec/components/drop_down_menu.dart';
import 'package:bookrec/components/text_form_field.dart';
import 'package:bookrec/dummy/book.dart';
import 'package:bookrec/theme/color.dart';
import 'package:bookrec/theme/dashboard_title.dart';
import 'package:bookrec/theme/texts.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DashboardShelf extends StatefulWidget {
  const DashboardShelf({Key? key}) : super(key: key);

  @override
  State<DashboardShelf> createState() => _DashboardShelfState();
}

class _DashboardShelfState extends State<DashboardShelf> {
  List _book = books_profile;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final type = ['Latest', 'Alpabetical', 'Rating'];
    return SelectionArea(
      child: Scaffold(
        backgroundColor: vintageCream,
        body: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 20,
                      top: screenHeight * 0.04,
                      //left: 20,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        dashboard_title(title: 'Shelf'),
                        Row(
                          children: [
                            Container(
                              width: screenWidth * 0.1,
                              child: VintageTextFormField(
                                screenWidth: screenWidth,
                                icon: Icons.search,
                                hintText: 'Search your books',
                                onChanged: (value) {
                                  if (value.isNotEmpty) {
                                    setState(() {
                                      _book = searchBook(books_profile, value);
                                    });
                                  } else {
                                    setState(() {
                                      _book = books_profile;
                                    });
                                  }
                                },
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.01),
                            menu_drop(
                              type: type,
                              title: 'Sort by',
                              onChanged: (value) {
                                setState(() {
                                  _book = _sort(_book, value);
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: vintageCream,
                      boxShadow: [
                        BoxShadow(
                          color: vintageBorderColor.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(
                            2,
                            0,
                          ), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        shelf_section(
                          image: true,
                          screenWidth: screenWidth,
                          book: const {},
                          widget: Text(
                            'Cover Image',
                            style: vintageSubtitleStyle,
                          ),
                        ),
                        shelf_section(
                          image: false,
                          screenWidth: screenWidth,
                          book: const {},
                          widget: Text(
                            'Title',
                            style: vintageSubtitleStyle,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        shelf_section(
                          image: false,
                          screenWidth: screenWidth,
                          book: const {},
                          widget: Text(
                            'Author',
                            style: vintageSubtitleStyle,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        shelf_section(
                          image: false,
                          screenWidth: screenWidth,
                          book: const {},
                          widget: Text(
                            'Rating',
                            style: vintageSubtitleStyle,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        shelf_section(
                          image: false,
                          screenWidth: screenWidth,
                          book: const {},
                          widget: Text(
                            'Date Added',
                            style: vintageSubtitleStyle,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        shelf_section(
                          image: false,
                          screenWidth: screenWidth,
                          book: const {},
                          widget: Text(
                            'Review',
                            style: vintageSubtitleStyle,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: ListView.builder(
                      itemCount: _book.length,
                      itemBuilder: (context, index) {
                        final book = _book[index];
                        return Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: vintageBorderColor.withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              shelf_section(
                                image: true,
                                screenWidth: screenWidth,
                                book: book,
                                widget: Image.network(book['cover']),
                              ),
                              shelf_section(
                                image: false,
                                screenWidth: screenWidth,
                                book: book,
                                widget: Text(
                                  book['title'],
                                  style: vintageTextStyle,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              shelf_section(
                                image: false,
                                screenWidth: screenWidth,
                                book: book,
                                widget: Text(
                                  book['author'],
                                  style: vintageTextStyle,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              shelf_section(
                                image: false,
                                screenWidth: screenWidth,
                                book: book,
                                widget: Text(
                                  book['rating'].toString(),
                                  style: vintageTextStyle,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              shelf_section(
                                image: false,
                                screenWidth: screenWidth,
                                book: book,
                                widget: Text(
                                  book['publication_year'].toString(),
                                  style: vintageTextStyle,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              shelf_section(
                                screenWidth: screenWidth,
                                book: book,
                                widget: TextButton(
                                  onPressed: () {},
                                  child: Text(
                                    'Write Review',
                                    style: vintageLabelStyle,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                image: false,
                              ),
                              SizedBox(width: screenWidth * 0.01),
                              VintageButton(text: 'Remove', onPressed: () {}),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 40, left: 30),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: vintageBorderColor, width: 1),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: screenHeight * 0.10),
                        Text(
                          'Books(${books_profile.length})',
                          style: vintageTextStyle.copyWith(
                            fontSize: 20,
                            height: 1.5,
                            fontWeight: FontWeight.bold,
                            color: vintageDarkBrown,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Text(
                          'Most Read Genres',
                          style: vintageTextStyle.copyWith(
                            fontSize: 18,
                            height: 1.5,
                            color: vintageDarkBrown.withOpacity(0.8),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            for (var genre in ['Fiction', 'Mystery', 'Fantasy'])
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.02,
                                  vertical: screenHeight * 0.01,
                                ),
                                decoration: BoxDecoration(
                                  color: vintageDarkBrown.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  genre,
                                  style: vintageTextStyle.copyWith(
                                    fontSize: 16,
                                    color: vintageDarkBrown,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Text(
                          'Most Read Authors',
                          style: vintageTextStyle.copyWith(
                            fontSize: 18,
                            height: 1.5,
                            color: vintageDarkBrown.withOpacity(0.8),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            for (var author in [
                              'Author A',
                              'Author B',
                              'Author C',
                            ])
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.02,
                                  vertical: screenHeight * 0.01,
                                ),
                                decoration: BoxDecoration(
                                  color: vintageDarkBrown.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  author,
                                  style: vintageTextStyle.copyWith(
                                    fontSize: 16,
                                    color: vintageDarkBrown,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<dynamic> _sort(List _book, String value) {
  if (value == 'Latest') {
    _book.sort(
      (a, b) => b['publication_year'].compareTo(a['publication_year']),
    );
  } else if (value == 'Alpabetical') {
    _book.sort((a, b) => a['title'].compareTo(b['title']));
  } else if (value == 'Rating') {
    _book.sort((a, b) => b['rating'].compareTo(a['rating']));
  }
  return _book;
}

List searchBook(List books, String query) {
  return books
      .where(
        (book) => book['title'].toLowerCase().contains(query.toLowerCase()),
      )
      .toList();
}

class shelf_section extends StatelessWidget {
  final double screenWidth;
  final Map<String, dynamic> book;
  Widget widget;
  bool image;
  final double width;

  shelf_section({
    super.key,
    required this.screenWidth,
    required this.book,
    required this.widget,
    required this.image,
  }) : width = image ? screenWidth * .05 : screenWidth * 0.07;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 20),
      child: Center(child: SizedBox(width: width, child: widget)),
    );
  }
}
