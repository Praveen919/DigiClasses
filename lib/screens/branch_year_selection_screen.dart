import 'package:flutter/material.dart';
import 'package:testing_app/screens/admin/dashboard_screen.dart';
import 'package:testing_app/screens/students/dashboard_screen.dart'; // Correct import path
import 'package:testing_app/screens/teachers/dashboardt.dart';

class BranchYearSelectionScreen extends StatefulWidget {
  final String name;
  final String branch;
  final String year;
  final String userRole;

  const BranchYearSelectionScreen({
    super.key,
    required this.name,
    required this.branch,
    required this.year,
    required this.userRole,
  });

  @override
  _BranchYearSelectionScreenState createState() =>
      _BranchYearSelectionScreenState();
}

class _BranchYearSelectionScreenState extends State<BranchYearSelectionScreen> {
  String? selectedBranch;
  String? selectedYear;
  final List<String> branches = ['Branch 1'];
  final List<String> years = ['2024-2025'];

  @override
  void initState() {
    super.initState();
    selectedBranch = branches.contains(widget.branch) ? widget.branch : null;
    selectedYear = years.contains(widget.year) ? widget.year : null;
    print('User Role: ${widget.userRole}'); // Debug print
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Branch-Year Selection'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Card(
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    'Branch-Year Selection',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Branch *',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedBranch,
                    items: branches.map((branch) {
                      return DropdownMenuItem<String>(
                        value: branch,
                        child: Text(branch),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedBranch = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || !branches.contains(value)) {
                        return 'Please select a valid branch';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Year *',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedYear,
                    items: years.map((year) {
                      return DropdownMenuItem<String>(
                        value: year,
                        child: Text(year),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedYear = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || !years.contains(value)) {
                        return 'Please select a valid year';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (selectedBranch != null && selectedYear != null) {
                        Widget destinationScreen;
                        print(
                            'Navigating to dashboard for role: ${widget.userRole}'); // Debug print
                        switch (widget.userRole) {
                          case 'Admin':
                            destinationScreen = DashboardScreen(
                              name: widget.name,
                              branch: selectedBranch!,
                              year: selectedYear!,
                            );
                            break;
                          case 'Teacher':
                            destinationScreen = DashboardT(
                              name: widget.name,
                              branch: selectedBranch!,
                              year: selectedYear!,
                            );
                            break;
                          case 'Student':
                            destinationScreen = Dashboard1Screen(
                              name: widget.name,
                              branch: selectedBranch!,
                              year: selectedYear!,
                            );
                            break;
                          default:
                            destinationScreen = DashboardScreen(
                              name: 'Default Name', // Fallback
                              branch: selectedBranch!,
                              year: selectedYear!,
                            );
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => destinationScreen,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Please select both branch and year.'),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 17.0),
                      backgroundColor: Colors.teal,
                    ),
                    child: const Text(
                      'Proceed',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
