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
            title: const Text('View My Attendance'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ViewMyAttendanceScreen(
                          classBatchId: '',
                        )),
              );
            },
          ),
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

class ViewMyAttendanceScreen extends StatefulWidget {
  final String classBatchId; // Pass classBatchId from login or state management

  const ViewMyAttendanceScreen({super.key, required this.classBatchId});

  @override
  _ViewMyAttendanceScreenState createState() => _ViewMyAttendanceScreenState();
}

class _ViewMyAttendanceScreenState extends State<ViewMyAttendanceScreen> {
  List<Map<String, dynamic>> attendanceData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAttendanceData();
  }

  Future<void> fetchAttendanceData() async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/attendance-data'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'classBatchId':
              widget.classBatchId, // Use the classBatchId passed to the widget
          'date': DateTime.now().toIso8601String(), // Adjust date as needed
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          attendanceData = data.map((item) {
            return {
              'subject': item[
                  'classBatchName'], // Adjust based on your response structure
              'date': item['date'], // Adjust based on your response structure
              'status': item['status'],
            };
          }).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load attendance data');
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Attendance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchAttendanceData,
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
                  // Attendance Summary
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'No Data Available Currently', // Hardcoded message
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red),
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Detailed Attendance Data
                  Expanded(
                    child: ListView.builder(
                      itemCount: attendanceData.length,
                      itemBuilder: (context, index) {
                        final attendance = attendanceData[index];
                        return ListTile(
                          title: Text(attendance['subject'] ?? 'No Subject'),
                          subtitle: Text('Date: ${attendance['date']}'),
                          trailing: Text(attendance['status'] ?? 'Unknown'),
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
    final response =
        await http.get(Uri.parse('${AppConfig.baseUrl}/api/documents'));

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
  String? studentId; // Store the student ID
  String selectedCategory = 'Course'; // Store the selected category
  String token = '';

  @override
  void initState() {
    super.initState();
    _loadToken();
    // Fetch the studentId from your user management or login state here
    // Example: studentId = Provider.of<UserProvider>(context, listen: false).studentId;
  }

  // Method to load token from SharedPreferences
  Future<void> _loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('authToken')!; // Ensure token is properly fetched
    });
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

            // Rating System
            const Text('Rate Your Experience:'),
            Row(
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1; // Update rating
                    });
                  },
                );
              }),
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
                String feedbackText = _feedbackController.text;
                print(feedbackText);
                print(token);
                // Check if feedback is not empty
                if (feedbackText != '') {
                  submitFeedback(feedbackText, _rating);
                } else {
                  // Show an error message if feedback is empty
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Error'),
                      content: const Text(
                          'Please enter your feedback before submitting.'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: const Text('Submit Feedback'),
            ),
          ],
        ),
      ),
    );
  }

  // Method to handle feedback submission
  void submitFeedback(String feedbackText, int rating) async {
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/api/feedbacks'),
      headers: {'Content-Type': 'application/json', 'authorization': token},
      body: json.encode({
        'subject': selectedCategory, // Use selected category here
        'feedback': feedbackText,
      }),
    );

    if (response.statusCode == 201) {
      // Show confirmation message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Feedback Submitted'),
          content: const Text('Thank you for your feedback!'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Optionally navigate back
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      // Show an error message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Failed to submit feedback. Please try again.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
