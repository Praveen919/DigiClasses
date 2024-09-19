import 'package:flutter/material.dart';

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
      case 'studentIdPassword':
        return const SendStudentIdPasswordScreen();
      case 'examReminder':
        return const SendExamReminderScreen();
      case 'examMarks':
        return const SendExamMarksMessageScreen();
      case 'absentAttendance':
        return const SendAbsentAttendanceMessageScreen();
      default:
        return const Center(child: Text('Unknown Option'));
    }
  }
}

// Below are the placeholder widgets for each message screen.
// Replace these with your actual implementation.

class SendStudentMessageScreen extends StatelessWidget {
  const SendStudentMessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Message to Students'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Message Type (changed to TextFormField)
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Message Type*',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),

            // Title
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Title*',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),

            // Message
            TextFormField(
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Message*',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32.0),

            // Confirm Button
            ElevatedButton(
              onPressed: () {
                // Implement confirmation logic here
              },
              child: const Text('Confirm'),
            ),
          ],
        ),
      ),
    );
  }
}

class SendStaffMessageScreen extends StatelessWidget {
  const SendStaffMessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Message to Staff'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Message Type (changed to TextFormField)
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Message Type*',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),

            // Title
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Title*',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),

            // Message
            TextFormField(
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Message*',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32.0),

            // Confirm Button
            ElevatedButton(
              onPressed: () {
                // Implement confirmation logic here
              },
              child: const Text('Confirm'),
            ),
          ],
        ),
      ),
    );
  }
}

class SendStaffIdPasswordScreen extends StatelessWidget {
  const SendStaffIdPasswordScreen({super.key});

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

              // Send Message with Mobile App Link
              DropdownButtonFormField<String>(
                value: '-- Select --',
                items: <String>['Option 1', 'Option 2', 'Option 3']
                    .map((String value) => DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                ))
                    .toList(),
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

              // Staff ID/Password Details
              const Text('Staff ID/Password Details',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16.0),

              // List of staff details
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 1, // Replace with actual number of staff
                itemBuilder: (context, index) {
                  return const StaffDetailsCard(
                    // Pass staff data here
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

// Custom widget for each staff's details
class StaffDetailsCard extends StatelessWidget {
  const StaffDetailsCard({super.key});

  // Add necessary properties for staff data

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Staff Name: XXXXXXXXX'),
            const Text('User ID: XXXXXXXXX'),
            const Text('Password: XXXXXXXXX'),

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

class SendStudentIdPasswordScreen extends StatelessWidget {
  const SendStudentIdPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send ID/Password to Student'),
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

              // Send Message with Mobile App Link
              DropdownButtonFormField<String>(
                value: '-- Select --',
                items: <String>['Option 1', 'Option 2', 'Option 3']
                    .map((String value) => DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                ))
                    .toList(),
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

              // Staff ID/Password Details
              const Text('Student ID/Password Details',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16.0),

              // List of staff details
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 1, // Replace with actual number of staff
                itemBuilder: (context, index) {
                  return const StaffDetailsCard(
                    // Pass staff data here
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

class StudentDetailsCard extends StatelessWidget {
  const StudentDetailsCard({super.key});

  // Add necessary properties for staff data

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Student Name: XXXXXXXXX'),
            const Text('User ID: XXXXXXXXX'),
            const Text('Password: XXXXXXXXX'),

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

class SendExamReminderScreen extends StatelessWidget {
  const SendExamReminderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Upcoming Exam Message to Student'),
      ),
      resizeToAvoidBottomInset:
      true, // Ensures proper resizing to avoid keyboard overlap
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Standard
              DropdownButtonFormField<String>(
                value: 'All',
                items: <String>['All', '1st Std', '2nd Std', '3rd Std']
                    .map((String value) => DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                ))
                    .toList(),
                onChanged: (String? newValue) {
                  // Handle dropdown selection change
                },
                decoration: const InputDecoration(
                  labelText: 'Standard',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),

              // Subject
              DropdownButtonFormField<String>(
                value: 'All',
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
                  // Handle dropdown selection change
                },
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),

              // Exam Name
              DropdownButtonFormField<String>(
                value: '-- Select --',
                items: <String>[
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
                  // Handle dropdown selection change
                },
                decoration: const InputDecoration(
                  labelText: 'Exam Name*',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32.0),

              // Confirm Button
              ElevatedButton(
                onPressed: () {
                  // Implement confirmation logic here
                },
                child: const Text('Confirm'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SendExamMarksMessageScreen extends StatelessWidget {
  const SendExamMarksMessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Exam Marks to Student'),
      ),
      resizeToAvoidBottomInset:
      true, // Ensures proper resizing to avoid keyboard overlap
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Standard
              DropdownButtonFormField<String>(
                value: 'All',
                items: <String>['All', '1st Std', '2nd Std', '3rd Std']
                    .map((String value) => DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                ))
                    .toList(),
                onChanged: (String? newValue) {
                  // Handle dropdown selection change
                },
                decoration: const InputDecoration(
                  labelText: 'Standard',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),

              // Subject
              DropdownButtonFormField<String>(
                value: 'All',
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
                  // Handle dropdown selection change
                },
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),

              // Exam Name
              DropdownButtonFormField<String>(
                value: '-- Select --',
                items: <String>[
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
                  // Handle dropdown selection change
                },
                decoration: const InputDecoration(
                  labelText: 'Exam Name*',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32.0),

              // Confirm Button
              ElevatedButton(
                onPressed: () {
                  // Implement confirmation logic here
                },
                child: const Text('Confirm'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SendAbsentAttendanceMessageScreen extends StatelessWidget {
  const SendAbsentAttendanceMessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Today Absent Attendance Message'),
      ),
      resizeToAvoidBottomInset:
      true, // Ensures proper resizing to avoid keyboard overlap
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
                    'User1 was absent today at SRS Classes for the batch that starts at 11:30 AM. Thank you, Viha IT Services',
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

              // Today's Absentees
              const Text('Today\'s Absentees',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16.0),

              // List of today's absentees
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 1, // Replace with actual number of absent students
                itemBuilder: (context, index) {
                  return const AbsentStudentCard(
                    // Pass absent student data here
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
  const AbsentStudentCard({super.key});

  // Add necessary properties for absent student data

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