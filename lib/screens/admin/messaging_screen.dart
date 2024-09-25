import 'package:flutter/material.dart';
import 'package:testing_app/screens/config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
      case 'staffIdPassword':
        return const SendStaffIdPasswordScreen();
      case 'studentIdPassword':
        return const SendStudentIdPasswordScreen();
      case 'examReminder':
        return const SendExamReminderScreen();
      case 'feeStatus':
        return const SendFeeStatusMessageScreen();
      case 'feeReminder':
        return const SendFeeReminderScreen();
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
  _SendStudentMessageScreenState createState() => _SendStudentMessageScreenState();
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
      final response = await http.get(Uri.parse('${AppConfig.baseUrl}/api/auth/users?role=Student'));

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

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/messageStudent'),
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
        final errorMessage = json.decode(response.body)['error'] ?? 'Failed to send message';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      // Handle network error or other exceptions
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error sending message. Please try again later.')),
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

  void fetchStaffMembers() async {
    try {
      final response = await http.get(Uri.parse('${AppConfig.baseUrl}/api/staff/teachers')); // Replace with your API endpoint
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          staffList = data.map<Map<String, String>>((staff) {
            return {
              'id': staff['id'].toString(), // Ensure it's a string
              'name': staff['name'] ?? 'Unknown', // Handle null name
            };
          }).toList();
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load staff members';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred: $e';
      });
    }
  }

  Future<void> sendMessage() async {
    if (selectedStaffId == null || titleController.text.isEmpty || messageController.text.isEmpty) {
      setState(() {
        errorMessage = 'Please fill all fields.';
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/messageStudent'), // Replace with your API endpoint
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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Message sent successfully')));
      } else {
        setState(() {
          errorMessage = 'Failed to send message: ${json.decode(response.body)['error']}';
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
              items: staffList.map<DropdownMenuItem<String>>((Map<String, String> staff) {
                return DropdownMenuItem<String>(
                  value: staff['id'], // Use the ID for selection
                  child: Text(staff['name'] ?? 'Unknown'), // Display the staff name
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
                style: TextStyle(color: Colors.red),
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

class SendStaffIdPasswordScreen extends StatefulWidget {
  const SendStaffIdPasswordScreen({super.key});

  @override
  _SendStaffIdPasswordScreenState createState() => _SendStaffIdPasswordScreenState();
}

class _SendStaffIdPasswordScreenState extends State<SendStaffIdPasswordScreen> {
  List<Staff> _staff = [];
  List<Staff> _filteredStaff = [];
  String? _selectedStaffId;
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _fetchStaff();
  }

  Future<void> _fetchStaff() async {
    try {
      final response = await http.get(Uri.parse('${AppConfig.baseUrl}/api/auth/users?role=Teacher'));
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
        const SnackBar(content: Text('Error fetching staff. Please try again later.')),
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
        const SnackBar(content: Text('Error sending message. Please try again later.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                value: '-- Select --',
                items: <String>['Option 1', 'Option 2', 'Option 3']
                    .map((String value) => DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                )).toList(),
                onChanged: (String? newValue) {
                  // Handle dropdown selection change
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
              const Text('Staff ID/Password Details', style: TextStyle(fontWeight: FontWeight.bold)),
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
      password: json['password'], // Assuming password is available in the response
    );
  }
}

class StaffDetailsCard extends StatelessWidget {
  final Staff staff;
  final Function(String, String) onSendMessage;

  const StaffDetailsCard({super.key, required this.staff, required this.onSendMessage});

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
  _SendStudentIdPasswordScreenState createState() => _SendStudentIdPasswordScreenState();
}

class _SendStudentIdPasswordScreenState extends State<SendStudentIdPasswordScreen> {
  List<Student> _students = [];
  String? _selectedStudentId;
  String _selectedStudentName = '';

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    try {
      final response = await http.get(Uri.parse('${AppConfig.baseUrl}/api/auth/users?role=Student'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _students = data.map((student) => Student.fromJson(student)).toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch students')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching students. Please try again later.')),
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
        const SnackBar(content: Text('Error sending message. Please try again later.')),
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
                    _selectedStudentName = newValue != null ? _students.firstWhere((student) => student.id == newValue).name : '';
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Select Student',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),

              // Student ID/Password Details
              const Text('Student ID/Password Details', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16.0),

              if (_selectedStudentId != null)
                StudentDetailsCard(
                  student: _students.firstWhere((student) => student.id == _selectedStudentId),
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

  const StudentDetailsCard({super.key, required this.student, required this.onSendMessage});

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

class SendExamReminderScreen extends StatefulWidget {
  const SendExamReminderScreen({super.key});

  @override
  _SendExamReminderScreenState createState() => _SendExamReminderScreenState();
}

class _SendExamReminderScreenState extends State<SendExamReminderScreen> {
  String selectedStandard = 'All';
  String selectedSubject = 'All';
  String selectedExamName = '-- Select --';

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
    // Implement the API call to send the exam notification
    // Example:
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
      // Handle success response
    } else {
      // Handle error response
    }
  }
}

class SendFeeStatusMessageScreen extends StatelessWidget {
  const SendFeeStatusMessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Fee Status Message to Student'),
      ),
      resizeToAvoidBottomInset: true, // Ensures proper resizing to avoid keyboard overlap
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
                    'Dear John, Your fee status is: Total fees amount - 5000, Total received amount - 1000. Total pending amount - 4000. Thank you, SRS Classes. Service by, Viha IT Services',
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              // Search Bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      // Implement search functionality here
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              // Students with Pending Fees
              const Text('Students with Pending Fees', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16.0),

              // List of students with pending fees
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 1, // Replace with actual number of students with pending fees
                itemBuilder: (context, index) {
                  return const StudentWithPendingFeeCard(
                    // Pass student data here
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

// Custom widget for each student with pending fees
class StudentWithPendingFeeCard extends StatelessWidget {
  const StudentWithPendingFeeCard({super.key});

  // Add necessary properties for student data

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Student Name: XXXXXX'),
            const Text('Standard: XX'),
            const Text('Batch: XX'),

            // Send Message button
            ElevatedButton(
              onPressed: () {
                // Implement send message functionality
              },
              child: const Text('Send Message'),
            ),
          ],
        ),
      ),
    );
  }
}

class SendFeeReminderScreen extends StatelessWidget {
  const SendFeeReminderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Fee Reminder to Student'),
      ),
      resizeToAvoidBottomInset: true, // Ensures proper resizing to avoid keyboard overlap
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
                    'Dear John, Your fee payment is due at SRS Classes. This is a friendly reminder to submit it and ignore it if you already processed it. Total pending amount is 4000. Thank you, SRS Classes. Service by, Viha IT Services',
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              // With Total Pending Amount
              CheckboxListTile(
                title: const Text('With Total Pending Amount'),
                value: false, // Set initial value to false
                onChanged: (bool? value) {
                  // Handle checkbox change
                },
              ),
              const SizedBox(height: 16.0),

              // Search Bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      // Implement search functionality here
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              // Students with Pending Fees
              const Text('Students with Pending Fees', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16.0),

              // List of students with pending fees
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 1, // Replace with actual number of students with pending fees
                itemBuilder: (context, index) {
                  return const StudentWithPendingFeeCard(
                    // Pass student data here
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

// Custom widget for each student with pending fees
class StudentWithPendingFeeCard1 extends StatelessWidget {
  const StudentWithPendingFeeCard1({super.key});

  // Add necessary properties for student data

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Student Name: XXXXXX'),
            const Text('Standard: XX'),
            const Text('Batch: XX'),

            // Send Message button
            ElevatedButton(
              onPressed: () {
                // Implement send message functionality
              },
              child: const Text('Send Message'),
            ),
          ],
        ),
      ),
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
  List<String> absentees = [];
  List<String> filteredAbsentees = [];

  @override
  void initState() {
    super.initState();
    fetchAbsentees(); // Fetch absentees from the backend
  }

  // Function to fetch absentees from the API
  Future<void> fetchAbsentees() async {
    final response = await http.get(Uri.parse('${AppConfig.baseUrl}/api/absenceMessage/absences/today'));

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
          .where((student) => student.toLowerCase().contains(query.toLowerCase()))
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
