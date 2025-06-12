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
}
