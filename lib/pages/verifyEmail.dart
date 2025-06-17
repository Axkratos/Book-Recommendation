import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final String baseUrl = dotenv.env['baseUrl']!;
  final TextEditingController _emailController = TextEditingController();

  Future<void> _resendVerification(BuildContext context) async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter your email')));
      return;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/auth/resendverification'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    final data = jsonDecode(response.body);
    final message = data['message'] ?? 'Something went wrong';

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.email_outlined, size: 80, color: Colors.indigo),
              const SizedBox(height: 24),
              Text('Check your email', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              const Text(
                'We’ve sent you an email with a verification link. Please check your inbox and follow the instructions to verify your email address.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Enter your email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => _resendVerification(context),
                icon: const Icon(Icons.refresh),
                label: const Text('Resend email'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
