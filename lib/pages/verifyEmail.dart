import 'package:flutter/material.dart';

class EmailVerificationPage extends StatelessWidget {
  const EmailVerificationPage({super.key});

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
              TextButton.icon(
                onPressed: () {
                  // TODO: Handle resend verification logic
                },
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
