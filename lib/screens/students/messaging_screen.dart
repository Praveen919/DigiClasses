import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

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
                MaterialPageRoute(builder: (context) => RequestCredentialsScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('Send Inquiry Message'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SendInquiryMessageScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('Send Today Absent Attendance'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TodaysAbsenceMessageScreen()),
              );
            },
          ),
          // Add more ListTile items if needed
        ],
      ),
    );
  }
}



// Example of SendMessageToTeacher widget
class SendMessageScreen extends StatelessWidget {
  // Removed the controllers from class properties to reduce state
  // and keep it minimal

  @override
  Widget build(BuildContext context) {
    // Define controllers directly inside the build method
    final TextEditingController _subjectController = TextEditingController();
    final TextEditingController _messageController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Message to Teacher'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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

            // Message Body Field with reduced height
            TextField(
              controller: _messageController,
              maxLines: 5,  // Reduced maxLines to minimize height
              decoration: const InputDecoration(
                hintText: 'Type your message here...',
                border: OutlineInputBorder(),
                labelText: 'Message',
              ),
            ),
            const SizedBox(height: 16.0),

            // Optional Attachment Button
            ElevatedButton(
              onPressed: () async {
                // Handle file selection
                FilePickerResult? result = await FilePicker.platform.pickFiles();
                if (result != null) {
                  // Handle the selected file
                  // For example, show a confirmation message or attach the file
                }
              },
              child: const Text('Attach File'),
            ),
            const SizedBox(height: 16.0),

            // Send Button
            ElevatedButton(
              onPressed: () {
                String subject = _subjectController.text;
                String message = _messageController.text;

                // Validate inputs
                if (subject.isNotEmpty && message.isNotEmpty) {
                  // Process the message (e.g., send it to a server)
                  sendMessage(subject, message);

                  // Show confirmation message or navigate back
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Message Sent'),
                      content: const Text('Your message has been sent successfully!'),
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
                  // Show an error message if any field is empty
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Error'),
                      content: const Text('Please fill in both the subject and message fields before sending.'),
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

  // Example method to handle message submission
  void sendMessage(String subject, String message) {
    // Implement the message sending logic
    // For example, send the subject and message to a server
  }
}
// Example of RequestStudentIdPassword widget
class RequestCredentialsScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();

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
            Text(
              'If you have forgotten your student ID or password, please enter your email address below. '
                  'If you have a student ID, you can also enter it to expedite the process.',
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 16.0),

            // Email Field
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
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
              decoration: InputDecoration(
                hintText: 'Enter your student ID (optional)',
                border: OutlineInputBorder(),
                labelText: 'Student ID',
              ),
            ),
            const SizedBox(height: 16.0),

            // Request Button
            ElevatedButton(
              onPressed: () {
                String email = _emailController.text;
                String studentId = _studentIdController.text;

                // Validate email
                if (email.isNotEmpty) {
                  // Process the request
                  requestCredentials(email, studentId);

                  // Show confirmation message
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Request Submitted'),
                      content: const Text('Your request has been submitted. Please check your email for further instructions.'),
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
                  // Show error message
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

  // Example method to handle request submission
  void requestCredentials(String email, String studentId) {
    // Implement the logic to handle the credential request
    // For example, send the email and optional student ID to a server for processing
  }
}
class SendInquiryMessageScreen extends StatelessWidget {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

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
            // Instructions
            Text(
              'If you have any questions or need assistance, please enter the subject and your message below. '
                  'Our support team will get back to you as soon as possible.',
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 16.0),

            // Subject Field
            TextField(
              controller: _subjectController,
              decoration: InputDecoration(
                hintText: 'Enter subject of your inquiry',
                border: OutlineInputBorder(),
                labelText: 'Subject',
              ),
            ),
            const SizedBox(height: 16.0),

            // Message Body Field
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Enter your message',
                border: OutlineInputBorder(),
                labelText: 'Message',
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16.0),

            // Send Button
            ElevatedButton(
              onPressed: () {
                String subject = _subjectController.text;
                String message = _messageController.text;

                // Validate input
                if (subject.isNotEmpty && message.isNotEmpty) {
                  // Process the inquiry
                  sendInquiry(subject, message);

                  // Show confirmation message
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Inquiry Sent'),
                      content: const Text('Your inquiry has been sent successfully. We will get back to you shortly.'),
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
                  // Show error message
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Error'),
                      content: const Text('Please fill in both the subject and the message.'),
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

  // Example method to handle inquiry submission
  void sendInquiry(String subject, String message) {
    // Implement the logic to send the inquiry
    // For example, send the subject and message to a server or support system
  }
}

// Example of SendInquiryMessage widget
class TodaysAbsenceMessageScreen extends StatefulWidget {
  @override
  _TodaysAbsenceMessageScreenState createState() => _TodaysAbsenceMessageScreenState();
}

class _TodaysAbsenceMessageScreenState extends State<TodaysAbsenceMessageScreen> {
  final TextEditingController _reasonController = TextEditingController();
  String? _filePath;

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
            // Instructions
            Text(
              'If you are absent today, please provide the reason for your absence below. '
                  'You may also upload any supporting documents if needed.',
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 16.0),

            // Reason Field
            TextField(
              controller: _reasonController,
              decoration: InputDecoration(
                hintText: 'Enter reason for absence',
                border: OutlineInputBorder(),
                labelText: 'Reason',
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16.0),

            // Optional Upload Field
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
                Text(_filePath != null ? 'File: ${_filePath!.split('/').last}' : 'No file selected'),
              ],
            ),
            const SizedBox(height: 16.0),

            // Send Button
            ElevatedButton(
              onPressed: () {
                String reason = _reasonController.text;

                // Validate input
                if (reason.isNotEmpty) {
                  // Process the absence notification
                  sendAbsenceNotification(reason, _filePath);

                  // Show confirmation message
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Absence Notification Sent'),
                      content: const Text('Your absence notification has been sent successfully.'),
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
                  // Show error message
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Error'),
                      content: const Text('Please provide a reason for your absence.'),
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
              child: const Text('Send Notification'),
            ),
          ],
        ),
      ),
    );
  }

  // Example method to handle absence notification
  void sendAbsenceNotification(String reason, String? filePath) {
    // Implement the logic to send the absence notification
    // For example, send the reason and file path to a server or school system
  }
}