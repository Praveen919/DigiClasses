import 'package:flutter/material.dart';

class LogbookT extends StatelessWidget {
  const LogbookT({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logbook'),
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    return const LogBookScreen();
  }
}

class LogBookScreen extends StatefulWidget {
  const LogBookScreen({super.key});

  @override
  _LogBookScreenState createState() => _LogBookScreenState();
}

class _LogBookScreenState extends State<LogBookScreen> {
  final TextEditingController _standardController = TextEditingController();

  bool isEditable = false; // Controls whether the grid is editable or not

  // Sample logbook data (normally this would be fetched from a database)
  List<List<String?>> _logbook = List.generate(4, (i) => List.filled(4, null));

  void _viewLogbook() {
    setState(() {
      // Example: Fetch logbook based on standard and batch
      // This should be replaced with real data fetching logic
      _logbook = [
        ['01/01/2024', '9:30-10:30', 'English', 'Lesson 1'],
        ['01/01/2024', '10:30-11:30', 'Biology', 'Lesson 1'],
        ['02/01/2024', '9:30-10:30', 'History', 'Lesson 1'],
        ['02/01/2024', '10:30-11:30', 'Geography', 'Lesson 1'],
        ['02/01/2024', '11:30-12:30', 'Physics', 'Lesson 1'],
      ];
      isEditable = false;
    });
  }

  void _resetLogbook() {
    setState(() {
      isEditable = true;
    });
  }

  void _updateLogbook() {
    setState(() {
      // Example: Save the updated logbook
      // This should be replaced with real data saving logic
      isEditable = false;
      // Save _Logbook to the database or backend
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
                labelText: 'Enter Month *',
                hintText: 'e.g. January',
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _viewLogbook,
                  child: const Text('View Logbook'),
                ),
                ElevatedButton(
                  onPressed: _resetLogbook,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                  ),
                  child: const Text('Update Logbook'),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            const Row(
              children: [
                SizedBox(width: 26),
                Text("Date"),
                SizedBox(width: 47),
                Text("Timing"),
                SizedBox(width: 34),
                Text("Subject"),
                SizedBox(width: 36),
                Text("Topic")
              ],
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 2,
                ),
                itemCount: 16, // 5 days * 5 time slots (can be adjusted)
                itemBuilder: (context, index) {
                  int day = index % 4;
                  int timeSlot = index ~/ 4;

                  return GestureDetector(
                    onTap: isEditable
                        ? () async {
                      String? newLecture = await _editLectureDialog(
                          _logbook[timeSlot][day]);
                      if (newLecture != null) {
                        setState(() {
                          _logbook[timeSlot][day] = newLecture;
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
                          _logbook[timeSlot][day] ?? '',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: isEditable ? _updateLogbook : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Update Logbook'),
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
