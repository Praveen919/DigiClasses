import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StudentT extends StatefulWidget {
  final String option;

  const StudentT({super.key, required this.option});

  @override
  _StudentScreenState createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentT> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student'),
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    switch (widget.option) {
      case 'studentAttendance':
        return const StudentAttendanceScreen();
      case 'shareDocuments':
        return const ShareDocumentsScreen();
      case 'manageSharedDocuments':
        return const ManageSharedDocumentsScreen();
      case 'chatWithStudents':
        return const ChatWithStudentsScreen();
      case 'studentsFeedback':
        return const StudentsFeedbackScreen();
      default:
        return const Center(child: Text('Unknown Option'));
    }
  }
}

// Below are the placeholder widgets for each student-related screen.
// Replace these with your actual implementation.

// Custom widget for each student inquiry

class StudentAttendanceScreen extends StatefulWidget {
  const StudentAttendanceScreen({super.key});

  @override
  _StudentAttendanceScreenState createState() =>
      _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState extends State<StudentAttendanceScreen> {
  // Initialize date variables with current date
  String _selectedMonth = DateFormat('MMMM').format(DateTime.now());
  String _day = DateFormat('d').format(DateTime.now());
  String _year = DateFormat('y').format(DateTime.now());
  bool _displayClassBatch = false;
  String? _selectedClassBatch;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Student Attendance'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Take Student Attendance
            const Text('Take Student Attendance',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16.0),

            // Attendance Date
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedMonth,
                    items: <String>[
                      'January',
                      'February',
                      'March',
                      'April',
                      'May',
                      'June',
                      'July',
                      'August',
                      'September',
                      'October',
                      'November',
                      'December'
                    ]
                        .map((String value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    ))
                        .toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedMonth = newValue!;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Month',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Day',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    initialValue: _day,
                    onChanged: (value) {
                      setState(() {
                        _day = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Year',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    initialValue: _year,
                    onChanged: (value) {
                      setState(() {
                        _year = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),

            // Display my Class/Batch (Time table wise)
            CheckboxListTile(
              title: const Text('Display my Class/Batch(Time table wise)'),
              value: _displayClassBatch,
              onChanged: (bool? value) {
                setState(() {
                  _displayClassBatch = value!;
                });
              },
            ),
            const SizedBox(height: 16.0),

            // Class/Batch
            DropdownButtonFormField<String>(
              value: _selectedClassBatch,
              hint: const Text('-- Select --'),
              items: <String>['Class/Batch 1', 'Class/Batch 2', 'Class/Batch 3']
                  .map((String value) => DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              ))
                  .toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedClassBatch = newValue;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Class/Batch*',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32.0),

            // Take Attendance Button
            ElevatedButton(
              onPressed: () {
                // Implement take attendance functionality
              },
              child: const Text('Take Attendance'),
            ),
          ],
        ),
      ),
    );
  }
}

class ShareDocumentsScreen extends StatefulWidget {
  const ShareDocumentsScreen({super.key});

  @override
  _ShareDocumentsScreenState createState() => _ShareDocumentsScreenState();
}

class _ShareDocumentsScreenState extends State<ShareDocumentsScreen> {
  // Variables to hold selected values
  String _selectedStandard = '-- Select --';
  String _selectedShareOption = '-- Select --';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Documents'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selection
            const Text('Selection',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16.0),

            // Select Standard to Share Document
            DropdownButtonFormField<String>(
              value: _selectedStandard,
              items: <String>[
                '-- Select --',
                'Standard 1',
                'Standard 2',
                'Standard 3'
              ]
                  .map((String value) => DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              ))
                  .toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedStandard = newValue!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Select Standard To Share Document',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),

            // How Would You Like To Share Document
            DropdownButtonFormField<String>(
              value: _selectedShareOption,
              items:
              <String>['-- Select --', 'Option 1', 'Option 2', 'Option 3']
                  .map((String value) => DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              ))
                  .toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedShareOption = newValue!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'How Would You Like To Share Document',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32.0),

            // Confirm Button
            ElevatedButton(
              onPressed: () {
                // Implement confirmation logic here
                if (_selectedStandard == '-- Select --' ||
                    _selectedShareOption == '-- Select --') {
                  // Show error or perform validation
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please select all required options')),
                  );
                } else {
                  // Proceed with confirmation logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Document sharing confirmed')),
                  );
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        ),
      ),
    );
  }
}

class ManageSharedDocumentsScreen extends StatefulWidget {
  const ManageSharedDocumentsScreen({super.key});

  @override
  _ManageSharedDocumentsScreenState createState() =>
      _ManageSharedDocumentsScreenState();
}

class _ManageSharedDocumentsScreenState
    extends State<ManageSharedDocumentsScreen> {
  // Dummy data for the shared documents list
  final List<Map<String, String>> _sharedDocuments = [
    {'standard': 'Standard 1', 'document': 'Document1.pdf'},
    {'standard': 'Standard 2', 'document': 'Document2.docx'},
    // Add more documents here
  ];

  void _editDocument(int index) {
    // Navigate to an edit screen or show a dialog to edit the document
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Document'),
          content:
          Text('Editing document: ${_sharedDocuments[index]['document']}'),
          actions: [
            TextButton(
              onPressed: () {
                // Implement save functionality
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _deleteDocument(int index) {
    // Implement delete functionality
    setState(() {
      _sharedDocuments.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Document deleted')),
    );
  }

  void _viewDocument(int index) {
    // Navigate to a view screen or show a dialog to view the document
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('View Document'),
          content:
          Text('Viewing document: ${_sharedDocuments[index]['document']}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Shared Documents'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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

            // Shared Documents List
            Expanded(
              child: ListView.builder(
                itemCount: _sharedDocuments.length,
                itemBuilder: (context, index) {
                  return SharedDocumentCard(
                    documentData: _sharedDocuments[index],
                    onEdit: () => _editDocument(index),
                    onDelete: () => _deleteDocument(index),
                    onView: () => _viewDocument(index),
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

// Custom widget for each shared document
class SharedDocumentCard extends StatelessWidget {
  final Map<String, String> documentData;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onView;

  const SharedDocumentCard({
    super.key,
    required this.documentData,
    required this.onEdit,
    required this.onDelete,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Standard: ${documentData['standard']}'),
            Text('Document Shared: ${documentData['document']}'),

            // Edit, Delete, and View buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: onDelete,
                ),
                IconButton(
                  icon: const Icon(Icons.visibility),
                  onPressed: onView,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ChatWithStudentsScreen extends StatelessWidget {
  const ChatWithStudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat With Students'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add New Chat
            const Text('Add New Chat',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16.0),

            // Subject/Topic
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Subject/Topic*',
                border: OutlineInputBorder(),
                contentPadding:
                EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              ),
            ),
            const SizedBox(height: 16.0),

            // Student Name
            DropdownButtonFormField<String>(
              value: null, // Changed to null to show default prompt
              items: <String>['Student 1', 'Student 2', 'Student 3']
                  .map((String value) => DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              ))
                  .toList(),
              onChanged: (String? newValue) {
                // Handle dropdown selection change
              },
              decoration: const InputDecoration(
                labelText: 'Student Name*',
                border: OutlineInputBorder(),
                contentPadding:
                EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              ),
            ),
            const SizedBox(height: 16.0),

            // Message
            TextFormField(
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Message*',
                border: OutlineInputBorder(),
                contentPadding:
                EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              ),
            ),
            const SizedBox(height: 32.0),

            // Send and Cancel buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        // Implement send message functionality
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, // Custom background color
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                      ),
                      child: const Text('Send', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        // Implement cancel functionality
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey, // Custom background color
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                      ),
                      child:
                      const Text('Cancel', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class StudentsFeedbackScreen extends StatelessWidget {
  const StudentsFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Feedback List'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
              ),
            ),
            const SizedBox(height: 16.0),

            // Student Feedback List
            Expanded(
              child: ListView.builder(
                itemCount: 1, // Replace with actual number of feedback
                itemBuilder: (context, index) {
                  return const StudentFeedbackCard(
                    // Pass feedback data here
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

// Custom widget for each student feedback
class StudentFeedbackCard extends StatelessWidget {
  const StudentFeedbackCard({super.key});

  // Add necessary properties for feedback data

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
          vertical: 8.0), // Adds vertical spacing between cards
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Student Name: XXXXXX',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Subject: XXXXXXXXXX',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'Feedback: Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
              style: TextStyle(
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16.0),

            // Action buttons (optional)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Implement view details functionality
                  },
                  child: const Text('View Details'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}