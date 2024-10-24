import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:testing_app/screens/students/help_screen.dart';
import 'package:testing_app/screens/students/estudy_screen.dart';
import 'package:testing_app/screens/students/exam_screen.dart';
import 'package:testing_app/screens/students/messaging_screen.dart';
import 'package:testing_app/screens/students/report_screen.dart';
import 'package:testing_app/screens/students/settings_screen.dart';
import 'package:testing_app/screens/students/student_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:testing_app/screens/config.dart';

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
              // Add more settings options here
            ],
          ),

          ExpansionTile(
            leading: const Icon(Icons.people),
            title: const Text('Student'),
            children: <Widget>[
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
              ListTile(
                leading: const Icon(Icons.message_outlined),
                title: const Text('View Messages for me'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MessageReceivingScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.message_outlined),
                title: const Text('View Messages for me from teacher'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MessageReceivingTeacherScreen()),
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
          const NotificationsCard(
            userId: 'userId',
          ), // Dynamic notifications
          const StudentTools(),
          const Shortcuts()
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
          onPressed: () => _logout(context), // Call the logout function
        ),
      ),
    );
  }
}

Future<List<String>> fetchNotifications(String userId) async {
  final response = await http
      .get(Uri.parse('${AppConfig.baseUrl}/api/notification-settings/$userId'));

  if (response.statusCode == 200) {
    Map<String, dynamic> jsonResponse = json.decode(response.body);
    List<dynamic> data =
        jsonResponse['notifications']; // Adjust based on your API response
    return data.cast<String>(); // Assuming the API returns a list of strings
  } else {
    throw Exception('Failed to load notifications');
  }
}

class NotificationsCard extends StatefulWidget {
  const NotificationsCard(
      {super.key, required this.userId}); // Require userId in the constructor

  final String userId; // Added userId field

  @override
  _NotificationsCardState createState() => _NotificationsCardState();
}

class _NotificationsCardState extends State<NotificationsCard> {
  List<String> notifications = [];
  bool isLoading = true;
  late Timer _timer; // Declare Timer

  @override
  void initState() {
    super.initState();
    _loadNotifications();

    // Poll for new notifications every 30 seconds
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _loadNotifications();
    });
  }

  Future<void> _loadNotifications() async {
    try {
      List<String> fetchedNotifications =
          await fetchNotifications(widget.userId); // Use userId from widget
      setState(() {
        notifications = fetchedNotifications;
        isLoading = false;
      });
    } catch (e) {
      // Handle error (you might want to show a Snackbar here)
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when disposing
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text("Today's Notifications"),
            trailing: CircleAvatar(
              backgroundColor: Colors.orange,
              child:
                  Text(notifications.length.toString()), // Notification count
            ),
          ),
          isLoading
              ? const CircularProgressIndicator() // Show loader while fetching
              : notifications.isEmpty
                  ? const ListTile(
                      title: Text('No notifications for today'),
                    )
                  : ListView.builder(
                      shrinkWrap:
                          true, // Add this to avoid infinite height issues
                      physics:
                          const NeverScrollableScrollPhysics(), // Disable scrolling for this inner ListView
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(notifications[index]),
                        );
                      },
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ListTile(
              title: Text(
                "Student Tools",
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
                      "Submit Exams",
                      () {
                        // Navigate to SubmitExamScreen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ViewManualExamScreen(),
                          ),
                        );
                      },
                    ),
                    _buildTableToolItem(
                      context,
                      Icons.assignment_sharp,
                      "Submit Assignments",
                      () {
                        // Navigate to SubmitAssignmentScreen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ViewAssignmentsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    _buildTableToolItem(
                      context,
                      Icons.person,
                      "Profile Settings",
                      () {
                        // Navigate to Profile Settings
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfileSettings(),
                          ),
                        );
                      },
                    ),
                    _buildTableToolItem(
                      context,
                      Icons.book_sharp,
                      "View Notes",
                      () {
                        // Navigate to ViewNotesScreen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const ViewStudyMaterialScreen(),
                          ),
                        );
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
          title: const Text("Send Message to Teacher"),
          trailing: const CircleAvatar(
            child: Icon(
              Icons.arrow_forward_sharp,
              color: Colors.black,
            ),
          ),
          onTap: () {
            // Navigate to the Send Message Screen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SendMessageScreen()),
            );
          },
        ),
        ListTile(
          title: const Text("Give Feedback"),
          trailing: const CircleAvatar(
            child: Icon(
              Icons.arrow_forward_sharp,
              color: Colors.black,
            ),
          ),
          onTap: () {
            // Navigate to the Feedback Screen
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const GiveFeedbackScreen()),
            );
          },
        ),
      ],
    );
  }
}
