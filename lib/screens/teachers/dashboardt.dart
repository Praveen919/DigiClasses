import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testing_app/screens/config.dart';
import 'package:testing_app/screens/teachers/estudyt.dart';
import 'package:testing_app/screens/teachers/examt.dart';
import 'package:testing_app/screens/teachers/helpt.dart';
import 'package:testing_app/screens/teachers/logbookt.dart';
import 'package:testing_app/screens/teachers/messagingt.dart';
import 'package:testing_app/screens/teachers/reportst.dart';
import 'package:testing_app/screens/teachers/settingst.dart';
import 'package:testing_app/screens/teachers/setupt.dart';
import 'package:testing_app/screens/teachers/studentt.dart';

class DashboardT extends StatelessWidget {
  final String name;
  final String branch;
  final String year;

  const DashboardT({
    super.key,
    required this.name,
    required this.branch,
    required this.year,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Panel'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer(); // Open the drawer
            },
          ),
        ),
      ),
      drawer: const SidePanel(), // Adding the drawer here
      body: DashboardTab(
        name: name,
        branch: branch,
        year: year,
      ),
    );
  }
}

class SidePanel extends StatelessWidget {
  const SidePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.green,
            ),
            child: Text(
              'My Panel',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              // Navigate to Dashboard or any screen
            },
          ),
          ExpansionTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profile Setting'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const SettingsT(option: 'profileSetting'),
                    ),
                  );
                  // Navigate to Change Password screen
                },
              ),
              ListTile(
                leading: const Icon(Icons.key_sharp),
                title: const Text('Change Password'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const SettingsT(option: 'changePassword'),
                    ),
                  );
                  // Navigate to Profile Setting screen
                },
              ),
              ListTile(
                leading: const Icon(FontAwesomeIcons.whatsapp),
                title: const Text('Auto WhatsApp Settings'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const SettingsT(option: 'autoWhatsApp'),
                    ),
                  );
                  // Navigate to Change Password screen
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications_active_outlined),
                title: const Text('Auto Notification Settings'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const SettingsT(option: 'autoNotification'),
                    ),
                  );
                  // Navigate to Change Password screen
                },
              )
            ],
          ),
          ExpansionTile(
            leading: const Icon(Icons.settings),
            title: const Text('Setup'),
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.edit_calendar_rounded),
                title: const Text('Add Year'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SetupT(option: 'addYear')),
                  );
                  // Navigate to Change Password screen
                },
              ),
              ListTile(
                leading: const Icon(Icons.group_add),
                title: const Text('Add Class/Batch'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const SetupT(option: 'addClassBatch')),
                  );
                  // Navigate to Change Password screen
                },
              ),
              ListTile(
                leading: const Icon(Icons.schedule_outlined),
                title: const Text('Manage TimeTable'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const SetupT(option: 'manageTimeTable')),
                  );
                },
              ),
            ],
          ),
          ExpansionTile(
            leading: const Icon(Icons.people),
            title: const Text('Student'),
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.app_registration_sharp),
                title: const Text('View Student Attendance'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const StudentT(option: 'studentAttendance')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.add_box_outlined),
                title: const Text('Share Documents'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const StudentT(option: 'shareDocuments')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Manage Shared Documents'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const StudentT(option: 'manageSharedDocuments')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.message_outlined),
                title: const Text('Chat with Students'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const StudentT(option: 'chatWithStudents')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.feedback_outlined),
                title: const Text('View Students Feedback'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const StudentT(option: 'studentsFeedback')),
                  );
                },
              ),
            ],
          ),
          ExpansionTile(
            leading: const Icon(Icons.school),
            title: const Text('Exam'),
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.post_add),
                title: const Text('Create Manual Exam'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const ExamT(option: 'createManualExam')),
                  );
                  // Navigate to Student management
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_note_sharp),
                title: const Text('View Manual Exam'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const ExamT(option: 'manageManualExam')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.my_library_books_sharp),
                title: const Text('Create MCQ Exam'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const ExamT(option: 'createMCQExam')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_note),
                title: const Text('View MCQ Exam'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const ExamT(option: 'manageMCQExam')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.menu_book_rounded),
                title: const Text('Create Assignments'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const ExamT(option: 'createAssignments')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('View Assignments'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const ExamT(option: 'manageAssignments')),
                  );
                },
              ),
            ],
          ),
          ExpansionTile(
            leading: const Icon(Icons.school_outlined),
            title: const Text('eStudy'),
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.menu_book_outlined),
                title: const Text('Create Study Material'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const EstudyT(option: 'createStudyMaterial')),
                  );
                  // Navigate to Student management
                },
              ),
              ListTile(
                leading: const Icon(Icons.mode_edit_sharp),
                title: const Text('Manage Study Material'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const EstudyT(option: 'manageStudyMaterial')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_note_sharp),
                title: const Text('Manage Shared Study Material'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const EstudyT(option: 'manageSharedStudyMaterial')),
                  );
                },
              ),
            ],
          ),
          ExpansionTile(
            leading: const Icon(Icons.content_paste_outlined),
            title: const Text('Logbook'),
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.create),
                title: const Text('Update My Logbook'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LogBookScreen()),
                  );
                },
              )
            ],
          ),
          ExpansionTile(
            leading: const Icon(Icons.message_outlined),
            title: const Text('Messaging'),
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Send message to Student'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const MessagingT(option: 'student')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_sharp),
                title: const Text('Send message to Staff'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const MessagingT(option: 'staff')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.password),
                title: const Text('Send Student Id/Password'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const MessagingT(option: 'studentIdPassword')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.remember_me),
                title: const Text('Send Upcoming Exam Reminder'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const MessagingT(option: 'examReminder')),
                  );
                },
              ),
              /*  ListTile(
                leading: const Icon(Icons.score_outlined),
                title: const Text('Send Exam Marks Message'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                        const MessagingT(option: 'examMarks')),
                  );
                },
              ), */
              ListTile(
                leading: const Icon(Icons.person_remove_alt_1_outlined),
                title: const Text('Send Absent Student Attendance Message'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const MessagingT(option: 'absentAttendance')),
                  );
                },
              ),
            ],
          ),
          ExpansionTile(
            leading: const Icon(Icons.file_open_outlined),
            title: const Text('Report'),
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.details_rounded),
                title: const Text('Student Detail Report'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const ReportT(option: 'studentDetail')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.grade),
                title: const Text('Student Card Report'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const ReportT(option: 'studentCard')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_calendar_outlined),
                title: const Text('Student Attendance Report'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const ReportT(option: 'studentAttendance')),
                  );
                },
              )
            ],
          ),
          ExpansionTile(
            leading: const Icon(Icons.live_help_outlined),
            title: const Text('Help'),
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.connect_without_contact),
                title: const Text('Contact us'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const HelpT(option: 'contactUs')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.feedback),
                title: const Text('Feedback'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const HelpT(option: 'feedback')),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DashboardTab extends ConsumerWidget {
  final String name;
  final String branch;
  final String year;

  const DashboardTab({
    super.key,
    required this.name,
    required this.branch,
    required this.year,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch statistics when the widget builds
    ref.read(statisticsProvider.notifier).fetchStatistics();

    final statistics =
        ref.watch(statisticsProvider); // Watch the statistics provider

    return SingleChildScrollView(
      child: Column(
        children: [
          UserInfoCard(
            name: name,
            branch: branch,
            year: year,
          ),
          const NotificationsCard(),
          StatisticsCard(
            studentsCount: statistics.studentsCount,
            absenteesCount: statistics.absenteesCount,
          ),
          const TeacherTools(),
          const Shortcuts(),
        ],
      ),
    );
  }
}

class UserInfoCard extends StatelessWidget {
  final String name;
  final String branch;
  final String year;

  const UserInfoCard({
    super.key,
    required this.name,
    required this.branch,
    required this.year,
  });

  // Function to handle user logout and navigate to login screen
  void _logout(BuildContext context) {
    // Add any logout logic here, like clearing user data, tokens, etc.
    // Then, navigate to the login screen
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading:
            const CircleAvatar(child: Text('Logo')), // Adjust logo as necessary
        title: Text(name), // Display the user's name
        subtitle:
            Text('Branch: $branch\nYear: $year'), // Display branch and year
        trailing: IconButton(
          icon: const Icon(Icons.power_settings_new),
          onPressed: () =>
              _logout(context), // Call the logout function when pressed
        ),
      ),
    );
  }
}

class NotificationsCard extends StatelessWidget {
  const NotificationsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text("Today's Notifications"),
            trailing:
                CircleAvatar(backgroundColor: Colors.orange, child: Text('0')),
          ),
        ],
      ),
    );
  }
}

class Statistics {
  final int studentsCount;
  final int absenteesCount;

  Statistics({
    required this.studentsCount,
    required this.absenteesCount,
  });
}

class StatisticsNotifier extends StateNotifier<Statistics> {
  StatisticsNotifier() : super(Statistics(studentsCount: 0, absenteesCount: 0));

  Future<void> fetchStatistics() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      if (token != null) {
        // Fetch total students count
        final studentsResponse = await http.get(
          Uri.parse('${AppConfig.baseUrl}/api/auth/students/count'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );

        final studentsCount = jsonDecode(studentsResponse.body)['count'];

        // Fetch today's absentees count
        final absenteesResponse = await http.get(
          Uri.parse('${AppConfig.baseUrl}/api/statistics/absentees/count'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );

        final absenteesCount = jsonDecode(absenteesResponse.body)['count'];

        // Update the state with the fetched data
        state = Statistics(
          studentsCount: studentsCount ?? 0,
          absenteesCount: absenteesCount ?? 0,
        );
      } else {
        print('No token found! Please log in again.');
        // Handle no token scenario appropriately
      }
    } catch (error) {
      print('Error fetching statistics: $error');
      // Handle error appropriately
    }
  }
}

// Define the provider
final statisticsProvider =
    StateNotifierProvider<StatisticsNotifier, Statistics>((ref) {
  return StatisticsNotifier();
});

class StatisticsCard extends StatelessWidget {
  final int studentsCount;
  final int absenteesCount;

  const StatisticsCard({
    Key? key,
    required this.studentsCount,
    required this.absenteesCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          const ListTile(title: Text('Student Status')),
          ListTile(
            leading: const Icon(Icons.group),
            title: const Text('Total Students'),
            trailing: CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text(studentsCount.toString()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person_off),
            title: const Text('Today Absentees'),
            trailing: CircleAvatar(
              backgroundColor: Colors.cyan,
              child: Text(absenteesCount.toString()),
            ),
          ),
        ],
      ),
    );
  }
}

class TeacherTools extends StatelessWidget {
  const TeacherTools({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
        child: Column(children: [
      ListTile(title: Text("Teacher Tools")),
      Row(children: [
        Expanded(
            child: ListTile(
                leading: Icon(Icons.note_sharp, color: Colors.black),
                title: Text("Upload Exams"))),
        Expanded(
            child: ListTile(
                leading: Icon(Icons.assignment_sharp, color: Colors.black),
                title: Text("Upload Assignments"))),
        Expanded(
            child: ListTile(
                leading:
                    Icon(Icons.calendar_today_outlined, color: Colors.black),
                title: Text("View Timetable")))
      ]),
      Row(children: [
        Expanded(
            child: ListTile(
                leading: Icon(Icons.edit_note_outlined, color: Colors.black),
                title: Text("Update Attendance"))),
        Expanded(
            child: ListTile(
                leading: Icon(Icons.book_sharp, color: Colors.black),
                title: Text("Upload Notes"))),
        Expanded(
            child: ListTile(
                leading: Icon(Icons.message, color: Colors.black),
                title: Text("Messages")))
      ])
    ]));
  }
}

class Shortcuts extends StatelessWidget {
  const Shortcuts({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        ListTile(
            title: Text("Update my Logbook"),
            trailing: CircleAvatar(
                child: Icon(
              Icons.arrow_forward_sharp,
              color: Colors.black,
            ))),
        ListTile(
            title: Text("Send Exam/Assignment Reminder"),
            trailing: CircleAvatar(
                child: Icon(
              Icons.arrow_forward_sharp,
              color: Colors.black,
            ))),
      ],
    );
  }
}
