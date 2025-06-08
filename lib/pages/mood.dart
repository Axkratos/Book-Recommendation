import 'package:bookrec/components/VintageBookCard.dart';
import 'package:bookrec/components/VintageButton.dart';
import 'package:bookrec/components/drop_down_menu.dart';
import 'package:bookrec/components/footer.dart';
import 'package:bookrec/components/similarBooks/similarBookSection.dart';
import 'package:bookrec/constants/constants.dart';
import 'package:bookrec/dummy/book.dart';
import 'package:flutter/material.dart';
import 'package:bookrec/theme/color.dart';
import 'package:bookrec/theme/texts.dart';

class Mood extends StatelessWidget {
  const Mood({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    return SelectionArea(
      child: Scaffold(
        backgroundColor: vintageCream,
        body: ListView(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                //vertical: screenHeight * 0.02,
                horizontal:
                    screenWidth < 600 ? screenWidth * 0.01 : screenWidth * 0.09,
              ),
              child: Column(
                children: [
                  med_screen_layout(screenHeight: screenHeight),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      //double cardWidth = constraints.maxWidth;
                      if (constraints.maxWidth > 900) {
                        // Desktop
                        return Container(
                          height: screenHeight * 0.7,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              VintageBookCard(book: book),
                              Expanded(
                                child: SimilarBooksSection(
                                  similarBooks: similar_books,
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: VintageBookCard(book: book),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 200,
                              child: SimilarBooksSection(
                                isSmallScreen: true,
                                similarBooks: similar_books,
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            SimpleElegantVintageFooter(),
          ],
        ),
      ),
    );
  }
}

class med_screen_layout extends StatelessWidget {
  const med_screen_layout({super.key, required this.screenHeight});

  final double screenHeight;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    // Determine crossAxisCount based on screen width for responsiveness

    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 243, 203, 123),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Center(
        child: GridView(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: screenHeight * 0.2, // allows spacing
            childAspectRatio: 3.5, // adjusted for dropdown + button width
            mainAxisSpacing: 15,
            crossAxisSpacing: 15,
          ),
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: [
            menu_drop(type: mood, title: 'Mood', onChanged: (value) {}),
            menu_drop(type: genres, title: 'Genres', onChanged: (value) {}),
            menu_drop(type: seasons, title: 'Seasons', onChanged: (value) {}),
            menu_drop(
              type: countries,
              title: 'Countries',
              onChanged: (value) {},
            ),
            menu_drop(
              type: pg_rated,
              title: 'PG Rating',
              onChanged: (value) {},
            ),
            menu_drop(type: rated, title: 'Ratings', onChanged: (value) {}),
            menu_drop(type: gore, title: 'Gore', onChanged: (value) {}),

            Center(
              child: SizedBox(
                height: 38, // Adjust height as needed
                width: double.infinity, // Adjust width as needed
                child: VintageButton(text: 'Submit', onPressed: () {}),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
