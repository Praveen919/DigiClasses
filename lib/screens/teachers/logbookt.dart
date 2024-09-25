import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:testing_app/screens/config.dart';

// LogBookService Class for HTTP Requests
class LogBookService {
  final String apiUrl = "${AppConfig.baseUrl}/api/logbook"; // Use HTTP

  // Function to save logbook data to the backend
  Future<void> saveLogbook(List<Map<String, dynamic>> logbookData) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(logbookData),
      );

      if (response.statusCode == 200) {
        print("Logbook saved successfully");
      } else {
        print("Failed to save logbook. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error saving logbook: $e");
    }
  }

  // Function to fetch logbook data from the backend for a specific month
  Future<List<dynamic>> fetchLogbook(String month) async {
    try {
      final response = await http.get(Uri.parse('$apiUrl?month=$month'));

      if (response.statusCode == 200) {
        List<dynamic> logbook = jsonDecode(response.body);
        return logbook;
      } else {
        print("Failed to fetch logbook. Status code: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Error fetching logbook: $e");
      return [];
    }
  }
}

// LogBookScreen for UI and Data Entry
class LogBookScreen extends StatefulWidget {
  const LogBookScreen({super.key});

  @override
  _LogBookScreenState createState() => _LogBookScreenState();
}

class _LogBookScreenState extends State<LogBookScreen> {
  final TextEditingController _standardController = TextEditingController();
  bool isEditable = false; // Controls whether the grid is editable or not
  List<List<String?>> _logbook = List.generate(4, (i) => List.filled(4, null));

  // View Logbook based on month
  void _viewLogbook() async {
    String month = _standardController.text; // Get month from input
    List<dynamic> fetchedData = await LogBookService().fetchLogbook(month);

    setState(() {
      _logbook = fetchedData.map<List<String?>>((row) {
        return [row['date'], row['timing'], row['subject'], row['topic']];
      }).toList();
      isEditable = false;
    });
  }

  // Enable editing mode
  void _resetLogbook() {
    setState(() {
      isEditable = true;
    });
  }

  // Update and save logbook to backend
  void _updateLogbook() async {
    List<Map<String, dynamic>> logbookData = _logbook.map((row) {
      return {
        'date': row[0],
        'timing': row[1],
        'subject': row[2],
        'topic': row[3],
      };
    }).toList();

    await LogBookService().saveLogbook(logbookData);

    setState(() {
      isEditable = false;
    });
  }

  // Dialog for editing a specific log entry
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
}

