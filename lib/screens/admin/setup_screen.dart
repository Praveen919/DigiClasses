import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:testing_app/screens/config.dart';

class SetupScreen extends StatelessWidget {
  final String option;

  const SetupScreen({super.key, this.option = 'addYear'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup'),
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    switch (option) {
      case 'addYear':
        return const AddYearScreen();
      case 'manageYear':
        return const ManageYearScreen();
      case 'assignStandard':
        return const AssignStandardScreen();
      case 'assignSubject':
        return const AssignSubjectScreen();
      case 'addClassBatch':
        return const AddClassBatchScreen();
      case 'manageClassBatch':
        return const ManageClassBatchScreen();
      case 'manageTimeTable':
        return const ManageTimeTableScreen();
      default:
        return const Center(child: Text('Unknown Option'));
    }
  }
}

class AddYearScreen extends StatefulWidget {
  final String? yearId;
  final String? yearName;
  final String? fromDate;
  final String? toDate;
  final String? remarks;

  const AddYearScreen({
    super.key,
    this.yearId,
    this.yearName,
    this.fromDate,
    this.toDate,
    this.remarks,
  });

  @override
  _AddYearScreenState createState() => _AddYearScreenState();
}

class _AddYearScreenState extends State<AddYearScreen> {
  DateTime? fromDate;
  DateTime? toDate;
  final TextEditingController _yearNameController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.yearId != null) {
      _yearNameController.text = widget.yearName ?? '';
      _remarksController.text = widget.remarks ?? '';
      fromDate = widget.fromDate != null ? _parseDate(widget.fromDate!) : null;
      toDate = widget.toDate != null ? _parseDate(widget.toDate!) : null;
    }
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          isFromDate ? fromDate ?? DateTime.now() : toDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isFromDate) {
          fromDate = picked;
        } else {
          toDate = picked;
        }
      });
    }
  }

  // Format date in dd/mm/yyyy
  String? _formatDate(DateTime? date) {
    if (date == null) return null;
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // Parse date from dd/mm/yyyy format
  DateTime _parseDate(String date) {
    final parts = date.split('/');
    if (parts.length != 3) {
      throw const FormatException('Invalid date format');
    }
    final day = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final year = int.parse(parts[2]);
    return DateTime(year, month, day);
  }

  Future<void> _submit() async {
    if (_yearNameController.text.isEmpty ||
        fromDate == null ||
        toDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    final response = widget.yearId == null
        ? await http.post(
            Uri.parse('${AppConfig.baseUrl}/api/years/add'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'yearName': _yearNameController.text,
              'fromDate': _formatDate(fromDate),
              'toDate': _formatDate(toDate),
              'remarks': _remarksController.text,
            }),
          )
        : await http.put(
            Uri.parse('${AppConfig.baseUrl}/api/years/edit/${widget.yearId}'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'yearName': _yearNameController.text,
              'fromDate': _formatDate(fromDate),
              'toDate': _formatDate(toDate),
              'remarks': _remarksController.text,
            }),
          );

    if (response.statusCode == 201 || response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Year saved successfully')),
      );
      Navigator.pop(context, true); // Pass 'true' indicating success
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to save year: ${response.reasonPhrase}')),
      );
    }
  }

  void _reset() {
    setState(() {
      _yearNameController.clear();
      _remarksController.clear();
      fromDate = null;
      toDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.yearId == null ? 'Add Year' : 'Edit Year'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _yearNameController,
              decoration: const InputDecoration(
                labelText: 'Year Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
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
                      child: Text(_formatDate(fromDate) ?? 'Select date'),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, false),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'To Date',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(_formatDate(toDate) ?? 'Select date'),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _remarksController,
              decoration: const InputDecoration(
                labelText: 'Remarks',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _submit,
                  child:
                      Text(widget.yearId == null ? 'Add Year' : 'Update Year'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _reset,
                  child: const Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ManageYearScreen extends StatefulWidget {
  const ManageYearScreen({super.key});

  @override
  _ManageYearScreenState createState() => _ManageYearScreenState();
}

class _ManageYearScreenState extends State<ManageYearScreen> {
  List<Year> _years = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchYears();
  }

  Future<void> _fetchYears() async {
    final response =
        await http.get(Uri.parse('${AppConfig.baseUrl}/api/years/list'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _years = data.map((e) => Year.fromJson(e)).toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch years')),
      );
    }
  }

  Future<void> _deleteYear(String id) async {
    final response = await http
        .delete(Uri.parse('${AppConfig.baseUrl}/api/years/delete/$id'));
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Year deleted successfully')),
      );
      _fetchYears();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete year')),
      );
    }
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this year?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteYear(id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Years'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _years.isEmpty
              ? const Center(child: Text('No Years Found'))
              : ListView.builder(
                  itemCount: _years.length,
                  itemBuilder: (context, index) {
                    final year = _years[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(year.yearName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('From Date: ${year.fromDate}'),
                            Text('To Date: ${year.toDate}'),
                            Text('Remarks: ${year.remarks}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddYearScreen(
                                      yearId: year.id,
                                      yearName: year.yearName,
                                      fromDate: year.fromDate,
                                      toDate: year.toDate,
                                      remarks: year.remarks,
                                    ),
                                  ),
                                ).then((_) => _fetchYears());
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _confirmDelete(year.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class Year {
  final String id;
  final String yearName;
  final String fromDate;
  final String toDate;
  final String remarks;

  Year({
    required this.id,
    required this.yearName,
    required this.fromDate,
    required this.toDate,
    required this.remarks,
  });

  factory Year.fromJson(Map<String, dynamic> json) {
    return Year(
      id: json['_id'],
      yearName: json['yearName'],
      fromDate: json['fromDate'],
      toDate: json['toDate'],
      remarks: json['remarks'],
    );
  }
}

class AssignStandardScreen extends StatefulWidget {
  const AssignStandardScreen({super.key});

  @override
  _AssignStandardScreenState createState() => _AssignStandardScreenState();
}

class _AssignStandardScreenState extends State<AssignStandardScreen> {
  List<String> standards = [
    '5th Standard',
    '6th Standard',
    '7th Standard',
    '8th Standard',
    '9th Standard',
    '10th Standard',
    '11th Science',
    '11th Commerce',
    '11th Arts',
    '12th Science',
    '12th Commerce',
    '12th Arts'
  ];

  List<String> assignedStandards = [];
  List<String> alreadyAssignedStandards = [];
  Map<String, bool> standardSelections = {};
  bool hasOtherRequirements = false;

  @override
  void initState() {
    super.initState();
    for (var standard in standards) {
      standardSelections[standard] = false;
    }
    _fetchAlreadyAssignedStandards(); // Fetch the already assigned standards when screen loads
  }

  Future<void> _fetchAlreadyAssignedStandards() async {
    try {
      final url =
          Uri.parse('${AppConfig.baseUrl}/api/assignStandard/alreadyAssigned');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['standards'] is List) {
          setState(() {
            alreadyAssignedStandards = List<String>.from(data['standards']);
          });
        } else {
          _showMessage('Unexpected data format');
        }
      } else {
        _showMessage(
            'Failed to load already assigned standards: ${response.reasonPhrase}');
      }
    } catch (e) {
      _showMessage('Error loading assigned standards: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Assign Standard',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildAlreadyAssignedSection(), // New section for already assigned standards
          const SizedBox(height: 20),
          _buildManageStandardSection(),
          const SizedBox(height: 20),
          _buildAssignedStandardSection(),
          const SizedBox(height: 20),
          _buildButtonsSection(),
          const SizedBox(height: 20),
          _buildAdditionalRequirementsCheckbox(),
          const SizedBox(height: 20),
          Row(
            children: [
              ElevatedButton(
                onPressed: _saveAssignment,
                child: const Text('Save Standards'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                  onPressed: _removeAllAssignedStandards,
                  child: const Text('Remove Standards')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlreadyAssignedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Standards Already Assigned:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5),
          ),
          child: alreadyAssignedStandards.isNotEmpty
              ? ListView(
                  shrinkWrap:
                      true, // Allows the ListView to size itself to the content
                  physics:
                      const NeverScrollableScrollPhysics(), // Prevents scrolling inside the container
                  children: alreadyAssignedStandards.map((standard) {
                    return ListTile(
                      title: Text(standard),
                    );
                  }).toList(),
                )
              : const Center(
                  child: Text(
                    'No standards assigned',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildManageStandardSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Manage Standard',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Search by Standard Name',
            suffixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        _buildStandardCheckboxList(),
      ],
    );
  }

  Widget _buildStandardCheckboxList() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        children: standards.map((standard) {
          return CheckboxListTile(
            title: Text(standard),
            value: standardSelections[standard],
            onChanged: (bool? value) {
              setState(() {
                standardSelections[standard] = value!;
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAssignedStandardSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Assigned Standards:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5),
          ),
          child: assignedStandards.isNotEmpty
              ? ListView(
                  shrinkWrap:
                      true, // Allows the ListView to size itself to the content
                  physics:
                      const NeverScrollableScrollPhysics(), // Prevents scrolling inside the container
                  children: assignedStandards.map((assignedStandard) {
                    return ListTile(
                      title: Text(assignedStandard),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            assignedStandards.remove(assignedStandard);
                            _showMessage('Standard removed successfully');
                          });
                        },
                      ),
                    );
                  }).toList(),
                )
              : const Center(
                  child: Text(
                    'No standards selected',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildButtonsSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: _assignStandard,
          child: const Text('Assign Standard'),
        ),
        ElevatedButton(
          onPressed: _removeStandard,
          child: const Text('Remove Standard'),
        ),
      ],
    );
  }

  Widget _buildAdditionalRequirementsCheckbox() {
    return CheckboxListTile(
      title: const Text('Do you have any other Standard requirements?'),
      value: hasOtherRequirements,
      onChanged: (bool? value) {
        setState(() {
          hasOtherRequirements = value!;
        });
      },
    );
  }

  void _assignStandard() {
    List<String> messages = [];
    setState(() {
      final newAssignments = <String>[];
      standardSelections.forEach((key, value) {
        if (value) {
          if (!assignedStandards.contains(key)) {
            newAssignments.add(key);
            assignedStandards.add(key);
          } else {
            messages.add('Subject already assigned: $key');
          }
        }
      });
      if (newAssignments.isEmpty && messages.isEmpty) {
        messages.add('No new subjects to assign');
      }
    });
    if (messages.isNotEmpty) {
      _showMessage(messages.join('\n'));
    }
  }

  void _removeStandard() {
    List<String> messages = [];
    setState(() {
      final removedAssignments = <String>[];
      standardSelections.forEach((key, value) {
        if (value) {
          if (assignedStandards.contains(key)) {
            removedAssignments.add(key);
            assignedStandards.remove(key);
          } else {
            messages.add('Standard not assigned: $key');
          }
        }
      });
      if (removedAssignments.isEmpty && messages.isEmpty) {
        messages.add('No Standard to remove');
      }
    });
    if (messages.isNotEmpty) {
      _showMessage(messages.join('\n'));
    }
  }

  Future<void> _saveAssignment() async {
    if (assignedStandards.isEmpty) {
      _showMessage('Please select at least one standard to assign.');
      return;
    }

    // Fetch currently assigned standards from the server
    final url =
        Uri.parse('${AppConfig.baseUrl}/api/assignStandard/alreadyAssigned');
    final response = await http.get(url);

    List<String> dbAssignedStandards = [];

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['standards'] is List) {
        dbAssignedStandards = List<String>.from(data['standards']);
      }
    } else {
      _showMessage('Failed to fetch assigned standards from the server.');
      return;
    }

    List<String> messages = [];
    final newAssignments = <String>[];

    // Check each standard to see if it's already assigned
    for (final standard in assignedStandards) {
      if (dbAssignedStandards.contains(standard)) {
        messages.add('Subject already assigned: $standard');
      } else {
        newAssignments.add(standard);
      }
    }

    if (newAssignments.isNotEmpty) {
      final saveUrl =
          Uri.parse('${AppConfig.baseUrl}/api/assignStandard/assign');
      final saveResponse = await http.post(
        saveUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'standards': newAssignments,
          'hasOtherRequirements': hasOtherRequirements,
        }),
      );

      if (saveResponse.statusCode == 200 || saveResponse.statusCode == 201) {
        setState(() {
          // Reset checkboxes and assigned standards
          standardSelections.updateAll((key, value) => false);
          assignedStandards.clear();
        });
        _showMessage('Standards saved successfully!');
        _fetchAlreadyAssignedStandards(); // Refresh the already assigned standards
      } else {
        _showMessage('Failed to save standards: ${saveResponse.reasonPhrase}');
      }
    } else {
      _showMessage(messages.join('\n'));
    }
  }

  Future<void> _removeAllAssignedStandards() async {
    if (assignedStandards.isEmpty) {
      _showMessage('No standards to remove');
      return;
    }

    // Fetch currently assigned standards from the server
    final url =
        Uri.parse('${AppConfig.baseUrl}/api/assignStandard/alreadyAssigned');
    final response = await http.get(url);

    List<String> dbAssignedStandards = [];

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['standards'] is List) {
        dbAssignedStandards = List<String>.from(data['standards']);
      }
    } else {
      _showMessage('Failed to fetch assigned standards from the server.');
      return;
    }

    List<String> messages = [];
    final removedAssignments = <String>[];

    // Check each standard to see if it's assigned
    for (final standard in assignedStandards) {
      if (dbAssignedStandards.contains(standard)) {
        removedAssignments.add(standard);
      } else {
        messages.add('Standard not assigned: $standard');
      }
    }

    if (removedAssignments.isNotEmpty) {
      final removeUrl =
          Uri.parse('${AppConfig.baseUrl}/api/assignStandard/remove');
      final removeResponse = await http.post(
        removeUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'standardsToRemove': removedAssignments,
        }),
      );

      if (removeResponse.statusCode == 200) {
        setState(() {
          // Clear assigned standards and reset checkboxes
          assignedStandards.clear();
          standardSelections.updateAll((key, value) => false);
        });
        _showMessage('All assigned standards removed successfully');
        _fetchAlreadyAssignedStandards(); // Refresh the already assigned standards
      } else {
        _showMessage(
            'Failed to remove standards: ${removeResponse.reasonPhrase}');
      }
    } else {
      _showMessage(messages.join('\n'));
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class AssignSubjectScreen extends StatefulWidget {
  const AssignSubjectScreen({super.key});

  @override
  _AssignSubjectScreenState createState() => _AssignSubjectScreenState();
}

class _AssignSubjectScreenState extends State<AssignSubjectScreen> {
  List<String> subjects = [
    'English',
    'Maths',
    'Science',
    'Social Science',
    'Hindi',
    'Marathi',
    'Physics',
    'Chemistry',
    'Biology',
    'OC',
    'SP',
    'Computer Science'
  ];

  List<String> assignedSubjects = [];
  List<String> alreadyAssignedSubjects = [];
  Map<String, bool> subjectSelections = {};
  bool hasOtherRequirements = false;

  @override
  void initState() {
    super.initState();
    for (var subject in subjects) {
      subjectSelections[subject] = false;
    }
    _fetchAlreadyAssignedSubjects();
  }

  Future<void> _fetchAlreadyAssignedSubjects() async {
    try {
      final url =
          Uri.parse('${AppConfig.baseUrl}/api/assignSubject/alreadyAssigned');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['subjects'] is List) {
          setState(() {
            alreadyAssignedSubjects = List<String>.from(data['subjects']);
          });
        } else {
          _showMessage('Unexpected data format');
        }
      } else {
        _showMessage(
            'Failed to load already assigned subjects: ${response.reasonPhrase}');
      }
    } catch (e) {
      _showMessage('Error loading assigned subjects: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Assign Subjects',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildAlreadyAssignedSection(),
          const SizedBox(height: 20),
          _buildManageSubjectSection(),
          const SizedBox(height: 20),
          _buildAssignedSubjectSection(),
          const SizedBox(height: 20),
          _buildButtonsSection(),
          const SizedBox(height: 20),
          _buildAdditionalRequirementsCheckbox(),
          const SizedBox(height: 20),
          Row(
            children: [
              ElevatedButton(
                  onPressed: _saveAssignment,
                  child: const Text('Save Subjects')),
              const SizedBox(width: 30),
              ElevatedButton(
                  onPressed: _removeAllAssignedSubjects,
                  child: const Text('Remove Subjects'))
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlreadyAssignedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Subjects Already Assigned:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(5),
            ),
            child: alreadyAssignedSubjects.isNotEmpty
                ? ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: alreadyAssignedSubjects.map((subject) {
                      return ListTile(
                        title: Text(subject),
                      );
                    }).toList(),
                  )
                : const Center(
                    child: Text(
                      'No Subjects Assigned.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ))
      ],
    );
  }

  Widget _buildManageSubjectSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Manage Subjects: ',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        const TextField(
          decoration: InputDecoration(
              labelText: 'Search by Subject Name',
              suffixIcon: Icon(Icons.search),
              border: OutlineInputBorder()),
        ),
        const SizedBox(height: 10),
        _buildSubjectCheckboxList(),
      ],
    );
  }

  Widget _buildSubjectCheckboxList() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        children: subjects.map((subject) {
          return CheckboxListTile(
            title: Text(subject),
            value: subjectSelections[subject],
            onChanged: (bool? value) {
              setState(() {
                subjectSelections[subject] = value!;
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAssignedSubjectSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Assigned Subjects:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(5),
            ),
            child: assignedSubjects.isNotEmpty
                ? ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: assignedSubjects.map((assignedSubject) {
                      return ListTile(
                        title: Text(assignedSubject),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              assignedSubjects.remove(assignedSubject);
                              _showMessage('Subject removed successfully');
                            });
                          },
                        ),
                      );
                    }).toList(),
                  )
                : const Center(
                    child: Text(
                      'No subjects selected',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ))
      ],
    );
  }

  Widget _buildButtonsSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: _assignSubject,
          child: const Text('Assign Subject'),
        ),
        ElevatedButton(
          onPressed: _removeSubject,
          child: const Text('Remove Subject'),
        ),
      ],
    );
  }

  Widget _buildAdditionalRequirementsCheckbox() {
    return CheckboxListTile(
      title: const Text('Do you have any other Subject requirements?'),
      value: hasOtherRequirements,
      onChanged: (bool? value) {
        setState(() {
          hasOtherRequirements = value!;
        });
      },
    );
  }

  void _assignSubject() {
    List<String> messages = [];
    setState(() {
      final newAssignments = <String>[];
      subjectSelections.forEach((key, value) {
        if (value) {
          if (!assignedSubjects.contains(key)) {
            newAssignments.add(key);
            assignedSubjects.add(key);
          } else {
            messages.add('Subject already assigned: $key');
          }
        }
      });
      if (newAssignments.isEmpty && messages.isEmpty) {
        messages.add('No new subjects to assign');
      }
    });
    if (messages.isNotEmpty) {
      _showMessage(messages.join('\n'));
    }
  }

  void _removeSubject() {
    List<String> messages = [];
    setState(() {
      final removedAssignments = <String>[];
      subjectSelections.forEach((key, value) {
        if (value) {
          if (assignedSubjects.contains(key)) {
            removedAssignments.add(key);
            assignedSubjects.remove(key);
          } else {
            messages.add('Subject not assigned: $key');
          }
        }
      });
      if (removedAssignments.isEmpty && messages.isEmpty) {
        messages.add('No Subject to remove');
      }
    });
    if (messages.isNotEmpty) {
      _showMessage(messages.join('\n'));
    }
  }

  Future<void> _saveAssignment() async {
    if (assignedSubjects.isEmpty) {
      _showMessage('Please select at least one subject to assign.');
      return;
    }

    final url =
        Uri.parse('${AppConfig.baseUrl}/api/assignSubject/alreadyAssigned');
    final response = await http.get(url);

    List<String> dbAssignedSubjects = [];

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['subjects'] is List) {
        dbAssignedSubjects = List<String>.from(data['subjects']);
      }
    } else {
      _showMessage('Failed to fetch assigned subjects from the server.');
      return;
    }

    List<String> messages = [];
    final newAssignments = <String>[];

    for (final subject in assignedSubjects) {
      if (dbAssignedSubjects.contains(subject)) {
        messages.add('Subject already assigned: $subject');
      } else {
        newAssignments.add(subject);
      }
    }

    if (newAssignments.isNotEmpty) {
      final saveUrl =
          Uri.parse('${AppConfig.baseUrl}/api/assignSubject/assign');
      final saveResponse = await http.post(
        saveUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'assignedSubjects': newAssignments,
          'otherRequirements': hasOtherRequirements,
        }),
      );

      if (saveResponse.statusCode == 200) {
        _showMessage('Subjects assigned successfully');

        // Clear selections and refresh the screen
        setState(() {
          assignedSubjects.clear();
          for (var subject in subjects) {
            subjectSelections[subject] = false;
          }
        });

        await _fetchAlreadyAssignedSubjects(); // Refresh assigned subjects from the server
      } else {
        _showMessage('Failed to assign subjects');
      }
    }

    if (messages.isNotEmpty) {
      _showMessage(messages.join('\n'));
    }
  }

  Future<void> _removeAllAssignedSubjects() async {
    // Check which subjects are assigned
    List<String> subjectsToRemove = assignedSubjects.where((subject) {
      return alreadyAssignedSubjects.contains(subject);
    }).toList();

    if (subjectsToRemove.isEmpty) {
      _showMessage('Subjects not currently assigned.');
      return;
    }

    final url = Uri.parse('${AppConfig.baseUrl}/api/assignSubject/remove');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'subjectsToRemove': subjectsToRemove}),
    );

    if (response.statusCode == 200) {
      _showMessage('Assigned subjects removed successfully');

      // Clear selections and refresh the screen
      setState(() {
        assignedSubjects.clear();
        for (var subject in subjects) {
          subjectSelections[subject] = false;
        }
      });

      await _fetchAlreadyAssignedSubjects(); // Refresh assigned subjects from the server
    } else {
      // If the response indicates some subjects were not assigned
      final responseData = jsonDecode(response.body);
      if (responseData['message'] != null) {
        _showMessage(responseData['message']);
      } else {
        _showMessage('Failed to remove assigned subjects');
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    ));
  }
}

class AddClassBatchScreen extends StatefulWidget {
  const AddClassBatchScreen({super.key});

  @override
  _AddClassBatchScreenState createState() => _AddClassBatchScreenState();
}

class _AddClassBatchScreenState extends State<AddClassBatchScreen> {
  final _formKey = GlobalKey<FormState>();
  String? classBatchName;
  int? strength;
  TimeOfDay? fromTime;
  TimeOfDay? toTime;

  Future<void> _selectTime(BuildContext context, bool isFromTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime:
          isFromTime ? fromTime ?? TimeOfDay.now() : toTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isFromTime) {
          fromTime = picked;
        } else {
          toTime = picked;
        }
      });
    }
  }

  Future<void> _saveClassBatch() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/class-batch'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'classBatchName': classBatchName,
          'strength': strength,
          'fromTime': fromTime!.format(context),
          'toTime': toTime!.format(context),
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Class/Batch created successfully!')),
        );
        _formKey.currentState!.reset();
        setState(() {
          fromTime = null;
          toTime = null;
        });
      } else {
        // Handle the error if classBatchName already exists
        final responseBody = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  responseBody['message'] ?? 'Failed to create Class/Batch')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create New Class/Batch',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Class/Batch Name *',
                hintText: 'e.g. Class Room A 1',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a class/batch name';
                }
                return null;
              },
              onSaved: (value) {
                classBatchName = value;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Strength *',
                hintText: 'e.g. 30',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the strength';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
              onSaved: (value) {
                strength = int.tryParse(value!);
              },
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectTime(context, true),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'From Time *',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        fromTime != null
                            ? fromTime!.format(context)
                            : 'Select time',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectTime(context, false),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'To Time *',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        toTime != null
                            ? toTime!.format(context)
                            : 'Select time',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveClassBatch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                    ),
                    child: const Text('SAVE'),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _formKey.currentState!.reset();
                      setState(() {
                        fromTime = null;
                        toTime = null;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[900],
                    ),
                    child: const Text('RESET'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Model class for ClassBatch
class ClassBatch {
  final String id;
  final String classBatchName;
  final int strength;
  final String fromTime;
  final String toTime;

  ClassBatch({
    required this.id,
    required this.classBatchName,
    required this.strength,
    required this.fromTime,
    required this.toTime,
  });

  factory ClassBatch.fromJson(Map<String, dynamic> json) {
    return ClassBatch(
      id: json['_id'],
      classBatchName: json['classBatchName'],
      strength: json['strength'],
      fromTime: json['fromTime'],
      toTime: json['toTime'],
    );
  }
}

// Dialog for editing a class batch
class EditClassBatchDialog extends StatefulWidget {
  final ClassBatch batch;

  const EditClassBatchDialog({super.key, required this.batch});

  @override
  _EditClassBatchDialogState createState() => _EditClassBatchDialogState();
}

class _EditClassBatchDialogState extends State<EditClassBatchDialog> {
  late TextEditingController _nameController;
  late TextEditingController _strengthController;
  late TextEditingController _fromTimeController;
  late TextEditingController _toTimeController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.batch.classBatchName);
    _strengthController =
        TextEditingController(text: widget.batch.strength.toString());
    _fromTimeController = TextEditingController(text: widget.batch.fromTime);
    _toTimeController = TextEditingController(text: widget.batch.toTime);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Class/Batch'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Class/Batch Name'),
          ),
          TextField(
            controller: _strengthController,
            decoration: const InputDecoration(labelText: 'Strength'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _fromTimeController,
            decoration: const InputDecoration(labelText: 'From Time'),
          ),
          TextField(
            controller: _toTimeController,
            decoration: const InputDecoration(labelText: 'To Time'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final updatedBatch = ClassBatch(
              id: widget.batch.id,
              classBatchName: _nameController.text,
              strength: int.tryParse(_strengthController.text) ?? 0,
              fromTime: _fromTimeController.text,
              toTime: _toTimeController.text,
            );
            Navigator.of(context).pop(updatedBatch);
          },
          child: const Text('Update'),
        ),
      ],
    );
  }
}

class ManageClassBatchScreen extends StatefulWidget {
  const ManageClassBatchScreen({super.key});

  @override
  _ManageClassBatchScreenState createState() => _ManageClassBatchScreenState();
}

class _ManageClassBatchScreenState extends State<ManageClassBatchScreen> {
  List<ClassBatch> _classBatches = [];
  List<ClassBatch> _filteredClassBatches = [];

  @override
  void initState() {
    super.initState();
    _fetchClassBatches();
  }

  Future<void> _fetchClassBatches() async {
    final response =
        await http.get(Uri.parse('${AppConfig.baseUrl}/api/class-batch'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _classBatches = data.map((json) => ClassBatch.fromJson(json)).toList();
        _filteredClassBatches = _classBatches;
      });
    } else {
      throw Exception('Failed to load class batches');
    }
  }

  Future<void> _deleteClassBatch(String id) async {
    final response = await http
        .delete(Uri.parse('${AppConfig.baseUrl}/api/class-batch/$id'));
    if (response.statusCode == 200) {
      setState(() {
        _classBatches.removeWhere((batch) => batch.id == id);
        _filteredClassBatches.removeWhere((batch) => batch.id == id);
      });
    } else {
      throw Exception('Failed to delete Class/Batch');
    }
  }

  void _filterClassBatches(String query) {
    setState(() {
      _filteredClassBatches = _classBatches
          .where((batch) =>
              batch.classBatchName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _editClassBatch(ClassBatch batch) async {
    final updatedBatch = await showDialog<ClassBatch>(
      context: context,
      builder: (context) => EditClassBatchDialog(batch: batch),
    );

    if (updatedBatch != null) {
      final response = await http.put(
        Uri.parse('${AppConfig.baseUrl}/api/class-batch/${updatedBatch.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'classBatchName': updatedBatch.classBatchName,
          'strength': updatedBatch.strength,
          'fromTime': updatedBatch.fromTime,
          'toTime': updatedBatch.toTime,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          final index =
              _classBatches.indexWhere((b) => b.id == updatedBatch.id);
          if (index != -1) {
            _classBatches[index] = updatedBatch;
            _filteredClassBatches[index] = updatedBatch;
          }
        });
      } else {
        // Handle the error if classBatchName already exists
        final responseBody = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  responseBody['message'] ?? 'Failed to update class batch')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Manage Class/Batch'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: _filterClassBatches,
              decoration: const InputDecoration(
                hintText: 'Search...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredClassBatches.length,
              itemBuilder: (context, index) {
                final batch = _filteredClassBatches[index];
                return ListTile(
                  title: Text(batch.classBatchName),
                  subtitle: Text(
                      'Strength: ${batch.strength} \nFrom: ${batch.fromTime} \nTo: ${batch.toTime}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editClassBatch(batch),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteClassBatch(batch.id),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ManageTimeTableScreen extends StatefulWidget {
  const ManageTimeTableScreen({super.key});

  @override
  _ManageTimeTableScreenState createState() => _ManageTimeTableScreenState();
}

class _ManageTimeTableScreenState extends State<ManageTimeTableScreen> {
  final TextEditingController _standardController = TextEditingController();
  final TextEditingController _batchController = TextEditingController();
  bool isEditable = false;

  List<List<String?>> _timeTable =
      List.generate(5, (i) => List.filled(6, null)); // 5 time slots, 6 days

  Future<void> _viewTimeTable() async {
    final standard = _standardController.text;
    final batch =
        _batchController.text.toLowerCase(); // Convert to lowercase here

    if (standard.isEmpty || batch.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter standard and batch')),
      );
      return;
    }

    try {
      final response = await http.get(Uri.parse(
          '${AppConfig.baseUrl}/api/timetable?standard=$standard&batch=$batch')); // Use the lowercase batch directly

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        setState(() {
          _timeTable = List.generate(5, (i) => List.filled(6, null));
          for (var item in data) {
            int day = item['day'] ?? 0; // Default to 0 if null
            int timeSlot = item['timeSlot'] ?? 0; // Default to 0 if null
            if (timeSlot >= 0 && timeSlot < 5 && day >= 0 && day < 6) {
              _timeTable[timeSlot][day] = item['subject']; // Allow null
            }
          }
          isEditable = false;
        });
      } else if (response.statusCode == 404) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Standard/Batch not found. Creating new timetable.')),
        );
        await _createNewTimeTable(standard, batch);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${response.statusCode}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load timetable: $e')));
    }
  }

  Future<void> _createNewTimeTable(String standard, String batch) async {
    final newTimeTable =
        List.generate(5, (i) => List.filled(6, null)); // Allow null values

    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/api/timetable/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'standard': standard,
        'batch': batch.toLowerCase(),
        'timetable': newTimeTable,
      }),
    );

    if (response.statusCode == 201) {
      setState(() {
        _timeTable = newTimeTable; // Refresh the timetable to empty
        isEditable = false; // Exit edit mode
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New timetable created successfully.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create new timetable.')),
      );
    }
  }

  Future<void> _updateTimeTable() async {
    final standard = _standardController.text;
    final batch = _batchController.text;

    if (standard.isEmpty || batch.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter standard and batch')),
      );
      return;
    }

    final updatedData = _timeTable
        .expand((row) => row.asMap().entries.map((e) => {
              'day': e.key,
              'timeSlot': _timeTable.indexOf(row),
              'subject': e.value, // Allow null
            }))
        .toList();

    final response = await http.put(
      Uri.parse('${AppConfig.baseUrl}/api/timetable/update'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'standard': standard,
        'batch': batch.toLowerCase(),
        'timetable': updatedData,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        isEditable = false; // Exit edit mode after update
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Timetable updated successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update timetable')),
      );
    }
  }

  Future<void> _deleteTimeTable(String standard, String batch) async {
    if (standard.isEmpty || batch.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Standard and Batch cannot be empty')),
      );
      return;
    }

    final response = await http.delete(
      Uri.parse(
        '${AppConfig.baseUrl}/api/timetable/delete?standard=$standard&batch=${batch.toLowerCase()}',
      ),
    );

    if (response.statusCode == 200) {
      setState(() {
        _timeTable =
            List.generate(5, (i) => List.filled(6, null)); // Clear timetable
        _standardController.clear();
        _batchController.clear();
        isEditable = false; // Exit edit mode
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Timetable deleted successfully')),
      );
    } else {
      // Handle specific status codes for better debugging
      String message;
      if (response.statusCode == 404) {
        message = 'Timetable not found';
      } else {
        message = 'Error: ${response.statusCode}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete timetable: $message')),
      );
    }
  }

  void _resetFields() {
    _standardController.clear();
    _batchController.clear();
    setState(() {
      _timeTable =
          List.generate(5, (i) => List.filled(6, null)); // Clear timetable
      isEditable = false; // Reset edit state
    });
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content:
              const Text('Are you sure you want to delete this timetable?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteTimeTable(
                    _standardController.text, _batchController.text);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Time Table'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _standardController,
              decoration: const InputDecoration(
                labelText: 'Enter Standard *',
                hintText: 'e.g. 9th',
              ),
            ),
            TextField(
              controller: _batchController,
              decoration: const InputDecoration(
                labelText: 'Enter Batch *',
                hintText: 'e.g. Morning/Afternoon/Evening',
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _viewTimeTable,
                  child: const Text('View'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_standardController.text.isNotEmpty &&
                        _batchController.text.isNotEmpty) {
                      setState(() {
                        isEditable = !isEditable;
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please enter standard and batch')),
                      );
                    }
                  },
                  child: Text(isEditable ? 'Cancel Edit' : 'Edit'),
                ),
                ElevatedButton(
                  onPressed: _resetFields,
                  child: const Text('Reset'),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            const Text(
              'Timetable:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Expanded(
                    child: Text('Timing',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                const SizedBox(width: 8),
                for (var day in ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'])
                  Expanded(
                      child: Text(day,
                          style: const TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
            const SizedBox(height: 10),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: 5, // Only 5 rows for time slots
              itemBuilder: (context, timeSlotIndex) {
                return Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Time Slot ${timeSlotIndex + 1}',
                          enabled: isEditable,
                        ),
                        onChanged: (value) {
                          _timeTable[timeSlotIndex][0] = value.isEmpty
                              ? null
                              : value; // Store the time slot as nullable
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    for (var dayIndex = 0; dayIndex < 6; dayIndex++) ...[
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            enabled: isEditable,
                          ),
                          onChanged: (value) {
                            _timeTable[timeSlotIndex][dayIndex] = value.isEmpty
                                ? null
                                : value; // Update subject to allow null
                          },
                          controller: TextEditingController(
                            text: _timeTable[timeSlotIndex][dayIndex] ?? '',
                          ),
                        ),
                      ),
                      if (dayIndex < 5) const SizedBox(width: 10), // Spacing
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton(
                  onPressed: isEditable ? _updateTimeTable : null,
                  child: const Text('Update Timetable'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: isEditable ? _confirmDelete : null,
                  child: const Text('Delete Timetable'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
