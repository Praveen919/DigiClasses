import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:testing_app/screens/config.dart';

class HelpScreen extends StatelessWidget {
  final String option;

  const HelpScreen({super.key, this.option = 'contactUs'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help'),
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    switch (option) {
      case 'contactUs':
        return const ContactUsScreen();
      case 'feedback':
        return const FeedbackScreen();
      default:
        return const Center(child: Text('Unknown Option'));
    }
  }
}

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Contact Us',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Email us at: xyzemail@gmail.com',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Call us: +91 81695 56700',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  String? selectedSubject;
  final TextEditingController _commentController = TextEditingController();

  Future<void> _sendFeedback() async {
    if (selectedSubject == null || _commentController.text.isEmpty) {
      // Show an error message if fields are empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    // Feedback API endpoint
    const String apiUrl =
        '${AppConfig.baseUrl}/api/feedbacks'; // Replace with your backend URL

    try {
      // Build the feedback payload
      final Map<String, dynamic> feedbackData = {
        'subject': selectedSubject,
        'feedback': _commentController.text,
        'studentId': 'student-id-here', // Replace with actual student ID
        'teacherId': 'teacher-id-here', // Replace with actual teacher ID
        // Add staffId if applicable
      };

      // Make POST request to send feedback
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer your-jwt-token', // Replace with actual JWT token
        },
        body: jsonEncode(feedbackData),
      );

      if (response.statusCode == 201) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Feedback submitted successfully')),
        );
        // Optionally clear form fields
        setState(() {
          selectedSubject = null;
          _commentController.clear();
        });
      } else {
        // Show error message if submission failed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit feedback')),
        );
      }
    } catch (e) {
      // Show error message on exception
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Send Feedback',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDropdownField('Subject *', '--Select--'),
            const SizedBox(height: 16),
            _buildCommentField(),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        _sendFeedback, // Call the function to send feedback
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Send'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedSubject = null;
                        _commentController.clear();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                    ),
                    child: const Text('Reset'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(
              value: 'Subject 1',
              child: Text('Subject 1'),
            ),
            DropdownMenuItem(
              value: 'Subject 2',
              child: Text('Subject 2'),
            ),
            DropdownMenuItem(
              value: 'Subject 3',
              child: Text('Subject 3'),
            ),
          ],
          onChanged: (value) {
            setState(() {
              selectedSubject = value;
            });
          },
          hint: Text(hint),
          value: selectedSubject,
        ),
      ],
    );
  }

  Widget _buildCommentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Comment *',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _commentController,
          maxLines: 5,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}
