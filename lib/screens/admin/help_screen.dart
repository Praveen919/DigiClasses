import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:testing_app/screens/config.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
      case 'viewFeedback':
        return const ViewTeacherFeedbackScreen();
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
  const facebookUrl =
      'https://www.facebook.com/yourProfileLink'; // Replace with your Facebook profile link
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
            const CircleAvatar(
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
              child: const ListTile(
                leading: Icon(
                  Icons.email,
                  color: Colors.blueAccent,
                  size: 30,
                ),
                title: Text(
                  'Email Us',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
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
              child: const ListTile(
                leading: Icon(
                  Icons.phone,
                  color: Colors.green,
                  size: 30,
                ),
                title: Text(
                  'Call Us',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
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
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: FaIcon(FontAwesomeIcons.facebook),
                  color: Colors.blue,
                  iconSize: 30,
                  onPressed: _openFacebook, // Link to your Facebook page
                ),
                IconButton(
                  icon: FaIcon(FontAwesomeIcons.instagram),
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

class ViewTeacherFeedbackScreen extends StatefulWidget {
  const ViewTeacherFeedbackScreen({super.key});

  @override
  _ViewTeacherFeedbackScreenState createState() =>
      _ViewTeacherFeedbackScreenState();
}

class _ViewTeacherFeedbackScreenState extends State<ViewTeacherFeedbackScreen> {
  List<dynamic> _feedbacks = [];
  List<dynamic> _filteredFeedbacks = [];
  String _searchQuery = '';
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('authToken');
    });
    if (_token != null) {
      await _fetchFeedbacks();
    } else {
      print('No token found. User might not be logged in.');
    }
  }

  Future<void> _fetchFeedbacks() async {
    try {
      final response = await http.get(
        Uri.parse(
            '${AppConfig.baseUrl}/api/feedbacks/admin'), // Assuming this endpoint returns teacher feedback
        headers: {
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> feedbacks = jsonDecode(response.body);
        setState(() {
          _feedbacks = feedbacks;
          _filteredFeedbacks = feedbacks; // Initial filtering set to all
        });
      } else {
        print('Failed to load feedbacks: ${response.reasonPhrase}');
        throw Exception('Failed to load feedbacks: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error in fetching feedbacks: $e');
      _showErrorDialog('Error fetching feedbacks: ${e.toString()}');
    }
  }

  void _filterFeedbacks(String query) {
    setState(() {
      _searchQuery = query;
      _filteredFeedbacks = _feedbacks.where((feedback) {
        String teacherName =
            feedback['teacherId']['name'] ?? 'Unknown'; // Changed to teacherId
        String subject = feedback['subject'] ?? 'No Subject';
        return teacherName.toLowerCase().contains(query.toLowerCase()) ||
            subject.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('View Teacher Feedbacks'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              onChanged: _filterFeedbacks,
              decoration: InputDecoration(
                hintText: 'Search by Teacher Name or Subject',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {},
                ),
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
              ),
            ),
            const SizedBox(height: 16.0),

            // Feedback List
            Expanded(
              child: _filteredFeedbacks.isEmpty
                  ? const Center(child: Text('No feedbacks to show'))
                  : ListView.builder(
                      itemCount: _filteredFeedbacks.length,
                      itemBuilder: (context, index) {
                        return TeacherFeedbackCard(
                          feedback: _filteredFeedbacks[index],
                          onViewDetails: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FeedbackDetailScreen(
                                    feedback: _filteredFeedbacks[index]),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom widget for each teacher feedback
class TeacherFeedbackCard extends StatelessWidget {
  final Map<String, dynamic> feedback;
  final VoidCallback onViewDetails;

  const TeacherFeedbackCard({
    super.key,
    required this.feedback,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    // Convert createdAt to a readable date format
    DateTime createdAt = DateTime.parse(feedback['createdAt']);
    String formattedDate =
        "${createdAt.day}/${createdAt.month}/${createdAt.year}";

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Teacher: ${feedback['teacherId']['name'] ?? 'Unknown'}', // Changed to teacherId
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Subject: ${feedback['subject']}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Feedback: ${feedback['feedback']}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Date Sent: $formattedDate',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8.0),
            TextButton(
              onPressed: onViewDetails,
              child: const Text('View Details'),
            ),
          ],
        ),
      ),
    );
  }
}

// Feedback detail screen
class FeedbackDetailScreen extends StatelessWidget {
  final Map<String, dynamic> feedback;

  const FeedbackDetailScreen({super.key, required this.feedback});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feedback Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Teacher Name: ${feedback['teacherId']['name'] ?? 'Unknown'}'), // Changed to teacherId
            Text('Subject: ${feedback['subject']}'),
            Text('Feedback: ${feedback['feedback']}'),
          ],
        ),
      ),
    );
  }
}
