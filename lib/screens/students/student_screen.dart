
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class StudentScreen extends StatelessWidget {
  const StudentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('View My Attendance'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ViewMyAttendanceScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('View Share Documents'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ViewSharedDocumentsScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('Give Feedback'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GiveFeedbackScreen()),
              );
            },
          ),
          // Add more ListTile items if needed
        ],
      ),
    );
  }
}



class ViewMyAttendanceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Attendance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Handle refresh action
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Attendance Summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Attendance Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8.0),
                    Text('Total Classes: 30'),
                    Text('Classes Attended: 25'),
                    Text('Classes Missed: 5'),
                    Text('Attendance Percentage: 83.33%'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            // Calendar View (Placeholder)
            const Text('Attendance Calendar (Coming Soon)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16.0),

            // Detailed Attendance Data
            Expanded(
              child: ListView.builder(
                itemCount: attendanceData.length, // Replace with actual count
                itemBuilder: (context, index) {
                  final attendance = attendanceData[index];
                  return ListTile(
                    title: Text(attendance['subject'] ?? 'No Subject'),
                    subtitle: Text('Date: ${attendance['date']}'),
                    trailing: Text(attendance['status'] ?? 'Unknown'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Sample data for demonstration
  final List<Map<String, String>> attendanceData = [
    {'subject': 'Math', 'date': DateFormat('dd-MM-yyyy').format(DateTime.now().subtract(Duration(days: 2))), 'status': 'Attended'},
    {'subject': 'Science', 'date': DateFormat('dd-MM-yyyy').format(DateTime.now().subtract(Duration(days: 1))), 'status': 'Missed'},
    {'subject': 'History', 'date': DateFormat('dd-MM-yyyy').format(DateTime.now()), 'status': 'Attended'},
  ];
}
class ViewSharedDocumentsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared Documents'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Handle search action
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Handle refresh action
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search documents',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),

            // Document List
            Expanded(
              child: ListView.builder(
                itemCount: sharedDocuments.length, // Replace with actual count
                itemBuilder: (context, index) {
                  final document = sharedDocuments[index];
                  return ListTile(
                    title: Text(document['title'] ?? 'No Title'),
                    subtitle: Text('Type: ${document['type'] ?? 'Unknown'}'),
                    trailing: IconButton(
                      icon: Icon(Icons.download),
                      onPressed: () {
                        // Handle document download or view action
                        // For example, you might use a package to open the document
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Sample data for demonstration
  final List<Map<String, String>> sharedDocuments = [
    {'title': 'Math Assignment', 'type': 'PDF', 'dateAdded': '01-09-2024'},
    {'title': 'Science Lab Report', 'type': 'PDF', 'dateAdded': '05-09-2024'},
    {'title': 'History Notes', 'type': 'Word', 'dateAdded': '10-09-2024'},
  ];
}
class GiveFeedbackScreen extends StatelessWidget {
  final TextEditingController _feedbackController = TextEditingController();
  final int _rating = 0; // Replace with actual rating logic if needed

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Give Feedback'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Feedback Text Field
            TextField(
              controller: _feedbackController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Enter your feedback here...',
                border: OutlineInputBorder(),
                labelText: 'Feedback',
              ),
            ),
            const SizedBox(height: 16.0),

            // Optional Rating System
            Text('Rate Your Experience:'),
            Row(
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: () {
                    // Handle rating logic
                  },
                );
              }),
            ),
            const SizedBox(height: 16.0),

            // Optional Feedback Category
            Text('Feedback Category:'),
            DropdownButton<String>(
              value: 'Course',
              onChanged: (String? newValue) {
                // Handle category change
              },
              items: <String>['Course', 'Instructor', 'App', 'Other']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 16.0),

            // Submit Button
            ElevatedButton(
              onPressed: () {
                String feedbackText = _feedbackController.text;
                // Check if feedback is not empty
                if (feedbackText.isNotEmpty) {
                  // Process the feedback (e.g., send it to a server)
                  submitFeedback(feedbackText, _rating);
                  // Show confirmation message or navigate back
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Feedback Submitted'),
                      content: const Text('Thank you for your feedback!'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop(); // Optionally navigate back
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                } else {
                  // Show an error message if feedback is empty
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Error'),
                      content: const Text('Please enter your feedback before submitting.'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: const Text('Submit Feedback'),
            ),
          ],
        ),
      ),
    );
  }

  // Example method to handle feedback submission
  void submitFeedback(String feedbackText, int rating) {
    // Implement the feedback submission logic
    // For example, send the feedbackText and rating to a server
  }
}
