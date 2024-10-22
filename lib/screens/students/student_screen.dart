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
  String selectedCategory = 'Course';
  String? _token;
  bool _isSubmitting = false; // Track submission state

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('authToken');
      print('Loaded Token: $_token');
    });
  }

  Future<void> _sendFeedback() async {
    if (selectedCategory.isEmpty || _feedbackController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (_isSubmitting) {
      return; // Prevent multiple submissions
    }

    setState(() {
      _isSubmitting = true; // Disable button and show loading indicator
    });

    const String apiUrl = '${AppConfig.baseUrl}/api/feedbacks';

    try {
      final Map<String, dynamic> feedbackData = {
        'subject': selectedCategory,
        'feedback': _feedbackController.text,
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode(feedbackData),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Feedback submitted successfully')),
        );
        setState(() {
          selectedCategory = 'Course';
          _feedbackController.clear();
        });
      } else {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to submit feedback: ${responseBody['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isSubmitting = false; // Re-enable the button after submission
      });
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
              onPressed:
                  _isSubmitting ? null : _sendFeedback, // Disable if submitting
              child: _isSubmitting
                  ? const CircularProgressIndicator() // Show loading while submitting
                  : const Text('Submit Feedback'),
            ),
          ],
        ),
      ),
    );
  }
}
