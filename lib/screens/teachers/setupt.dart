import 'package:flutter/material.dart';

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
  const AddYearScreen({super.key});

  @override
  _AddYearScreenState createState() => _AddYearScreenState();
}

class _AddYearScreenState extends State<AddYearScreen> {
  DateTime? fromDate;
  DateTime? toDate;

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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Add Year',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          TextFormField(
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
                    child: Text(
                      fromDate != null
                          ? "${fromDate!.toLocal()}".split(' ')[0]
                          : 'Select date',
                    ),
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
                    child: Text(
                      toDate != null
                          ? "${toDate!.toLocal()}".split(' ')[0]
                          : 'Select date',
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Remarks',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Handle submit
              // You can access fromDate and toDate here
            },
            child: const Text('Reset'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Handle submit
              // You can access fromDate and toDate here
            },
            child: const Text('Submit'),
          ),
        ],
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
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        // Handle save action
                      }
                    },
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

class ManageTimeTableScreen extends StatefulWidget {
  const ManageTimeTableScreen({super.key});

  @override
  _ManageTimeTableScreenState createState() => _ManageTimeTableScreenState();
}

class _ManageTimeTableScreenState extends State<ManageTimeTableScreen> {
  final TextEditingController _standardController = TextEditingController();
  final TextEditingController _batchController = TextEditingController();

  bool isEditable = false; // Controls whether the grid is editable or not

  // Sample timetable data (normally this would be fetched from a database)
  List<List<String?>> _timeTable =
  List.generate(5, (i) => List.filled(5, null));

  void _viewTimeTable() {
    setState(() {
      // Example: Fetch timetable based on standard and batch
      // This should be replaced with real data fetching logic
      _timeTable = [
        ['Math', 'Science', 'English', 'History', 'PE'],
        ['Physics', 'Chemistry', 'Biology', 'Geography', 'Art'],
        ['Math', 'Science', 'English', 'History', 'PE'],
        ['Physics', 'Chemistry', 'Biology', 'Geography', 'Art'],
        ['Math', 'Science', 'English', 'History', 'PE'],
      ];
      isEditable = false;
    });
  }

  void _resetTimeTable() {
    setState(() {
      isEditable = true;
    });
  }

  void _updateTimeTable() {
    setState(() {
      // Example: Save the updated timetable
      // This should be replaced with real data saving logic
      isEditable = false;
      // Save _timeTable to the database or backend
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _viewTimeTable,
                  child: const Text('View'),
                ),
                ElevatedButton(
                  onPressed: _resetTimeTable,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                  ),
                  child: const Text('Reset'),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Timetable:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5, // 5 columns for Mon-Fri
                  childAspectRatio: 2,
                ),
                itemCount: 25, // 5 days * 5 time slots (can be adjusted)
                itemBuilder: (context, index) {
                  int day = index % 5; // Day (Mon-Fri)
                  int timeSlot = index ~/ 5; // Time slot index

                  return GestureDetector(
                    onTap: isEditable
                        ? () async {
                      String? newLecture = await _editLectureDialog(
                          _timeTable[timeSlot][day]);
                      if (newLecture != null) {
                        setState(() {
                          _timeTable[timeSlot][day] = newLecture;
                        });
                      }
                    }
                        : null,
                    child: Container(
                      margin: const EdgeInsets.all(4.0),
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        color: isEditable ? Colors.white : Colors.grey[300],
                      ),
                      child: Center(
                        child: Text(
                          _timeTable[timeSlot][day] ?? '',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: isEditable ? _updateTimeTable : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Update Time Table'),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _editLectureDialog(String? currentLecture) async {
    String? newLecture = currentLecture;
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Lecture'),
          content: TextField(
            controller: TextEditingController(text: newLecture),
            onChanged: (value) {
              newLecture = value;
            },
            decoration: const InputDecoration(hintText: 'Enter Lecture Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(newLecture);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}