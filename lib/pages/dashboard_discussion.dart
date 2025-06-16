import 'dart:convert';

import 'package:bookrec/modals.dart/forum_modal.dart';
import 'package:bookrec/services/discussApi.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bookrec/components/VintageButton.dart';
import 'package:bookrec/components/vintage_feed.dart';
import 'package:bookrec/theme/color.dart';
import 'package:bookrec/theme/dashboard_title.dart';

/// Safely decode JSON content into a List<dynamic> for Quill
dynamic safeDecode(dynamic body) {
  try {
    // Keep decoding if it's a string
    while (body is String) {
      body = jsonDecode(body);
    }

    if (body is List) {
      return body;
    }
  } catch (e) {
    debugPrint("Failed to decode discussionBody: $e");
  }

  // Fallback: return default Quill delta
  return [
    {"insert": "Invalid or no content\n"},
  ];
}

class DiscussionPage extends StatefulWidget {
  const DiscussionPage({Key? key}) : super(key: key);

  @override
  State<DiscussionPage> createState() => _DiscussionPageState();
}

class _DiscussionPageState extends State<DiscussionPage> {
  List<Forum> _forums = [];
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoading = false;

  final discuss = Discussapi();

  @override
  void initState() {
    super.initState();
    _loadPage(_currentPage);
  }

  Future<void> _loadPage(int page) async {
    setState(() => _isLoading = true);
    try {
      final response = await discuss.fetchForums(page: page);
      setState(() {
        _forums = response.forums;
        _currentPage = page;
        _totalPages = response.totalPages;
      });
    } catch (e) {
      debugPrint('Error fetching forums: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<Widget> _buildPaginationButtons() {
    return List<Widget>.generate(_totalPages, (i) {
      final page = i + 1;
      return TextButton(
        onPressed: () => _loadPage(page),
        child: Text(
          '$page',
          style: TextStyle(
            color: page == _currentPage ? Colors.black : Colors.grey,
            fontWeight:
                page == _currentPage ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return SelectionArea(
      child: Scaffold(
        backgroundColor: vintageCream,
        body: Padding(
          padding: EdgeInsets.only(top: screenHeight * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  dashboard_title(title: 'Discussion/Forum'),
                  VintageButton(
                    text: '+ Create Discussion',
                    onPressed:
                        () => context.go('/dashboard/discussion/writereview'),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),

              /// Forum List
              Expanded(
                child:
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _forums.isEmpty
                        ? const Center(child: Text('No discussions found.'))
                        : ListView.builder(
                          itemCount: _forums.length,
                          itemBuilder: (context, index) {
                            final forum = _forums[index];
                            final content = safeDecode(forum.discussionBody);

                            return GestureDetector(
                              onTap: () => context.go('/view/${forum.id}'),
                              child: VintageFeedCard(
                                reviewData: {
                                  'id': forum.id ?? 'Unknown ID',
                                  'title': forum.discussionTitle ?? 'No Title',
                                  'book': forum.bookTitle ?? 'Unknown Book',
                                  'author': forum.userId ?? 'Unknown Author',
                                  'cover':
                                      'https://covers.openlibrary.org/b/isbn/${forum.isbn}-M.jpg',

                                  'content': content,
                                  'upvotes': forum.likeCount.toString(),
                                  'comments': '900',
                                  'timeAgo':
                                      forum.createdAt != null
                                          ? DateTime.now()
                                                  .difference(
                                                    DateTime.parse(
                                                      forum.createdAt!,
                                                    ),
                                                  )
                                                  .inDays
                                                  .toString() +
                                              ' days ago'
                                          : 'Unknown time',
                                  'reason': 'Recommended for you',
                                },
                              ),
                            );
                          },
                        ),
              ),

              /// Pagination
              if (_totalPages > 1)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _buildPaginationButtons(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
