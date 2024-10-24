import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testing_app/screens/config.dart';
import 'package:testing_app/screens/teachers/estudyt.dart';
import 'package:testing_app/screens/teachers/examt.dart';
import 'package:testing_app/screens/teachers/helpt.dart';
import 'package:testing_app/screens/teachers/messagingt.dart';
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
            ],
          ),
          ExpansionTile(
            leading: const Icon(Icons.people),
            title: const Text('Student'),
            children: <Widget>[
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
            leading: const Icon(Icons.message_outlined),
            title: const Text('Messaging'),
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.person_sharp),
                title: const Text('Send message to Admin'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                        const MessagingT(option: 'admin')),
                  );
                },
              ),
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
              ListTile(
                leading: const Icon(Icons.message_outlined),
                title: const Text('View Messages for me'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                        const MessagingT(option: 'receivedMessage')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_remove_alt_1_outlined),
                title: const Text('View Absent Student Message'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const MessagingT(option: 'absentStudents')),
                  );
                },
              ),
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
          Uri.parse('${AppConfig.baseUrl}/api/registration/students/count'),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ListTile(
              title: Text(
                "Teacher Tools",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            const Divider(),
            Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                TableRow(
                  children: [
                    _buildTableToolItem(
                      context,
                      Icons.note_sharp,
                      "Upload Exams",
                      () {
                        // Navigate to CreateManualExamScreen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const CreateManualExamScreen(),
                          ),
                        );
                      },
                    ),
                    _buildTableToolItem(
                      context,
                      Icons.assignment_sharp,
                      "Upload Assignments",
                      () {
                        // Navigate to upload assignments screen
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const CreateAssignmentsScreen()));
                      },
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    _buildTableToolItem(
                      context,
                      Icons.book_sharp,
                      "Upload Notes",
                      () {
                        // Navigate to upload notes screen
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const CreateStudyMaterialScreen()));
                      },
                    ),
                    _buildTableToolItem(
                      context,
                      Icons.message,
                      "View Messages",
                      () {
                        // Navigate to messages screen
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const SendStudentMessageScreen()));
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build table items with navigation
  Widget _buildTableToolItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          children: [
            Icon(icon, color: Colors.black, size: 30),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class Shortcuts extends StatelessWidget {
  const Shortcuts({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: const Text("Send Exam Reminder"),
          trailing: const CircleAvatar(
            child: Icon(
              Icons.arrow_forward_sharp,
              color: Colors.black,
            ),
          ),
          onTap: () {
            // Navigate to the Reminder screen
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const SendExamReminderScreen()),
            );
          },
        ),
      ],
    );
  }
}
