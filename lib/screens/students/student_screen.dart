import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testing_app/screens/config.dart';

class StudentScreen extends StatelessWidget {
  const StudentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('View Share Documents'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ViewSharedDocumentsScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('Give Feedback'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const GiveFeedbackScreen()),
              );
            },
          ),
          // Add more ListTile items if needed
        ],
      ),
    );
  }
}

class ViewSharedDocumentsScreen extends StatefulWidget {
  const ViewSharedDocumentsScreen({super.key});

  @override
  _ViewSharedDocumentsScreenState createState() =>
      _ViewSharedDocumentsScreenState();
}

class _ViewSharedDocumentsScreenState extends State<ViewSharedDocumentsScreen> {
  List<Map<String, dynamic>> sharedDocuments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSharedDocuments();
  }

  Future<void> fetchSharedDocuments() async {
    final response = await http
        .get(Uri.parse('${AppConfig.baseUrl}/api/documents/documents'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        sharedDocuments = data.map((item) {
          return {
            'id': item['_id'],
            'title': item['documentName'],
            'type':
                item['documentPath'].split('.').last, // Extracting file type
            'url': item['documentPath'],
            'message': item['message'],
            'dateAdded': item['uploadedAt'],
          };
        }).toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared Documents'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchSharedDocuments,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Document List
                  Expanded(
                    child: ListView.builder(
                      itemCount: sharedDocuments.length,
                      itemBuilder: (context, index) {
                        final document = sharedDocuments[index];
                        return ListTile(
                          title: Text(document['title'] ?? 'No Title'),
                          subtitle:
                              Text('Type: ${document['type'] ?? 'Unknown'}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.download),
                            onPressed: () {
                              // Handle document download or view action
                              // Use document['url'] for the download link
                            },
                          ),
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

class GiveFeedbackScreen extends StatefulWidget {
  const GiveFeedbackScreen({super.key});

  @override
  _GiveFeedbackScreenState createState() => _GiveFeedbackScreenState();
}

class _GiveFeedbackScreenState extends State<GiveFeedbackScreen> {
  final TextEditingController _feedbackController = TextEditingController();
  int _rating = 0; // Track the rating
  String selectedCategory = 'Course'; // Store the selected category
  String? _token; // To hold the authentication token

  @override
  void initState() {
    super.initState();
    _loadToken(); // Load the token during initialization
  }

  Future<void> _loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('authToken'); // Load the token
      print('Loaded Token: $_token'); // Debugging: log the loaded token
    });
  }

  Future<void> _sendFeedback() async {
    if (selectedCategory.isEmpty || _feedbackController.text.isEmpty) {
      // Show an error message if fields are empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    const String apiUrl =
        '${AppConfig.baseUrl}/api/feedbacks'; // Feedback API endpoint

    try {
      // Build the feedback payload
      final Map<String, dynamic> feedbackData = {
        'subject': selectedCategory,
        'feedback': _feedbackController.text,
      };

      print(
          'Sending Feedback Data: $feedbackData'); // Debugging: log feedback data
      print('Using Token: $_token'); // Debugging: log token being used

      // Make POST request to send feedback
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token', // Add the token to the headers
        },
        body: jsonEncode(feedbackData),
      );

      // Debugging: log the response status code and body
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 201) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Feedback submitted successfully')),
        );
        // Optionally clear form fields
        setState(() {
          _rating = 0;
          selectedCategory = 'Course';
          _feedbackController.clear();
        });
      } else {
        // Show error message if submission failed
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit feedback')),
        );
      }
    } catch (e) {
      // Show error message on exception
      print('Error occurred: $e'); // Debugging: log the error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Give Feedback'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Feedback Text Field
            TextField(
              controller: _feedbackController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Enter your feedback here...',
                border: OutlineInputBorder(),
                labelText: 'Feedback',
              ),
            ),
            const SizedBox(height: 16.0),

            // Feedback Category
            const Text('Feedback Category:'),
            DropdownButton<String>(
              value: selectedCategory,
              onChanged: (String? newValue) {
                setState(() {
                  selectedCategory = newValue!;
                });
              },
              items: <String>['Course', 'Instructor', 'App', 'Other']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 16.0),

            // Submit Button
            ElevatedButton(
              onPressed: () {
                _sendFeedback(); // Use the new logic to send feedback
              },
              child: const Text('Submit Feedback'),
            ),
          ],
        ),
      ),
    );
  }
}
