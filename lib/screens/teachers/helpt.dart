import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:testing_app/screens/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HelpT extends StatelessWidget {
  final String option;

  const HelpT({super.key, this.option = 'contactUs'});

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

void _openInstagram() async {
  const String instagramUrl = 'https://www.instagram.com/digi.class2024/';
  await FlutterWebBrowser.openWebPage(url: instagramUrl);
}


// Function to open the Facebook page
void _openFacebook() async {
  const facebookUrl = 'https://www.facebook.com/yourProfileLink'; // Replace with your Facebook profile link
  if (await canLaunchUrl(Uri.parse(facebookUrl))) {
    await launchUrl(Uri.parse(facebookUrl));
  } else {
    throw 'Could not launch $facebookUrl';
  }
}

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Contact Us'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon and heading
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blueAccent,
              child: Icon(
                Icons.support_agent,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Contact Us',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 24),

            // Email section
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.email,
                  color: Colors.blueAccent,
                  size: 30,
                ),
                title: const Text(
                  'Email Us',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  'digiclass737@gmail.com',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Call section
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.phone,
                  color: Colors.green,
                  size: 30,
                ),
                title: const Text(
                  'Call Us',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  '+91 81695 56700',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Social media links section
            const Text(
              'Follow Us',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.facebook),
                  color: Colors.blue,
                  iconSize: 30,
                  onPressed: _openFacebook, // Link to your Facebook page
                ),
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.instagram),
                  color: Colors.pinkAccent,
                  iconSize: 30,
                  onPressed: _openInstagram, // Link to your Instagram page
                ),
              ],
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
    final prefs = await SharedPreferences.getInstance(); // Get instance of SharedPreferences
    final String? token = prefs.getString('token'); // Retrieve token from SharedPreferences
    final String? userId = prefs.getString('userId'); // Retrieve userId from SharedPreferences
    final String? role = prefs.getString('role'); // Retrieve role from SharedPreferences

    if (token == null || userId == null || role == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not authenticated!')),
      );
      return;
    }

    // Prepare the body with dynamic role ID
    Map<String, dynamic> feedbackData = {
      'subject': selectedSubject,
      'feedback': _commentController.text,
    };

    // Attach userId dynamically based on role
    if (role == 'student') {
      feedbackData['studentId'] = userId;
    } else if (role == 'teacher') {
      feedbackData['teacherId'] = userId;
    } else if (role == 'staff') {
      feedbackData['staffId'] = userId;
    }

    // Send feedback request
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/api/feedbacks/feedbacks'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Include Bearer token
      },
      body: jsonEncode(feedbackData),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Feedback submitted successfully')),
      );
      _commentController.clear(); // Clear the form after successful submission
      setState(() {
        selectedSubject = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting feedback: ${response.body}')),
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
                    onPressed: _sendFeedback, // Call the send feedback function
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
                      // Reset the form
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
          'Message *',
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
