import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:testing_app/screens/config.dart';

class SetupT extends StatelessWidget {
  final String option;

  const SetupT({super.key, this.option = 'addYear'});

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
      case 'addClassBatch':
        return const AddClassBatchScreen();
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
        automaticallyImplyLeading: false,
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

      try {
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
          // Success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Class/Batch created successfully!')),
          );
          _formKey.currentState!.reset();
          setState(() {
            fromTime = null;
            toTime = null;
          });
        } else {
          // Check if response body is JSON
          if (response.headers['content-type']?.contains('application/json') ==
              true) {
            final responseBody = jsonDecode(response.body);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    responseBody['message'] ?? 'Failed to create Class/Batch'),
              ),
            );
          } else {
            // If response is not JSON, handle it as plain text or error page
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Failed to create Class/Batch: ${response.statusCode}'),
              ),
            );
          }
        }
      } catch (e) {
        // Handle network or other errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
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
    final batch = _batchController.text.toLowerCase(); // Convert to lowercase

    if (standard.isEmpty || batch.isEmpty) {
      _showSnackBar('Please enter standard and batch');
      return;
    }

    try {
      final response = await http.get(Uri.parse(
          '${AppConfig.baseUrl}/api/timetable?standard=$standard&batch=$batch')); // Use lowercase batch

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Check if the data is a Map and contains a 'message' (meaning it's not a timetable but an info message)
        if (data is Map<String, dynamic> && data.containsKey('message')) {
          _showSnackBar(data['message']); // Display the message from the server
        }
        // Otherwise, assume it's a timetable list
        else if (data is List) {
          _updateTimeTableFromResponse(response); // Process timetable
        } else {
          _showSnackBar('Unexpected data format received');
        }
      } else if (response.statusCode == 404) {
        _showSnackBar('Standard/Batch not found. Creating new timetable.');
        await _createNewTimeTable(standard, batch);
      } else {
        _showSnackBar('Error: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackBar('Failed to load timetable: $e');
    }
  }

  Future<void> _createNewTimeTable(String standard, String batch) async {
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/api/timetable/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'standard': standard,
        'batch': batch.toLowerCase(),
        'timetable': _timeTable, // Use the existing timetable structure
      }),
    );

    if (response.statusCode == 201) {
      _resetTimetable();
      _showSnackBar('New timetable created successfully.');
    } else {
      _showSnackBar('Failed to create new timetable.');
    }
  }

  Future<void> _updateTimeTable() async {
    final standard = _standardController.text.trim();
    final batch = _batchController.text.trim();

    if (standard.isEmpty || batch.isEmpty) {
      _showSnackBar('Please enter standard and batch');
      return;
    }

    // Map the timetable into the format expected by the backend
    final updatedTimeTable = _timeTable.asMap().entries.map((entry) {
      final timeSlotIndex = entry.key;
      final timeSlot = entry.value;

      return {
        'time': 'Time Slot ${timeSlotIndex + 1}',
        'lectures': timeSlot
            .asMap()
            .entries
            .map((e) {
              final dayIndex = e.key;
              final subject = e.value?.trim(); // Trim whitespace

              if (subject == null || subject.isEmpty) {
                return null; // Ignore empty or whitespace-only entries
              }

              return {
                'day': dayIndex,
                'subject': subject,
              };
            })
            .where((lecture) => lecture != null) // Remove null lectures
            .toList(),
      };
    }).toList();

    // Send the update request
    final response = await http.put(
      Uri.parse('${AppConfig.baseUrl}/api/timetable/update'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'standard': standard,
        'batch': batch.toLowerCase(),
        'timetable': updatedTimeTable,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        isEditable = false; // Exit edit mode after update
      });
      _showSnackBar('Timetable updated successfully');
    } else {
      _showSnackBar('Failed to update timetable');
    }
  }

  Future<void> _deleteTimeTable(String standard, String batch) async {
    if (standard.isEmpty || batch.isEmpty) {
      _showSnackBar('Standard and Batch cannot be empty');
      return;
    }

    final response = await http.delete(
      Uri.parse(
        '${AppConfig.baseUrl}/api/timetable/delete?standard=$standard&batch=${batch.toLowerCase()}',
      ),
    );

    if (response.statusCode == 200) {
      _resetTimetable();
      _showSnackBar('Timetable deleted successfully');
    } else {
      String message = (response.statusCode == 404)
          ? 'Timetable not found'
          : 'Error: ${response.statusCode}';
      _showSnackBar('Failed to delete timetable: $message');
    }
  }

  void _resetTimetable() {
    setState(() {
      _timeTable =
          List.generate(5, (i) => List.filled(6, null)); // Clear timetable
      _standardController.clear();
      _batchController.clear();
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

  void _updateTimeTableFromResponse(http.Response response) {
    final data = jsonDecode(response.body) as List<dynamic>;

    setState(() {
      // Initialize the timetable with 5 time slots and 7 periods (for 6 days + timing)
      _timeTable = List.generate(5, (i) => List.filled(7, null));

      for (var item in data) {
        int day = item['day'] ?? 0; // Default to 0 if null
        int timeSlot = item['timeSlot'] ?? 0; // Default to 0 if null
        if (timeSlot >= 0 && timeSlot < 5 && day >= 0 && day < 6) {
          _timeTable[timeSlot][day] = item['subject']; // Allow null
        }
      }
      isEditable = false; // Exit edit mode after update
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
                      _showSnackBar('Please enter standard and batch');
                    }
                  },
                  child: Text(isEditable ? 'Cancel Edit' : 'Edit'),
                ),
                ElevatedButton(
                  onPressed: _resetTimetable,
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
                            text: _timeTable[timeSlotIndex][dayIndex],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            if (isEditable)
              ElevatedButton(
                onPressed: _updateTimeTable,
                child: const Text('Update Timetable'),
              ),
            if (!isEditable)
              ElevatedButton(
                onPressed: () => _confirmDelete(),
                child: const Text('Delete Timetable'),
              ),
          ],
        ),
      ),
    );
  }
}
