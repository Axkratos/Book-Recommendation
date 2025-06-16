import 'dart:convert';

import 'package:bookrec/components/VintageButton.dart';
import 'package:bookrec/components/chat_ai.dart';
import 'package:bookrec/components/llmRec.dart';
import 'package:bookrec/dummy/book.dart';
import 'package:bookrec/modals.dart/book_modal.dart';
import 'package:bookrec/pages/FeaturedPage.dart';
import 'package:bookrec/provider/authprovider.dart';
import 'package:bookrec/services/booksapi.dart';
import 'package:bookrec/theme/color.dart';
import 'package:bookrec/theme/dashboard_title.dart';
import 'package:bookrec/theme/texts.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class DashboardHome extends StatelessWidget {
  const DashboardHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ProviderUser = Provider.of<UserProvider>(context);
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
                    Container(height: 250, child: AIPromptSection()),
                    SizedBox(height: screenHeight * 0.04),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.05,
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
                    book_card_section(type: 'item'),

                    SizedBox(height: screenHeight * 0.04),
                    Text(
                      'Here are some books, that people with similar interests to you have read and loved.',
                      style: vintageTextStyle.copyWith(
                        fontSize: 20,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 20),
                    book_card_section(type: 'user'),
                    SizedBox(height: screenHeight * 0.04),
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
  const book_card_section({super.key, required this.type});

  final String type; // This can be 'recommended' or 'similar'

  @override
  Widget build(BuildContext context) {
    final ProviderUser = Provider.of<UserProvider>(context);
    //final String token = ProviderUser.token;

    return FutureBuilder<List<Book>>(
      future:
          type == 'item'
              ? BooksInfo().fetchBooks(ProviderUser.token)
              : BooksInfo().fetchBooksUser(ProviderUser.token),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No books found'));
        }

        final books = snapshot.data!;

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
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 0.6,
                mainAxisSpacing: 5,
                crossAxisSpacing: 5,
              ),
              itemCount: books.length,
              itemBuilder: (context, index) {
                return dashboard_book_card(books: books[index]);
              },
            ),
          ),
        );
      },
    );
  }
}

class dashboard_book_card extends StatelessWidget {
  dashboard_book_card({super.key, required this.books});
  final Book books;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(),
      child: Column(
        children: [
          Flexible(child: Image.network(books.thumbnail, fit: BoxFit.cover)),
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
