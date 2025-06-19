import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Authservice {
  final String baseUrl = dotenv.env['baseUrl']!;
  Future<String> sendRegisterRequest(
    String first_name,
    //String last_name,
    String email,
    String password,
  ) async {
    final url = Uri.parse('${baseUrl}/api/v1/auth/signup');

    Map<String, dynamic> registerUser = {
      "fullName": first_name,
      //"lastName": last_name,
      "email": email,
      "password": password,
      "confirmPassword": password,
      "role": "tourist",
    };

    final response = await http.post(
      url,
      headers: {'content-type': 'application/json'},
      body: jsonEncode(registerUser),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return 'success';
      //print('Sucess:${response.body}');
    } else {
      final responseData = jsonDecode(response.body);
      if (responseData['message'] != null) {
        return responseData['message'];
      } else {
        return 'An error occurred. Please try again.';
      }
    }
  }

  Future<Map<String, dynamic>> sendLoginRequest(
    String email,
    String password,
  ) async {
    final url = Uri.parse('${baseUrl}/api/v1/auth/login');
    Map<String, dynamic> loginUser = {"email": email, "password": password};
    final response = await http.post(
      url,
      headers: {'content-type': 'application/json'},
      body: jsonEncode(loginUser),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      print('Response from sendLogin ${responseData.toString()}');
      return responseData;
    } else {
      final responseData = jsonDecode(response.body);
      return {
        'status': 'failed',
        'message':
            '${responseData['message'] ?? 'An error occurred. Please try again.'}',
      };
    }
  }

  Future<Map<String, String>> verifyEmail(String token) async {
    final url = Uri.parse('${baseUrl}/api/v1/auth/verifyemail/$token');
    final response = await http.get(
      url,
      headers: {'content-type': 'application/json'},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      print('Response from verifEmail ${responseData.toString()}');
      return {'status': 'success', 'token': responseData['token']};
    } else {
      print('Error from verifEmail: ${response.statusCode}');
      return {
        'status': 'failed ${response.statusCode}',
        'message': 'An error occurred. Please try again.',
      };
    }
  }
}
