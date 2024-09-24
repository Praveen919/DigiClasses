import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:testing_app/screens/students/help_screen.dart';
import 'package:testing_app/screens/students/estudy_screen.dart';
import 'package:testing_app/screens/students/exam_screen.dart';
import 'package:testing_app/screens/students/messaging_screen.dart';
import 'package:testing_app/screens/students/report_screen.dart';
import 'package:testing_app/screens/students/settings_screen.dart';
import 'package:testing_app/screens/students/student_screen.dart';

class Dashboard1Screen extends StatelessWidget {
  final String name;
  final String branch;
  final String year;

  const Dashboard1Screen({
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
                      builder: (context) => const ProfileSettings(),
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
                      builder: (context) => const ChangePassword(),
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
                      builder: (context) => const AutoWhatsappSettingScreen(),
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
                          const AutoNotificationSettingsScreen(),
                    ),
                  );
                  // Navigate to Change Password screen
                },
              ),

              // Add more settings options here
            ],
          ),

          ExpansionTile(
            leading: const Icon(Icons.people),
            title: const Text('Student'),
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.app_registration_sharp),
                title: const Text('View My Attendance'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ViewMyAttendanceScreen(classBatchId: '')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.add_box_outlined),
                title: const Text('View Share Documents'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ViewSharedDocumentsScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.feedback_outlined),
                title: const Text('Give Feedback'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => GiveFeedbackScreen()),
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
                title: const Text('View Manual Exam'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ExamScreen()),
                  );
                  // Navigate to Student management
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
                        builder: (context) => ViewMCQExamScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.menu_book_rounded),
                title: const Text('View Assignments'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ViewAssignmentsScreen()),
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
                title: const Text('View Study Material'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ViewStudyMaterialScreen()),
                  );
                  // Navigate to Student management
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_note_sharp),
                title: const Text('View Shared Study Material'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const ViewSharedStudyMaterialScreen()),
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
                leading: const Icon(Icons.person),
                title: const Text('Send message to Teacher'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SendMessageScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.password_outlined),
                title: const Text('Request for Id/Password'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RequestCredentialsScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.add_alert),
                title: const Text('Send Inquiry Message'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SendInquiryMessageScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_remove_alt_1_outlined),
                title: const Text('Send Todays Absent Attendance Message'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TodaysAbsenceMessageScreen()),
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
                title: const Text('View My Detailed Report'),
                onTap: () {
                  // Pop the current screen
                  Navigator.pop(context);

                  // Retrieve the student ID from your authentication context or provider
                  String studentId =
                      AuthProvider.of(context).currentUser?.id ?? '';

                  // Navigate to the ViewDetailReportScreen with the dynamic student ID
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
                leading: Icon(Icons.grade),
                title: const Text('View My Card Report'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  ViewMyCardReport()),

                  );
                },
              ),*/
              ListTile(
                leading: const Icon(Icons.edit_calendar_outlined),
                title: const Text('View Attendance Report'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ViewMyAttendanceReport()),
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
                title: const Text('Conatct US'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HelpScreen()),
                  );
                  // Navigate to Student management
                },
              ),
            ],
          ),
          // Add more ListTiles for other menu items as per your design
        ],
      ),
    );
  }
}

class DashboardTab extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          UserInfoCard(
            name: name,
            branch: branch,
            year: year,
          ),
          const NotificationsCard(),
          const StatisticsCard(),
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
          ListTile(
            leading: Icon(Icons.calendar_today),
            title: Text('Upcoming exam date'),
            trailing: Text('31 Dec 2024'),
          ),
        ],
      ),
    );
  }
}

class StatisticsCard extends StatelessWidget {
  const StatisticsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Column(
        children: [
          ListTile(
            title: Text('My Status'),
            trailing: Icon(Icons.arrow_drop_down),
          ),
          ListTile(
            leading: Icon(Icons.question_answer),
            title: Text("Today's Notification"),
            trailing:
                CircleAvatar(backgroundColor: Colors.green, child: Text('0')),
          ),
          ListTile(
            leading: Icon(Icons.person_off),
            title: Text('Today Absentees'),
            trailing:
                CircleAvatar(backgroundColor: Colors.cyan, child: Text('0')),
          ),
        ],
      ),
    );
  }
}

class StudentTools extends StatelessWidget {
  const StudentTools({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
        child: Column(children: [
      ListTile(title: Text("Student Tools")),
      Row(children: [
        Expanded(
            child: ListTile(
                leading: Icon(Icons.note_sharp, color: Colors.black),
                title: Text("Submit Exams"))),
        Expanded(
            child: ListTile(
                leading: Icon(Icons.assignment_sharp, color: Colors.black),
                title: Text("Submit Assignments"))),
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
                title: Text("View Attendance"))),
        Expanded(
            child: ListTile(
                leading: Icon(Icons.book_sharp, color: Colors.black),
                title: Text("View Notes"))),
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
            title: Text("Check Exam Marks"),
            trailing: CircleAvatar(
                child: Icon(
              Icons.arrow_forward_sharp,
              color: Colors.black,
            ))),
        ListTile(
            title: Text("Check Reminder"),
            trailing: CircleAvatar(
                child: Icon(
              Icons.arrow_forward_sharp,
              color: Colors.black,
            ))),
      ],
    );
  }
}







/*https://www.figma.com/proto/QDv0ZOA5joCftuPL14imWv/Untitled?page-id=0%3A1&node-id=4-3&viewport=538%2C316%2C0.
56&t=95oB0YAjJGF1CD8L-1&scaling=scale-down&content-scaling=fixed&starting-point-node-id=4%3A3&show-proto-sidebar=1
*/
