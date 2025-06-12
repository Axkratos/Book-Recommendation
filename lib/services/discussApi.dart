import 'package:bookrec/modals.dart/forum_modal.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Discussapi {
  final String baseUrl = dotenv.env['baseUrl']!;

  Future<bool> createDiscussion({
    required String token,
    required String isbn,
    required String bookTitle,
    required String discussionTitle,
    required String discussionBody,
  }) async {
    final url = Uri.parse('${baseUrl}/api/v1/books/forum');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'ISBN': isbn,
        'bookTitle': bookTitle,
        'discussionTitle': discussionTitle,
        'discussionBody': discussionBody,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      print('Failed to create discussion: ${response.body}');
      return false;
    }
  }

  Future<ForumPageResponse> fetchForums({int page = 1, int limit = 5}) async {
    final String url = '${baseUrl}/api/v1/users/forums?page=$page&limit=$limit';
    print('Fetching forums from: $url'); // Debugging line to check URL

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      print('Response status: ${response.statusCode}'); // Debugging line
      //print('Response body: ${response.body}'); // Debugging line
      final data = json.decode(response.body);
      List forums = data['data'];
      print('Forums fetched: $forums'); // Debugging line
      return ForumPageResponse(
        forums: forums.map((json) => Forum.fromJson(json)).toList(),
        totalPages: data['totalPages'],
      );
    } else {
      throw Exception('Failed to load forum data');
    }
  }
}

class ForumPageResponse {
  final List<Forum> forums;
  final int totalPages;

  ForumPageResponse({required this.forums, required this.totalPages});
}
