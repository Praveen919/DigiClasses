import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
        return const ViewFeedbackScreen();
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


class ViewFeedbackScreen extends StatefulWidget {
  const ViewFeedbackScreen({super.key});

  @override
  _ViewFeedbackScreenState createState() => _ViewFeedbackScreenState();
}

class _ViewFeedbackScreenState extends State<ViewFeedbackScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _feedbacks = [];
  List<dynamic> _filteredFeedbacks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFeedbacks(); // Fetch feedbacks from the backend on screen load
  }

  Future<void> _fetchFeedbacks() async {
    try {
      final response = await http.get(Uri.parse('${AppConfig.baseUrl}/api/feedbacks/admin/feedbacks'));
      if (response.statusCode == 200) {
        setState(() {
          _feedbacks = jsonDecode(response.body);
          _filteredFeedbacks = _feedbacks;
          _isLoading = false;
        });
      } else {
        print('Failed to load feedbacks. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching feedbacks: $error');
    }
  }

  void _searchFeedbacks(String query) {
    setState(() {
      _filteredFeedbacks = _feedbacks
          .where((feedback) =>
      feedback['comment'].toString().toLowerCase().contains(query.toLowerCase()) ||
          feedback['subject'].toString().toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Feedbacks'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator()) // Show loading spinner while fetching data
                  : _buildFeedbackList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        labelText: 'Search Feedbacks',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            setState(() {
              _searchController.clear();
              _filteredFeedbacks = _feedbacks;
            });
          },
        )
            : null,
      ),
      onChanged: _searchFeedbacks,
    );
  }

  Widget _buildFeedbackList() {
    return ListView.builder(
      itemCount: _filteredFeedbacks.length,
      itemBuilder: (context, index) {
        final feedback = _filteredFeedbacks[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            title: Text(feedback['subject'] ?? 'No Subject'),
            subtitle: Text(feedback['comment'] ?? 'No Comment'),
            trailing: Text(feedback['date'] ?? 'Unknown Date'),
          ),
        );
      },
    );
  }
}
