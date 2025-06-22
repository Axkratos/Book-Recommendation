import 'package:bookrec/provider/authprovider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:provider/provider.dart';

class Isloading extends StatefulWidget {
  const Isloading({super.key, this.token});
  final String? token;

  @override
  State<Isloading> createState() => _IsloadingState();
}

class _IsloadingState extends State<Isloading> {
  String? _message;
  bool _isVerifying = true;

  @override
  void initState() {
    super.initState();
    _verifyTokenAndNavigate();
  }

  Future<void> _verifyTokenAndNavigate() async {
    final result = await verifyEmail(widget.token!);

    if (result['status'] == 'success') {
      // Delay a bit so the user sees the loading for a moment
      if (!mounted) return;
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.setToken = (result['token'] ?? '');
      await Future.delayed(Duration(seconds: 1));
      if (!mounted) return;
      context.push('/like');
    } else {
      setState(() {
        _isVerifying = false;
        _message = result['message'];
      });
    }
  }

  Future<Map<String, String>> verifyEmail(String token) async {
    final String baseUrl = dotenv.env['baseUrl']!;
    final url = Uri.parse('$baseUrl/api/v1/auth/verifyemail/$token');

    try {
      final response = await http.get(
        url,
        headers: {'content-type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        print('Response from verifyEmail: ${responseData.toString()}');
        return {'status': 'success', 'token': responseData['token']};
      } else {
        print('Error from verifyEmail: ${response.statusCode}');
        return {
          'status': 'failed',
          'message': 'Verification failed. Code: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'failed', 'message': 'An error occurred: $e'};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child:
            _isVerifying
                ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text("Verifying...", style: TextStyle(fontSize: 18)),
                  ],
                )
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, color: Colors.red, size: 40),
                    SizedBox(height: 10),
                    Text(
                      _message ?? "Something went wrong.",
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
      ),
    );
  }
}
