import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:testing_app/screens/config.dart';
import 'package:url_launcher/url_launcher.dart'; // Add this line

class ExamScreen extends StatelessWidget {
  final String option;

  const ExamScreen({super.key, this.option = 'viewManualExam'});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam'),
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    switch (option) {
      case 'viewManualExam':
        return const ViewManualExamScreen();
      case 'viewMCQExam':
        return const ViewMCQExamScreen();
      case 'viewAssignments':
        return const ViewAssignmentsScreen();
      default:
        return const Center(child: Text('Unknown Option'));
    }
  }
}

class Exam {
  final String standard;
  final String subject;
  final String examName;
  final int totalMarks;
  final DateTime examDate;
  final String fromTime;
  final String toTime;
  final String? note;
  final String? remark;
  final String? documentPath;

  Exam({
    required this.standard,
    required this.subject,
    required this.examName,
    required this.totalMarks,
    required this.examDate,
    required this.fromTime,
    required this.toTime,
    this.note,
    this.remark,
    this.documentPath,
  });

  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      standard: json['standard'],
      subject: json['subject'],
      examName: json['examName'],
      totalMarks: json['totalMarks'],
      examDate: DateTime.parse(json['examDate']),
      fromTime: json['fromTime'],
      toTime: json['toTime'],
      note: json['note'],
      remark: json['remark'],
      documentPath: json['documentPath'],
    );
  }
}

class ExamService {
  Future<List<Exam>> fetchExams() async {
    final response =
        await http.get(Uri.parse('${AppConfig.baseUrl}/api/exams'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((exam) => Exam.fromJson(exam)).toList();
    } else {
      throw Exception('Failed to load exams');
    }
  }
}

class ViewManualExamScreen extends StatefulWidget {
  const ViewManualExamScreen({super.key});

  @override
  _ViewManualExamScreenState createState() => _ViewManualExamScreenState();
}

class _ViewManualExamScreenState extends State<ViewManualExamScreen> {
  late Future<List<Exam>> futureExams;

  @override
  void initState() {
    super.initState();
    futureExams = ExamService().fetchExams();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Manual Exams'),
      ),
      body: FutureBuilder<List<Exam>>(
        future: futureExams,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No exams found'));
          }

          List<Exam> exams = snapshot.data!;

          return ListView.builder(
            itemCount: exams.length,
            itemBuilder: (context, index) {
              Exam exam = exams[index];
              return ListTile(
                title: Text(exam.examName),
                subtitle: Text(
                    'Subject: ${exam.subject} | Standard: ${exam.standard}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ExamDetailsScreen(exam: exam),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class ExamDetailsScreen extends StatelessWidget {
  final Exam exam;

  const ExamDetailsScreen({super.key, required this.exam});

  Future<void> _launchDocumentUrl(String documentPath) async {
    final url = '${AppConfig.baseUrl}$documentPath';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(exam.examName)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Standard: ${exam.standard}',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('Subject: ${exam.subject}',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('Total Marks: ${exam.totalMarks}',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('Exam Date: ${exam.examDate.toLocal()}'.split(' ')[0],
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('Time: ${exam.fromTime} - ${exam.toTime}',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 16),
              if (exam.note != null) ...[
                const Text('Note:',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(exam.note!, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 16),
              ],
              if (exam.remark != null) ...[
                const Text('Remark:',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(exam.remark!, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 16),
              ],
              if (exam.documentPath != null &&
                  exam.documentPath!.isNotEmpty) ...[
                const Text('Document:',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ElevatedButton(
                  onPressed: () => _launchDocumentUrl(exam.documentPath!),
                  child: const Text('View Document'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class ViewMCQExamScreen extends StatefulWidget {
  const ViewMCQExamScreen({super.key});

  @override
  _ViewMCQExamScreenState createState() => _ViewMCQExamScreenState();
}

class _ViewMCQExamScreenState extends State<ViewMCQExamScreen> {
  List<Map<String, dynamic>> exams = [];
  bool isLoading = false;
  String searchTerm = '';

  @override
  void initState() {
    super.initState();
    _fetchExams();
  }

  Future<void> _fetchExams() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/mcq-exams/'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          exams = data.map((exam) {
            return {
              'id': exam['_id'],
              'paperName': exam['paperName'] ?? 'N/A',
              'standard': exam['standard'] ?? 'N/A',
              'subject': exam['subject'] ?? 'N/A',
              'examPaperType': exam['examPaperType'] ?? 'N/A',
            };
          }).toList();
        });
      } else {
        _showErrorSnackbar('Failed to load exams: ${response.statusCode}');
      }
    } catch (error) {
      _showErrorSnackbar('Error fetching exams: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _navigateToViewMCQsScreen(String examId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewMCQsScreen(examId: examId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('View MCQ Exams'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.grey[200],
            child: const Text(
              'Select MCQ Exam',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchTerm = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : exams.isEmpty
                    ? const Center(
                        child: Text(
                          'No MCQ Exams found',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: exams.length,
                        itemBuilder: (context, index) {
                          final exam = exams[index];
                          if (!exam['paperName']
                              .toLowerCase()
                              .contains(searchTerm)) {
                            return const SizedBox.shrink();
                          }
                          return Card(
                            margin: const EdgeInsets.all(8.0),
                            child: ListTile(
                              title: Text(exam['paperName']),
                              subtitle: Text(
                                  'Standard: ${exam['standard']} \nSubject: ${exam['subject']}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.arrow_forward),
                                onPressed: () {
                                  _navigateToViewMCQsScreen(exam['id']);
                                },
                              ),
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

class ViewMCQsScreen extends StatefulWidget {
  final String examId;

  const ViewMCQsScreen({super.key, required this.examId});

  @override
  _ViewMCQsScreenState createState() => _ViewMCQsScreenState();
}

class _ViewMCQsScreenState extends State<ViewMCQsScreen> {
  int currentQuestionIndex = 0;
  Map<int, String?> selectedAnswers = {};
  List<String> questions = [];
  List<List<String>> options = [];
  String paperName = '';
  String subject = '';
  bool isLoading = true;

  Duration examDuration = const Duration(minutes: 30);
  late DateTime examEndTime;
  late Duration timeRemaining;
  late String timerDisplay = '';

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchMCQExam();
  }

  @override
  void dispose() {
    // Cancel the timer if it's still running when the widget is disposed
    _timer?.cancel();
    super.dispose();
  }

  Future<void> fetchMCQExam() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/mcq-exams/${widget.examId}'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          paperName = data['paperName'];
          subject = data['subject'];
          questions =
              List<String>.from(data['questions'].map((q) => q['question']));
          options = List<List<String>>.from(
              data['questions'].map((q) => List<String>.from(q['options'])));
          examEndTime = DateTime.now().add(examDuration);
          startTimer(); // Start the timer after loading the exam
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load exam');
      }
    } catch (error) {
      print('Error loading MCQ exam: $error');
    }
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
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
        _timer?.cancel();
      }
    });
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exam submitted successfully')),
    );
    if (mounted) {
      Navigator.of(context)
          .pop(); // Ensure the screen is still in the widget tree
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('MCQ Exam'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Exam: $paperName',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Subject: $subject',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Time remaining: $timerDisplay',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Question ${currentQuestionIndex + 1}/${questions.length}: ${questions[currentQuestionIndex]}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  ...options[currentQuestionIndex].map((option) {
                    return RadioListTile<String>(
                      title: Text(option),
                      value: option,
                      groupValue: selectedAnswers[currentQuestionIndex],
                      onChanged: (value) {
                        selectAnswer(currentQuestionIndex, value!);
                      },
                    );
                  }),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: goToPreviousQuestion,
                        child: const Text('Previous'),
                      ),
                      ElevatedButton(
                        onPressed: goToNextQuestion,
                        child: const Text('Next'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: submitExam,
                    child: const Text('Submit Exam'),
                  ),
                ],
              ),
            ),
    );
  }
}

class ViewAssignmentsScreen extends StatefulWidget {
  const ViewAssignmentsScreen({super.key});

  @override
  _ViewAssignmentsScreenState createState() => _ViewAssignmentsScreenState();
}

class _ViewAssignmentsScreenState extends State<ViewAssignmentsScreen> {
  List<Map<String, dynamic>> assignments = [];
  List<Map<String, dynamic>> filteredAssignments = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchAssignments();
  }

  Future<void> fetchAssignments() async {
    try {
      final response =
          await http.get(Uri.parse('${AppConfig.baseUrl}/api/assignments'));

      if (response.statusCode == 200) {
        setState(() {
          assignments =
              List<Map<String, dynamic>>.from(json.decode(response.body));
          filteredAssignments = assignments; // Initialize filtered list
        });
      } else {
        print('Failed to load assignments');
      }
    } catch (error) {
      print('Error fetching assignments: $error');
    }
  }

  void filterAssignments(String query) {
    setState(() {
      searchQuery = query;
      filteredAssignments = assignments.where((assignment) {
        final assignmentName =
            assignment['assignmentName']?.toLowerCase() ?? '';
        return assignmentName.contains(query.toLowerCase());
      }).toList();
    });
  }

  void showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String tempQuery = searchQuery; // Temporary variable for dialog
        return AlertDialog(
          title: const Text('Search Assignments'),
          content: TextField(
            onChanged: (value) {
              tempQuery = value;
            },
            decoration: const InputDecoration(
              hintText: 'Type to search...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                filterAssignments(tempQuery);
                Navigator.of(context).pop();
              },
              child: const Text('Search'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
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
        automaticallyImplyLeading: false,
        title: const Text('Assignments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: showSearchDialog, // Call the search dialog function
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
              onChanged: filterAssignments,
              decoration: const InputDecoration(
                hintText: 'Search assignments',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),

            // Assignment List
            Expanded(
              child: ListView.builder(
                itemCount: filteredAssignments.length,
                itemBuilder: (context, index) {
                  final assignment = filteredAssignments[index];
                  return ListTile(
                    title: Text(assignment['assignmentName'] ?? 'No Title'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Standard: ${assignment['standard'] ?? 'N/A'}'),
                        Text('Subject: ${assignment['subject'] ?? 'N/A'}'),
                        Text(
                            'Due Date: ${assignment['dueDate'] ?? 'No Due Date'}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AssignmentDetailsScreen(assignment: assignment),
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
}

class AssignmentDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> assignment;

  const AssignmentDetailsScreen({super.key, required this.assignment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignment Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Title: ${assignment['assignmentName'] ?? 'No Title'}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            Text('Standard: ${assignment['standard'] ?? 'N/A'}'),
            const SizedBox(height: 16.0),
            Text('Subject: ${assignment['subject'] ?? 'N/A'}'),
            const SizedBox(height: 16.0),
            Text('Due Date: ${assignment['dueDate'] ?? 'No Due Date'}'),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}
