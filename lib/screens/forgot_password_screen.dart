import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:testing_app/screens/config.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final TextEditingController userIdController = TextEditingController();

  ForgotPasswordScreen({super.key});

  Future<void> submitForgotPassword(String email, BuildContext context) async {
    final String apiUrl = '${AppConfig.baseUrl}/api/forgotPass/forgot-password';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({'email': email}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset link sent to your email')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send reset link.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred. Please try again later.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(12.0),
                color: Colors.blue[800],
                child: const Center(
                  child: Text(
                    'Submit your Email',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Email * :',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: userIdController,
                decoration: InputDecoration(
                  hintText: 'example123@gmail.com',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  String email = userIdController.text.trim();
                  if (email.isNotEmpty) {
                    submitForgotPassword(email, context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter your email')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[400],
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Divider(
                color: Colors.grey,
                thickness: 1,
              ),
              const Center(
                child: Text(
                  '--OR--',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () {
                  Navigator.pop(context); // Navigates back to login screen
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  side: const BorderSide(color: Colors.green),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'Sign In',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const Center(
                child: Text(
                  'DigiClasses ©2024',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
