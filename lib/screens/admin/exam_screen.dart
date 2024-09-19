import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mime/mime.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:testing_app/screens/config.dart';

class ExamScreen extends StatelessWidget {
  final String option;

  const ExamScreen({super.key, this.option = 'createManualExam'});
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
      case 'createManualExam':
        return CreateManualExamScreen();
      case 'manageManualExam':
        return ManageManualExamScreen();
      case 'createMCQExam':
        return CreateMCQExamScreen();
      case 'manageMCQExam':
        return ManageMCQExamScreen();
      case 'createAssignments':
        return CreateAssignmentsScreen();
      case 'manageAssignments':
        return ManageAssignmentsScreen();

      default:
        return Center(child: Text('Unknown Option'));
    }
  }
}

class CreateManualExamScreen extends StatefulWidget {
  final Map<String, dynamic>? examData;

  CreateManualExamScreen({this.examData});

  @override
  _CreateManualExamScreenState createState() => _CreateManualExamScreenState();
}

class _CreateManualExamScreenState extends State<CreateManualExamScreen> {
  final _formKey = GlobalKey<FormState>(); // Form Key

  TimeOfDay? _fromTime;
  TimeOfDay? _toTime;
  DateTime? _examDate;
  File? _selectedFile;

  // Form Field Controllers
  final TextEditingController _standardController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _examNameController = TextEditingController();
  final TextEditingController _totalMarksController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeFormData();
  }

  void _initializeFormData() {
    if (widget.examData != null) {
      final exam = widget.examData!;
      _standardController.text = exam['standard'] ?? '';
      _subjectController.text = exam['subject'] ?? '';
      _examNameController.text = exam['examName'] ?? '';
      _totalMarksController.text =
          exam['totalMarks'] != null ? exam['totalMarks'].toString() : '';
      _examDate = DateTime.tryParse(exam['examDate'] ?? '') ?? DateTime.now();
      _fromTime = _parseTime(exam['fromTime']);
      _toTime = _parseTime(exam['toTime']);
      // Ensure the file path is properly handled
      _selectedFile = exam['document'] != null ? File(exam['document']) : null;
    } else {
      _clearForm();
    }
  }

  void _clearForm() {
    _standardController.clear();
    _subjectController.clear();
    _examNameController.clear();
    _totalMarksController.clear();
    _examDate = null;
    _fromTime = null;
    _toTime = null;
    _selectedFile = null;
  }

  TimeOfDay? _parseTime(String? time) {
    if (time == null) return null;
    try {
      final parts = time.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (_) {
      return null;
    }
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return '';
    final now = DateTime.now();
    final dateTime =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat.Hm().format(dateTime); // 24-hour format
  }

  Future<void> _selectFromTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _fromTime = picked;
      });
    }
  }

  Future<void> _selectToTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _toTime = picked;
      });
    }
  }

  Future<void> _selectExamDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _examDate = picked;
      });
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'pdf', 'doc', 'docx', 'xls', 'xlsx'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _saveExam() async {
    if (_formKey.currentState!.validate()) {
      final examData = {
        'standard': _standardController.text,
        'subject': _subjectController.text,
        'examName': _examNameController.text,
        'totalMarks': _totalMarksController.text,
        'examDate':
            _examDate?.toIso8601String() ?? '', // Use empty string if null
        'fromTime': _formatTime(_fromTime),
        'toTime': _formatTime(_toTime),
      };

      try {
        final uri = widget.examData != null
            ? Uri.parse(
                '${AppConfig.baseUrl}/api/exams/${widget.examData!['_id']}')
            : Uri.parse('${AppConfig.baseUrl}/api/exams');

        final request = http.MultipartRequest(
            widget.examData != null ? 'PUT' : 'POST', uri);

        // Convert nullable values to non-null values using ??
        request.fields
            .addAll(examData.map((key, value) => MapEntry(key, value)));

        if (_selectedFile != null) {
          request.files.add(await http.MultipartFile.fromPath(
            'document',
            _selectedFile!.path,
          ));
        }

        final response = await request.send();

        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Exam saved successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save exam'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _resetForm() {
    setState(() {
      _initializeFormData(); // Reset the form to the initial state
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.examData != null
            ? 'Edit Manual Exam'
            : 'Create Manual Exam'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Standard
                TextFormField(
                  controller: _standardController,
                  decoration: InputDecoration(
                    labelText: 'Standard',
                    hintText: 'e.g. 10th',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter the standard';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),

                // Subject
                TextFormField(
                  controller: _subjectController,
                  decoration: InputDecoration(
                    labelText: 'Subject',
                    hintText: 'e.g. English',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter the subject';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),

                // Exam Name
                TextFormField(
                  controller: _examNameController,
                  decoration: InputDecoration(
                    labelText: 'Exam Name',
                    hintText: 'e.g. English-Sem-1',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter the exam name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),

                // Total Marks
                TextFormField(
                  controller: _totalMarksController,
                  decoration: InputDecoration(
                    labelText: 'Total Marks',
                    hintText: 'e.g. 100',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter the total marks';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),

                // Exam Date
                Row(
                  children: [
                    Text(
                      _examDate == null
                          ? 'Select Exam Date'
                          : DateFormat('dd-MM-yyyy').format(_examDate!),
                    ),
                    SizedBox(width: 16.0),
                    ElevatedButton(
                      onPressed: () => _selectExamDate(context),
                      child: Text('Pick Date'),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),

                // From Time
                Row(
                  children: [
                    Text(_fromTime == null
                        ? 'Select From Time'
                        : _fromTime!.format(context)),
                    SizedBox(width: 16.0),
                    ElevatedButton(
                      onPressed: () => _selectFromTime(context),
                      child: Text('Pick From Time'),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),

                // To Time
                Row(
                  children: [
                    Text(_toTime == null
                        ? 'Select To Time'
                        : _toTime!.format(context)),
                    SizedBox(width: 16.0),
                    ElevatedButton(
                      onPressed: () => _selectToTime(context),
                      child: Text('Pick To Time'),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),

                // File Upload
                Row(
                  children: [
                    _selectedFile != null
                        ? Text(_selectedFile!.path.split('/').last)
                        : Text('No file selected'),
                    SizedBox(width: 16.0),
                    ElevatedButton(
                      onPressed: _pickFile,
                      child: Text('Select File'),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),

                // Save Button
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _saveExam,
                      child: Text('Save Exam'),
                    ),
                    SizedBox(width: 16.0),
                    ElevatedButton(
                      onPressed: _resetForm,
                      child: Text('Reset'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ManageManualExamScreen extends StatefulWidget {
  @override
  _ManageManualExamScreenState createState() => _ManageManualExamScreenState();
}

class _ManageManualExamScreenState extends State<ManageManualExamScreen> {
  List<dynamic> _exams = [];
  List<dynamic> _filteredExams = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchExams();
    _searchController.addListener(_filterExams);
  }

  Future<void> _fetchExams() async {
    try {
      final response = await http
          .get(Uri.parse('${AppConfig.baseUrl}/api/exams')); // Adjust API path

      if (response.statusCode == 200) {
        setState(() {
          _exams = json.decode(response.body);
          _filteredExams = _exams;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load exams');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _filterExams() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredExams = _exams.where((exam) {
        final examName = exam['examName']?.toLowerCase() ?? '';
        return examName.contains(query);
      }).toList();
    });
  }

  Future<void> _openDocument(String documentUrl) async {
    try {
      final response = await http.get(Uri.parse(documentUrl));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final fileName = documentUrl.split('/').last;

        final tempDir = await getTemporaryDirectory();
        final tempFilePath = '${tempDir.path}/$fileName';
        final tempFile = File(tempFilePath);
        await tempFile.writeAsBytes(bytes);

        final mimeType = lookupMimeType(tempFilePath);
        await OpenFile.open(tempFilePath, type: mimeType);
      } else {
        throw Exception('Failed to download document');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening document: $e')),
      );
    }
  }

  Future<void> _deleteExam(String examId) async {
    try {
      final response = await http.delete(Uri.parse(
          '${AppConfig.baseUrl}/api/exams/$examId')); // Adjust API path

      if (response.statusCode == 200) {
        setState(() {
          _exams.removeWhere((exam) => exam['_id'] == examId);
          _filteredExams = _exams;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Exam deleted successfully')),
        );
      } else {
        throw Exception('Failed to delete exam');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Manual Exams'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search Exams',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Expanded(
                  child: _filteredExams.isEmpty
                      ? Center(child: Text('No exams found'))
                      : ListView.builder(
                          itemCount: _filteredExams.length,
                          itemBuilder: (context, index) {
                            final exam = _filteredExams[index];
                            return ListTile(
                              title: Text(exam['examName'] ?? ''),
                              subtitle:
                                  Text('Standard: ${exam['standard'] ?? ''}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              CreateManualExamScreen(
                                            examData: exam,
                                          ),
                                        ),
                                      );
                                      if (result == true) {
                                        _fetchExams(); // Refresh exam list on successful edit
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text('Delete Exam'),
                                            content: Text(
                                                'Are you sure you want to delete this exam?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                  _deleteExam(exam['_id']);
                                                },
                                                child: Text('Delete'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.picture_as_pdf),
                                    onPressed: () {
                                      final documentUrl = exam['documentUrl'];
                                      if (documentUrl != null) {
                                        _openDocument(documentUrl);
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'No document available')),
                                        );
                                      }
                                    },
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

class CreateMCQExamScreen extends StatefulWidget {
  const CreateMCQExamScreen({super.key});

  @override
  _CreateMCQExamScreenState createState() => _CreateMCQExamScreenState();
}

class _CreateMCQExamScreenState extends State<CreateMCQExamScreen> {
  final _formKey = GlobalKey<FormState>();
  String? paperName, standard, subject, examPaperType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create MCQ Exam'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'My Panel',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Manage MCQ Paper',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              const Text(
                'Create MCQ Paper',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Paper Name *',
                  hintText: 'e.g. English MCQ Paper',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
                onSaved: (value) => paperName = value,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Standard *',
                  hintText: 'e.g. 10th',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
                onSaved: (value) => standard = value,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Subject *',
                  hintText: 'e.g. English',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
                onSaved: (value) => subject = value,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Exam Paper Type *',
                  hintText: 'e.g. Simple/Comprehensive MCQs',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
                onSaved: (value) => examPaperType = value,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                child: const Text('SAVE'),
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                child: const Text('RESET'),
                onPressed: _resetForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      // Prepare the data to be sent
      final data = {
        "paperName": paperName,
        "standard": standard,
        "subject": subject,
        "examPaperType": examPaperType,
      };

      try {
        // Send POST request to create an MCQ exam
        final response = await http.post(
          Uri.parse('${AppConfig.baseUrl}/api/mcq-exams'),
          headers: {"Content-Type": "application/json"},
          body: json.encode(data),
        );

        if (response.statusCode == 201) {
          final responseData = json.decode(response.body);
          // ignore: unused_local_variable
          final String examId = responseData['exam']?['_id'] ?? '';

          // Navigate to AddMCQQuestionsScreen with the new examId
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddMCQQuestionsScreen(
                paperName: paperName ?? 'Unnamed Paper',
                paperId: '',
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to create MCQ exam')),
          );
        }
      } catch (error) {
        print('Error creating MCQ exam: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating MCQ exam')),
        );
      }
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    setState(() {
      paperName = null;
      standard = null;
      subject = null;
      examPaperType = null;
    });
  }
}

class AddMCQQuestionsScreen extends StatefulWidget {
  final String paperId;
  final String paperName;

  AddMCQQuestionsScreen({required this.paperId, required this.paperName});

  @override
  _AddMCQQuestionsScreenState createState() => _AddMCQQuestionsScreenState();
}

class _AddMCQQuestionsScreenState extends State<AddMCQQuestionsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numberOfQuestionsController = TextEditingController();
  final List<Map<String, dynamic>> _questions = [];
  int _numberOfQuestions = 0;

  void _generateQuestions() {
    if (_numberOfQuestions > 0) {
      setState(() {
        _questions.clear();
        for (int i = 0; i < _numberOfQuestions; i++) {
          _questions.add({
            'question': '',
            'options': ['', '', '', ''],
            'correctAnswer': 0,
          });
        }
      });
    }
  }

  Future<void> _saveQuestions() async {
    if (_formKey.currentState!.validate()) {
      final questionsData = _questions.map((question) {
        return {
          'question': question['question'],
          'options': question['options'],
          'correctAnswer': question['correctAnswer'],
        };
      }).toList();

      final requestData = {'questions': questionsData};

      try {
        final response = await http.post(
          Uri.parse(
              '${AppConfig.baseUrl}/api/mcq-exams/${widget.paperId}/questions'),
          body: json.encode(requestData),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('MCQ Questions saved successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Return to the previous screen
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Failed to save MCQ Questions: ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _resetForm() {
    setState(() {
      _questions.clear();
      _numberOfQuestions = 0;
      _numberOfQuestionsController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add MCQ Questions for ${widget.paperName}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Add MCQ Questions for ${widget.paperName}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 16.0),
                      TextFormField(
                        controller: _numberOfQuestionsController,
                        decoration: InputDecoration(
                          labelText: 'Number of Questions',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the number of questions';
                          }
                          final number = int.tryParse(value);
                          if (number == null || number <= 0) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _numberOfQuestions = int.tryParse(value) ?? 0;
                          });
                        },
                      ),
                      SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: _generateQuestions,
                        child: Text('Generate Questions'),
                      ),
                      SizedBox(height: 16.0),
                      if (_questions.isNotEmpty)
                        for (int i = 0; i < _questions.length; i++)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Question ${i + 1}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              TextFormField(
                                decoration:
                                    InputDecoration(labelText: 'Question'),
                                onChanged: (value) {
                                  _questions[i]['question'] = value;
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter the question';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 12.0),
                              for (int j = 0; j < 4; j++)
                                Row(
                                  children: [
                                    Radio<int>(
                                      value: j,
                                      groupValue: _questions[i]
                                          ['correctAnswer'],
                                      onChanged: (value) {
                                        setState(() {
                                          _questions[i]['correctAnswer'] =
                                              value!;
                                        });
                                      },
                                    ),
                                    Expanded(
                                      child: TextFormField(
                                        decoration: InputDecoration(
                                          labelText: 'Option ${j + 1}',
                                        ),
                                        onChanged: (value) {
                                          _questions[i]['options'][j] = value;
                                        },
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter Option ${j + 1}';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              SizedBox(height: 16.0),
                            ],
                          ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: _saveQuestions,
                  child: Text('Save Questions'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50), // Full-width button
                  ),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _resetForm,
                  child: Text('Reset'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50), // Full-width button
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ManageMCQExamScreen extends StatefulWidget {
  const ManageMCQExamScreen({super.key});

  @override
  _ManageMCQExamScreenState createState() => _ManageMCQExamScreenState();
}

class _ManageMCQExamScreenState extends State<ManageMCQExamScreen> {
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
        Uri.parse('${AppConfig.baseUrl}/api/mcq-exams'),
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

  Future<void> _deleteExam(String examId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this exam?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        final response = await http.delete(
          Uri.parse('${AppConfig.baseUrl}/api/mcq-exams/$examId'),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Exam deleted successfully')),
          );
          _fetchExams(); // Refresh the list
        } else {
          _showErrorSnackbar('Failed to delete exam: ${response.statusCode}');
        }
      } catch (error) {
        _showErrorSnackbar('An error occurred: $error');
      }
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

  void _navigateToEditMCQPaperScreen(String paperId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditMCQPaperScreen(paperId: paperId),
      ),
    );

    if (result == true) {
      _fetchExams(); // Refresh the list
    }
  }

  void _navigateToEditMCQsScreen(String paperId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditMCQsScreen(
          paperId: paperId,
          paperName: '',
        ),
      ),
    );

    if (result == true) {
      _fetchExams(); // Refresh the list
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage MCQ Exams'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.grey[200],
            child: const Text(
              'Manage MCQ Exams',
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
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      _navigateToEditMCQPaperScreen(exam['id']);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      _deleteExam(exam['id']);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.question_answer),
                                    onPressed: () {
                                      _navigateToEditMCQsScreen(exam['id']);
                                    },
                                  ),
                                ],
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

class EditMCQPaperScreen extends StatefulWidget {
  final String paperId;

  EditMCQPaperScreen({required this.paperId});

  @override
  _EditMCQPaperScreenState createState() => _EditMCQPaperScreenState();
}

class _EditMCQPaperScreenState extends State<EditMCQPaperScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _paperNameController = TextEditingController();
  final TextEditingController _standardController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _fromTimeController = TextEditingController();
  final TextEditingController _toTimeController = TextEditingController();
  final TextEditingController _examDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPaperDetails();
  }

  Future<void> _fetchPaperDetails() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/mcq-exams/${widget.paperId}'),
      );

      if (response.statusCode == 200) {
        final paperData = json.decode(response.body);
        setState(() {
          _paperNameController.text = paperData['paperName'] ?? '';
          _standardController.text = paperData['standard'] ?? '';
          _subjectController.text = paperData['subject'] ?? '';
          _fromTimeController.text = paperData['fromTime'] ?? '';
          _toTimeController.text = paperData['toTime'] ?? '';
          _examDateController.text = paperData['examDate'] ?? '';
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to load paper details: ${response.statusCode}')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching paper details')),
      );
    }
  }

  Future<void> _updatePaper() async {
    if (_formKey.currentState!.validate()) {
      final paperData = {
        'paperName': _paperNameController.text,
        'standard': _standardController.text,
        'subject': _subjectController.text,
        'fromTime': _fromTimeController.text,
        'toTime': _toTimeController.text,
        'examDate': _examDateController.text,
      };

      try {
        final response = await http.put(
          Uri.parse('${AppConfig.baseUrl}/api/mcq-exams/${widget.paperId}'),
          body: json.encode(paperData),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('MCQ Paper updated successfully')),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update MCQ paper')),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating paper')),
        );
      }
    }
  }

  Future<void> _selectTime(
      BuildContext context, TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.format(context);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _examDateController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit MCQ Paper'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _paperNameController,
                decoration: InputDecoration(
                  labelText: 'Paper Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter paper name' : null,
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _standardController,
                decoration: InputDecoration(
                  labelText: 'Standard',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter standard' : null,
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _subjectController,
                decoration: InputDecoration(
                  labelText: 'Subject',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter subject' : null,
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _fromTimeController,
                      decoration: InputDecoration(
                        labelText: 'From Time',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                      onTap: () => _selectTime(context, _fromTimeController),
                      validator: (value) =>
                          value!.isEmpty ? 'Please select from time' : null,
                    ),
                  ),
                  SizedBox(width: 8.0),
                  ElevatedButton(
                    onPressed: () => _selectTime(context, _fromTimeController),
                    child: Text('Pick From Time'),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _toTimeController,
                      decoration: InputDecoration(
                        labelText: 'To Time',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                      onTap: () => _selectTime(context, _toTimeController),
                      validator: (value) =>
                          value!.isEmpty ? 'Please select to time' : null,
                    ),
                  ),
                  SizedBox(width: 8.0),
                  ElevatedButton(
                    onPressed: () => _selectTime(context, _toTimeController),
                    child: Text('Pick To Time'),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _examDateController,
                      decoration: InputDecoration(
                        labelText: 'Exam Date',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      validator: (value) =>
                          value!.isEmpty ? 'Please select exam date' : null,
                    ),
                  ),
                  SizedBox(width: 8.0),
                  ElevatedButton(
                    onPressed: () => _selectDate(context),
                    child: Text('Pick Date'),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _updatePaper,
                child: Text('Update Paper'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditMCQsScreen extends StatefulWidget {
  final String paperId;
  final String paperName; // Include paperName

  EditMCQsScreen({required this.paperId, required this.paperName});

  @override
  _EditMCQsScreenState createState() => _EditMCQsScreenState();
}

class _EditMCQsScreenState extends State<EditMCQsScreen> {
  List<Map<String, dynamic>> _questions = [];

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/mcq-exams/${widget.paperId}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _questions = List<Map<String, dynamic>>.from(data['questions'] ?? []);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load questions')),
        );
      }
    } catch (error) {
      print('Error fetching questions: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching questions')),
      );
    }
  }

  Future<void> _updateQuestion(
      String questionId, Map<String, dynamic> updatedQuestion) async {
    try {
      final response = await http.put(
        Uri.parse(
            '${AppConfig.baseUrl}/api/mcq-exams/${widget.paperId}/questions/$questionId'),
        body: json.encode({
          'question': updatedQuestion['question'],
          'options': updatedQuestion['options'],
          'correctAnswer': updatedQuestion['correctAnswer'],
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Question updated successfully')),
        );
        _fetchQuestions(); // Refresh the questions list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update question')),
        );
      }
    } catch (error) {
      print('Error updating question: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating question')),
      );
    }
  }

  Future<void> _deleteQuestion(String questionId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this question?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Delete'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        final response = await http.delete(
          Uri.parse(
              '${AppConfig.baseUrl}/api/mcq-exams/${widget.paperId}/questions/$questionId'),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Question deleted successfully')),
          );
          _fetchQuestions(); // Refresh the questions list
        } else {
          final responseBody = json.decode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Failed to delete question: ${responseBody['message']}')),
          );
        }
      } catch (error) {
        print('Error deleting question: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting question')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.paperName), // Show the paperName in the AppBar
      ),
      body: _questions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'No questions found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddMCQQuestionsScreen(
                            paperId: widget.paperId, // Pass paperId
                            paperName: widget.paperName, // Pass paperName
                          ),
                        ),
                      );
                    },
                    child: Text('Add MCQs'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                final question = _questions[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(question['question'] ?? 'Untitled Question'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('1: ${question['options']?[0] ?? ''}'),
                        Text('2: ${question['options']?[1] ?? ''}'),
                        Text('3: ${question['options']?[2] ?? ''}'),
                        Text('4: ${question['options']?[3] ?? ''}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddMCQQuestionsScreen(
                                  paperId: widget.paperId,
                                  paperName: widget.paperName, // Pass paperName
                                ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _deleteQuestion(question['_id']);
                          },
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

class CreateAssignmentsScreen extends StatefulWidget {
  final Map? assignment; // Optional assignment data for editing

  CreateAssignmentsScreen({super.key, this.assignment});

  @override
  _CreateAssignmentsScreenState createState() =>
      _CreateAssignmentsScreenState();
}

class _CreateAssignmentsScreenState extends State<CreateAssignmentsScreen> {
  final _formKey = GlobalKey<FormState>();
  String? standard, subject, assignmentName;
  String? fileName;
  File? file;
  DateTime? dueDate;
  TextEditingController _dueDateController =
      TextEditingController(); // Controller for the due date field

  @override
  void initState() {
    super.initState();
    if (widget.assignment != null) {
      // Pre-fill form if editing
      standard = widget.assignment!['standard'];
      subject = widget.assignment!['subject'];
      assignmentName = widget.assignment!['assignmentName'];

      // Parsing the date from 'dd-mm-yyyy' format if editing
      dueDate = _parseDate(widget.assignment!['dueDate']);
      _dueDateController.text = dueDate != null
          ? '${dueDate!.day.toString().padLeft(2, '0')}-${dueDate!.month.toString().padLeft(2, '0')}-${dueDate!.year}'
          : '';
      fileName = widget.assignment!['fileName'];
    }
  }

  // Helper method to parse 'dd-mm-yyyy' format to DateTime
  DateTime? _parseDate(String? dateString) {
    if (dateString == null) return null;
    try {
      List<String> parts = dateString.split('-');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
    } catch (e) {
      return null; // Handle any parsing errors
    }
    return null;
  }

  // Picking the due date with DatePicker and updating the controller in 'dd-mm-yyyy' format
  Future<void> _pickDueDate() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: dueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      setState(() {
        dueDate = selectedDate;
        _dueDateController.text =
            '${dueDate!.day.toString().padLeft(2, '0')}-${dueDate!.month.toString().padLeft(2, '0')}-${dueDate!.year}';
      });
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'pdf', 'doc', 'docx', 'txt'],
    );

    if (result != null) {
      setState(() {
        fileName = result.files.single.name;
        file = File(result.files.single.path!);
      });
    }
  }

  Future<void> _saveAssignment() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      try {
        var url = widget.assignment == null
            ? '${AppConfig.baseUrl}/api/assignments'
            : '${AppConfig.baseUrl}/api/assignments/${widget.assignment!['_id']}';

        var request = http.MultipartRequest(
          widget.assignment == null ? 'POST' : 'PUT',
          Uri.parse(url),
        );

        // Ensure that required fields are not null or empty
        request.fields['standard'] =
            standard ?? 'Unknown Standard'; // Provide a default if needed
        request.fields['subject'] =
            subject ?? 'Unknown Subject'; // Provide a default if needed
        request.fields['assignmentName'] = assignmentName ??
            'Unnamed Assignment'; // Provide a default if needed

        // Format dueDate as 'dd-mm-yyyy' before sending
        request.fields['dueDate'] = dueDate != null
            ? '${dueDate!.day.toString().padLeft(2, '0')}-${dueDate!.month.toString().padLeft(2, '0')}-${dueDate!.year}'
            : '';

        // Add file if selected
        if (file != null) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'file',
              file!.path,
            ),
          );
        }

        var response = await request.send();

        if (response.statusCode == 201 || response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.assignment == null
                  ? 'Assignment created successfully!'
                  : 'Assignment updated successfully!'),
            ),
          );
          Navigator.pop(context); // Go back to manage assignments screen
        } else {
          final responseBody = await response.stream.bytesToString();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Failed to save assignment. Status: ${response.statusCode}. Response: $responseBody'),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.assignment == null
            ? 'Create Assignment'
            : 'Edit Assignment'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Standard *',
                  hintText: 'e.g. 10th',
                  border: OutlineInputBorder(),
                ),
                initialValue: standard,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
                onSaved: (value) => standard = value,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Subject *',
                  hintText: 'e.g. English',
                  border: OutlineInputBorder(),
                ),
                initialValue: subject,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
                onSaved: (value) => subject = value,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Assignment Name *',
                  hintText: 'e.g. English Assignment 1',
                  border: OutlineInputBorder(),
                ),
                initialValue: assignmentName,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
                onSaved: (value) => assignmentName = value,
              ),
              SizedBox(height: 16),
              GestureDetector(
                onTap: _pickDueDate,
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _dueDateController, // Attach the controller
                    decoration: InputDecoration(
                      labelText: 'Due Date *',
                      hintText: 'Select Due Date',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => dueDate == null ? 'Required' : null,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _pickFile,
                    child: Text('Choose File'),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      fileName ?? 'No File Chosen',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              ElevatedButton(
                child: Text(widget.assignment == null ? 'SAVE' : 'UPDATE'),
                onPressed: _saveAssignment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ManageAssignmentsScreen extends StatefulWidget {
  const ManageAssignmentsScreen({super.key});

  @override
  _ManageAssignmentsScreenState createState() =>
      _ManageAssignmentsScreenState();
}

class _ManageAssignmentsScreenState extends State<ManageAssignmentsScreen> {
  List<dynamic> assignments = []; // List to store assignments

  @override
  void initState() {
    super.initState();
    _fetchAssignments(); // Fetch assignments when the screen initializes
  }

  // Fetch all assignments from the server
  Future<void> _fetchAssignments() async {
    final response =
        await http.get(Uri.parse('${AppConfig.baseUrl}/api/assignments'));

    if (response.statusCode == 200) {
      setState(() {
        assignments = json.decode(response.body);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load assignments')),
      );
    }
  }

  Future<void> _deleteAssignment(String assignmentId) async {
    bool confirm = await _showDeleteConfirmationDialog();
    if (confirm) {
      final response = await http.delete(
          Uri.parse('${AppConfig.baseUrl}/api/assignments/$assignmentId'));

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Assignment deleted successfully')),
        );
        _fetchAssignments(); // Refresh the list of assignments
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete assignment')),
        );
      }
    }
  }

  // Show confirmation dialog for deletion
  Future<bool> _showDeleteConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Confirm Deletion'),
              content: Text('Are you sure you want to delete this assignment?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('Delete'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Cancel'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Assignments'),
        backgroundColor: Colors.teal,
      ),
      body: assignments.isEmpty
          ? Center(
              child: Text('No Assignments Found'),
            )
          : ListView.builder(
              itemCount: assignments.length,
              itemBuilder: (context, index) {
                final assignment = assignments[index];

                return Card(
                  elevation: 4,
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(assignment['assignmentName'] ?? 'No Name'),
                    subtitle: Text(
                      'Standard: ${assignment['standard'] ?? 'No Standard'}\nDue Date: ${assignment['dueDate'] ?? 'No Due Date'}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CreateAssignmentsScreen(
                                    assignment: assignment),
                              ),
                            );
                            _fetchAssignments(); // Refresh the list after editing
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteAssignment(assignment['_id']),
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
