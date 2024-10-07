import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
//import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:testing_app/screens/config.dart';
//import 'package:http_parser/http_parser.dart';

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
  String _selectedMonth = DateFormat('MMMM').format(DateTime.now());
  String _day = DateFormat('d').format(DateTime.now());
  String _year = DateFormat('y').format(DateTime.now());
  bool _displayClassBatch = false;
  String? _selectedClassBatch;
  bool _attendanceTaken = false;
  bool _isEditable = false;
  DateTime? _fromDate;
  DateTime? _toDate;
  List<String> _classBatches = [];
  List<Map<String, dynamic>> attendanceData = []; // Updated type

  @override
  void initState() {
    super.initState();
    _fetchClassBatches();
  }

  Future<void> _fetchClassBatches() async {
    try {
      final response =
          await http.get(Uri.parse('${AppConfig.baseUrl}/api/class-batch'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _classBatches = data.map((item) => item['name'] as String).toList();
        });
      }
    } catch (e) {
      print('Error fetching class batches: $e');
    }
  }

  Future<void> _fetchAttendanceData() async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/attendance/attendance-data'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'classBatchId': _selectedClassBatch,
          'date': DateFormat('yyyy-MM-dd').format(DateTime(
            int.parse(_year),
            DateFormat('MMMM').parse(_selectedMonth).month,
            int.parse(_day),
          )),
        }),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          attendanceData = data.map((item) {
            return {
              'id': item['_id'] ?? '',
              'date':
                  DateFormat('dd/MM/yyyy').format(DateTime.parse(item['date'])),
              'classBatch': item['classBatch'] ?? '',
              'student': item['studentName'] ?? '',
              'attendance': item['status'] ?? 'Absent',
            };
          }).toList();
        });
      }
    } catch (e) {
      print('Error fetching attendance data: $e');
    }
  }

  Future<void> _updateAttendance() async {
    try {
      for (var data in attendanceData) {
        final response = await http.post(
          Uri.parse('${AppConfig.baseUrl}/api/update-attendance'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'attendanceId': data['id'],
            'status': data['attendance'],
          }),
        );
        if (response.statusCode != 200) {
          throw Exception('Failed to update attendance');
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attendance updated successfully')));
    } catch (e) {
      print('Error updating attendance: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Attendance'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            _attendanceTaken ? _buildAttendanceTable() : _buildAttendanceForm(),
      ),
    );
  }

  Widget _buildAttendanceForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Take Student Attendance',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16.0),
        Row(
          children: [
            Flexible(
              flex: 3,
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
            const SizedBox(width: 8.0),
            Flexible(
              flex: 1,
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
            const SizedBox(width: 8.0),
            Flexible(
              flex: 2,
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
        CheckboxListTile(
          title: const Text('Display my Class/Batch (Time table wise)'),
          value: _displayClassBatch,
          onChanged: (bool? value) {
            setState(() {
              _displayClassBatch = value!;
            });
          },
        ),
        const SizedBox(height: 16.0),
        DropdownButtonFormField<String>(
          value: _selectedClassBatch,
          hint: const Text('-- Select --'),
          items: _classBatches
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
        const SizedBox(height: 16.0),
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                _fetchAttendanceData();
                setState(() {
                  _attendanceTaken = true;
                  _isEditable = false;
                });
              },
              child: const Text('Get Attendance'),
            ),
            const SizedBox(width: 16.0),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isEditable = true;
                });
              },
              child: const Text('Reset'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAttendanceTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Student Attendance',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16.0),
        Table(
          border: TableBorder.all(),
          children: [
            const TableRow(
              children: [
                TableCell(child: Center(child: Text('Sr. No'))),
                TableCell(child: Center(child: Text('Date'))),
                TableCell(child: Center(child: Text('Class/Batch'))),
                TableCell(child: Center(child: Text('Student'))),
                TableCell(child: Center(child: Text('Attendance'))),
              ],
            ),
            for (int i = 0; i < attendanceData.length; i++)
              TableRow(
                children: [
                  TableCell(child: Center(child: Text('${i + 1}'))),
                  TableCell(
                      child: Center(
                          child: Text(attendanceData[i]['date'] as String))),
                  TableCell(
                      child: Center(
                          child:
                              Text(attendanceData[i]['classBatch'] as String))),
                  TableCell(
                      child: Center(
                          child: Text(attendanceData[i]['student'] as String))),
                  TableCell(
                    child: Center(
                      child: DropdownButton<String>(
                        value: attendanceData[i]['attendance'] as String,
                        items: ['Present', 'Absent']
                            .map((String value) => DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                ))
                            .toList(),
                        onChanged: _isEditable
                            ? (String? newValue) {
                                setState(() {
                                  attendanceData[i]['attendance'] = newValue!;
                                });
                              }
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 16.0),
        ElevatedButton(
          onPressed: _updateAttendance,
          child: const Text('Save Changes'),
        ),
      ],
    );
  }
}

class ShareDocumentsScreen extends StatefulWidget {
  const ShareDocumentsScreen({super.key});

  @override
  _ShareDocumentsScreenState createState() => _ShareDocumentsScreenState();
}

class _ShareDocumentsScreenState extends State<ShareDocumentsScreen> {
  String _selectedClassBatch = '-- Select --';
  String _selectedStandard = '-- Select --'; // New variable for standard
  File? _selectedFile;
  String _message = '';

  // Lists to hold class/batch and standard from the backend
  List<String> _classBatchList = ['-- Select --'];
  List<String> _standardList = [
    '-- Select --',
    '1st',
    '2nd',
    '3rd',
    '4th',
    '5th',
    '6th',
    '7th',
    '8th',
    '9th',
    '10th',
    '11th',
    '12th'
  ];

  @override
  void initState() {
    super.initState();
    _fetchClassBatchData(); // Fetch the class/batch data from the backend
  }

  // Method to fetch class/batch data from the backend
  Future<void> _fetchClassBatchData() async {
    try {
      final response = await http.get(Uri.parse(
          '${AppConfig.baseUrl}/api/class-batch')); // Replace with your backend API URL
      if (response.statusCode == 200) {
        List<dynamic> classBatches = jsonDecode(response.body);

        // Map the class batches to a List<String>
        setState(() {
          _classBatchList = ['-- Select --'] +
              classBatches
                  .map((item) => item['classBatchName'] as String)
                  .toList(); // Cast to String
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load class/batch data')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Method to pick a file
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  // Method to upload data to the backend
  // Method to upload data to the backend
  Future<void> _uploadDocument() async {
    if (_selectedClassBatch == '-- Select --' ||
        _selectedStandard == '-- Select --' || // Check if standard is selected
        _selectedFile == null ||
        _message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            '${AppConfig.baseUrl}/api/documents')); // Replace with your API URL
    request.fields['class_batch'] = _selectedClassBatch;
    request.fields['standard'] = _selectedStandard; // Include standard field
    request.fields['message'] = _message;
    request.files
        .add(await http.MultipartFile.fromPath('file', _selectedFile!.path));

    try {
      var response = await request.send();

      // Check the response status code
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody =
            await response.stream.bytesToString(); // Read the response body
        print(
            'Document uploaded successfully: $responseBody'); // Log success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document uploaded successfully')),
        );
      } else {
        final responseBody = await response.stream.bytesToString();
        print('Failed to upload document: ${response.statusCode}');
        print('Response body: $responseBody');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to upload document: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error during document upload: $e'); // Log error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred during upload')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Document'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Select Class/Batch
            const Text('Select Class/Batch',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: _selectedClassBatch,
              items: _classBatchList.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedClassBatch = newValue!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Select Class/Batch',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),

            // Select Standard
            const Text('Select Standard',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: _selectedStandard,
              items: _standardList.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedStandard = newValue!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Select Standard',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),

            // Select File to Upload
            const Text('Select File to Upload',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _pickFile,
              child: const Text('Choose File'),
            ),
            if (_selectedFile != null)
              Text('Selected File: ${_selectedFile!.path}'),

            const SizedBox(height: 16.0),

            // Message Input Field
            const Text('Message',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16.0),
            TextField(
              onChanged: (value) {
                setState(() {
                  _message = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Enter your message',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32.0),

            // Confirm Button
            ElevatedButton(
              onPressed: _uploadDocument,
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
  List<Map<String, dynamic>> _sharedDocuments = [];
  List<Map<String, dynamic>> _filteredDocuments = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchDocuments();
    _searchController.addListener(_filterDocuments);
  }

  Future<void> _fetchDocuments() async {
    try {
      final response =
          await http.get(Uri.parse('${AppConfig.baseUrl}/api/documents'));
      if (response.statusCode == 200) {
        final List<dynamic> documents = jsonDecode(response.body);
        setState(() {
          _sharedDocuments = documents
              .map((doc) => {
                    'id': doc['_id'],
                    'standard': doc['standard'],
                    'document': doc['documentName'],
                    'message': doc['message'] ?? ''
                  })
              .toList();
          _filteredDocuments =
              _sharedDocuments; // Initially, all documents are shown
        });
      } else {
        throw Exception('Failed to load documents');
      }
    } catch (e) {
      print(e);
    }
  }

  void _filterDocuments() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredDocuments = _sharedDocuments.where((doc) {
        final documentName = doc['document'].toLowerCase();
        final standard = doc['standard'].toLowerCase();
        return documentName.contains(query) || standard.contains(query);
      }).toList();
    });
  }

  void _editDocument(int index) {
    TextEditingController messageController = TextEditingController();
    TextEditingController standardController = TextEditingController();
    TextEditingController documentController = TextEditingController();

    messageController.text = _filteredDocuments[index]['message'] ?? '';
    standardController.text = _filteredDocuments[index]['standard'];
    documentController.text = _filteredDocuments[index]['document'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Document'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: standardController,
                decoration: const InputDecoration(labelText: 'Class/Batch'),
              ),
              TextField(
                controller: documentController,
                decoration: const InputDecoration(labelText: 'Document Name'),
              ),
              TextField(
                controller: messageController,
                decoration: const InputDecoration(labelText: 'Message'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await _updateDocument(
                  _filteredDocuments[index]['id'],
                  standardController.text,
                  documentController.text,
                  messageController.text,
                );
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

  Future<void> _updateDocument(
      String id, String standard, String documentName, String message) async {
    try {
      final response = await http.put(
        Uri.parse('${AppConfig.baseUrl}/api/documents/$id'),
        body: jsonEncode({
          'standard': standard,
          'documentName': documentName,
          'message': message,
        }),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        _fetchDocuments(); // Refresh the list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document updated successfully')),
        );
      } else {
        throw Exception('Failed to update document');
      }
    } catch (e) {
      print(e);
    }
  }

  void _deleteDocument(int index) async {
    try {
      final response = await http.delete(
        Uri.parse(
            '${AppConfig.baseUrl}/api/documents/${_filteredDocuments[index]['id']}'),
      );
      if (response.statusCode == 200) {
        setState(() {
          _filteredDocuments.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document deleted')),
        );
      } else {
        throw Exception('Failed to delete document');
      }
    } catch (e) {
      print(e);
    }
  }

  void _viewDocument(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('View Document'),
          content: Text(
              'Viewing document: ${_filteredDocuments[index]['document']}'),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _filterDocuments(); // Reset the list to original
                  },
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            // Shared Documents List
            Expanded(
              child: ListView.builder(
                itemCount: _filteredDocuments.length,
                itemBuilder: (context, index) {
                  return SharedDocumentCard(
                    documentData: _filteredDocuments[index],
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

class SharedDocumentCard extends StatelessWidget {
  final Map<String, dynamic> documentData;
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
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(documentData['document']),
        subtitle: Text('Class/Batch: ${documentData['standard']}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.visibility),
              onPressed: onView,
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class ChatWithStudentsScreen extends StatefulWidget {
  const ChatWithStudentsScreen({super.key});

  @override
  _ChatWithStudentsScreenState createState() => _ChatWithStudentsScreenState();
}

class _ChatWithStudentsScreenState extends State<ChatWithStudentsScreen> {
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _filteredStudents = [];
  String? _selectedStudent;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchStudents();
    _searchController.addListener(_filterStudents);
  }

  Future<void> _fetchStudents() async {
    try {
      final response = await http.get(Uri.parse(
          '${AppConfig.baseUrl}/api/students')); //if this not works change it to (Uri.parse('${AppConfig.baseUrl}/api/users?role=Student'));
      if (response.statusCode == 200) {
        final List<dynamic> students = jsonDecode(response.body);
        setState(() {
          _students = students
              .map((student) => {
                    'id': student['_id'],
                    'name': student['name'],
                  })
              .toList();
          _filteredStudents = _students;
        });
      } else {
        throw Exception('Failed to load students');
      }
    } catch (e) {
      print(e);
    }
  }

  void _filterStudents() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredStudents = _students.where((student) {
        return student['name'].toLowerCase().contains(query);
      }).toList();
    });
  }

  void _selectStudent(String studentName) {
    setState(() {
      _selectedStudent = studentName;
      _searchController.text =
          studentName; // Set the search bar with the selected student's name
    });
  }

  Future<void> _sendMessage() async {
    if (_selectedStudent != null &&
        _subjectController.text.isNotEmpty &&
        _messageController.text.isNotEmpty) {
      try {
        final student = _students
            .firstWhere((student) => student['name'] == _selectedStudent);
        final response = await http.post(
          Uri.parse('${AppConfig.baseUrl}/api/messageStudent'),
          body: jsonEncode({
            'studentId': student['id'],
            'subject': _subjectController.text,
            'message': _messageController.text,
          }),
          headers: {'Content-Type': 'application/json'},
        );
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Message sent successfully')),
          );
          _resetForm();
        } else {
          throw Exception('Failed to send message');
        }
      } catch (e) {
        print(e);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all the fields')),
      );
    }
  }

  void _resetForm() {
    setState(() {
      _selectedStudent = null;
      _subjectController.clear();
      _messageController.clear();
      _searchController.clear();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Chat With Students'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search Student',
                suffixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16.0),

            // Dropdown for Student Names
            DropdownButtonFormField<String>(
              value: _selectedStudent,
              items: _filteredStudents.map((student) {
                return DropdownMenuItem<String>(
                  value: student['name'],
                  child: Text(student['name']),
                );
              }).toList(),
              onChanged: (String? newValue) {
                _selectStudent(newValue!);
              },
              decoration: const InputDecoration(
                labelText: 'Student Name*',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              ),
            ),
            const SizedBox(height: 16.0),

            // Subject/Topic
            TextFormField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: 'Subject/Topic*',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
                      onPressed: _sendMessage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
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
                      onPressed: _resetForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
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

class StudentsFeedbackScreen extends StatefulWidget {
  const StudentsFeedbackScreen({super.key});

  @override
  _StudentsFeedbackScreenState createState() => _StudentsFeedbackScreenState();
}

class _StudentsFeedbackScreenState extends State<StudentsFeedbackScreen> {
  List<dynamic> _feedbacks = [];
  List<dynamic> _filteredFeedbacks = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchFeedbacks();
  }

  Future<void> _fetchFeedbacks() async {
    try {
      final response =
          await http.get(Uri.parse('${AppConfig.baseUrl}/api/feedbacks'));
      if (response.statusCode == 200) {
        final List<dynamic> feedbacks = jsonDecode(response.body);
        setState(() {
          _feedbacks = feedbacks;
          _filteredFeedbacks = feedbacks;
        });
      } else {
        throw Exception('Failed to load feedbacks');
      }
    } catch (e) {
      print(e);
    }
  }

  void _filterFeedbacks(String query) {
    setState(() {
      _searchQuery = query;
      _filteredFeedbacks = _feedbacks.where((feedback) {
        return feedback['studentName']
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            feedback['subject'].toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Student Feedback List'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              onChanged: _filterFeedbacks,
              decoration: InputDecoration(
                hintText: 'Search by Student Name or Subject',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    // Implement search functionality here if needed
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
                itemCount: _filteredFeedbacks.length,
                itemBuilder: (context, index) {
                  return StudentFeedbackCard(
                    feedback: _filteredFeedbacks[index],
                    onViewDetails: () {
                      // Implement view details functionality
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FeedbackDetailScreen(
                              feedback: _filteredFeedbacks[index]),
                        ),
                      );
                    },
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
  final Map<String, dynamic> feedback;
  final VoidCallback onViewDetails;

  const StudentFeedbackCard(
      {super.key, required this.feedback, required this.onViewDetails});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Student Name: ${feedback['studentName']}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Subject: ${feedback['subject']}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Feedback: ${feedback['feedback']}',
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16.0),

            // Action button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: onViewDetails,
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

// Dummy feedback detail screen
class FeedbackDetailScreen extends StatelessWidget {
  final Map<String, dynamic> feedback;

  const FeedbackDetailScreen({super.key, required this.feedback});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feedback Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Student Name: ${feedback['studentName']}'),
            Text('Subject: ${feedback['subject']}'),
            Text('Feedback: ${feedback['feedback']}'),
          ],
        ),
      ),
    );
  }
}
