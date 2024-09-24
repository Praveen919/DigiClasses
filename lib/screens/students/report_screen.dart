import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:testing_app/screens/config.dart';
import 'package:testing_app/screens/students/help_screen.dart';

// User model and AuthProvider
class User {
  final String id;

  User({required this.id});
}

class AuthProvider with ChangeNotifier {
  User? _currentUser;

  User? get currentUser => _currentUser;

  void login(String userId) {
    _currentUser = User(id: userId);
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  static AuthProvider of(BuildContext context) {
    return Provider.of<AuthProvider>(context, listen: false);
  }
}

// ReportScreen to show report options
class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Options'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('View My Detailed Report'),
            onTap: () {
              String studentId = AuthProvider.of(context).currentUser?.id ?? '';
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ViewDetailReportScreen(studentId: studentId),
                ),
              );
            },
          ),
          /*ListTile(
            title: const Text('View My Card Report'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ViewMyCardReport(),
                ),
              );
            },
          ),*/
          ListTile(
            title: const Text('View My Attendance Report'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ViewMyAttendanceReport(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// View Detail Report Screen
class ViewDetailReportScreen extends StatefulWidget {
  final String studentId;

  const ViewDetailReportScreen({super.key, required this.studentId});

  @override
  _ViewDetailReportScreenState createState() => _ViewDetailReportScreenState();
}

class _ViewDetailReportScreenState extends State<ViewDetailReportScreen> {
  StudentReport? _report;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStudentReport();
  }

  Future<void> fetchStudentReport() async {
    final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/students/${widget.studentId}'));

    if (response.statusCode == 200) {
      setState(() {
        _report = StudentReport.fromJson(json.decode(response.body));
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      // Optionally show an error message
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Detailed Report'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_report == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Detailed Report'),
        ),
        body: const Center(child: Text('No report available.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Detailed Report'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Student Information',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8.0),
            Text('Name: ${_report!.studentName}'),
            Text('Standard: ${_report!.classSection}'),
            Text('Batch: ${_report!.classBatch}'),
            Text('Course: ${_report!.courseName}'),
            Text('Join Date: ${_report!.joinDate}'),
            const SizedBox(height: 16.0),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const HelpScreen()), // Navigate to your existing HelpScreen
                );
              },
              child: const Text('Need Help? Contact Support'),
            ),
          ],
        ),
      ),
    );
  }
}

// Student Report Model
class StudentReport {
  final String studentName;
  final String classSection;
  final String classBatch;
  final String courseName;
  final String joinDate;

  StudentReport({
    required this.studentName,
    required this.classSection,
    required this.classBatch,
    required this.courseName,
    required this.joinDate,
  });

  factory StudentReport.fromJson(Map<String, dynamic> json) {
    return StudentReport(
      studentName: json['studentName'],
      classSection: json['classSection'],
      classBatch: json['classBatch'],
      courseName: json['courseName'],
      joinDate: json['joinDate'],
    );
  }
}

/*class ViewMyCardReport extends StatelessWidget {
  const ViewMyCardReport({super.key});

  // Define the card report data as a static constant
  static const StudentCardReport cardReport = StudentCardReport(
    studentName: 'John Doe',
    rollNumber: '12345',
    classSection: '10-A',
    performanceSummary: 'Overall performance is good with some areas for improvement.',
    grades: [
      {'subject': 'Math', 'grade': 'A'},
      {'subject': 'Science', 'grade': 'B'},
      {'subject': 'English', 'grade': 'A'},
      {'subject': 'History', 'grade': 'B'},
    ],
    comments: 'John has shown improvement in Mathematics and is encouraged to focus on Science.',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Card Report'),
      ),
      body: SingleChildScrollView(  // Added SingleChildScrollView
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Student Information',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8.0),
            Text('Name: ${cardReport.studentName}'),
            Text('Roll Number: ${cardReport.rollNumber}'),
            Text('Class/Section: ${cardReport.classSection}'),
            const SizedBox(height: 16.0),

            Text(
              'Performance Summary',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8.0),
            Text(cardReport.performanceSummary),
            const SizedBox(height: 16.0),

            Text(
              'Grades',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8.0),
            for (var grade in cardReport.grades)
              ListTile(
                title: Text(grade['subject'] ?? 'Unknown Subject'),
                trailing: Text('Grade: ${grade['grade'] ?? 'N/A'}'),
              ),
            const SizedBox(height: 16.0),

            Text(
              'Teacher\'s Comments',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8.0),
            Text(cardReport.comments),

            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Handle download or export
              },
              child: const Text('Download Report'),
            ),
            const SizedBox(height: 16.0),

            TextButton(
              onPressed: () {
                // Navigate to contact or help screen
              },
              child: const Text('Need Help? Contact Support'),
            ),
          ],
        ),
      ),
    );
  }
}

class StudentCardReport {
  final String studentName;
  final String rollNumber;
  final String classSection;
  final String performanceSummary;
  final List<Map<String, String>> grades;
  final String comments;

  const StudentCardReport({
    required this.studentName,
    required this.rollNumber,
    required this.classSection,
    required this.performanceSummary,
    required this.grades,
    required this.comments,
  });
}
*/

class ViewMyAttendanceReport extends StatelessWidget {
  const ViewMyAttendanceReport({super.key});

  @override
  Widget build(BuildContext context) {
    // Assuming you have access to the student ID from the AuthProvider
    final studentId = AuthProvider.of(context).currentUser?.id ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Attendance Report'),
      ),
      body: FutureBuilder<List<StudentAttendanceRecord>>(
        future: fetchAttendanceReport(studentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('No attendance records available.'));
          }

          final attendanceRecords = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Attendance Summary',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8.0),
                Text('Total Classes Held: ${attendanceRecords.length}'),
                Text(
                    'Total Classes Attended: ${attendanceRecords.where((record) => record.status == 'Present').length}'),
                Text(
                    'Total Absences: ${attendanceRecords.where((record) => record.status == 'Absent').length}'),
                const SizedBox(height: 16.0),
                Text(
                  'Detailed Attendance Records',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8.0),
                Expanded(
                  child: ListView.builder(
                    itemCount: attendanceRecords.length,
                    itemBuilder: (context, index) {
                      final record = attendanceRecords[index];
                      return ListTile(
                        title: Text(record.date),
                        trailing: Text('Status: ${record.status}'),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16.0),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HelpScreen()),
                    );
                  },
                  child: const Text('Need Help? Contact Support'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<List<StudentAttendanceRecord>> fetchAttendanceReport(
      String studentId) async {
    final response = await http.get(Uri.parse(
        '${AppConfig.baseUrl}/api/attendance/student-attendance/$studentId'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse
          .map((data) => StudentAttendanceRecord.fromJson(data))
          .toList();
    } else {
      throw Exception('Failed to load attendance data');
    }
  }
}

class StudentAttendanceRecord {
  final String date;
  final String status;

  StudentAttendanceRecord({
    required this.date,
    required this.status,
  });

  factory StudentAttendanceRecord.fromJson(Map<String, dynamic> json) {
    return StudentAttendanceRecord(
      date: json['date'],
      status: json['status'],
    );
  }
}
