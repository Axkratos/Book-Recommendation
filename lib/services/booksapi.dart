import 'package:http/http.dart' as http; // To make HTTP requests
import 'dart:convert'; // To decode the JSON response

class BooksInfo {
  Future<List> getBookInfo(String title ) async {
    String formattedTitle = Uri.encodeQueryComponent(title).replaceAll('%20', '+');
    http.Response response = await http.get(
      Uri.parse(
        'https://openlibrary.org/search.json?title=$formattedTitle&fields=key,title,author_name,average_rating,cover_i&limit=1',
      ),
    );
    Map data = jsonDecode(response.body);

    return (data['docs']);
  }
}
