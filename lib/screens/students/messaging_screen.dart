import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:testing_app/screens/config.dart';

class MessagingScreen extends StatelessWidget {
  const MessagingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('message'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Send Message To Teacher'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SendMessageScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('Request Student Id Password'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => RequestCredentialsScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('Send Inquiry Message'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SendInquiryMessageScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('Send Today Absent Attendance'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TodaysAbsenceMessageScreen()),
              );
            },
          ),
          // Add more ListTile items if needed
        ],
      ),
    );
  }
}

class SendMessageScreen extends StatelessWidget {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _recipientController =
      TextEditingController(); // To enter recipient ID

  // URL for your API (using AppConfig for the base URL)
  final String apiUrl =
      '${AppConfig.baseUrl}/api/messageStudent/student/messages';

  SendMessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Message to Teacher/Admin'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipient ID Field
            TextField(
              controller: _recipientController,
              decoration: const InputDecoration(
                hintText: 'Enter recipient (Teacher/Admin) ID here...',
                border: OutlineInputBorder(),
                labelText: 'Recipient ID',
              ),
            ),
            const SizedBox(height: 16.0),

            // Subject Field
            TextField(
              controller: _subjectController,
              decoration: const InputDecoration(
                hintText: 'Enter subject here...',
                border: OutlineInputBorder(),
                labelText: 'Subject',
              ),
            ),
            const SizedBox(height: 16.0),

            // Message Field
            TextField(
              controller: _messageController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Type your message here...',
                border: OutlineInputBorder(),
                labelText: 'Message',
              ),
            ),
            const SizedBox(height: 16.0),

            // Send Button
            ElevatedButton(
              onPressed: () {
                String subject = _subjectController.text;
                String message = _messageController.text;
                String recipientId = _recipientController.text;

                // Validate inputs
                if (subject.isNotEmpty &&
                    message.isNotEmpty &&
                    recipientId.isNotEmpty) {
                  // Call sendMessage() to send the data to the server
                  sendMessage(subject, message, recipientId).then((response) {
                    if (response['success'] == true) {
                      // Show confirmation dialog
                      _showDialog(context, 'Message Sent',
                          'Your message has been sent successfully!');
                    } else {
                      // Show error dialog
                      _showDialog(context, 'Error',
                          'Failed to send the message. Try again later.');
                    }
                  });
                } else {
                  // Show validation error dialog
                  _showDialog(context, 'Error', 'All fields are required.');
                }
              },
              child: const Text('Send Message'),
            ),
          ],
        ),
      ),
    );
  }

  // Function to send the message to the server
  Future<Map<String, dynamic>> sendMessage(
      String subject, String message, String recipientId) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'senderStudentId':
              'studentId', // Replace with actual student ID logic
          'recipientId': recipientId,
          'subject': subject,
          'message': message,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'success': false};
      }
    } catch (e) {
      print(e);
      return {'success': false};
    }
  }

  // Helper function to show a dialog
  void _showDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Optionally, navigate back if needed
              // Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class RequestCredentialsScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  // URL for your API (change it to your server address)
  final String apiUrl =
      '${AppConfig.baseUrl}/api/messageStudentIdPass/student/messages';

  RequestCredentialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Student ID/Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Instructions
            const Text(
              'If you have forgotten your student ID or password, please enter your email address below. '
              'If you have a student ID, you can also enter it to expedite the process. '
              'You can also add a message to notify the admin or teacher.',
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 16.0),

            // Email Field
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                hintText: 'Enter your email address',
                border: OutlineInputBorder(),
                labelText: 'Email Address',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16.0),

            // Student ID Field (Optional)
            TextField(
              controller: _studentIdController,
              decoration: const InputDecoration(
                hintText: 'Enter your student ID (optional)',
                border: OutlineInputBorder(),
                labelText: 'Student ID',
              ),
            ),
            const SizedBox(height: 16.0),

            // Message Field
            TextField(
              controller: _messageController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Type your message here...',
                border: OutlineInputBorder(),
                labelText: 'Message',
              ),
            ),
            const SizedBox(height: 16.0),

            // Request Button
            ElevatedButton(
              onPressed: () {
                String email = _emailController.text;
                String studentId = _studentIdController.text;
                String message = _messageController.text;

                // Validate email
                if (email.isNotEmpty) {
                  // Process the request
                  requestCredentials(email, studentId, message)
                      .then((response) {
                    if (response['success']) {
                      // Show confirmation message
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Request Submitted'),
                          content: const Text(
                              'Your request has been submitted. Please check your email for further instructions.'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.of(context)
                                    .pop(); // Optionally navigate back
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    } else {
                      // Show error message
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Error'),
                          content: const Text(
                              'Failed to submit your request. Please try again later.'),
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
                  });
                } else {
                  // Show validation error
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Error'),
                      content: const Text('Please enter your email address.'),
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
              child: const Text('Request Credentials'),
            ),
          ],
        ),
      ),
    );
  }

  // Function to send the request to the server
  Future<Map<String, dynamic>> requestCredentials(
      String email, String studentId, String message) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'studentId': studentId,
          'message': message,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'success': false};
      }
    } catch (e) {
      print(e);
      return {'success': false};
    }
  }
}

class SendInquiryMessageScreen extends StatelessWidget {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  SendInquiryMessageScreen({super.key});

  Future<void> sendInquiry(String subject, String message) async {
    const url =
        '${AppConfig.baseUrl}/api/inquiriesStudent/inquiries'; // Replace with your backend URL

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'subject': subject,
          'message': message,
        }),
      );

      if (response.statusCode == 201) {
        print('Inquiry sent successfully.');
      } else {
        print('Failed to send inquiry.');
      }
    } catch (error) {
      print('Error occurred while sending inquiry: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Inquiry Message'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'If you have any questions or need assistance, please enter the subject and your message below. '
              'Our support team will get back to you as soon as possible.',
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _subjectController,
              decoration: const InputDecoration(
                hintText: 'Enter subject of your inquiry',
                border: OutlineInputBorder(),
                labelText: 'Subject',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Enter your message',
                border: OutlineInputBorder(),
                labelText: 'Message',
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                String subject = _subjectController.text;
                String message = _messageController.text;

                if (subject.isNotEmpty && message.isNotEmpty) {
                  sendInquiry(subject, message);

                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Inquiry Sent'),
                      content: const Text(
                          'Your inquiry has been sent successfully. We will get back to you shortly.'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context)
                                .pop(); // Optionally navigate back
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Error'),
                      content: const Text(
                          'Please fill in both the subject and the message.'),
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
              child: const Text('Send Message'),
            ),
          ],
        ),
      ),
    );
  }
}

class TodaysAbsenceMessageScreen extends StatefulWidget {
  const TodaysAbsenceMessageScreen({super.key});

  @override
  _TodaysAbsenceMessageScreenState createState() =>
      _TodaysAbsenceMessageScreenState();
}

class _TodaysAbsenceMessageScreenState
    extends State<TodaysAbsenceMessageScreen> {
  final TextEditingController _reasonController = TextEditingController();
  String? _filePath;
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
    });
  }

  Future<void> sendAbsenceNotification(String reason, String? filePath) async {
    if (reason.isEmpty) {
      _showErrorDialog('Please provide a reason for your absence.');
      return;
    }

    if (_isSubmitting) {
      return; // Prevent multiple submissions
    }

    setState(() {
      _isSubmitting = true; // Disable button and show loading indicator
    });

    var request = http.MultipartRequest(
      'POST',
      Uri.parse(
          '${AppConfig.baseUrl}/api/absenceMessage/absence'), // Update with your actual endpoint
    );

    request.headers['Authorization'] = 'Bearer $_token';
    request.fields['reason'] = reason;

    if (filePath != null) {
      request.files
          .add(await http.MultipartFile.fromPath('document', filePath));
    }

    try {
      var response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        _showSuccessDialog(
            'Your absence notification has been sent successfully.');
        _reasonController.clear(); // Clear the text field after submission
        setState(() {
          _filePath = null; // Reset the file path
        });
      } else {
        if (response.statusCode == 401) {
          _showErrorDialog('Invalid token. Please log in again.');
        } else {
          _showErrorDialog(
              'Failed to send absence notification: ${response.statusCode}');
        }
        print(
            'Response body: $responseBody'); // Log the response body for debugging
      }
    } catch (e) {
      _showErrorDialog('Error: $e');
    } finally {
      setState(() {
        _isSubmitting = false; // Re-enable the button after submission
      });
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: Text(message),
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
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Absence Notification'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'If you are absent today, please provide the reason for your absence below. '
              'You may also upload any supporting documents if needed.',
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                hintText: 'Enter reason for absence',
                border: OutlineInputBorder(),
                labelText: 'Reason',
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final result = await FilePicker.platform.pickFiles();
                    if (result != null) {
                      setState(() {
                        _filePath = result.files.single.path;
                      });
                    }
                  },
                  child: const Text('Upload Supporting Document'),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Text(
                    _filePath != null
                        ? 'File: ${_filePath!.split('/').last}'
                        : 'No file selected',
                    overflow: TextOverflow.ellipsis, // Prevent overflow
                    maxLines: 1, // Limit to one line
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _isSubmitting
                  ? null
                  : () {
                      String reason = _reasonController.text;
                      sendAbsenceNotification(reason, _filePath);
                    },
              child: _isSubmitting
                  ? const CircularProgressIndicator() // Show loading while submitting
                  : const Text('Send Notification'),
            ),
          ],
        ),
      ),
    );
  }
}
