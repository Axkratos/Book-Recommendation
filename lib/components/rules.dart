import 'package:bookrec/theme/color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Data class for our rules
class RuleItemData {
  final String title;
  final String description;
  bool isExpanded;

  RuleItemData({
    required this.title,
    required this.description,
    this.isExpanded = false,
  });
}

class BookDiscussionRulesWidget extends StatefulWidget {
  const BookDiscussionRulesWidget({super.key});

  @override
  State<BookDiscussionRulesWidget> createState() =>
      _BookDiscussionRulesWidgetState();
}

class _BookDiscussionRulesWidgetState extends State<BookDiscussionRulesWidget> {
  // Define your rules here
  final List<RuleItemData> _rules = [
    RuleItemData(
      title: "Respect Thy Fellow Bibliophiles",
      description:
          "Engage with courtesy. No personal attacks, hate speech, or harassment. Foster a welcoming haven for all readers. Disagreements on literary merit are fine; disrespect is not.",
    ),
    RuleItemData(
      title: "Stay On Topic",
      description:
          "Discussions should focus on books, authors, genres, and literary themes. Off-topic posts may be gently redirected or removed to maintain the integrity of our discourse.",
    ),

    RuleItemData(
      title: "Guard Against Spoilers",
      description:
          "Clearly mark spoilers for major plot twists, character fates, or endings. Use spoiler tags (`>!text!<`) and specify the book, if possible. Preserve the joy of discovery for others.",
    ),
    RuleItemData(
      title: "Keep Discussions Literary",
      description:
          "Conversations should revolve around books, authors, genres, literary themes, and the art of storytelling. Tangential discussions may be gently guided back or removed.",
    ),
    RuleItemData(
      title: "No Self-Promotion",
      description:
          "Avoid excessive self-promotion or advertising of personal blogs, social media, or book-related businesses. Relevant recommendations are welcome, but blatant marketing is discouraged.",
    ),
    RuleItemData(
      title: "No Piracy or Illicit Tomes",
      description:
          "Do not share links to pirated e-books, unauthorized copies, or any illegally distributed copyrighted material. Support authors and publishers by acquiring books through legitimate channels.",
    ),
    RuleItemData(
      title: "Offer Considered Recommendations",
      description:
          "When suggesting a book, elaborate on *why* it's a worthy read. Mention genre, themes, writing style, or what resonated with you. 'It's good' is but a whisper in the wind.",
    ),
    RuleItemData(
      title: "Criticize with Care & Construction",
      description:
          "When expressing dislike for a book, be specific and constructive. Avoid mere dismissals. Explain what didn't work for you, fostering a deeper understanding of literary preferences.",
    ),
    RuleItemData(
      title: "Prudent Self-Promotion",
      description:
          "Minimal, relevant self-promotion of your own book-related works (blogs, reviews, published books) may be permissible in designated areas or with moderator approval. Avoid excessive solicitation.",
    ),
    RuleItemData(
      title: "Cite Thy Sources, If Able",
      description:
          "When presenting factual claims about literary history, authorial intent, or critical interpretations, providing sources enhances the scholarly quality of our discourse.",
    ),
  ];

  // Vintage Colors
  // Expansion tile background

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300, // Adjust width as needed
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: vintageCream,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: vintageBrown.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(2, 2),
          ),
        ],
        border: Border.all(color: vintageBrown.withOpacity(0.5), width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0, left: 4.0, right: 4.0),
            child: Text(
              "The Reader's Compact", // Vintage Title
              style: GoogleFonts.playfairDisplay(
                // Or try Lora, EB Garamond
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: vintageDarkBrown,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Divider(color: vintageAccent.withOpacity(0.7), thickness: 1),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(), // Important if inside another scrollable
            itemCount: _rules.length,
            itemBuilder: (context, index) {
              final rule = _rules[index];
              return Theme(
                data: Theme.of(context).copyWith(
                  dividerColor:
                      Colors
                          .transparent, // Remove default divider in ExpansionTile
                  iconTheme: IconThemeData(color: vintageBrown),
                  textTheme: TextTheme(
                    bodyMedium: GoogleFonts.lora(
                      color: vintageDarkBrown,
                      fontSize: 14,
                    ), // For expanded text
                  ),
                ),
                child: ExpansionTile(
                  key: PageStorageKey(rule.title), // Preserve expansion state
                  backgroundColor: vintagePaper.withOpacity(0.5),
                  collapsedBackgroundColor: Colors.transparent,
                  iconColor: vintageBrown,
                  collapsedIconColor: vintageBrown,
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 0,
                  ),
                  childrenPadding: const EdgeInsets.all(12.0).copyWith(top: 0),
                  initiallyExpanded: rule.isExpanded,
                  onExpansionChanged: (bool expanded) {
                    setState(() {
                      rule.isExpanded = expanded;
                    });
                  },
                  title: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${index + 1}.",
                        style: GoogleFonts.lora(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: vintageDarkBrown,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          rule.title,
                          style: GoogleFonts.lora(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: vintageDarkBrown,
                          ),
                        ),
                      ),
                    ],
                  ),
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 23.0,
                      ), // Align with title text
                      child: Text(
                        rule.description,
                        style: GoogleFonts.lora(
                          // Use Lora or Merriweather for body
                          fontSize: 13.5,
                          color: vintageBrown,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
