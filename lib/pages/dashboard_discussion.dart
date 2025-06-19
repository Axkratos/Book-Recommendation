import 'dart:convert';
import 'package:http/http.dart' as http; // Add this import

import 'package:bookrec/modals.dart/forum_modal.dart';
import 'package:bookrec/provider/authprovider.dart';
import 'package:bookrec/services/discussApi.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bookrec/components/VintageButton.dart';
import 'package:bookrec/components/vintage_feed.dart';
import 'package:bookrec/theme/color.dart';
import 'package:bookrec/theme/dashboard_title.dart';
import 'package:bookrec/pages/dashboard_home.dart';
import 'package:provider/provider.dart'; // <-- Add this line

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
  bool _showUserForums = false; // <-- Add this

  final discuss = Discussapi();

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<UserProvider>(context, listen: false);

    _loadPage(_currentPage, provider.token); // <-- Pass the token
  }

  Future<void> _loadPage(int page, String token) async {
    setState(() => _isLoading = true);

    try {
      final response =
          _showUserForums
              ? await discuss.fetchUsersForums(
                page: page,
                token: token,
              ) // <-- Add this method
              : await discuss.fetchForums(page: page);
      print('Fetched forums for page $response');
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

  Future<void> _deleteForum(String forumId, String token) async {
    try {
      final response = await discuss.deleteForum(forumId, token);
      if (response['status'] == 'success') {
        setState(() {
          _forums.removeWhere((f) => f.id == forumId);
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Forum deleted successfully')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete forum')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _reportForum({
    required String forumId,
    required String reporterId,
    required String token,
  }) async {
    final TextEditingController _controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Report Forum'),
            content: TextField(
              controller: _controller,
              decoration: InputDecoration(hintText: 'Describe the issue...'),
              maxLines: 3,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed:
                    () => Navigator.pop(context, _controller.text.trim()),
                child: Text('Submit'),
              ),
            ],
          ),
    );

    if (result != null && result.isNotEmpty) {
      try {
        final data = await discuss.report(
          type: 'forum', // Specify the type of report
          forumId: forumId,
          reporterId: reporterId,
          token: token,
          content: result,
        );
        if (data['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Report submitted. Thank you!')),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to submit report.')));
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  List<Widget> _buildPaginationButtons() {
    return List<Widget>.generate(_totalPages, (i) {
      final page = i + 1;
      return TextButton(
        onPressed:
            () => _loadPage(
              page,
              Provider.of<UserProvider>(context, listen: false).token,
            ),
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
        backgroundColor: Color(0xFFF7F2E9),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 40.0,
                vertical: 50.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SectionHeader(title: 'Discussion / Forum'),
                      VintageButton(
                        text: _showUserForums ? 'Global' : 'User',
                        onPressed: () {
                          setState(() {
                            _showUserForums = !_showUserForums;
                          });
                          _loadPage(
                            1,
                            Provider.of<UserProvider>(
                              context,
                              listen: false,
                            ).token,
                          ); // Reload forums for the new mode
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 24), // Match spacing from dashboard_home
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
                                final content = safeDecode(
                                  forum.discussionBody,
                                );
                                final userProvider = Provider.of<UserProvider>(
                                  context,
                                  listen: false,
                                );

                                return GestureDetector(
                                  onTap: () => context.go('/view/${forum.id}'),
                                  child: Stack(
                                    children: [
                                      ModernFeedCard(
                                        reviewData: {
                                          'id': forum.id! ?? 'Unknown ID',
                                          'title':
                                              forum.discussionTitle ??
                                              'No Title',
                                          'book':
                                              forum.bookTitle ?? 'Unknown Book',
                                          'author':
                                              forum.userId ?? 'Unknown Author',
                                          'cover':
                                              'https://covers.openlibrary.org/b/isbn/${forum.isbn}-M.jpg',
                                          'content': content,
                                          'upvotes': forum.likeCount.toString(),
                                          'comments': 'N/A',
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
                                      Positioned(
                                        top: 8,
                                        right: 35, // Move flag to the far right
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.flag,
                                            color: Colors.redAccent,
                                          ),
                                          tooltip: 'Report Forum',
                                          onPressed: () async {
                                            await _reportForum(
                                              forumId: forum.id!,
                                              reporterId: forum.userId!,
                                              // Adjust if your user model differs
                                              token: userProvider.token,
                                            );
                                          },
                                        ),
                                      ),
                                      if (_showUserForums)
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: PopupMenuButton<String>(
                                            icon: Icon(
                                              Icons.more_vert,
                                              color: Colors.black87,
                                            ),
                                            onSelected: (value) async {
                                              if (value == 'delete') {
                                                final token =
                                                    Provider.of<UserProvider>(
                                                      context,
                                                      listen: false,
                                                    ).token;
                                                await _deleteForum(
                                                  forum.id!,
                                                  token,
                                                );
                                              }
                                            },
                                            itemBuilder:
                                                (context) => [
                                                  PopupMenuItem(
                                                    value: 'delete',
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.delete,
                                                          color: Colors.red,
                                                        ),
                                                        SizedBox(width: 8),
                                                        Text('Delete'),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                          ),
                                        ),
                                    ],
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
        ),
      ),
    );
  }
}

// Add this to your Discussapi class (in discussApi.dart):
// (Make sure to handle authorization headers as needed)
