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

    // Check for successful response
    if (response.statusCode == 200) {
      print("Logbook saved successfully");
    } else {
      // Log the error response body if the status code is not 200
      print("Failed to save logbook: ${response.body}");
    }
  } catch (e) {
    print("Error saving logbook: $e");
  }
}


  Future<List<dynamic>> fetchLogbook(String month) async {
  try {
    final response = await http.get(Uri.parse('${AppConfig.baseUrl}/logbook?month=$month'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data']; // Access data field directly
    } else {
      throw Exception('Failed to load logbook: ${response.body}');
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
  final List<String> _months = [
    'January', 'February', 'March', 'April',
    'May', 'June', 'July', 'August',
    'September', 'October', 'November', 'December'
  ];
  String? _selectedMonth; // Holds the selected month
  bool isEditable = false; // Controls whether the grid is editable or not
  List<List<String?>> _logbook = List.generate(4, (i) => List.filled(4, null));

  // View Logbook based on month
  void _viewLogbook() async {
    if (_selectedMonth == null) {
      // Show error if no month is selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a month')),
      );
      return;
    }

    List<dynamic> fetchedData = await LogBookService().fetchLogbook(_selectedMonth!);

    setState(() {
      // Ensure the fetchedData is structured correctly
      _logbook = List.generate(4, (i) => List.filled(4, null)); // Reset logbook

      for (var row in fetchedData) {
        int timeSlot = (row['timing'] as int) - 1; // Adjusting to 0 index
        _logbook[timeSlot] = [
          row['date']?.toString(),
          row['timing']?.toString(),
          row['subject']?.toString(),
          row['topic']?.toString(),
        ];
      }
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
      appBar: AppBar(title: const Text('Logbook')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedMonth,
              hint: const Text('Select Month'),
              items: _months.map((String month) {
                return DropdownMenuItem<String>(
                  value: month,
                  child: Text(month),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  _selectedMonth = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Month *',
                border: OutlineInputBorder(),
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
                  child: const Text('Edit Logbook'),
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
                Text("Topic"),
              ],
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 2,
                ),
                itemCount: 16, // 4 days * 4 time slots
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
              child: const Text('Save Logbook'),
            ),
          ],
        ),
      ),
    );
  }
}
