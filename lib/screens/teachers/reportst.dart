import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting dates

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
      case 'studentInquiry':
        return const StudentInquiryReportScreen();
      case 'studentDetail':
        return const StudentDetailReportScreen();
      case 'studentCard':
        return const StudentCardReportScreen();
      case 'studentAttendance':
        return const StudentAttendanceReportScreen();
      case 'pendingFee':
        return const PendingFeeReportScreen();
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
      case 'studentInquiryAnalysis':
        return const StudentInquiryAnalysisReportScreen();
      case 'feeAnalysis':
        return const FeeAnalysisReportScreen();
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
  _StudentInquiryReportScreenState createState() =>
      _StudentInquiryReportScreenState();
}

class _StudentInquiryReportScreenState
    extends State<StudentInquiryReportScreen> {
  DateTime? fromDate;
  DateTime? toDate;
  bool isSolved1 = false;
  bool isSolved2 = false;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Inquiry Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Handle settings action
            },
          ),
        ],
      ),
      drawer: const Drawer(), // Add your drawer here
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
                  onPressed: () {
                    // Handle Get Data action
                  },
                  child: const Text('Get Data'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    title: const Text(
                        'Student Name: XXXXXXX\nStandard: XX\nInquiry Date: XX/XX/XXXX\nInquiry Source: XXXXXXXX'),
                    trailing: IconButton(
                      icon: Icon(
                        isSolved1 ? Icons.check_circle : Icons.cancel,
                        color: isSolved1 ? Colors.green : Colors.red,
                      ),
                      onPressed: () {
                        setState(() {
                          isSolved1 = !isSolved1;
                        });
                      },
                    ),
                    subtitle: Text(isSolved1 ? 'Solved' : 'Unsolved'),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text(
                        'Student Name: XXXXXXX\nStandard: XX\nInquiry Date: XX/XX/XXXX\nInquiry Source: XXXXXXXX'),
                    trailing: IconButton(
                      icon: Icon(
                        isSolved2 ? Icons.check_circle : Icons.cancel,
                        color: isSolved2 ? Colors.green : Colors.red,
                      ),
                      onPressed: () {
                        setState(() {
                          isSolved2 = !isSolved2;
                        });
                      },
                    ),
                    subtitle: Text(isSolved2 ? 'Solved' : 'Unsolved'),
                  ),
                ],
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

class StudentDetailReportScreen extends StatefulWidget {
  const StudentDetailReportScreen({super.key});

  @override
  _StudentDetailReportScreenState createState() =>
      _StudentDetailReportScreenState();
}

class _StudentDetailReportScreenState extends State<StudentDetailReportScreen> {
  DateTime? fromDate;
  DateTime? toDate;

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

  void _editStudentDetail() {
    // Handle edit action
  }

  void _deleteStudentDetail() {
    // Handle delete action
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Detail Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Handle settings action
            },
          ),
        ],
      ),
      drawer: const Drawer(), // Add your drawer here
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
                  onPressed: () {
                    // Handle Get Data action
                  },
                  child: const Text('Get Data'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    title: const Text(
                        'Student Name: XXXXXXX\nStandard: XX\nCourse Name: XXXXXXX\nClass/Batch: XXXXXXX\nJoin Date: XX/XX/XXXX'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: _editStudentDetail,
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: _deleteStudentDetail,
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text(
                        'Student Name: XXXXXXX\nStandard: XX\nCourse Name: XXXXXXX\nClass/Batch: XXXXXXX\nJoin Date: XX/XX/XXXX'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: _editStudentDetail,
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: _deleteStudentDetail,
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text(
                        'Student Name: XXXXXXX\nStandard: XX\nCourse Name: XXXXXXX\nClass/Batch: XXXXXXX\nJoin Date: XX/XX/XXXX'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: _editStudentDetail,
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: _deleteStudentDetail,
                        ),
                      ],
                    ),
                  ),
                ],
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

class StudentCardReportScreen extends StatefulWidget {
  const StudentCardReportScreen({super.key});

  @override
  _StudentCardReportScreenState createState() =>
      _StudentCardReportScreenState();
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
  _StudentAttendanceReportScreenState createState() =>
      _StudentAttendanceReportScreenState();
}

class _StudentAttendanceReportScreenState
    extends State<StudentAttendanceReportScreen> {
  DateTime? fromDate;
  DateTime? toDate;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Attendance Report'),
      ),
      drawer: const Drawer(), // Add your drawer here
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
                    DataColumn(label: Text('Attendance')),
                  ],
                  rows: List<DataRow>.generate(
                    5, // Adjust the number based on your data
                        (index) => DataRow(
                      cells: [
                        DataCell(Text((index + 1).toString())),
                        DataCell(Text('Name $index')),
                        DataCell(Text('STD $index')),
                        DataCell(Text('Batch $index')),
                        DataCell(Text('Attendance $index')),
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

class PendingFeeReportScreen extends StatefulWidget {
  const PendingFeeReportScreen({super.key});

  @override
  _PendingFeeReportScreenState createState() => _PendingFeeReportScreenState();
}

class _PendingFeeReportScreenState extends State<PendingFeeReportScreen> {
  DateTime? fromDate;
  DateTime? toDate;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Installment Fee Report'),
      ),
      drawer: const Drawer(), // Add your drawer here
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

class FeeStatusReportScreen extends StatelessWidget {
  const FeeStatusReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Variable to hold the selected date
    DateTime? selectedDate;

    // Function to show the date picker and update the selected date
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
        title: const Text('Fee Status Report'),
      ),
      body: Padding(
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
  _FeeCollectionReportScreenState createState() =>
      _FeeCollectionReportScreenState();
}

class _FeeCollectionReportScreenState extends State<FeeCollectionScreen> {
  DateTime? fromDate;
  DateTime? toDate;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fee Collection Report'),
      ),
      drawer: const Drawer(), // Add your drawer here
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

class ExpenseReportScreen extends StatelessWidget {
  const ExpenseReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Expense Report Screen'));
  }
}

class IncomeReportScreen extends StatelessWidget {
  const IncomeReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Income Report Screen'));
  }
}

class ProfitLossReportScreen extends StatelessWidget {
  const ProfitLossReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Profit/Loss Report Screen'));
  }
}

class StudentInquiryAnalysisReportScreen extends StatelessWidget {
  const StudentInquiryAnalysisReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Student Inquiry Analysis Report Screen'));
  }
}

class FeeAnalysisReportScreen extends StatelessWidget {
  const FeeAnalysisReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Fee Analysis Report Screen'));
  }
}

class AppAccessRightsScreen extends StatelessWidget {
  const AppAccessRightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('App Access Rights Screen'));
  }
}