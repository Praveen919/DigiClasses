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
      case 'viewFeedback':
        return const ViewFeedbackScreen();
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
      final response = await http.get(Uri.parse('${AppConfig.baseUrl}/api/feedbacks'));
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