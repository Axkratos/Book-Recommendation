import 'package:bookrec/provider/authprovider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http; // To make HTTP requests
import 'dart:convert';

import 'package:provider/provider.dart'; // To decode the JSON response

class BooksInfo {
  final String baseUrl = dotenv.env['baseUrl']!;

  Future<List> getBookInfo(String title) async {
    String formattedTitle = Uri.encodeQueryComponent(
      title,
    ).replaceAll('%20', '+');
    http.Response response = await http.get(
      Uri.parse(
        'https://openlibrary.org/search.json?title=$formattedTitle&fields=key,title,author_name,average_rating,cover_i&limit=1',
      ),
    );
    Map data = jsonDecode(response.body);

    return (data['docs']);
  }

  Future<List> getTrendingBooks() async {
    final url = Uri.parse('${baseUrl}/api/v1/users/trending');
    http.Response response = await http.get(url);
    Map data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      print('Trending books fetched successfully');
      //print(data['data']);
      return data['data'];
    } else {
      print('Error fetching trending books: ${response.statusCode}');

      return [];
    }
  }

  Future<Map<String, dynamic>> getSingleBook(String bookId) async {
    final url = Uri.parse('${baseUrl}/api/v1/users/books/$bookId');
    http.Response response = await http.get(url);
    if (response.statusCode == 200) {
      Map data = jsonDecode(response.body);
      return data['data'];
    } else {
      print('Error fetching book: ${response.statusCode}');
      return {};
    }
  }

  Future<String> bookRatings(String bookId, int value, String token) async {
    final url = Uri.parse('${baseUrl}/api/v1/books/rating');
    Map<String, dynamic> bookData = {
      'ISBN': bookId,
      'rating': value * 2, // Assuming a default rating of 5 for the example
    };

    http.Response respone = await http.post(
      url,
      headers: {
        'content-type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(bookData),
    );
    if (respone.statusCode == 200) {
      Map data = jsonDecode(respone.body);
      print('Book rating updated successfully: ${respone.statusCode}');
      return 'sucess';
    } else {
      print('response status code: ${respone.body}');
      print('Error rating book: ${respone.statusCode}');
      return 'error';
    }
  }
}
