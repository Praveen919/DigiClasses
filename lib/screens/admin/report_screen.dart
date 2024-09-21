import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting dates
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:testing_app/screens/config.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportScreen extends StatefulWidget {
  final String option;

  const ReportScreen({super.key, required this.option});

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
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
      case 'studentInquiry':
        return const StudentInquiryReportScreen();
      case 'studentDetail':
        return const StudentDetailReportScreen();
      case 'studentCard':
        return const StudentCardReportScreen();
      case 'studentAttendance':
        return const StudentAttendanceReportScreen();
      case 'feeStatus':
        return const FeeStatusReportScreen();
      case 'feeCollection':
        return const FeeCollectionScreen();
      case 'expense':
        return const ExpenseReportScreen();
      case 'income':
        return const IncomeReportScreen();
      case 'profitLoss':
        return const ProfitLossReportScreen();
      case 'appAccessRights':
        return const AppAccessRightsScreen();
      default:
        return const Center(child: Text('Unknown Option'));
    }
  }
}

// Below are the placeholder widgets for each report screen.
// Replace these with your actual implementation.

class StudentInquiryReportScreen extends StatefulWidget {
  const StudentInquiryReportScreen({super.key});

  @override
  _StudentInquiryReportScreenState createState() => _StudentInquiryReportScreenState();
}

class _StudentInquiryReportScreenState extends State<StudentInquiryReportScreen> {
  DateTime? fromDate;
  DateTime? toDate;
  TextEditingController searchController = TextEditingController();
  bool isLoading = false;
  List<Map<String, dynamic>> inquiries = []; // Store inquiries data

  // Method to select a date
  Future<void> _selectDate(BuildContext context, DateTime? initialDate, Function(DateTime) onDateSelected) async {
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

  // Method to fetch data from the database
  Future<void> _getInquiries() async {
    setState(() {
      isLoading = true;
    });

    // Fetch the data based on the fromDate and toDate
    final results = await fetchInquiriesFromDB(fromDate, toDate, searchController.text);

    setState(() {
      inquiries = results;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Student Inquiry Report'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            TextFormField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _getInquiries(); // Search filter when typing
              },
            ),
            const SizedBox(height: 16),
            // Date pickers
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(context, fromDate, (date) {
                      setState(() {
                        fromDate = date;
                      });
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        fromDate != null ? DateFormat.yMMMd().format(fromDate!) : 'From Date',
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
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        toDate != null ? DateFormat.yMMMd().format(toDate!) : 'To Date',
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _getInquiries,
                  child: const Text('Get Data'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Inquiry list
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
              child: inquiries.isNotEmpty
                  ? ListView.builder(
                itemCount: inquiries.length,
                itemBuilder: (context, index) {
                  final inquiry = inquiries[index];
                  return ListTile(
                    title: Text('Student Name: ${inquiry['studentName']}\nStandard: ${inquiry['standard']}\nInquiry Date: ${inquiry['inquiryDate']}\nInquiry Source: ${inquiry['inquirySource']}'),
                    subtitle: Text(inquiry['status'] ? 'Solved' : 'Unsolved'),
                    trailing: Icon(
                      inquiry['status'] ? Icons.check_circle : Icons.cancel,
                      color: inquiry['status'] ? Colors.green : Colors.red,
                    ),
                  );
                },
              )
                  : const Center(child: Text('No inquiries found')),
            ),
            const SizedBox(height: 16),
            // View Report button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Handle view report action
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Button color
                ),
                child: const Text('View Report'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to fetch inquiries from the database
  Future<List<Map<String, dynamic>>> fetchInquiriesFromDB(DateTime? fromDate, DateTime? toDate, String search) async {
    const String apiUrl = '${AppConfig.baseUrl}/inquiries'; // Replace with your actual API endpoint

    try {
      // Create query parameters
      Map<String, String> queryParams = {
        'search': search,
        'fromDate': fromDate != null ? DateFormat('yyyy-MM-dd').format(fromDate) : '',
        'toDate': toDate != null ? DateFormat('yyyy-MM-dd').format(toDate) : '',
      };

      // Make the HTTP GET request
      final response = await http.get(Uri.parse('$apiUrl?${Uri(queryParameters: queryParams).query}'));

      if (response.statusCode == 200) {
        // Parse the JSON response
        List<dynamic> data = json.decode(response.body);

        // Convert JSON data to a list of maps
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to load inquiries');
      }
    } catch (e) {
      print('Error fetching inquiries: $e');
      return [];
    }
  }
}

class StudentDetailReportScreen extends StatefulWidget {
  const StudentDetailReportScreen({super.key});

  @override
  _StudentDetailReportScreenState createState() => _StudentDetailReportScreenState();
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
    final response = await http.get(Uri.parse('${AppConfig.baseUrl}/api/students'));
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
  Future<void> _selectDate(BuildContext context, DateTime? initialDate, Function(DateTime) onDateSelected) async {
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
        bool matchesSearchQuery = student['name']
            .toLowerCase()
            .contains(searchQuery.toLowerCase());

        bool matchesFromDate = fromDate == null ||
            DateTime.parse(student['joinDate']).isAfter(fromDate!);

        bool matchesToDate = toDate == null ||
            DateTime.parse(student['joinDate']).isBefore(toDate!);

        return matchesSearchQuery && matchesFromDate && matchesToDate;
      }).toList();
    });
  }

  Future<void> _editStudentDetail(int studentId, Map<String, dynamic> updatedData) async {
    final response = await http.put(
      Uri.parse('${AppConfig.baseUrl}/api/students/$studentId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updatedData),
    );

    if (response.statusCode == 200) {
      setState(() {
        // Update the local students list with the new data
        final index = students.indexWhere((student) => student['id'] == studentId);
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
    final response = await http.delete(Uri.parse('${AppConfig.baseUrl}/api/students/$studentId'));

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
    TextEditingController nameController = TextEditingController(text: student['name']);
    TextEditingController standardController = TextEditingController(text: student['standard']);
    TextEditingController courseController = TextEditingController(text: student['course']);
    TextEditingController batchController = TextEditingController(text: student['batch']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Student'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Student Name'),
              ),
              TextField(
                controller: standardController,
                decoration: InputDecoration(labelText: 'Standard'),
              ),
              TextField(
                controller: courseController,
                decoration: InputDecoration(labelText: 'Course'),
              ),
              TextField(
                controller: batchController,
                decoration: InputDecoration(labelText: 'Batch'),
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
              child: Text('Save'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
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
          title: Text('Filtered Student Report'),
          content: Container(
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
              child: Text('Close'),
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
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        fromDate != null ? DateFormat.yMMMd().format(fromDate!) : 'From Date',
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
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        toDate != null ? DateFormat.yMMMd().format(toDate!) : 'To Date',
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _filterStudents, // Filter data based on selected dates and search query
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
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            _showEditDialog(student);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
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
              child: Text('View Report'),
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
  _StudentCardReportScreenState createState() => _StudentCardReportScreenState();
}

class _StudentCardReportScreenState extends State<StudentCardReportScreen> {
  DateTime? _fromDate;
  DateTime? _toDate;

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != (isFromDate ? _fromDate : _toDate)) {
      setState(() {
        if (isFromDate) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading : false,
        title: const Text('Student Card Report'),
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

            // From Date and To Date
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, true),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'From Date',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _fromDate != null
                            ? "${_fromDate!.toLocal()}".split(' ')[0]
                            : 'Select Date',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, false),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'To Date',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _toDate != null
                            ? "${_toDate!.toLocal()}".split(' ')[0]
                            : 'Select Date',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),

            // Student Card List
            Expanded(
              child: ListView.builder(
                itemCount: 2, // Replace with actual number of students
                itemBuilder: (context, index) {
                  return const StudentCard(
                    // Pass student data here
                  );
                },
              ),
            ),

            // Export Button
            ElevatedButton(
              onPressed: () {
                // Implement export functionality here
              },
              child: const Text('Export'),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom widget for each student card
class StudentCard extends StatelessWidget {
  const StudentCard({super.key});

  // Add necessary properties for student data

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student Name, Standard, Batch, etc.
            const Text('Student Name: XXXXXX'),
            const Text('Standard: XX'),
            const Text('Batch: XX'),
            const Text('Attendance: XX%'),
            const Text('Join Date: XX/XX/XX'),

            // Edit and Delete buttons
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // Implement edit functionality
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    // Implement delete functionality
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class StudentAttendanceReportScreen extends StatefulWidget {
  const StudentAttendanceReportScreen({super.key});

  @override
  _StudentAttendanceReportScreenState createState() => _StudentAttendanceReportScreenState();
}

class _StudentAttendanceReportScreenState extends State<StudentAttendanceReportScreen> {
  DateTime? selectedDate;
  List<Map<String, dynamic>> allAttendanceData = [];
  List<Map<String, dynamic>> filteredAttendanceData = [];
  TextEditingController searchController = TextEditingController();

  // Method to fetch attendance data from API
  Future<void> _fetchAttendance({String? searchQuery, DateTime? selectedDate}) async {
    try {
      String apiUrl = '${AppConfig.baseUrl}/api/attendance';

      // Build query parameters based on inputs (search query, date)
      Map<String, String> queryParams = {};
      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['name'] = searchQuery;
      }
      if (selectedDate != null) {
        queryParams['date'] = selectedDate.toIso8601String(); // Convert to ISO string
      }

      Uri uri = Uri.parse(apiUrl).replace(queryParameters: queryParams);

      // Make the HTTP GET request
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        List<Map<String, dynamic>> fetchedData = List<Map<String, dynamic>>.from(json.decode(response.body));

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
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        selectedDate != null ? DateFormat.yMMMd().format(selectedDate!) : 'Select Date',
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
                        DataCell(Text(filteredAttendanceData[index]['attendance'])),
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


class FeeStatusReportScreen extends StatelessWidget {
  const FeeStatusReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    DateTime? selectedDate;

    Future<void> selectDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate ?? DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );
      if (picked != null && picked != selectedDate) {
        selectedDate = picked;
      }
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Fee Status Report'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student Name
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Student Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),

            // Standard
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Standard',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),

            // Course Type
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Course Type',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),

            // Roll No
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Roll No',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),

            // Attendance Date
            GestureDetector(
              onTap: () => selectDate(context),
              child: AbsorbPointer(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Attendance Date',
                    hintText: selectedDate != null
                        ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                        : 'Select Date',
                    border: const OutlineInputBorder(),
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            // GR. No
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'GR. No',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),

            // Category
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),

            // Group
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Group',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32.0),

            // Search Button
            ElevatedButton(
              onPressed: () {
                // Implement search functionality here
              },
              child: const Text('Search'),
            ),
          ],
        ),
      ),
    );
  }
}

class FeeCollectionScreen extends StatefulWidget {
  const FeeCollectionScreen({super.key});

  @override
  _FeeCollectionReportScreenState createState() => _FeeCollectionReportScreenState();
}

class _FeeCollectionReportScreenState extends State<FeeCollectionScreen> {
  DateTime? fromDate;
  DateTime? toDate;
  List<Map<String, dynamic>> studentData = []; // Student data from the database
  List<Map<String, dynamic>> filteredData = []; // Filtered data after search or date selection
  String searchQuery = ''; // Current search query
  bool isEditable = false; // Controls whether data is editable

  // Method to select a date
  Future<void> _selectDate(BuildContext context, DateTime? initialDate, Function(DateTime) onDateSelected) async {
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

  Future<void> _fetchData() async {
    if (fromDate != null && toDate != null) {
      // Format dates
      final formattedFromDate = DateFormat('yyyy-MM-dd').format(fromDate!);
      final formattedToDate = DateFormat('yyyy-MM-dd').format(toDate!);

      try {
        // API call to fetch data from the server based on date range
        final response = await http.get(
          Uri.parse('${AppConfig.baseUrl}/api/feeCollection/fees?fromDate=$formattedFromDate&toDate=$formattedToDate'),
        );

        if (response.statusCode == 200) {
          // Parse the response JSON into a list
          final List<dynamic> data = json.decode(response.body);

          setState(() {
            // Cast the data into a List<Map<String, dynamic>> explicitly
            studentData = List<Map<String, dynamic>>.from(data);
            _filterData(); // Call your filtering method
          });
        } else {
          print('Error fetching data: ${response.statusCode}');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to fetch data')),
          );
        }
      } catch (error) {
        print('Error fetching data: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error fetching data')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both From and To dates')),
      );
    }
  }

  // Filter data based on search query
  void _filterData() {
    setState(() {
      filteredData = studentData.where((student) {
        final name = student['name']?.toString().toLowerCase() ?? '';
        final std = student['std']?.toString().toLowerCase() ?? '';
        final batch = student['batch']?.toString().toLowerCase() ?? '';
        final query = searchQuery.toLowerCase();

        return name.contains(query) || std.contains(query) || batch.contains(query);
      }).toList();
    });
  }

  Future<void> _updateData() async {
    try {
      // Loop through filteredData (updated student data) and send it to the database
      for (var student in filteredData) {
        // Example of an API call for each student update
        final response = await http.put(
          Uri.parse('${AppConfig.baseUrl}/api/feeCollection/updateStudent'),  // Make sure this URL is correct
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: json.encode({
            '_id': student['id'],                       // Use '_id' if that's what your backend expects
            'totalFees': student['totalFees'],         // Data being updated
            'discountedFees': student['discountedFees'],
            'amtPaid': student['amtPaid'],
            'date': student['date'],                   // Updated date field
          }),
        );

        if (response.statusCode == 200) {
          // Successfully updated the student data
          print('Student updated: ${student['id']}');
        } else {
          // Handle server errors
          print('Failed to update student: ${student['id']}');
        }
      }

      // Show a success message after all updates
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data updated successfully')),
      );
    } catch (error) {
      print('Error updating data: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error updating data')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Fee Collection Report'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                  _filterData(); // Filter the data based on the search query
                });
              },
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
                    onTap: () => _selectDate(context, fromDate, (date) {
                      setState(() {
                        fromDate = date;
                      });
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        fromDate != null ? DateFormat.yMMMd().format(fromDate!) : 'From Date',
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
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        toDate != null ? DateFormat.yMMMd().format(toDate!) : 'To Date',
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _fetchData, // Fetch data when button is clicked
                  child: const Text('Get Data'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Sr. No')),
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('STD')),
                    DataColumn(label: Text('Batch')),
                    DataColumn(label: Text('Total Fees')),
                    DataColumn(label: Text('Discounted Fees')),
                    DataColumn(label: Text('Amt Paid')),
                    DataColumn(label: Text('Date')),
                  ],
                  rows: List<DataRow>.generate(
                    filteredData.length,
                        (index) => DataRow(
                      cells: [
                        DataCell(Text((index + 1).toString())),
                        DataCell(Text(filteredData[index]['name'])),
                        DataCell(Text(filteredData[index]['std'])),
                        DataCell(Text(filteredData[index]['batch'])),
                        DataCell(
                          isEditable
                              ? TextFormField(
                            initialValue: filteredData[index]['totalFees'].toString(),
                            onChanged: (value) {
                              setState(() {
                                filteredData[index]['totalFees'] = int.tryParse(value) ?? filteredData[index]['totalFees'];
                              });
                            },
                          )
                              : Text(filteredData[index]['totalFees'].toString()),
                        ),
                        DataCell(
                          isEditable
                              ? TextFormField(
                            initialValue: filteredData[index]['discountedFees'].toString(),
                            onChanged: (value) {
                              setState(() {
                                filteredData[index]['discountedFees'] = int.tryParse(value) ?? filteredData[index]['discountedFees'];
                              });
                            },
                          )
                              : Text(filteredData[index]['discountedFees'].toString()),
                        ),
                        DataCell(
                          isEditable
                              ? TextFormField(
                            initialValue: filteredData[index]['amtPaid'].toString(),
                            onChanged: (value) {
                              setState(() {
                                filteredData[index]['amtPaid'] = int.tryParse(value) ?? filteredData[index]['amtPaid'];
                              });
                            },
                          )
                              : Text(filteredData[index]['amtPaid'].toString()),
                        ),
                        DataCell(
                          isEditable
                              ? GestureDetector(
                            onTap: () => _selectDate(context, DateTime.parse(filteredData[index]['date']), (date) {
                              setState(() {
                                filteredData[index]['date'] = DateFormat('yyyy-MM-dd').format(date);
                              });
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                filteredData[index]['date'],
                                style: const TextStyle(color: Colors.black87),
                              ),
                            ),
                          )
                              : Text(filteredData[index]['date']),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isEditable = !isEditable; // Toggle the edit mode
                    });
                  },
                  child: Text(isEditable ? 'Cancel' : 'Edit'),
                ),
                ElevatedButton(
                  onPressed: _updateData, // Save the updated data
                  child: const Text('Update'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ExpenseReportScreen extends StatefulWidget {
  const ExpenseReportScreen({super.key});

  @override
  _ExpenseReportScreenState createState() => _ExpenseReportScreenState();
}

class _ExpenseReportScreenState extends State<ExpenseReportScreen> {
  DateTime? fromDate;
  DateTime? toDate;
  List<dynamic> expenseData = [];
  List<dynamic> filteredData = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // Method to fetch data from the database
  Future<void> _fetchData() async {
    try {
      final response = await http.get(Uri.parse('${AppConfig.baseUrl}/api/expenses/expenses'));
      if (response.statusCode == 200) {
        setState(() {
          expenseData = json.decode(response.body);
          filteredData = expenseData;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  // Method to filter data based on dates and search query
  void _filterData() {
    setState(() {
      filteredData = expenseData.where((expense) {
        final expenseDate = DateTime.parse(expense['date']);
        final isInDateRange = (fromDate == null || expenseDate.isAfter(fromDate!) || expenseDate.isAtSameMomentAs(fromDate!)) &&
            (toDate == null || expenseDate.isBefore(toDate!) || expenseDate.isAtSameMomentAs(toDate!));
        final matchesSearchQuery = expense['expenseType'].toLowerCase().contains(searchQuery.toLowerCase());
        return isInDateRange && matchesSearchQuery;
      }).toList();
    });
  }

  // Method to select a date
  Future<void> _selectDate(BuildContext context, DateTime? initialDate, Function(DateTime) onDateSelected) async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Expense Report'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                  _filterData();
                });
              },
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
                    onTap: () => _selectDate(context, fromDate, (date) {
                      setState(() {
                        fromDate = date;
                      });
                      _filterData();
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        fromDate != null ? DateFormat.yMMMd().format(fromDate!) : 'From Date',
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
                      _filterData();
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        toDate != null ? DateFormat.yMMMd().format(toDate!) : 'To Date',
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    _filterData(); // Filter data on button click
                  },
                  child: const Text('Get Data'),
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
                    DataColumn(label: Text('Expense Type')),
                    DataColumn(label: Text('Payment Mode')),
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Amount')),
                  ],
                  rows: List<DataRow>.generate(
                    filteredData.length,
                        (index) => DataRow(
                      cells: [
                        DataCell(Text((index + 1).toString())),
                        DataCell(Text(filteredData[index]['expenseType'])),
                        DataCell(Text(filteredData[index]['paymentMode'])),
                        DataCell(Text(filteredData[index]['date'])),
                        DataCell(Text(filteredData[index]['amount'].toString())),
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

class IncomeReportScreen extends StatefulWidget {
  const IncomeReportScreen({super.key});

  @override
  _IncomeReportScreenState createState() => _IncomeReportScreenState();
}

class _IncomeReportScreenState extends State<IncomeReportScreen> {
  DateTime? fromDate;
  DateTime? toDate;
  List<dynamic> incomeData = [];
  List<dynamic> filteredData = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // Method to fetch data from the database
  Future<void> _fetchData() async {
    try {
      final response = await http.get(Uri.parse('${AppConfig.baseUrl}/api/expenses/incomes'));
      if (response.statusCode == 200) {
        setState(() {
          incomeData = json.decode(response.body);
          filteredData = incomeData;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  // Method to filter data based on dates and search query
  void _filterData() {
    setState(() {
      filteredData = incomeData.where((income) {
        final incomeDate = DateTime.parse(income['date']);
        final isInDateRange = (fromDate == null || incomeDate.isAfter(fromDate!) || incomeDate.isAtSameMomentAs(fromDate!)) &&
            (toDate == null || incomeDate.isBefore(toDate!) || incomeDate.isAtSameMomentAs(toDate!));
        final matchesSearchQuery = income['incomeType'].toLowerCase().contains(searchQuery.toLowerCase());
        return isInDateRange && matchesSearchQuery;
      }).toList();
    });
  }

  // Method to select a date
  Future<void> _selectDate(BuildContext context, DateTime? initialDate, Function(DateTime) onDateSelected) async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Income Report'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                  _filterData();
                });
              },
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
                    onTap: () => _selectDate(context, fromDate, (date) {
                      setState(() {
                        fromDate = date;
                      });
                      _filterData();
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        fromDate != null ? DateFormat.yMMMd().format(fromDate!) : 'From Date',
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
                      _filterData();
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        toDate != null ? DateFormat.yMMMd().format(toDate!) : 'To Date',
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    _filterData(); // Filter data on button click
                  },
                  child: const Text('Get Data'),
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
                    DataColumn(label: Text('Income Type')),
                    DataColumn(label: Text('Payment Mode')),
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Amount')),
                  ],
                  rows: List<DataRow>.generate(
                    filteredData.length,
                        (index) => DataRow(
                      cells: [
                        DataCell(Text((index + 1).toString())),
                        DataCell(Text(filteredData[index]['incomeType'])),
                        DataCell(Text(filteredData[index]['paymentMode'])),
                        DataCell(Text(filteredData[index]['date'])),
                        DataCell(Text(filteredData[index]['amount'].toString())),
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

class ProfitLossReportScreen extends StatefulWidget {
  const ProfitLossReportScreen({super.key});

  @override
  _ProfitLossReportScreenState createState() => _ProfitLossReportScreenState();
}

class _ProfitLossReportScreenState extends State<ProfitLossReportScreen> {
  DateTime? _fromDate;
  DateTime? _toDate;
  double totalIncome = 0;
  double totalExpense = 0;

  Future<void> _selectFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fromDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _fromDate) {
      setState(() {
        _fromDate = picked;
      });
    }
  }

  Future<void> _selectToDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _toDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _toDate) {
      setState(() {
        _toDate = picked;
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select Date';
    return DateFormat('MMMM dd, yyyy').format(date);
  }

  Future<void> _fetchData() async {
    if (_fromDate != null && _toDate != null) {
      final formattedFromDate = _fromDate!.toIso8601String();
      final formattedToDate = _toDate!.toIso8601String();

      // Fetch income data
      final incomeResponse = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/expenses/incomes?from=$formattedFromDate&to=$formattedToDate'),
      );
      if (incomeResponse.statusCode == 200) {
        final incomeData = json.decode(incomeResponse.body);
        totalIncome = incomeData.fold(0, (sum, item) => sum + item['amount']); // Adjust based on your data structure
      }

      // Fetch expense data
      final expenseResponse = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/expenses/expenses?from=$formattedFromDate&to=$formattedToDate'),
      );
      if (expenseResponse.statusCode == 200) {
        final expenseData = json.decode(expenseResponse.body);
        totalExpense = expenseData.fold(0, (sum, item) => sum + item['amount']); // Adjust based on your data structure
      }

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Aligns elements to the left
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Search',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('From Date:'),
                    const SizedBox(height: 8.0),
                    GestureDetector(
                      onTap: () => _selectFromDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(_formatDate(_fromDate)),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('To Date:'),
                    const SizedBox(height: 8.0),
                    GestureDetector(
                      onTap: () => _selectToDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(_formatDate(_toDate)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _fetchData,
              child: const Text('Get Data'),
            ),
            const SizedBox(height: 32.0),
            totalIncome == 0 && totalExpense == 0
                ? const Center(child: Text('No data available'))
                : Column(
              children: [
                SizedBox(
                  height: 200, // Define height for the PieChart
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          value: totalIncome,
                          title: 'Profit: \$${totalIncome.toStringAsFixed(2)}',
                          color: Colors.green,
                          radius: 60,
                        ),
                        PieChartSectionData(
                          value: totalExpense,
                          title: 'Loss: \$${totalExpense.toStringAsFixed(2)}',
                          color: Colors.red,
                          radius: 60,
                        ),
                      ],
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 0,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                _buildLegend(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Column(
      children: [
        _buildLegendItem(Colors.green, 'Profit: \$${totalIncome.toStringAsFixed(2)}'),
        const SizedBox(height: 8.0),
        _buildLegendItem(Colors.red, 'Loss: \$${totalExpense.toStringAsFixed(2)}'),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12.0,
          height: 12.0,
          color: color,
        ),
        const SizedBox(width: 8.0),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}


class AppAccessRightsScreen extends StatefulWidget {
  const AppAccessRightsScreen({Key? key}) : super(key: key);

  @override
  _AppAccessRightsScreenState createState() => _AppAccessRightsScreenState();
}

class _AppAccessRightsScreenState extends State<AppAccessRightsScreen> {
  String selectedRights = 'Admin';
  List<Map<String, dynamic>> users = []; // Changed to hold user data
  bool isLoading = false;

  Future<void> _fetchUsers() async {
    setState(() {
      isLoading = true;
    });

    final response = await http.get(Uri.parse('${AppConfig.baseUrl}/api/auth?role=$selectedRights'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      users = List<Map<String, dynamic>>.from(data);
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _deleteUser(String userId) async {
    final response = await http.delete(Uri.parse('${AppConfig.baseUrl}/api/auth/$userId'));

    if (response.statusCode == 200) {
      setState(() {
        users.removeWhere((user) => user['id'] == userId);
      });
    }
  }

  Future<void> _updateUserRole(String userId, String newRole) async {
    final response = await http.put(
      Uri.parse('${AppConfig.baseUrl}/api/auth/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'role': newRole}),
    );

    if (response.statusCode == 200) {
      setState(() {
        final index = users.indexWhere((user) => user['id'] == userId);
        if (index != -1) {
          users[index]['role'] = newRole; // Update locally
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'App Access Rights',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _fetchUsers();
              },
              child: const Text('Check App Access Rights'),
              style: ElevatedButton.styleFrom(foregroundColor: Colors.black, backgroundColor: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text('Check Rights:', style: TextStyle(fontWeight: FontWeight.bold)),
            RadioListTile(
              title: const Text('Check Admin Rights'),
              value: 'Admin',
              groupValue: selectedRights,
              onChanged: (value) => setState(() {
                selectedRights = value.toString();
                _fetchUsers(); // Fetch users when the radio button is changed
              }),
            ),
            RadioListTile(
              title: const Text('Check Teacher Rights'),
              value: 'Teacher',
              groupValue: selectedRights,
              onChanged: (value) => setState(() {
                selectedRights = value.toString();
                _fetchUsers(); // Fetch users when the radio button is changed
              }),
            ),
            RadioListTile(
              title: const Text('Check Student Rights'),
              value: 'Student',
              groupValue: selectedRights,
              onChanged: (value) => setState(() {
                selectedRights = value.toString();
                _fetchUsers(); // Fetch users when the radio button is changed
              }),
            ),
            const SizedBox(height: 16),
            const Text('Users with Rights:', style: TextStyle(fontWeight: FontWeight.bold)),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (users.isEmpty)
              const Center(child: Text('No users found'))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return ListTile(
                    leading: CircleAvatar(child: Text('U${index + 1}')),
                    title: Text(user['name']),
                    subtitle: Text('Role: ${user['role']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            // Show a dialog to edit the role
                            _showEditRoleDialog(user['id'], user['role']);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _deleteUser(user['id']);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Implement any additional functionality here
              },
              child: const Text('Update'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditRoleDialog(String userId, String currentRole) {
    String newRole = currentRole; // Default to current role
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit User Role'),
          content: DropdownButton<String>(
            value: newRole,
            items: <String>['Admin', 'Teacher', 'Student'].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? value) {
              if (value != null) {
                newRole = value;
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                _updateUserRole(userId, newRole);
                Navigator.of(context).pop();
              },
              child: const Text('Update'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
