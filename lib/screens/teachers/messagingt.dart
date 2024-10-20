import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:testing_app/screens/config.dart';

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
      case 'student':
        return const SendStudentMessageScreen();
      case 'staff':
        return const SendStaffMessageScreen();
      case 'examReminder':
        return const SendExamReminderScreen();
      case 'absentAttendance':
        return const AbsentAttendanceMessageScreen();
      default:
        return const Center(child: Text('Unknown Option'));
    }
  }
}

// Below are the placeholder widgets for each message screen.
// Replace these with your actual implementation.

class SendStudentMessageScreen extends StatefulWidget {
  const SendStudentMessageScreen({super.key});

  @override
  _SendStudentMessageScreenState createState() =>
      _SendStudentMessageScreenState();
}

class _SendStudentMessageScreenState extends State<SendStudentMessageScreen> {
  String? _selectedStudentId;
  List<dynamic> _students = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    try {
      final response = await http
          .get(Uri.parse('${AppConfig.baseUrl}/api/registration/students'));

      if (response.statusCode == 200) {
        setState(() {
          _students = json.decode(response.body);
        });
      } else {
        // Handle error response
        final errorMessage =
            json.decode(response.body)['error'] ?? 'Failed to fetch students';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      // Handle network error or other exceptions
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error fetching students. Please try again later.')),
      );
    }
  }

  Future<void> _sendMessage() async {
    if (_selectedStudentId == null ||
        _titleController.text.isEmpty ||
        _messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/messageStudent/teacher/messages'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'studentId': _selectedStudentId,
          'title': _titleController.text,
          'message': _messageController.text,
        }),
      );

      if (response.statusCode == 200) {
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
        final errorMessage =
            json.decode(response.body)['error'] ?? 'Failed to send message';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      // Handle network error or other exceptions
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error sending message. Please try again later.')),
      );
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
                    child:
                        Text('${student['firstName']} ${student['lastName']}'),
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
                onPressed: _sendMessage,
                child: const Text('Send'),
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
    const url =
        '${AppConfig.baseUrl}/api/staff'; // Replace with actual endpoint

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
          'subject': titleController.text,
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
  List<String> absentees = [];
  List<String> filteredAbsentees = [];

  @override
  void initState() {
    super.initState();
    fetchAbsentees(); // Fetch absentees from the backend
  }

  // Function to fetch absentees from the API
  Future<void> fetchAbsentees() async {
    final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/absenceMessage/absences/today'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);

      // Extract the required data (assuming the response has a 'reason' field or any other you need)
      setState(() {
        absentees = data.map((item) => "${item['reason']}").toList();
        filteredAbsentees = absentees;
      });
    } else {
      print('Failed to fetch absentees');
    }
  }

  void _filterAbsentees(String query) {
    setState(() {
      filteredAbsentees = absentees
          .where(
              (student) => student.toLowerCase().contains(query.toLowerCase()))
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
                decoration: const InputDecoration(
                  hintText: 'Search',
                  suffixIcon: Icon(Icons.search),
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

              // List of Today's Absentees
              filteredAbsentees.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredAbsentees.length,
                      itemBuilder: (context, index) {
                        return AbsentStudentCard(
                          studentName: filteredAbsentees[index],
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

// Custom widget for each absent student
class AbsentStudentCard extends StatelessWidget {
  final String studentName;

  const AbsentStudentCard({super.key, required this.studentName});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(studentName),
      ),
    );
  }
}
