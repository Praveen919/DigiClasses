import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testing_app/screens/admin/estudy_screen.dart';
import 'package:testing_app/screens/admin/exam_screen.dart';
import 'package:testing_app/screens/admin/expenses_income_screen.dart';
import 'package:testing_app/screens/admin/fee_screen.dart';
import 'package:testing_app/screens/admin/help_screen.dart';
import 'package:testing_app/screens/admin/messaging_screen.dart';
import 'package:testing_app/screens/admin/report_screen.dart';
import 'package:testing_app/screens/admin/settings_screen.dart';
import 'package:testing_app/screens/admin/setup_screen.dart';
import 'package:testing_app/screens/admin/staff_user_screen.dart';
import 'package:testing_app/screens/admin/student_screen.dart';
import 'package:testing_app/screens/config.dart';

class DashboardScreen extends StatelessWidget {
  final String name;
  final String branch;
  final String year;

  const DashboardScreen({
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
                          const SettingsScreen(option: 'profileSetting'),
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
                          const SettingsScreen(option: 'changePassword'),
                    ),
                  );
                  // Navigate to Profile Setting screen
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_add_alt),
                title: const Text('My Referral'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const SettingsScreen(option: 'myReferral'),
                    ),
                  );
                  // Navigate to Change Password screen
                },
              ),
              // Add more settings options here
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
                        builder: (context) =>
                            const SetupScreen(option: 'addYear')),
                  );
                  // Navigate to Change Password screen
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_calendar_rounded),
                title: const Text('Manage Year'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const SetupScreen(option: 'manageYear')),
                  );
                  // Navigate to Change Password screen
                },
              ),
              ListTile(
                leading: const Icon(Icons.assignment_turned_in),
                title: const Text('Assign Standard'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const SetupScreen(option: 'assignStandard')),
                  );
                  // Navigate to Change Password screen
                },
              ),
              ListTile(
                leading: const Icon(Icons.assignment_turned_in_sharp),
                title: const Text('Assign Subject'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const SetupScreen(option: 'assignSubject')),
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
                            const SetupScreen(option: 'addClassBatch')),
                  );
                  // Navigate to Change Password screen
                },
              ),
              ListTile(
                leading: const Icon(Icons.group_add_outlined),
                title: const Text('Manage Class/Batch'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const SetupScreen(option: 'manageClassBatch')),
                  );
                },
              ),
            ],
          ),
          ExpansionTile(
            leading: const Icon(Icons.people),
            title: const Text('Staff/User'),
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.person_add),
                title: const Text('Create Staff'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const StaffUserScreen(option: 'createStaff')),
                  );
                  // Navigate to Change Password screen
                },
              ),
              ListTile(
                leading: const Icon(Icons.people_outline_sharp),
                title: const Text('Manage Staff'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const StaffUserScreen(option: 'manageStaff')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.how_to_reg),
                title: const Text('Manage Staff Rights'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const StaffUserScreen(option: 'manageStaffRights')),
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
                leading: const Icon(Icons.add_alert),
                title: const Text('Add Student Inquiry'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const StudentScreen(option: 'addInquiry')),
                  );
                  // Navigate to Change Password screen
                },
              ),
              ListTile(
                leading: const Icon(Icons.border_color_outlined),
                title: const Text('Manage Student Inquiry'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const StudentScreen(option: 'manageInquiry')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_add_alt),
                title: const Text('Add Student Registration'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const StudentScreen(option: 'addRegistration')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.manage_accounts),
                title: const Text('Manage Student '),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const StudentScreen(option: 'manageStudent')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.assignment_turned_in_outlined),
                title: const Text('Assign Class/Batch'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const StudentScreen(option: 'assignClassBatch')),
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
                            const StudentScreen(option: 'shareDocuments')),
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
                        builder: (context) => const StudentScreen(
                            option: 'manageSharedDocuments')),
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
                            const StudentScreen(option: 'chatWithStudents')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.feedback_outlined),
                title: const Text('Students Feedback'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const StudentScreen(option: 'studentsFeedback')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.key),
                title: const Text('Student Rights'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const StudentScreen(option: 'studentRights')),
                  );
                },
              ),
            ],
          ),
          ExpansionTile(
            leading: const Icon(Icons.attach_money_sharp),
            title: const Text('Fee'),
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.menu_book_sharp),
                title: const Text('Create Fee Structure'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const FeeScreen(option: 'createFeeStructure')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_note),
                title: const Text('Manage Fee Structure'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const FeeScreen(option: 'manageFeeStructure')),
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
                            const ExamScreen(option: 'createManualExam')),
                  );
                  // Navigate to Student management
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_note_sharp),
                title: const Text('Manage Manual Exam'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const ExamScreen(option: 'manageManualExam')),
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
                            const ExamScreen(option: 'createMCQExam')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_note),
                title: const Text('Manage MCQ Exam'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const ExamScreen(option: 'manageMCQExam')),
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
                            const ExamScreen(option: 'createAssignments')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Manage Assignments'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const ExamScreen(option: 'manageAssignments')),
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
                            const EstudyScreen(option: 'createStudyMaterial')),
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
                            const EstudyScreen(option: 'manageStudyMaterial')),
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
                        builder: (context) => const EstudyScreen(
                            option: 'manageSharedStudyMaterial')),
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
                title: const Text('Send message to Student'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const MessagingScreen(option: 'student')),
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
                            const MessagingScreen(option: 'staff')),
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
                            const MessagingScreen(option: 'examReminder')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_remove_alt_1_outlined),
                title: const Text('Absent Student Attendance Message'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const MessagingScreen(option: 'absentAttendance')),
                  );
                },
              ),
            ],
          ),
          ExpansionTile(
            leading: const Icon(Icons.attach_money),
            title: const Text('Expense & Income'),
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.attach_money),
                title: const Text('Add Expense'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const ExpensesIncomeScreen(option: 'addExpense')),
                  );
                  // Navigate to Student management
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Manage Expense'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ExpensesIncomeScreen(
                            option: 'manageExpense')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.add_box_outlined),
                title: const Text('Add Income'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const ExpensesIncomeScreen(option: 'addIncome')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Manage Income'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const ExpensesIncomeScreen(option: 'manageIncome')),
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
                leading: const Icon(Icons.person),
                title: const Text('Student Inquiry Report'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const ReportScreen(option: 'studentInquiry')),
                  );
                  // Navigate to Student management
                },
              ),
              ListTile(
                leading: const Icon(Icons.menu_book_sharp),
                title: const Text('Expense Report'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const ReportScreen(option: 'expense')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.menu_book_sharp),
                title: const Text('Income Report'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const ReportScreen(option: 'income')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.check_circle_outlined),
                title: const Text('App Access Rights'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const ReportScreen(option: 'appAccessRights')),
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
                title: const Text('Contact Us'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const HelpScreen(option: 'contactUs')),
                  );
                  // Navigate to Student management
                },
              ),
              ListTile(
                leading: const Icon(Icons.feedback),
                title: const Text('View Feedbacks'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const HelpScreen(option: 'viewFeedback')),
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

class DashboardTab extends ConsumerStatefulWidget {
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
  _DashboardTabState createState() => _DashboardTabState();
}

class _DashboardTabState extends ConsumerState<DashboardTab>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ref
        .read(statisticsProvider.notifier)
        .fetchStatistics(); // Fetch statistics on init
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref
          .read(statisticsProvider.notifier)
          .fetchStatistics(); // Fetch statistics when resumed
    }
  }

  @override
  Widget build(BuildContext context) {
    final statistics =
        ref.watch(statisticsProvider); // Watch the statistics provider

    return SingleChildScrollView(
      child: Column(
        children: [
          UserInfoCard(
            name: widget.name,
            branch: widget.branch,
            year: widget.year,
          ),
          const NotificationsCard(),
          StatisticsCard(
            inquiriesCount: statistics.inquiriesCount,
            studentsCount: statistics.studentsCount,
            absenteesCount: statistics.absenteesCount,
          )
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

// Create a Statistics model class
class Statistics {
  final int inquiriesCount;
  final int studentsCount;
  final int absenteesCount;

  Statistics({
    required this.inquiriesCount,
    required this.studentsCount,
    required this.absenteesCount,
  });
}

// Create a StateNotifier for managing statistics state
class StatisticsNotifier extends StateNotifier<Statistics> {
  StatisticsNotifier()
      : super(
            Statistics(inquiriesCount: 0, studentsCount: 0, absenteesCount: 0));

  Future<void> fetchStatistics() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      if (token != null) {
        // Fetch inquiries count
        final inquiriesResponse = await http.get(
          Uri.parse('${AppConfig.baseUrl}/api/inquiries/count'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );

        final inquiriesCount = jsonDecode(inquiriesResponse.body)['count'];

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
          inquiriesCount: inquiriesCount ?? 0,
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

class StatisticsCard extends ConsumerStatefulWidget {
  const StatisticsCard(
      {super.key,
      required int inquiriesCount,
      required int studentsCount,
      required int absenteesCount});

  @override
  _StatisticsCardState createState() => _StatisticsCardState();
}

class _StatisticsCardState extends ConsumerState<StatisticsCard> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Fetch statistics initially
    ref.read(statisticsProvider.notifier).fetchStatistics();

    // Set up a timer to refresh data every 20 seconds
    _timer = Timer.periodic(const Duration(seconds: 20), (timer) {
      ref.read(statisticsProvider.notifier).fetchStatistics();
    });
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the statistics provider to get current statistics
    final statistics = ref.watch(statisticsProvider);

    return Card(
      child: Column(
        children: [
          const ListTile(title: Text('Student Status')),
          ListTile(
            leading: const Icon(Icons.question_answer),
            title: const Text("Today's Inquiries"),
            trailing: CircleAvatar(
              backgroundColor: Colors.green,
              child: Text(statistics.inquiriesCount.toString()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.group),
            title: const Text('Total Students'),
            trailing: CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text(statistics.studentsCount.toString()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person_off),
            title: const Text('Today Absentees'),
            trailing: CircleAvatar(
              backgroundColor: Colors.cyan,
              child: Text(statistics.absenteesCount.toString()),
            ),
          ),
        ],
      ),
    );
  }
}
