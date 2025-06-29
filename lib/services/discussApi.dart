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
      print('Forums fetched: ${data['totalPages']}'); // Debugging line
      return ForumPageResponse(
        forums: forums.map((json) => Forum.fromJson(json)).toList(),
        totalPages: data['totalPages'],
      );
    } else {
      throw Exception('Failed to load forum data');
    }
  }

  Future<ForumPageResponse> fetchUsersForums({
    int page = 1,
    int limit = 5,
    required String token,
  }) async {
    final String url =
        '${baseUrl}/api/v1/books/forum/user?page=$page&limit=$limit';
    print('Fetching forums from: $url'); // Debugging line to check URL

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${token}',
      },
    );

    if (response.statusCode == 200) {
      print('Response status: ${response.statusCode}'); // Debugging line
      //print('Response body: ${response.body}'); // Debugging line
      final data = json.decode(response.body);
      List forums = data['data'];
      print('Forums fetched: ${data['totalPages']}'); // Debugging line
      return ForumPageResponse(
        forums: forums.map((json) => Forum.fromJson(json)).toList(),
        totalPages: data['totalPages'],
      );
    } else {
      throw Exception('Failed to load forum data');
    }
  }

  Future<Map<String, dynamic>> deleteForum(String forumId, String token) async {
    final url = Uri.parse('$baseUrl/api/v1/books/forum/$forumId');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    return jsonDecode(response.body);
  }

  Future<String> CreateComment({
    required String isbn,
    required String forumId,
    required String commentBody,
    required String token,
  }) async {
    final url = Uri.parse('${baseUrl}/api/v1/books/comment');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "isbn": isbn,
        "forumId": forumId,
        "comment": commentBody,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Comment created successfully: ${response.body}');
      return 'sucess';
    } else {
      print('Failed to create comment: ${response.body}');
      return 'failed';
    }
  }

  Future<Map<String, dynamic>> report({
    required String forumId,
    required String reporterId,
    required String token,
    required String content,
    required String type,
  }) async {
    final url = Uri.parse('$baseUrl/api/v1/books/report');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "type": type,
        "targetId": forumId,
        "content": content,
        "createdBy": reporterId,
      }),
    );
    return jsonDecode(response.body);
  }
}

class ForumPageResponse {
  final List<Forum> forums;
  final int totalPages;

  ForumPageResponse({required this.forums, required this.totalPages});
}
