import 'package:flutter/material.dart';
import 'package:testing_app/screens/config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MessagingScreen extends StatefulWidget {
  final String option;

  const MessagingScreen({super.key, required this.option});

  @override
  _MessagingScreenState createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
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
      case 'receivedMessage':
        return const MessageReceivingScreen();
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
  bool isLoading = true;
  String? _token; // Store the JWT token

  @override
  void initState() {
    super.initState();
    _loadToken(); // Load the JWT token on screen initialization
  }

  // Method to load token from SharedPreferences
  Future<void> _loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('authToken'); // Ensure token is properly fetched
    });
    if (_token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No token found. Please log in again.')),
      );
    } else {
      _fetchStudents(); // Fetch students after token is loaded
    }
  }

  // Method to fetch students with the token
  Future<void> _fetchStudents() async {
    if (_token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No token found. Please log in again.')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/auth/students'),
        headers: {
          'Authorization': 'Bearer $_token', // Use the fetched token
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _students = json.decode(response.body);
          isLoading = false;
        });
      } else {
        final errorMessage =
            json.decode(response.body)['error'] ?? 'Failed to fetch students';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error fetching students. Please try again later.'),
        ),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  // Method to send a message to a student
  Future<void> _sendMessage() async {
    if (_selectedStudentId == null ||
        _titleController.text.isEmpty ||
        _messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    if (_token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No token found. Please log in again.')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/messageStudent/admin/messages'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token', // Use the fetched token
        },
        body: json.encode({
          'studentId': _selectedStudentId,
          'subject': _titleController.text,
          'message': _messageController.text,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message sent successfully!')),
        );
        _titleController.clear();
        _messageController.clear();
        setState(() {
          _selectedStudentId = null;
        });
      } else {
        final errorMessage =
            json.decode(response.body)['error'] ?? 'Failed to send message';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedStudentId,
                      hint: const Text('Select Student*'),
                      isExpanded: true,
                      items: _students.map((student) {
                        return DropdownMenuItem<String>(
                          value: student['_id'],
                          child: Text(student['name'] ?? 'No name'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedStudentId = value;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Select Student',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title*',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _messageController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Message*',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 32.0),
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
  List<Map<String, dynamic>> staffList = [];
  String? _selectedStaff;
  String? _subject;
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  String? _token; // Variable to hold the token

  @override
  void initState() {
    super.initState();
    _loadToken(); // Load token on initialization
  }

  Future<void> _loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('authToken');
    });
    if (_token != null) {
      _fetchStaff(); // Fetch staff if token exists
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No token found. Please log in again.')),
      );
    }
  }

  Future<void> _fetchStaff() async {
    const url =
        '${AppConfig.baseUrl}/api/staff'; // Replace with actual endpoint

    try {
      final response = await http.get(Uri.parse(url), headers: {
        'Authorization': 'Bearer $_token', // Add token to headers
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          staffList = data
              .map((staff) => {
                    'id': staff['_id'],
                    'firstName': staff['firstName'] ?? '',
                    'middleName': staff['middleName'] ?? '',
                    'lastName': staff['lastName'] ?? '',
                  })
              .toList();
        });
      } else {
        print('Failed to load staff: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching staff list: $e');
    }
  }

  Future<void> _sendMessage() async {
    if (_selectedStaff != null &&
        _messageController.text.isNotEmpty &&
        _subjectController.text.isNotEmpty) {
      final selectedStaffId = _selectedStaff;
      final message = _messageController.text;
      final subject = _subjectController.text;

      const url =
          '${AppConfig.baseUrl}/api/messageStudent/admin/staff'; // Correct API URL

      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $_token', // Add token to headers
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'staffId': selectedStaffId,
            'subject': subject,
            'message': message,
          }),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Message sent to ${staffList.firstWhere((staff) => staff['id'] == _selectedStaff)['firstName']}'),
          ));

          // Clear the message input and reset the dropdown
          setState(() {
            _messageController.clear();
            _subjectController.clear();
            _selectedStaff = null;
          });
        } else {
          print('Failed to send message: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
      } catch (e) {
        print('Error sending message: $e');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Please select a staff member, write a message, and add a subject'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Send Message to Staff'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Staff Member',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Staff Name*',
                border: OutlineInputBorder(),
              ),
              isDense: true, // Makes the dropdown smaller
              isExpanded: false, // Prevents the dropdown from taking full width
              value: _selectedStaff,
              items: staffList.map((staff) {
                return DropdownMenuItem<String>(
                  value: staff['id'],
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.person),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '${staff['firstName']} ${staff['middleName']} ${staff['lastName']}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStaff = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a staff member';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Subject:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _subjectController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter the subject here...',
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Message:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _messageController,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter your message here...',
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _sendMessage,
                child: const Text('Send Message'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SendStaffIdPasswordScreen extends StatefulWidget {
  const SendStaffIdPasswordScreen({super.key});

  @override
  _SendStaffIdPasswordScreenState createState() =>
      _SendStaffIdPasswordScreenState();
}

class _SendStaffIdPasswordScreenState extends State<SendStaffIdPasswordScreen> {
  List<Staff> _staff = [];
  List<Staff> _filteredStaff = [];
  String _searchText = '';
  String? _selectedValue; // State variable to track the selected dropdown value

  @override
  void initState() {
    super.initState();
    _fetchStaff();
  }

  Future<void> _fetchStaff() async {
    try {
      final response = await http
          .get(Uri.parse('${AppConfig.baseUrl}/api/auth/users?role=Teacher'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _staff = data.map((staff) => Staff.fromJson(staff)).toList();
          _filteredStaff = _staff;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch staff')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error fetching staff. Please try again later.')),
      );
    }
  }

  void _filterStaff(String searchText) {
    setState(() {
      _filteredStaff = _staff.where((staff) {
        return staff.name.toLowerCase().contains(searchText.toLowerCase());
      }).toList();
    });
  }

  Future<void> _sendMessage(String staffId, String staffPassword) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/messageStudent'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'staffId': staffId,
          'subject': 'Your Login Details',
          'message': 'Your User ID: $staffId, Password: $staffPassword',
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message sent successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send message.')),
        );
      }
    } catch (e) {
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
        title: const Text('Send ID/Password to Staff'),
      ),
      resizeToAvoidBottomInset: true, // Allows resizing to avoid keyboard
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sample Message Format
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Your login details for SRS Classes is: User ID: SCSTD4659 Password: 8X4X564, download app from http://bit.ly/2Cpwr55 Service by, Viha IT Services',
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              // Send Message with Mobile App Link Dropdown (for future use)
              DropdownButtonFormField<String>(
                value: _selectedValue ?? '-- Select --',
                items:
                    <String>['-- Select --', 'Option 1', 'Option 2', 'Option 3']
                        .map((String value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            ))
                        .toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedValue = newValue;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Send Message with Mobile App Link',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),

              // Search Bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search Staff',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      _filterStaff(_searchText);
                    },
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchText = value;
                  });
                  _filterStaff(value);
                },
              ),
              const SizedBox(height: 16.0),

              // Staff ID/Password Details
              const Text('Staff ID/Password Details',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16.0),

              // List of staff details
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredStaff.length,
                itemBuilder: (context, index) {
                  final staff = _filteredStaff[index];
                  return StaffDetailsCard(
                    staff: staff,
                    onSendMessage: _sendMessage,
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

class Staff {
  final String id;
  final String name;
  final String password;

  Staff({required this.id, required this.name, required this.password});

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      id: json['id'],
      name: json['name'],
      password:
          json['password'], // Assuming password is available in the response
    );
  }
}

class StaffDetailsCard extends StatelessWidget {
  final Staff staff;
  final Function(String, String) onSendMessage;

  const StaffDetailsCard(
      {super.key, required this.staff, required this.onSendMessage});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Staff Name: ${staff.name}'),
            Text('User ID: ${staff.id}'),
            Text('Password: ${staff.password}'),

            // Send Message button
            ElevatedButton(
              onPressed: () {
                onSendMessage(staff.id, staff.password);
              },
              child: const Text('Send Message'),
            ),
          ],
        ),
      ),
    );
  }
}

class SendStudentIdPasswordScreen extends StatefulWidget {
  const SendStudentIdPasswordScreen({super.key});

  @override
  _SendStudentIdPasswordScreenState createState() =>
      _SendStudentIdPasswordScreenState();
}

class _SendStudentIdPasswordScreenState
    extends State<SendStudentIdPasswordScreen> {
  List<Student> _students = [];
  String? _selectedStudentId;

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    try {
      final response = await http
          .get(Uri.parse('${AppConfig.baseUrl}/api/auth/users?role=Student'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _students = data.map((student) => Student.fromJson(student)).toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch students')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error fetching students. Please try again later.')),
      );
    }
  }

  Future<void> _sendMessage(String studentId, String studentPassword) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/messageStudent'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'studentId': studentId,
          'subject': 'Your Login Details',
          'message': 'Your User ID: $studentId, Password: $studentPassword',
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message sent successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send message.')),
        );
      }
    } catch (e) {
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
        title: const Text('Send ID/Password to Student'),
      ),
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Your login details for SRS Classes is: User ID: SCSTD4659 Password: 8X4X564, download app from http://bit.ly/2Cpwr55 Service by, Viha IT Services',
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              DropdownButtonFormField<String>(
                value: _selectedStudentId,
                items: _students.map((student) {
                  return DropdownMenuItem<String>(
                    value: student.id,
                    child: Text(student.name),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedStudentId = newValue;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Select Student',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),

              // Student ID/Password Details
              const Text('Student ID/Password Details',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16.0),

              if (_selectedStudentId != null)
                StudentDetailsCard(
                  student: _students.firstWhere(
                      (student) => student.id == _selectedStudentId),
                  onSendMessage: _sendMessage,
                ),
            ],
          ),
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

class StudentDetailsCard extends StatelessWidget {
  final Student student;
  final Function(String, String) onSendMessage;

  const StudentDetailsCard(
      {super.key, required this.student, required this.onSendMessage});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Student Name: ${student.name}'),
            Text('User ID: ${student.id}'),
            Text('Password: ${student.password}'),

            // Send Message button
            ElevatedButton(
              onPressed: () {
                onSendMessage(student.id, student.password);
              },
              child: const Text('Send Message'),
            ),
          ],
        ),
      ),
    );
  }
}

class Exam {
  final String id;
  final String examName; // Use examName instead of paperName
  final String examPaperType;

  Exam({
    required this.id,
    required this.examName,
    required this.examPaperType,
  });

  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      id: json['_id'],
      examName: json['examName'] ?? 'N/A',
      examPaperType: 'Manual', // Specify as manual
    );
  }
}

class MCQExam {
  final String id;
  final String paperName;
  final String standard;
  final String subject;
  final String examPaperType;

  MCQExam({
    required this.id,
    required this.paperName,
    required this.standard,
    required this.subject,
    required this.examPaperType,
  });

  factory MCQExam.fromJson(Map<String, dynamic> json) {
    return MCQExam(
      id: json['_id'],
      paperName: json['paperName'] ?? 'N/A',
      standard: json['standard'] ?? 'N/A',
      subject: json['subject'] ?? 'N/A',
      examPaperType: json['examPaperType'] ?? 'N/A',
    );
  }
}

class SendExamReminderScreen extends StatefulWidget {
  const SendExamReminderScreen({super.key});

  @override
  _SendExamReminderScreenState createState() => _SendExamReminderScreenState();
}

class _SendExamReminderScreenState extends State<SendExamReminderScreen> {
  String selectedStandard = '';
  String selectedSubject = '';
  String selectedExamName = '';
  List<String> alreadyAssignedStandards = [];
  List<String> alreadyAssignedSubjects = [];
  List<dynamic> allExams = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchAlreadyAssignedStandards();
    _fetchAlreadyAssignedSubjects();
    _fetchAllExams();
  }

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
                value: selectedStandard.isNotEmpty ? selectedStandard : null,
                items: alreadyAssignedStandards.isNotEmpty
                    ? alreadyAssignedStandards.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList()
                    : null,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedStandard = newValue ?? '';
                    selectedSubject = '';
                    selectedExamName = '';
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
                value: selectedSubject.isNotEmpty ? selectedSubject : null,
                items: alreadyAssignedSubjects.isNotEmpty
                    ? alreadyAssignedSubjects.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList()
                    : null,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedSubject = newValue ?? '';
                    selectedExamName = '';
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
                value: selectedExamName.isNotEmpty ? selectedExamName : null,
                items: allExams.isNotEmpty
                    ? allExams.map((exam) {
                        String examType =
                            (exam is MCQExam) ? '(MCQ)' : '(Manual)';
                        String displayName = (exam is MCQExam)
                            ? exam.paperName
                            : exam.examName; // Use correct field
                        return DropdownMenuItem<String>(
                          value: exam.id,
                          child: Text('$displayName $examType'),
                        );
                      }).toList()
                    : null,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedExamName = newValue ?? '';
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
                onPressed: _sendNotification, // Call the send function
                child: const Text('Send'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _fetchAlreadyAssignedStandards() async {
    try {
      final url =
          Uri.parse('${AppConfig.baseUrl}/api/assignStandard/alreadyAssigned');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['standards'] is List) {
          setState(() {
            alreadyAssignedStandards = List<String>.from(data['standards']);
          });
        } else {
          _showMessage('Unexpected data format');
        }
      } else {
        _showMessage(
            'Failed to load already assigned standards: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      _showMessage('Error loading assigned standards: $e');
    }
  }

  Future<void> _fetchAlreadyAssignedSubjects() async {
    try {
      final url =
          Uri.parse('${AppConfig.baseUrl}/api/assignSubject/alreadyAssigned');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['subjects'] is List) {
          setState(() {
            alreadyAssignedSubjects = List<String>.from(data['subjects']);
          });
        } else {
          _showMessage('Unexpected data format');
        }
      } else {
        _showMessage(
            'Failed to load already assigned subjects: ${response.reasonPhrase}');
      }
    } catch (e) {
      _showMessage('Error loading assigned subjects: $e');
    }
  }

  Future<void> _fetchMCQExams() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/mcq-exams/'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          allExams.addAll(data.map((exam) => MCQExam.fromJson(exam)).toList());
        });
      } else {
        _showMessage('Failed to load MCQ exams: ${response.statusCode}');
      }
    } catch (error) {
      _showMessage('Error fetching MCQ exams: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchManualExams() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/exams'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          allExams.addAll(data.map((exam) => Exam.fromJson(exam)).toList());
        });
      } else {
        _showMessage('Failed to load manual exams: ${response.statusCode}');
      }
    } catch (error) {
      _showMessage('Error fetching manual exams: $error');
    }
  }

  Future<void> _fetchAllExams() async {
    await Future.wait([_fetchMCQExams(), _fetchManualExams()]);
  }

  Future<void> _sendNotification() async {
    // Validate if the necessary fields are selected
    if (selectedStandard.isEmpty ||
        selectedSubject.isEmpty ||
        selectedExamName.isEmpty) {
      _showMessage('Please select standard, subject, and exam name.');
      return;
    }

    // Construct the notification message
    String examName =
        allExams.firstWhere((exam) => exam.id == selectedExamName).examName;
    String message = '$examName upcoming';

    // Prepare the data to send
    final notificationData = {
      'standard': selectedStandard,
      'subject': selectedSubject,
      'examName': examName,
      'date': DateTime.now()
          .toIso8601String(), // You can modify this based on your requirements
    };

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/messageStudent/exam/notifications'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(notificationData),
      );

      if (response.statusCode == 200) {
        _showMessage('Notification sent successfully');
        // Clear the selections after sending
        setState(() {
          selectedStandard = '';
          selectedSubject = '';
          selectedExamName = '';
        });
      } else {
        _showMessage('Failed to send notification: ${response.body}');
      }
    } catch (error) {
      _showMessage('Error sending notification: $error');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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

              // Loading Indicator or Error Message
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else if (errorMessage.isNotEmpty)
                Center(
                    child: Text(errorMessage,
                        style: const TextStyle(color: Colors.red)))
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
                            document: filteredAbsentees[index]
                                .document, // Include document
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
      studentName:
          json['studentName'] ?? 'Unknown', // Default to 'Unknown' if null
      reason: json['reason'] ??
          'No reason provided', // Default to a message if null
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
            if (document != null &&
                document!.isNotEmpty) // Show document if it exists
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
            Text(senderName,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4.0),
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold)), // Display title
            const SizedBox(height: 4.0),
            Text(message),
            const SizedBox(height: 4.0),
            Text(
                'Received on: ${timestamp.toLocal().toString().split(' ')[0]}'),
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
        Uri.parse(
            '${AppConfig.baseUrl}/api/messageStudent/teacher/admin/messages'),
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
            messages =
                data.map((item) => ReceivedMessage.fromJson(item)).toList();
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
                ? Center(
                    child: Text(errorMessage,
                        style: const TextStyle(color: Colors.red)))
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
