import 'package:flutter/material.dart';

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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewDetailReportScreen(
                    report: StudentReport(
                      studentName: 'John Doe',
                      rollNumber: '12345',
                      classSection: '10-A',
                      academicPerformance: [],
                      totalClassesHeld: 0,
                      totalClassesAttended: 0,
                      detailedAttendance: [],
                      achievements: [],
                      teacherComments: '',
                    ),
                  ),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('View My Card Report'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ViewMyCardReport(),
                ),
              );
            },
          ),
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

class ViewDetailReportScreen extends StatelessWidget {
  final StudentReport report;

  const ViewDetailReportScreen({required this.report});

  @override
  Widget build(BuildContext context) {
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
            Text('Name: ${report.studentName}'),
            Text('Roll Number: ${report.rollNumber}'),
            Text('Class/Section: ${report.classSection}'),
            const SizedBox(height: 16.0),

            Text(
              'Academic Performance',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8.0),
            for (var subject in report.academicPerformance)
              ListTile(
                title: Text(subject['name'] ?? 'Unknown'),
                trailing: Text('Grade: ${subject['grade'] ?? 'N/A'}'),
              ),
            const SizedBox(height: 16.0),

            Text(
              'Attendance Record',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8.0),
            Text('Total Classes Held: ${report.totalClassesHeld}'),
            Text('Total Classes Attended: ${report.totalClassesAttended}'),
            const SizedBox(height: 8.0),
            for (var attendance in report.detailedAttendance)
              ListTile(
                title: Text(attendance['date'] ?? 'Unknown'),
                subtitle: Text('Status: ${attendance['status'] ?? 'N/A'}'),
              ),
            const SizedBox(height: 16.0),

            Text(
              'Achievements',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8.0),
            for (var achievement in report.achievements)
              ListTile(
                title: Text(achievement),
              ),
            const SizedBox(height: 16.0),

            Text(
              'Teacher\'s Comments',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8.0),
            Text(report.teacherComments),

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

class StudentReport {
  final String studentName;
  final String rollNumber;
  final String classSection;
  final List<Map<String, String>> academicPerformance;
  final int totalClassesHeld;
  final int totalClassesAttended;
  final List<Map<String, String>> detailedAttendance;
  final List<String> achievements;
  final String teacherComments;

  StudentReport({
    required this.studentName,
    required this.rollNumber,
    required this.classSection,
    required this.academicPerformance,
    required this.totalClassesHeld,
    required this.totalClassesAttended,
    required this.detailedAttendance,
    required this.achievements,
    required this.teacherComments,
  });
}





class ViewMyCardReport extends StatelessWidget {
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


class ViewMyAttendanceReport extends StatelessWidget {
  const ViewMyAttendanceReport({super.key});

  @override
  Widget build(BuildContext context) {
    final attendanceReport = StudentAttendanceReport(
      studentName: 'John Doe',
      rollNumber: '12345',
      classSection: '10-A',
      totalClassesHeld: 100,
      totalClassesAttended: 90,
      attendanceRecords: [
        {'date': '01-09-2024', 'status': 'Present'},
        {'date': '02-09-2024', 'status': 'Absent'},
        {'date': '03-09-2024', 'status': 'Present'},
      ],
      comments: 'John has maintained good attendance overall but missed a few classes.',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Attendance Report'),
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
            Text('Name: ${attendanceReport.studentName}'),
            Text('Roll Number: ${attendanceReport.rollNumber}'),
            Text('Class/Section: ${attendanceReport.classSection}'),
            const SizedBox(height: 16.0),

            Text(
              'Attendance Summary',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8.0),
            Text('Total Classes Held: ${attendanceReport.totalClassesHeld}'),
            Text('Total Classes Attended: ${attendanceReport.totalClassesAttended}'),
            Text('Total Absences: ${attendanceReport.totalClassesHeld - attendanceReport.totalClassesAttended}'),
            const SizedBox(height: 16.0),

            Text(
              'Detailed Attendance Records',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8.0),
            Expanded(
              child: ListView.builder(
                itemCount: attendanceReport.attendanceRecords.length,
                itemBuilder: (context, index) {
                  final record = attendanceReport.attendanceRecords[index];
                  return ListTile(
                    title: Text(record['date'] ?? 'Unknown Date'),
                    trailing: Text('Status: ${record['status'] ?? 'N/A'}'),
                  );
                },
              ),
            ),
            const SizedBox(height: 16.0),

            Text(
              'Comments',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8.0),
            Text(attendanceReport.comments),

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

class StudentAttendanceReport {
  final String studentName;
  final String rollNumber;
  final String classSection;
  final int totalClassesHeld;
  final int totalClassesAttended;
  final List<Map<String, String>> attendanceRecords;
  final String comments;

  StudentAttendanceReport({
    required this.studentName,
    required this.rollNumber,
    required this.classSection,
    required this.totalClassesHeld,
    required this.totalClassesAttended,
    required this.attendanceRecords,
    required this.comments,
  });
}