import 'package:bookrec/components/VintageButton.dart';
import 'package:bookrec/components/vintage_feed.dart';
import 'package:bookrec/dummy/reviews.dart';
import 'package:bookrec/theme/color.dart';
import 'package:bookrec/theme/dashboard_title.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DiscussionPage extends StatelessWidget {
  const DiscussionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    return SelectionArea(
      child: Scaffold(
        backgroundColor: vintageCream,
        body: Padding(
          padding: EdgeInsets.only(top: screenHeight * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  dashboard_title(title: 'Discussion/Forum'),
                  VintageButton(
                    text: '+ Create Discussion',
                    onPressed: () {
                      context.go('/dashboard/discussion/writereview');
                    },
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),

              Container(
                height: screenHeight * 0.74,
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    return VintageFeedCard(reviewData: reviews[index]);
                  },
                  itemCount: reviews.length,
                  //shrinkWrap: true,
                  //physics: NeverScrollableScrollPhysics(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
