import 'package:flutter/material.dart';
//import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

class ExamScreen extends StatelessWidget {
  final String option;

  ExamScreen({this.option = 'viewManualExam'});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exam'),
      ),
      body: _buildContent(),
    );
  }
  Widget _buildContent() {
    switch (option) {
      case 'viewManualExam':
        return ViewManualExamScreen();
      case 'viewMCQPaper':
        return ViewMCQPaperScreen();
      case 'viewMCQExam':
        return ViewMCQExamScreen();

      case 'viewAssignments':
        return ViewAssignmentsScreen();


      default:
        return Center(child: Text('Unknown Option'));
    }
  }
}

class ViewManualExamScreen extends StatelessWidget {
  final String examName = 'English Semester 1';
  final String subject = 'English';
  final String standard = '10th Grade';
  final DateTime examDate = DateTime(2024, 12, 15);
  final TimeOfDay fromTime = TimeOfDay(hour: 10, minute: 0);
  final TimeOfDay toTime = TimeOfDay(hour: 12, minute: 0);
  final int totalMarks = 100;
  final List<String> instructions = [
    'Be on time.',
    'Bring all necessary stationery.',
    'No electronic devices allowed.'
  ];
  final List<String> notes = [
    'Please ensure you have read the assigned chapters.',
    'Focus on grammar and comprehension for the essay section.'
  ];
  final String? uploadedDocument = 'exam_guide.pdf';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manual Exam Details'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exam Information
              Text(
                'Exam: $examName',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              Text('Subject: $subject'),
              SizedBox(height: 8.0),
              Text('Standard: $standard'),
              SizedBox(height: 8.0),
              Text('Date: ${DateFormat('dd-MM-yyyy').format(examDate)}'),
              SizedBox(height: 8.0),
              Text('Time: ${fromTime.format(context)} - ${toTime.format(context)}'),
              SizedBox(height: 8.0),
              Text('Total Marks: $totalMarks'),
              SizedBox(height: 16.0),

              // Instructions
              Text(
                'Instructions:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              for (String instruction in instructions)
                Text('- $instruction', style: TextStyle(fontSize: 16)),
              SizedBox(height: 16.0),

              // Notes
              Text(
                'Important Notes:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              for (String note in notes)
                Text('- $note', style: TextStyle(fontSize: 16)),
              SizedBox(height: 16.0),

              // Uploaded Document
              if (uploadedDocument != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Attached Document:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8.0),
                    ElevatedButton(
                      onPressed: () {
                        // Logic to view or download the document
                      },
                      child: Text('View $uploadedDocument'),
                    ),
                  ],
                ),

              // Countdown Timer (optional feature)
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  // Logic to go back or close the screen
                  Navigator.pop(context);
                },
                child: Text('Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class ViewMCQPaperScreen extends StatefulWidget {
  @override
  _ViewMCQPaperScreenState createState() => _ViewMCQPaperScreenState();
}

class _ViewMCQPaperScreenState extends State<ViewMCQPaperScreen> {
  int currentQuestionIndex = 0;
  Map<int, String?> selectedAnswers = {};
  final List<String> questions = [
    'What is the capital of France?',
    'What is 2 + 2?',
    'What is the chemical symbol for water?',
  ];
  final List<List<String>> options = [
    ['Berlin', 'Madrid', 'Paris', 'Rome'],
    ['3', '4', '5', '6'],
    ['H2O', 'O2', 'CO2', 'H2'],
  ];

  // Dummy timer value for countdown
  Duration examDuration = Duration(minutes: 30);

  // Timer related variables
  late DateTime examEndTime;
  late Duration timeRemaining;
  late String timerDisplay;

  @override
  void initState() {
    super.initState();
    examEndTime = DateTime.now().add(examDuration);
    updateTimer();
  }

  void updateTimer() {
    final now = DateTime.now();
    if (examEndTime.isAfter(now)) {
      setState(() {
        timeRemaining = examEndTime.difference(now);
        timerDisplay = formatDuration(timeRemaining);
      });
    } else {
      setState(() {
        timerDisplay = "Time's up!";
      });
      submitExam();
    }
  }

  String formatDuration(Duration duration) {
    return "${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}";
  }

  void selectAnswer(int index, String answer) {
    setState(() {
      selectedAnswers[index] = answer;
    });
  }

  void goToNextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    }
  }

  void goToPreviousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
      });
    }
  }

  void submitExam() {
    print('Exam submitted');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MCQ Exam'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Exam: MCQ Paper',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              'Subject: General Knowledge',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8.0),
            Text(
              'Time Remaining: $timerDisplay',
              style: TextStyle(fontSize: 16, color: Colors.red),
            ),
            SizedBox(height: 16.0),
            Text(
              'Question ${currentQuestionIndex + 1} of ${questions.length}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16.0),
            Text(
              questions[currentQuestionIndex],
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            ...options[currentQuestionIndex].map((option) {
              return RadioListTile<String>(
                title: Text(option),
                value: option,
                groupValue: selectedAnswers[currentQuestionIndex] ?? '', // Provide default value
                onChanged: (value) {
                  selectAnswer(currentQuestionIndex, value!);
                },
              );
            }).toList(),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: goToPreviousQuestion,
                  child: Text('Previous'),
                ),
                ElevatedButton(
                  onPressed: goToNextQuestion,
                  child: Text('Next'),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Center(
              child: ElevatedButton(
                onPressed: submitExam,
                child: Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class ViewMCQExamScreen extends StatefulWidget {
  @override
  _ViewMCQExamScreenState createState() => _ViewMCQExamScreenState();
}

class _ViewMCQExamScreenState extends State<ViewMCQExamScreen> {
  int currentQuestionIndex = 0;
  Map<int, String?> selectedAnswers = {}; // Stores selected answers for each question
  final List<String> questions = [
    'What is the capital of France?',
    'What is 2 + 2?',
    'What is the chemical symbol for water?',
  ];
  final List<List<String>> options = [
    ['Berlin', 'Madrid', 'Paris', 'Rome'],
    ['3', '4', '5', '6'],
    ['H2O', 'O2', 'CO2', 'H2'],
  ];

  // Dummy timer value for countdown
  Duration examDuration = Duration(minutes: 30);
  late DateTime examEndTime;
  late Duration timeRemaining;
  late String timerDisplay;

  @override
  void initState() {
    super.initState();
    examEndTime = DateTime.now().add(examDuration);
    updateTimer();
  }

  void updateTimer() {
    final now = DateTime.now();
    if (examEndTime.isAfter(now)) {
      setState(() {
        timeRemaining = examEndTime.difference(now);
        timerDisplay = formatDuration(timeRemaining);
      });
      Future.delayed(Duration(seconds: 1), updateTimer);
    } else {
      // Time's up
      setState(() {
        timerDisplay = "Time's up!";
      });
      // Optionally, submit the exam automatically when time is up
      submitExam();
    }
  }

  String formatDuration(Duration duration) {
    return "${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}";
  }

  void selectAnswer(int index, String answer) {
    setState(() {
      selectedAnswers[index] = answer;
    });
  }

  void goToNextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    }
  }

  void goToPreviousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
      });
    }
  }

  void submitExam() {
    // Logic to handle exam submission
    // For example: Save answers to a database or send to server
    print('Exam submitted');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MCQ Exam'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exam Information
            Text(
              'Exam: MCQ Paper',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              'Subject: General Knowledge',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8.0),
            Text(
              'Time Remaining: $timerDisplay',
              style: TextStyle(fontSize: 16, color: Colors.red),
            ),
            SizedBox(height: 16.0),

            // Question Progress
            Text(
              'Question ${currentQuestionIndex + 1} of ${questions.length}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16.0),

            // Question Display
            Text(
              questions[currentQuestionIndex],
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),

            // Answer Choices
            ...options[currentQuestionIndex].map((option) {
              return RadioListTile<String>(
                title: Text(option),
                value: option,
                groupValue: selectedAnswers[currentQuestionIndex],
                onChanged: (value) {
                  selectAnswer(currentQuestionIndex, value!);
                },
              );
            }).toList(),

            // Navigation Buttons
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: goToPreviousQuestion,
                  child: Text('Previous'),
                ),
                ElevatedButton(
                  onPressed: goToNextQuestion,
                  child: Text('Next'),
                ),
              ],
            ),
            SizedBox(height: 16.0),

            // Submit Button
            Center(
              child: ElevatedButton(
                onPressed: submitExam,
                child: Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class ViewAssignmentsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assignments'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Handle search action
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search assignments',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),

            // Assignment List
            Expanded(
              child: ListView.builder(
                itemCount: assignments.length, // Replace with the actual count
                itemBuilder: (context, index) {
                  final assignment = assignments[index];
                  return ListTile(
                    title: Text(assignment['title'] ?? 'No Title'), // Provide default value
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Due Date: ${assignment['dueDate'] ?? 'No Due Date'}'), // Provide default value
                        Text('Status: ${assignment['status'] ?? 'No Status'}'), // Provide default value
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.arrow_forward),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AssignmentDetailsScreen(assignment: assignment),
                          ),
                        );
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
  final List<Map<String, String?>> assignments = [
    {'title': 'Math Homework', 'dueDate': '01-10-2024', 'status': 'Pending'},
    {'title': 'Science Project', 'dueDate': '05-10-2024', 'status': 'Completed'},
    {'title': 'History Essay', 'dueDate': '10-10-2024', 'status': 'Overdue'},
  ];
}

class AssignmentDetailsScreen extends StatelessWidget {
  final Map<String, String?> assignment;

  AssignmentDetailsScreen({required this.assignment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assignment Details'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Title: ${assignment['title'] ?? 'No Title'}', // Provide default value
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            Text('Due Date: ${assignment['dueDate'] ?? 'No Due Date'}'), // Provide default value
            SizedBox(height: 16.0),
            Text('Status: ${assignment['status'] ?? 'No Status'}'), // Provide default value
            SizedBox(height: 16.0),
            if (assignment['status'] == 'Pending') ...[
              ElevatedButton(
                onPressed: () {
                  // Handle submission action
                },
                child: Text('Submit Assignment'),
              ),
            ],
            if (assignment['status'] == 'Completed') ...[
              ElevatedButton(
                onPressed: () {
                  // Handle view or download action
                },
                child: Text('View Submitted Assignment'),
              ),
            ],
            if (assignment['status'] == 'Overdue') ...[
              Text(
                'This assignment is overdue.',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }
}