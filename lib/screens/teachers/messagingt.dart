import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:testing_app/screens/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessagingT extends StatefulWidget {
  final String option;

  const MessagingT({super.key, required this.option});

  @override
  _MessagingScreenState createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingT> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messaging'),
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    switch (widget.option) {
      case 'admin':
        return const SendMessageToAdminScreen();
      case 'student':
        return const SendStudentMessageScreen();
      case 'staff':
        return const SendStaffMessageScreen();
      case 'examReminder':
        return const SendExamReminderScreen();
      case 'absentStudents':
        return const AbsentAttendanceMessageScreen();
      case 'receivedMessage':
        return const MessageReceivingScreen();
      default:
        return const Center(child: Text('Unknown Option'));
    }
  }
}

// Below are the placeholder widgets for each message screen.
// Replace these with your actual implementation.
class SendMessageToAdminScreen extends StatefulWidget {
  const SendMessageToAdminScreen({super.key});

  @override
  _SendMessageToAdminScreenState createState() => _SendMessageToAdminScreenState();
}

class _SendMessageToAdminScreenState extends State<SendMessageToAdminScreen> {
  String? _selectedAdminId;
  String? _token;
  List<dynamic> _admins = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  bool _isSubmitting = false; // Track submission state

  @override
  void initState() {
    super.initState();
    _fetchAdmins();
    _loadToken();
  }

  Future<void> _loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('authToken');
      print('Loaded Token: $_token');
    });
  }

  Future<void> _fetchAdmins() async {
    try {
      final response = await http.get(Uri.parse('${AppConfig.baseUrl}/api/auth/admins'));

      if (response.statusCode == 200) {
        setState(() {
          _admins = json.decode(response.body);
        });
      } else {
        final errorMessage = json.decode(response.body)['error'] ?? 'Failed to fetch admins';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching admins. Please try again later.')),
      );
    }
  }

  Future<void> _sendMessage() async {
    if (_selectedAdminId == null || _titleController.text.isEmpty || _messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
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
        Uri.parse('${AppConfig.baseUrl}/api/messageStudent/teacher/admin/messages'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode({
          'adminId': _selectedAdminId,
          'title': _titleController.text,
          'message': _messageController.text,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200|| response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message sent successfully!')),
        );
        _titleController.clear();
        _messageController.clear();
        setState(() {
          _selectedAdminId = null;
        });
      } else {
        final errorMessage = json.decode(response.body)['error'] ?? 'Failed to send message';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      print('Exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error sending message. Please try again later.')),
      );
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
              // Admin Dropdown
              DropdownButton<String>(
                value: _selectedAdminId,
                hint: const Text('Select Admin*'),
                isExpanded: true,
                items: _admins.map((admin) {
                  return DropdownMenuItem<String>(
                    value: admin['_id'],
                    child: Text(admin['name'] ?? 'Unnamed Admin'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedAdminId = value;
                  });
                },
              ),

              const SizedBox(height: 16.0),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title*',
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



class SendStudentMessageScreen extends StatefulWidget {
  const SendStudentMessageScreen({super.key});

  @override
  _SendStudentMessageScreenState createState() => _SendStudentMessageScreenState();
}

class _SendStudentMessageScreenState extends State<SendStudentMessageScreen> {
  String? _selectedStudentId;
  String? _token;
  List<dynamic> _students = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  bool _isSubmitting = false; // Track submission state

  @override
  void initState() {
    super.initState();
    _fetchStudents();
    _loadToken();
  }

  Future<void> _loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('authToken');
      print('Loaded Token: $_token');
    });
  }

  Future<void> _fetchStudents() async {
    try {
      final response = await http.get(Uri.parse('${AppConfig.baseUrl}/api/registration/students'));

      if (response.statusCode == 200) {
        setState(() {
          _students = json.decode(response.body);
        });
      } else {
        // Handle error response
        final errorMessage = json.decode(response.body)['error'] ?? 'Failed to fetch students';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      // Handle network error or other exceptions
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching students. Please try again later.')),
      );
    }
  }

  Future<void> _sendMessage() async {
    if (_selectedStudentId == null || _titleController.text.isEmpty || _messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    if (_isSubmitting) {
      return; // Prevent multiple submissions
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/messageStudent/teacher/messages'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token', // Include token in headers
        },
        body: json.encode({
          'studentId': _selectedStudentId,
          'title': _titleController.text,
          'message': _messageController.text,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Message sent successfully
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message sent successfully!')),
        );
        // Clear the fields
        _titleController.clear();
        _messageController.clear();
        setState(() {
          _selectedStudentId = null; // Reset selected student
        });
      } else {
        // Handle error response
        final errorMessage = json.decode(response.body)['error'] ?? 'Failed to send message';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (e) {
      // Handle network error or other exceptions
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error sending message. Please try again later.')),
      );
    } finally {
      setState(() {
        _isSubmitting = false; // Reset submission state
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Send Message to Students'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Student Dropdown
              DropdownButton<String>(
                value: _selectedStudentId,
                hint: const Text('Select Student*'),
                isExpanded: true,
                items: _students.map((student) {
                  return DropdownMenuItem<String>(
                    value: student['_id'],
                    child: Text('${student['firstName']} ${student['lastName']}'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStudentId = value;
                  });
                },
              ),
              const SizedBox(height: 16.0),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title*',
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

class SendStaffMessageScreen extends StatefulWidget {
  const SendStaffMessageScreen({super.key});

  @override
  _SendStaffMessageScreenState createState() => _SendStaffMessageScreenState();
}

class _SendStaffMessageScreenState extends State<SendStaffMessageScreen> {
  String? selectedStaffId;
  List<Map<String, String>> staffList = []; // List to hold staff members
  final TextEditingController titleController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchStaffMembers();
  }

  Future<void> fetchStaffMembers() async {
    const url = '${AppConfig.baseUrl}/api/staff'; // Replace with actual endpoint

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          staffList = data.map<Map<String, String>>((staff) {
            return {
              'id': staff['_id'], // Ensure correct ID from response
              'name':
                  '${staff['firstName'] ?? ''} ${staff['middleName'] ?? ''} ${staff['lastName'] ?? ''}'
                      .trim(), // Concatenating first, middle, and last names
            };
          }).toList();
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load staff members: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred: $e';
      });
    }
  }

  Future<void> sendMessage() async {
    if (selectedStaffId == null ||
        titleController.text.isEmpty ||
        messageController.text.isEmpty) {
      setState(() {
        errorMessage = 'Please fill all fields.';
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(
            '${AppConfig.baseUrl}/api/messageStudent/teacher/staff/messages'), // Replace with your API endpoint
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'teacherId': selectedStaffId,
          'title': titleController.text,
          'message': messageController.text,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          errorMessage = null; // Clear any previous error message
          titleController.clear();
          messageController.clear();
          selectedStaffId = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Message sent successfully')));
      } else {
        setState(() {
          errorMessage =
              'Failed to send message: ${json.decode(response.body)['error']}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Send Message to Staff'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Staff Dropdown
            DropdownButtonFormField<String>(
              value: selectedStaffId,
              onChanged: (String? newValue) {
                setState(() {
                  selectedStaffId = newValue;
                });
              },
              items: staffList
                  .map<DropdownMenuItem<String>>((Map<String, String> staff) {
                return DropdownMenuItem<String>(
                  value: staff['id'], // Use the ID for selection
                  child: Text(
                      staff['name'] ?? 'Unknown'), // Display the staff name
                );
              }).toList(),
              decoration: const InputDecoration(
                labelText: 'Select Staff*',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),

            // Title
            TextFormField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title*',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),

            // Message
            TextFormField(
              controller: messageController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Message*',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),

            // Error Message
            if (errorMessage != null)
              Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 16.0),

            // Send Button
            ElevatedButton(
              onPressed: () {
                sendMessage();
              },
              child: const Text('Send'),
            ),
          ],
        ),
      ),
    );
  }
}

class Student {
  final String id;
  final String name;
  final String password;

  Student({required this.id, required this.name, required this.password});

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      name: json['name'],
      password: json['password'], // Assuming password is available
    );
  }
}

class SendExamReminderScreen extends StatefulWidget {
  const SendExamReminderScreen({super.key});

  @override
  _SendExamReminderScreenState createState() => _SendExamReminderScreenState();
}

class _SendExamReminderScreenState extends State<SendExamReminderScreen> {
  String selectedStandard = 'All';
  String selectedSubject = 'All';
  String selectedExamName = 'English Exam'; // Set a valid initial value

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Send Upcoming Exam Message to Student'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Standard Dropdown
              DropdownButtonFormField<String>(
                value: selectedStandard,
                items: <String>['All', '1st Std', '2nd Std', '3rd Std']
                    .map((String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ))
                    .toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedStandard = newValue!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Standard',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),

              // Subject Dropdown
              DropdownButtonFormField<String>(
                value: selectedSubject,
                items: <String>[
                  'All',
                  'English',
                  'Maths',
                  'Science',
                  'Social Science',
                  'Hindi',
                  'Marathi'
                ]
                    .map((String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ))
                    .toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedSubject = newValue!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),

              // Exam Name Dropdown
              DropdownButtonFormField<String>(
                value: selectedExamName,
                items: <String>[
                  'English Exam',
                  'Maths Exam',
                  'Science Exam',
                  'Social Science Exam',
                  'Hindi Exam',
                  'Marathi Exam'
                ]
                    .map((String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ))
                    .toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedExamName = newValue!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Exam Name*',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32.0),

              // Send Button
              ElevatedButton(
                onPressed: () async {
                  // Implement sending logic here
                  await sendExamNotification();
                },
                child: const Text('Send'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> sendExamNotification() async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/messageStudent/exam/notifications'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'standard': selectedStandard,
          'subject': selectedSubject,
          'examName': selectedExamName,
        }),
      );

      if (response.statusCode == 200) {
        // Show success message or handle success response
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification sent successfully!')),
        );
      } else {
        // Show error message or handle error response
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send notification.')),
        );
      }
    } catch (e) {
      // Handle exceptions
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}

class AbsentAttendanceMessageScreen extends StatefulWidget {
  const AbsentAttendanceMessageScreen({super.key});

  @override
  _AbsentAttendanceMessageScreenState createState() =>
      _AbsentAttendanceMessageScreenState();
}

class _AbsentAttendanceMessageScreenState
    extends State<AbsentAttendanceMessageScreen> {
  List<AbsentMessage> absentees = [];
  List<AbsentMessage> filteredAbsentees = [];
  bool isLoading = true; // Track loading state
  String errorMessage = ''; // Track error message

  @override
  void initState() {
    super.initState();
    fetchAbsentees(); // Fetch absentees from the backend
  }

  // Function to fetch absentees from the API
  Future<void> fetchAbsentees() async {
    setState(() {
      isLoading = true; // Set loading state to true
      errorMessage = ''; // Reset error message
    });

    try {
      final response = await http.get(
          Uri.parse('${AppConfig.baseUrl}/api/absenceMessage/absences/today'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        setState(() {
          if (data.isEmpty) {
            errorMessage = 'No absentees found';
          } else {
            absentees =
                data.map((item) => AbsentMessage.fromJson(item)).toList();
            filteredAbsentees = absentees;
          }
          isLoading = false; // Set loading state to false
        });
      } else {
        setState(() {
          errorMessage = 'Failed to fetch absentees: ${response.body}';
          isLoading = false; // Set loading state to false
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = 'Network error: $error';
        isLoading = false; // Set loading state to false
      });
    }
  }

  void _filterAbsentees(String query) {
    setState(() {
      filteredAbsentees = absentees
          .where((absent) =>
      absent.reason.toLowerCase().contains(query.toLowerCase()) ||
          absent.studentName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Send Today Absent Attendance Message'),
      ),
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  suffixIcon: const Icon(Icons.search),
                ),
                onChanged: (query) {
                  _filterAbsentees(query);
                },
              ),
              const SizedBox(height: 16.0),

              // Today's Absentees Header
              const Text('Today\'s Absentees',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16.0),

              // Loading Indicator or Error Message
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else if (errorMessage.isNotEmpty)
                Center(
                    child:
                    Text(errorMessage, style: const TextStyle(color: Colors.red)))
              else
                filteredAbsentees.isEmpty
                    ? const Center(child: Text('No absentees found'))
                    : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredAbsentees.length,
                  itemBuilder: (context, index) {
                    return AbsentStudentCard(
                      studentName: filteredAbsentees[index].studentName,
                      reason: filteredAbsentees[index].reason,
                      date: filteredAbsentees[index].createdAt,
                      document: filteredAbsentees[index].document, // Include document
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Model class for absent messages
class AbsentMessage {
  final String studentName;
  final String reason;
  final DateTime createdAt;
  final String? document; // Change to nullable String

  AbsentMessage({
    required this.studentName,
    required this.reason,
    required this.createdAt,
    this.document, // Optional parameter
  });

  factory AbsentMessage.fromJson(Map<String, dynamic> json) {
    return AbsentMessage(
      studentName: json['studentName'] ?? 'Unknown', // Default to 'Unknown' if null
      reason: json['reason'] ?? 'No reason provided', // Default to a message if null
      createdAt: DateTime.parse(json['createdAt']),
      document: json['document'], // Keep it nullable
    );
  }
}

// Custom widget for each absent student
class AbsentStudentCard extends StatelessWidget {
  final String studentName;
  final String reason;
  final DateTime date;
  final String? document; // Add document field

  const AbsentStudentCard({
    super.key,
    required this.studentName,
    required this.reason,
    required this.date,
    this.document, // Add document as optional
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(studentName,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4.0),
            Text(reason),
            const SizedBox(height: 4.0),
            Text(
              'Date: ${date.toLocal().toString().split(' ')[0]}', // Display the date
            ),
            if (document != null && document!.isNotEmpty) // Show document if it exists
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  'Document: $document',
                  style: const TextStyle(color: Colors.blue),
                ),
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
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/messageStudent/staff/messages'),
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
