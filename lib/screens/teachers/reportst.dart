import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting dates
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:testing_app/screens/config.dart';

class ReportT extends StatefulWidget {
  final String option;

  const ReportT({super.key, required this.option});

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportT> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report'),
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    switch (widget.option) {
      case 'studentDetail':
        return const StudentDetailReportScreen();
      case 'studentCard':
        return const StudentCardReportScreen();
      case 'studentAttendance':
        return const StudentAttendanceReportScreen();
      default:
        return const Center(child: Text('Unknown Option'));
    }
  }
}

class StudentDetailReportScreen extends StatefulWidget {
  const StudentDetailReportScreen({super.key});

  @override
  _StudentDetailReportScreenState createState() =>
      _StudentDetailReportScreenState();
}

class _StudentDetailReportScreenState extends State<StudentDetailReportScreen> {
  DateTime? fromDate;
  DateTime? toDate;
  List<dynamic> students = []; // List to hold student data
  List<dynamic> filteredStudents = []; // Filtered list to be displayed
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchStudents(); // Fetch data from the API on screen load
  }

  Future<void> fetchStudents() async {
    final response =
        await http.get(Uri.parse('${AppConfig.baseUrl}/api/student/students'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        students = data;
        filteredStudents = data; // Initially, show all students
      });
    } else {
      throw Exception('Failed to load students');
    }
  }

  // Method to select a date
  Future<void> _selectDate(BuildContext context, DateTime? initialDate,
      Function(DateTime) onDateSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != initialDate) {
      onDateSelected(picked);
    }
  }

  // Filter students by date and search query
  void _filterStudents() {
    setState(() {
      filteredStudents = students.where((student) {
        bool matchesSearchQuery =
            student['name'].toLowerCase().contains(searchQuery.toLowerCase());

        bool matchesFromDate = fromDate == null ||
            DateTime.parse(student['joinDate']).isAfter(fromDate!);

        bool matchesToDate = toDate == null ||
            DateTime.parse(student['joinDate']).isBefore(toDate!);

        return matchesSearchQuery && matchesFromDate && matchesToDate;
      }).toList();
    });
  }

  Future<void> _editStudentDetail(
      int studentId, Map<String, dynamic> updatedData) async {
    final response = await http.put(
      Uri.parse('${AppConfig.baseUrl}/api/student/students/$studentId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updatedData),
    );

    if (response.statusCode == 200) {
      setState(() {
        // Update the local students list with the new data
        final index =
            students.indexWhere((student) => student['id'] == studentId);
        if (index != -1) {
          students[index] = updatedData;
          _filterStudents(); // Re-filter the list with updated data
        }
      });
    } else {
      throw Exception('Failed to update student');
    }
  }

  Future<void> _deleteStudentDetail(int studentId) async {
    final response = await http.delete(
        Uri.parse('${AppConfig.baseUrl}/api/student/students/$studentId'));

    if (response.statusCode == 200) {
      setState(() {
        students.removeWhere((student) => student['id'] == studentId);
        _filterStudents(); // Re-filter the list after deletion
      });
    } else {
      throw Exception('Failed to delete student');
    }
  }

  void _showEditDialog(dynamic student) {
    TextEditingController nameController =
        TextEditingController(text: student['name']);
    TextEditingController standardController =
        TextEditingController(text: student['standard']);
    TextEditingController courseController =
        TextEditingController(text: student['course']);
    TextEditingController batchController =
        TextEditingController(text: student['batch']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Student'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Student Name'),
              ),
              TextField(
                controller: standardController,
                decoration: const InputDecoration(labelText: 'Standard'),
              ),
              TextField(
                controller: courseController,
                decoration: const InputDecoration(labelText: 'Course'),
              ),
              TextField(
                controller: batchController,
                decoration: const InputDecoration(labelText: 'Batch'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                final updatedData = {
                  'id': student['id'],
                  'name': nameController.text,
                  'standard': standardController.text,
                  'course': courseController.text,
                  'batch': batchController.text,
                  'joinDate': student['joinDate'],
                };
                _editStudentDetail(student['id'], updatedData);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
            ElevatedButton(
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

  void _viewReport() {
    // You can customize this report view further
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filtered Student Report'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: filteredStudents.length,
              itemBuilder: (context, index) {
                final student = filteredStudents[index];
                return ListTile(
                  title: Text(
                    'Student Name: ${student['name']}\nStandard: ${student['standard']}\nCourse: ${student['course']}\nBatch: ${student['batch']}\nJoin Date: ${student['joinDate']}',
                  ),
                );
              },
            ),
          ),
          actions: [
            ElevatedButton(
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
        automaticallyImplyLeading: false,
        title: const Text('Student Detail Report'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
                _filterStudents(); // Filter students based on the search query
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(context, fromDate, (date) {
                      setState(() {
                        fromDate = date;
                      });
                      _filterStudents(); // Apply filter after selecting the from date
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        fromDate != null
                            ? DateFormat.yMMMd().format(fromDate!)
                            : 'From Date',
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(context, toDate, (date) {
                      setState(() {
                        toDate = date;
                      });
                      _filterStudents(); // Apply filter after selecting the to date
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        toDate != null
                            ? DateFormat.yMMMd().format(toDate!)
                            : 'To Date',
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed:
                      _filterStudents, // Filter data based on selected dates and search query
                  child: const Text('Get Data'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: filteredStudents.length,
                itemBuilder: (context, index) {
                  final student = filteredStudents[index];
                  return ListTile(
                    title: Text(student['name']),
                    subtitle: Text(
                        'Standard: ${student['standard']} | Course: ${student['course']} | Batch: ${student['batch']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            _showEditDialog(student);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _deleteStudentDetail(student['id']);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _viewReport, // View the filtered student report
              child: const Text('View Report'),
            ),
          ],
        ),
      ),
    );
  }
}

class StudentCardReportScreen extends StatefulWidget {
  const StudentCardReportScreen({super.key});

  @override
  _StudentCardReportScreenState createState() =>
      _StudentCardReportScreenState();
}

class _StudentCardReportScreenState extends State<StudentCardReportScreen> {
  String? _selectedClassBatch;
  List<dynamic> _classBatches = [];
  List<dynamic> _studentReports = [];
  List<dynamic> _filteredReports = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchClassBatches();
  }

  Future<void> _fetchClassBatches() async {
    final response = await http
        .get(Uri.parse('${AppConfig.baseUrl}/api/class-batch/classbatch'));
    if (response.statusCode == 200) {
      setState(() {
        _classBatches = json.decode(response.body);
      });
    } else {
      // Handle error
    }
  }

  Future<void> _fetchStudentReports() async {
    if (_selectedClassBatch != null) {
      final response = await http.get(Uri.parse(
          '${AppConfig.baseUrl}/api/cardReport/card-report$_selectedClassBatch'));
      if (response.statusCode == 200) {
        setState(() {
          _studentReports = json.decode(response.body);
          _filteredReports = _studentReports; // Initialize filtered reports
        });
      } else {
        // Handle error
      }
    }
  }

  void _searchStudents(String query) {
    final filtered = _studentReports.where((student) {
      final name = '${student['firstName']} ${student['lastName']}';
      return name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredReports = filtered;
    });
  }

  void _editStudent(String studentId) {
    // Implement your edit functionality here
    // Example: Navigate to Edit Student screen
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EditStudentScreen(studentId: studentId)),
    );
  }

  Future<void> _deleteStudent(String studentId) async {
    final response = await http.delete(
        Uri.parse('${AppConfig.baseUrl}/api/student/students/$studentId'));
    if (response.statusCode == 200) {
      // Refresh the reports after deletion
      _fetchStudentReports();
    } else {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Card Report'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Class Batch Dropdown
            DropdownButton<String>(
              value: _selectedClassBatch,
              hint: const Text('Select Class Batch'),
              isExpanded: true,
              items: _classBatches.map((batch) {
                return DropdownMenuItem<String>(
                  value: batch['classBatchName'],
                  child: Text(batch['classBatchName']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedClassBatch = value;
                  _studentReports.clear(); // Clear previous reports
                  _filteredReports.clear();
                });
                _fetchStudentReports();
              },
            ),
            const SizedBox(height: 16.0),

            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    _searchStudents(_searchController.text);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            // Student Card List
            Expanded(
              child: ListView.builder(
                itemCount: _filteredReports.length,
                itemBuilder: (context, index) {
                  final student = _filteredReports[index];
                  return StudentCard(
                    student: student,
                    onEdit: _editStudent,
                    onDelete: _deleteStudent,
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

// Custom widget for each student card
class StudentCard extends StatelessWidget {
  final dynamic student;
  final Function(String) onEdit;
  final Function(String) onDelete;

  const StudentCard({
    required this.student,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Student Name: ${student['firstName']} ${student['lastName']}'),
            Text('Standard: ${student['standard']}'),
            Text('Class Batch: ${student['classBatch']}'),
            Text('Join Date: ${student['joinDate']?.split('T')[0]}'),
            Text(
                'Attendance: ${_calculateAttendance(student['attendanceRecords'])}%'),

            // Edit and Delete buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => onEdit(student['_id']),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => onDelete(student['_id']),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _calculateAttendance(List<dynamic> attendanceRecords) {
    if (attendanceRecords.isEmpty) return 0.0;
    int presentCount = attendanceRecords
        .where((record) => record['status'] == 'Present')
        .length;
    return (presentCount / attendanceRecords.length) * 100;
  }
}

// Edit Student Screen Placeholder
class EditStudentScreen extends StatelessWidget {
  final String studentId;

  const EditStudentScreen({required this.studentId, super.key});

  @override
  Widget build(BuildContext context) {
    // Implement your Edit Student UI here
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Student')),
      body: Center(child: Text('Edit Student ID: $studentId')),
    );
  }
}

class StudentAttendanceReportScreen extends StatefulWidget {
  const StudentAttendanceReportScreen({super.key});

  @override
  _StudentAttendanceReportScreenState createState() =>
      _StudentAttendanceReportScreenState();
}

class _StudentAttendanceReportScreenState
    extends State<StudentAttendanceReportScreen> {
  DateTime? selectedDate;
  List<Map<String, dynamic>> allAttendanceData = [];
  List<Map<String, dynamic>> filteredAttendanceData = [];
  TextEditingController searchController = TextEditingController();

  // Method to fetch attendance data from API
  Future<void> _fetchAttendance(
      {String? searchQuery, DateTime? selectedDate}) async {
    try {
      String apiUrl = '${AppConfig.baseUrl}/api/attendance';

      // Build query parameters based on inputs (search query, date)
      Map<String, String> queryParams = {};
      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['name'] = searchQuery;
      }
      if (selectedDate != null) {
        queryParams['date'] =
            selectedDate.toIso8601String(); // Convert to ISO string
      }

      Uri uri = Uri.parse(apiUrl).replace(queryParameters: queryParams);

      // Make the HTTP GET request
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        List<Map<String, dynamic>> fetchedData =
            List<Map<String, dynamic>>.from(json.decode(response.body));

        setState(() {
          allAttendanceData = fetchedData;
          filteredAttendanceData = fetchedData; // Initially display all data
        });
      } else {
        throw Exception('Failed to load attendance data');
      }
    } catch (e) {
      print('Error fetching attendance data: $e');
      // Handle error (e.g., show a snackbar or message to user)
    }
  }

  // Method to select a date
  Future<void> _selectDate(BuildContext context, DateTime? initialDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != initialDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // Method to handle search
  void _handleSearch(String searchQuery) {
    setState(() {
      filteredAttendanceData = allAttendanceData.where((attendance) {
        final name = attendance['name'].toLowerCase();
        return name.contains(searchQuery.toLowerCase());
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchAttendance(); // Fetch all data when screen loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Student Attendance Report'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: searchController,
              onChanged: _handleSearch,
              decoration: const InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(context, selectedDate),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        selectedDate != null
                            ? DateFormat.yMMMd().format(selectedDate!)
                            : 'Select Date',
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    _fetchAttendance(
                      searchQuery: searchController.text,
                      selectedDate: selectedDate,
                    );
                  },
                  child: const Text('View Report'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('')),
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('STD')),
                    DataColumn(label: Text('Batch')),
                    DataColumn(label: Text('Attendance')),
                  ],
                  rows: List<DataRow>.generate(
                    filteredAttendanceData.length,
                    (index) => DataRow(
                      cells: [
                        DataCell(Text((index + 1).toString())),
                        DataCell(Text(filteredAttendanceData[index]['name'])),
                        DataCell(Text(filteredAttendanceData[index]['std'])),
                        DataCell(Text(filteredAttendanceData[index]['batch'])),
                        DataCell(
                            Text(filteredAttendanceData[index]['attendance'])),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
