import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting dates
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:testing_app/screens/config.dart';

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
        automaticallyImplyLeading : false,
        title: const Text('Fee Collection Report'),
      ),
       // Add your drawer here
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
                  onPressed: () {
                    // Handle Get Data action
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
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('STD')),
                    DataColumn(label: Text('Batch')),
                    DataColumn(label: Text('Amt')),
                  ],
                  rows: List<DataRow>.generate(
                    5, // Adjust the number based on your data
                        (index) => DataRow(
                      cells: [
                        DataCell(Text((index + 1).toString())),
                        DataCell(Text('Name $index')),
                        DataCell(Text('STD $index')),
                        DataCell(Text('Batch $index')),
                        DataCell(Text('Amt $index')),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Handle Export action
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Button color
              ),
              child: const Text('Export'),
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
        automaticallyImplyLeading : false,
        title: const Text('Expense Report'),
      ),
      // Add your drawer here
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
                  onPressed: () {
                    // Handle Get Data action
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
                    5, // Adjust the number based on your data
                        (index) => DataRow(
                      cells: [
                        DataCell(Text((index + 1).toString())),
                        DataCell(Text('Expense Type $index')),
                        DataCell(Text('Payment Mode $index')),
                        DataCell(Text('Date $index')),
                        DataCell(Text('Amount $index')),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Handle Export action
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Button color
              ),
              child: const Text('Export'),
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
        automaticallyImplyLeading : false,
        title: const Text('Income Report'),
      ),
      // Add your drawer here
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
                  onPressed: () {
                    // Handle Get Data action
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
                    5, // Adjust the number based on your data
                        (index) => DataRow(
                      cells: [
                        DataCell(Text((index + 1).toString())),
                        DataCell(Text('Income Type $index')),
                        DataCell(Text('Payment Mode $index')),
                        DataCell(Text('Date $index')),
                        DataCell(Text('Amount $index')),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Handle Export action
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Button color
              ),
              child: const Text('Export'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
              onPressed: () {
                // Handle Get Data action
              },
              child: const Text('Get Data'),
            ),
            const SizedBox(height: 32.0),
            Expanded(
              child: Column(
                children: [
                  // Placeholder for Pie Chart
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Pie Diagram Placeholder',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem(Colors.blue, 'Profit amount - XXXXX'),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem(Colors.black, 'Loss amount - XXXXX'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Handle Export action
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: const Text('Export'),
            ),
          ],
        ),
      ),
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
            maxLines: 2, // Allows wrapping to the next line
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
  List<String> users = ['User-1 Name', 'User-2 Name', 'User-3 Name'];

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
              onPressed: () {},
              child: const Text('Check App Access Rights'),
              style: ElevatedButton.styleFrom(foregroundColor: Colors.black, backgroundColor: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text('Check Rights:', style: TextStyle(fontWeight: FontWeight.bold)),
            RadioListTile(
              title: const Text('Check Admin Rights'),
              value: 'Admin',
              groupValue: selectedRights,
              onChanged: (value) => setState(() => selectedRights = value.toString()),
            ),
            RadioListTile(
              title: const Text('Check Teacher Rights'),
              value: 'Teacher',
              groupValue: selectedRights,
              onChanged: (value) => setState(() => selectedRights = value.toString()),
            ),
            RadioListTile(
              title: const Text('Check Student Rights'),
              value: 'Student',
              groupValue: selectedRights,
              onChanged: (value) => setState(() => selectedRights = value.toString()),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Check Rights'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            ),
            const SizedBox(height: 16),
            const Text('Users with Admin Rights:', style: TextStyle(fontWeight: FontWeight.bold)),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: users.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(child: Text('U${index + 1}')),
                  title: Text(users[index]),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: Icon(Icons.edit), onPressed: () {}),
                      IconButton(icon: Icon(Icons.delete), onPressed: () {}),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Update'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
            ),
          ],
        ),
      ),
    );
  }
}
