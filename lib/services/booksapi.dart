import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http; // To make HTTP requests
import 'dart:convert'; // To decode the JSON response

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
}
