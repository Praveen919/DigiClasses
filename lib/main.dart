import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:testing_app/screens/loginscreen.dart';
import 'package:testing_app/screens/students/dashboard_screen.dart';
import 'package:testing_app/screens/teachers/dashboardt.dart';
import 'package:testing_app/screens/create_account_screen.dart';
import 'package:testing_app/screens/branch_year_selection_screen.dart';
import 'package:testing_app/screens/admin/dashboard_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp())); // Wrap MyApp with ProviderScope
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DigiClass',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      initialRoute: '/', // Default route
      routes: <String, WidgetBuilder>{
        '/': (context) => const LoginScreen(),
        '/createAccount': (context) => const CreateAccountScreen(),
        // Adjusted routes to handle parameters via arguments
        '/branchYearSelection': (context) {
          final arguments = ModalRoute.of(context)?.settings.arguments
              as Map<String, String>?; // Cast arguments to the expected type
          return BranchYearSelectionScreen(
            userRole: arguments?['userRole'] ?? '',
            name: arguments?['name'] ?? '',
            branch: arguments?['branch'] ?? '',
            year: arguments?['year'] ?? '',
          );
        },
        '/adminDashboard': (context) {
          final arguments = ModalRoute.of(context)?.settings.arguments
              as Map<String, String>?; // Cast arguments to the expected type
          return DashboardScreen(
            name: arguments?['name'] ?? '',
            branch: arguments?['branch'] ?? '',
            year: arguments?['year'] ?? '',
          );
        },
        '/teacherDashboard': (context) {
          final arguments = ModalRoute.of(context)?.settings.arguments
              as Map<String, String>?; // Cast arguments to the expected type
          return DashboardT(
            name: arguments?['name'] ?? '',
            branch: arguments?['branch'] ?? '',
            year: arguments?['year'] ?? '',
          );
        },
        '/studentDashboard': (context) {
          final arguments = ModalRoute.of(context)?.settings.arguments
              as Map<String, String>?; // Cast arguments to the expected type
          return Dashboard1Screen(
            name: arguments?['name'] ?? '',
            branch: arguments?['branch'] ?? '',
            year: arguments?['year'] ?? '',
          );
        },
      },
    );
  }
}
