import 'package:bookrec/components/VintageButton.dart';
import 'package:bookrec/components/chat_ai.dart';
import 'package:bookrec/dummy/book.dart';
import 'package:bookrec/theme/color.dart';
import 'package:bookrec/theme/dashboard_title.dart';
import 'package:bookrec/theme/texts.dart';
import 'package:flutter/material.dart';

class DashboardHome extends StatelessWidget {
  const DashboardHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    return SelectionArea(
      child: Scaffold(
        backgroundColor: vintageCream,
        body: Padding(
          padding: EdgeInsets.only(top: screenHeight * 0.04),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: ListView(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.04,
                      child: dashboard_title(title: 'Recommended Books'),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Here are some books we think you will love based on your past reads,preferences, and interests.',
                      style: vintageTextStyle.copyWith(
                        fontSize: 18,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 20),
                    book_card_section(),

                    SizedBox(height: screenHeight * 0.04),
                    Text(
                      'Here are some books, that people with similar interests to you have read and loved.',
                      style: vintageTextStyle.copyWith(
                        fontSize: 20,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 20),
                    book_card_section(),
                  ],
                ),
              ),
              Expanded(child: BookAIChatWidget()),
            ],
          ),
        ),
      ),
    );
  }
}

class book_card_section extends StatelessWidget {
  const book_card_section({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 2, color: vintageBorderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      height: MediaQuery.of(context).size.height * 0.65,
      width: MediaQuery.of(context).size.width * 0.6,
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            childAspectRatio: 0.6,
            mainAxisSpacing: 5,
            crossAxisSpacing: 5,
          ),
          itemCount: books_profile.length,
          clipBehavior: Clip.hardEdge,

          itemBuilder: (context, index) {
            return dashboard_book_card(books: books_profile[index]);
          },
        ),
      ),
    );
  }
}

class dashboard_book_card extends StatelessWidget {
  dashboard_book_card({super.key, required this.books});
  Map<String, dynamic> books;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(),
      child: Column(
        children: [
          Flexible(child: Image.network(books['cover'], fit: BoxFit.cover)),
          SizedBox(height: 10),
          VintageButton(text: 'Already Read', onPressed: () {}),
          SizedBox(height: 10),
          Text(
            'Not Interested',
            style: vintageTextStyle.copyWith(fontSize: 18, color: vintageRed),
          ),
        ],
      ),
    );
  }
}
