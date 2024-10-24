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
            title: const Text('Send Message To Admin'),
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
            title: const Text('Send Absent Message'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TodaysAbsenceMessageScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('View Messages for me'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => MessageReceivingScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('View Messages for me by teacher'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => MessageReceivingTeacherScreen()),
              );
            },
          ),// Add more ListTile items if needed
        ],
      ),
    );
  }
}

class SendMessageScreen extends StatefulWidget {
  const SendMessageScreen({super.key});

  @override
  _SendMessageScreenState createState() => _SendMessageScreenState();
}

class _SendMessageScreenState extends State<SendMessageScreen> {
  String? _selectedRecipientId;
  String? _token;
  List<dynamic> _recipients = [];
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  bool _isSubmitting = false; // Track submission state

  @override
  void initState() {
    super.initState();
    _fetchRecipients();
    _loadToken();
  }

  Future<void> _loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('authToken');
      print('Loaded Token: $_token');
    });
  }

  Future<void> _fetchRecipients() async {
    try {
      final response = await http.get(Uri.parse('${AppConfig.baseUrl}/api/auth/admins'));

      if (response.statusCode == 200) {
        setState(() {
          _recipients = json.decode(response.body);
        });
      } else {
        final errorMessage = json.decode(response.body)['error'] ?? 'Failed to fetch recipients';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching recipients. Please try again later.')),
      );
    }
  }

  Future<void> _sendMessage() async {
    if (_selectedRecipientId == null || _subjectController.text.isEmpty || _messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in all fields.')));
      return;
    }

    if (_isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/messageStudent/student/messages'), // Ensure this endpoint is correct
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode({
          'adminId': _selectedRecipientId, // Ensure this is correct
          'subject': _subjectController.text,
          'message': _messageController.text,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Message sent successfully!')));
        _subjectController.clear();
        _messageController.clear();
        setState(() {
          _selectedRecipientId = null;
        });
      } else {
        final errorMessage = json.decode(response.body)['error'] ?? 'Failed to send message';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (e) {
      print('Exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error sending message. Please try again later.')));
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Send Message to Admin'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recipient Dropdown (Admin/Teacher)
              DropdownButton<String>(
                value: _selectedRecipientId,
                hint: const Text('Select Admin/Teacher*'),
                isExpanded: true,
                items: _recipients.map((recipient) {
                  return DropdownMenuItem<String>(
                    value: recipient['_id'],
                    child: Text(recipient['name'] ?? 'Unnamed Recipient'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRecipientId = value;
                  });
                },
              ),

              const SizedBox(height: 16.0),

              // Subject
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'Subject*',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),

              // Message
              TextFormField(
                controller: _messageController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Message*',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32.0),

              // Send Button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _sendMessage, // Disable button during submission
                child: _isSubmitting
                    ? const CircularProgressIndicator() // Show loading indicator
                    : const Text('Send'),
              ),
            ],
          ),
        ),
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

class ReceivedMessage {
  final String senderName;
  final String title;
  final String message;
  final DateTime timestamp;

  ReceivedMessage({
    required this.senderName,
    required this.title,
    required this.message,
    required this.timestamp,
  });

  factory ReceivedMessage.fromJson(Map<String, dynamic> json) {
    String sender = 'Unknown'; // Default value

    // Check if teacherId is present
    if (json.containsKey('teacherId') && json['teacherId'] != null) {
      sender = json['teacherId']['name'] ?? 'Unknown';
    }
    // If teacherId is not there, fallback to adminId
    else if (json.containsKey('adminId') && json['adminId'] != null) {
      sender = 'Admin'; // Change this to actual admin name logic if available
    }

    return ReceivedMessage(
      senderName: sender,
      title: json['title'] ?? 'No Title',
      message: json['message'] ?? '',
      timestamp: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
    );
  }
}

class MessageCard extends StatelessWidget {
  final String senderName;
  final String title;
  final String message;
  final DateTime timestamp;

  const MessageCard({
    super.key,
    required this.senderName,
    required this.title,
    required this.message,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(senderName, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4.0),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), // Display title
            const SizedBox(height: 4.0),
            Text(message),
            const SizedBox(height: 4.0),
            Text('Received on: ${timestamp.toLocal().toString().split(' ')[0]}'),
          ],
        ),
      ),
    );
  }
}

class MessageReceivingScreen extends StatefulWidget {
  const MessageReceivingScreen({super.key});

  @override
  _MessageReceivingScreenState createState() => _MessageReceivingScreenState();
}

class _MessageReceivingScreenState extends State<MessageReceivingScreen> {
  List<ReceivedMessage> messages = [];
  bool isLoading = true;
  String errorMessage = '';
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
      fetchMessages();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No token found. Please log in again.')),
      );
    }
  }

  Future<void> fetchMessages() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(Uri.parse('${AppConfig.baseUrl}/api/messageStudent/student/received-messages'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success']) {
          List<dynamic> data = responseData['messages'];
          setState(() {
            messages = data.map((item) => ReceivedMessage.fromJson(item)).toList();
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = 'Failed to fetch messages';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = 'Network error: $error';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Received Messages')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
            ? Center(child: Text(errorMessage, style: const TextStyle(color: Colors.red)))
            : ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) {
            return MessageCard(
              senderName: messages[index].senderName,
              title: messages[index].title,
              message: messages[index].message,
              timestamp: messages[index].timestamp,
            );
          },
        ),
      ),
    );
  }
}

class MessageReceivingTeacherScreen extends StatefulWidget {
  const MessageReceivingTeacherScreen({super.key});

  @override
  _MessageReceivingTeacherScreenState createState() => _MessageReceivingTeacherScreenState();
}

class _MessageReceivingTeacherScreenState extends State<MessageReceivingTeacherScreen> {
  List<ReceivedMessage> messages = [];
  bool isLoading = true;
  String errorMessage = '';
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
      fetchMessages();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No token found. Please log in again.')),
      );
    }
  }

  Future<void> fetchMessages() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(Uri.parse('${AppConfig.baseUrl}/api/messageStudent/student/messages/teacher'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success']) {
          List<dynamic> data = responseData['messages'];
          setState(() {
            messages = data.map((item) => ReceivedMessage.fromJson(item)).toList();
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = 'Failed to fetch messages';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = 'Network error: $error';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Received Messages')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
            ? Center(child: Text(errorMessage, style: const TextStyle(color: Colors.red)))
            : ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) {
            return MessageCard(
              senderName: messages[index].senderName,
              title: messages[index].title,
              message: messages[index].message,
              timestamp: messages[index].timestamp,
            );
          },
        ),
      ),
    );
  }
}
