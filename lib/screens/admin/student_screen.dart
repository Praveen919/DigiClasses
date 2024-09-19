import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:testing_app/screens/config.dart';
import 'package:http_parser/http_parser.dart';

class StudentScreen extends StatefulWidget {
  final String option;

  const StudentScreen({super.key, required this.option});

  @override
  _StudentScreenState createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student'),
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    switch (widget.option) {
      case 'addInquiry':
        return const AddStudentInquiryScreen();
      case 'manageInquiry':
        return const ManageStudentInquiryScreen();
      case 'importStudents':
        return const ImportStudentsScreen();
      case 'addRegistration':
        return const AddStudentRegistrationScreen();
      case 'manageStudent':
        return const ManageStudentScreen();
      case 'assignClassBatch':
        return const AssignClassBatchScreen();
      case 'studentAttendance':
        return const StudentAttendanceScreen();
      case 'shareDocuments':
        return const ShareDocumentsScreen();
      case 'manageSharedDocuments':
        return const ManageSharedDocumentsScreen();
      case 'chatWithStudents':
        return const ChatWithStudentsScreen();
      case 'studentsFeedback':
        return const StudentsFeedbackScreen();
      case 'studentRights':
        return const StudentRightsScreen();
      default:
        return const Center(child: Text('Unknown Option'));
    }
  }
}

// Below are the placeholder widgets for each student-related screen.
// Replace these with your actual implementation.

class AddStudentInquiryScreen extends StatefulWidget {
  const AddStudentInquiryScreen({super.key});

  @override
  _AddStudentInquiryScreenState createState() =>
      _AddStudentInquiryScreenState();
}

class _AddStudentInquiryScreenState extends State<AddStudentInquiryScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _fileName;
  String? _fileType;
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'gif'],
    );

    if (result != null) {
      setState(() {
        _fileName = result.files.single.name;
        _fileType = result.files.single.extension;
        _formData['file'] = result.files.single.bytes;
      });
    }
  }

  Future<void> _saveInquiry() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      final uri = Uri.parse('${AppConfig.baseUrl}/api/inquiries');
      final request = http.MultipartRequest('POST', uri)
        ..fields['studentName'] = _formData['name'] ?? ''
        ..fields['gender'] = _formData['gender'] ?? ''
        ..fields['fatherMobile'] = _formData['fatherMobile'] ?? ''
        ..fields['motherMobile'] = _formData['motherMobile'] ?? ''
        ..fields['studentMobile'] = _formData['studentMobile'] ?? ''
        ..fields['studentEmail'] = _formData['studentEmail'] ?? ''
        ..fields['schoolCollege'] = _formData['school'] ?? ''
        ..fields['university'] = _formData['university'] ?? ''
        ..fields['standard'] = _formData['standard'] ?? ''
        ..fields['courseType'] = _formData['courseType'] ?? ''
        ..fields['referenceBy'] = _formData['referenceBy'] ?? ''
        ..fields['inquirySource'] = _formData['source'] ?? ''
        ..fields['inquiry'] = _formData['inquiry'] ?? ''
        ..fields['inquiryDate'] =
        DateFormat('yyyy-MM-dd').format(_selectedDate);

      if (_formData['file'] != null) {
        String contentType = 'image/jpeg';
        if (_fileType == 'png') {
          contentType = 'image/png';
        } else if (_fileType == 'gif') {
          contentType = 'image/gif';
        }

        request.files.add(http.MultipartFile.fromBytes(
          'file',
          _formData['file']!,
          filename: _fileName,
          contentType: MediaType.parse(contentType),
        ));
      }

      try {
        final response = await request.send();

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Inquiry saved successfully')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                Text('Failed to save inquiry: ${response.reasonPhrase}')),
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
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                // Action for 'Import Inquiry'
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent,
              ),
              child: const Text('Import Inquiry'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Student Inquiry Registration',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildPersonalDetailsSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personal Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        Divider(thickness: 1.5, color: Colors.grey[300]),
        const SizedBox(height: 10),
        _buildTextField('Student Name *', 'name', isRequired: true),
        _buildDropdownField('Gender', ['Male', 'Female', 'Other'], 'gender'),
        _buildTextField('Father Mobile', 'fatherMobile'),
        _buildTextField('Mother Mobile', 'motherMobile'),
        _buildTextField('Student Mobile', 'studentMobile', isRequired: true),
        _buildTextField('Student Email', 'studentEmail', isRequired: true),
        _buildTextField('School / College', 'school'),
        _buildTextField('University', 'university'),
        _buildDropdownField(
            'Standard', ['Class 1', 'Class 2', 'Class 3'], 'standard'),
        _buildDropdownField('Course Type', ['Type 1', 'Type 2'], 'courseType'),
        _buildTextField('Reference By', 'referenceBy'),
        _buildFilePicker(),
        _buildDatePicker(context),
        _buildTextField('Inquiry Source', 'source', isRequired: true),
        _buildTextArea('Inquiry', 'inquiry', isRequired: true),
        _buildSaveAndResetButtons(),
      ],
    );
  }

  Widget _buildDropdownField(String label, List<String> options, String key) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: '$label *',
                border: const OutlineInputBorder(),
              ),
              items: options.map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _formData[key] = value;
                });
              },
              validator: (value) => value == null || value.isEmpty
                  ? 'This field is required'
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String key, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: isRequired ? '$label *' : label,
          border: const OutlineInputBorder(),
        ),
        onSaved: (value) {
          _formData[key] = value;
        },
        validator: (value) => isRequired && (value == null || value.isEmpty)
            ? 'This field is required'
            : null,
      ),
    );
  }

  Widget _buildTextArea(String label, String key, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        maxLines: 4,
        decoration: InputDecoration(
          labelText: isRequired ? '$label *' : label,
          border: const OutlineInputBorder(),
        ),
        onSaved: (value) {
          _formData[key] = value;
        },
        validator: (value) => isRequired && (value == null || value.isEmpty)
            ? 'This field is required'
            : null,
      ),
    );
  }

  Widget _buildFilePicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          ElevatedButton(
            onPressed: _pickFile,
            child: const Text('Choose File'),
          ),
          const SizedBox(width: 16.0),
          Text(_fileName ?? 'No file chosen'),
        ],
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          ElevatedButton(
            onPressed: () => _selectDate(context),
            child: const Text('Select Date'),
          ),
          const SizedBox(width: 16.0),
          Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
        ],
      ),
    );
  }

  Widget _buildSaveAndResetButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: () {
              _formKey.currentState?.reset();
              setState(() {
                _selectedDate = DateTime.now();
                _fileName = null;
                _fileType = null;
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reset'),
          ),
          const SizedBox(width: 16.0),
          ElevatedButton(
            onPressed: _saveInquiry,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class InquiryDetailScreen extends StatelessWidget {
  final Inquiry inquiry;

  const InquiryDetailScreen({Key? key, required this.inquiry})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd'); // Define the date format

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inquiry Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Student Name: ${inquiry.studentName.isNotEmpty ? inquiry.studentName : 'Not Provided'}',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Standard: ${inquiry.standard.isNotEmpty ? inquiry.standard : 'Not Provided'}',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Inquiry Date: ${inquiry.inquiryDate != null ? dateFormat.format(inquiry.inquiryDate!) : 'Not Provided'}',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Inquiry Source: ${inquiry.inquirySource.isNotEmpty ? inquiry.inquirySource : 'Not Provided'}',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Solved: ${inquiry.isSolved ? 'Yes' : 'No'}',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Inquiry Details: ${inquiry.inquiry ?? 'Not Provided'}',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ManageStudentInquiryScreen extends StatefulWidget {
  const ManageStudentInquiryScreen({super.key});

  @override
  _ManageStudentInquiryScreenState createState() =>
      _ManageStudentInquiryScreenState();
}

class _ManageStudentInquiryScreenState
    extends State<ManageStudentInquiryScreen> {
  List<Inquiry> _inquiries = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchInquiries();
  }

  Future<void> _fetchInquiries() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/inquiries'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _inquiries = data.map((json) => Inquiry.fromJson(json)).toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch inquiries')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> updateInquiry(Inquiry inquiry) async {
    try {
      final response = await http.put(
        Uri.parse('${AppConfig.baseUrl}/api/inquiries/${inquiry.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(inquiry.toJson()),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inquiry updated successfully')),
        );
      } else {
        throw Exception('Failed to update inquiry');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> deleteInquiry(String inquiryId) async {
    try {
      final response = await http.delete(
        Uri.parse('${AppConfig.baseUrl}/api/inquiries/$inquiryId'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _inquiries.removeWhere((inquiry) => inquiry.id == inquiryId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inquiry deleted successfully')),
        );
      } else {
        throw Exception('Failed to delete inquiry');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _confirmDeleteInquiry(String inquiryId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this inquiry?'),
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
              deleteInquiry(inquiryId);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _openInquiryDetailScreen(Inquiry inquiry) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InquiryDetailScreen(inquiry: inquiry),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Manage Student Inquiries'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _fetchInquiries,
              child: const Text('Refresh'),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _inquiries.isEmpty
          ? const Center(child: Text('No inquiries available'))
          : ListView.builder(
        itemCount: _inquiries.length,
        itemBuilder: (context, index) {
          final inquiry = _inquiries[index];
          return GestureDetector(
            onTap: () => _openInquiryDetailScreen(inquiry),
            child: StudentInquiryCard(
              inquiry: inquiry,
              onSolvedChanged: (bool? value) {
                setState(() {
                  inquiry.isSolved = value ?? false;
                });
                updateInquiry(inquiry);
              },
              onDelete: () => _confirmDeleteInquiry(inquiry.id),
            ),
          );
        },
      ),
    );
  }
}

// Model class for Inquiry
class Inquiry {
  final String id;
  final String studentName;
  final String standard;
  final DateTime? inquiryDate;
  final String inquirySource;
  bool isSolved;
  final String? inquiry;

  Inquiry({
    required this.id,
    required this.studentName,
    required this.standard,
    this.inquiryDate,
    required this.inquirySource,
    required this.isSolved,
    this.inquiry,
  });

  factory Inquiry.fromJson(Map<String, dynamic> json) {
    return Inquiry(
      id: json['_id'] ?? '',
      studentName: json['studentName'] ?? '',
      standard: json['standard'] ?? '',
      inquiryDate: json['inquiryDate'] != null
          ? DateTime.parse(json['inquiryDate'])
          : null,
      inquirySource: json['inquirySource'] ?? '',
      isSolved: json['isSolved'] ?? false,
      inquiry: json['inquiry'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'studentName': studentName,
      'standard': standard,
      'inquiryDate': inquiryDate?.toIso8601String(),
      'inquirySource': inquirySource,
      'isSolved': isSolved,
      'inquiry': inquiry,
    };
  }
}

class StudentInquiryCard extends StatelessWidget {
  final Inquiry inquiry;
  final ValueChanged<bool?> onSolvedChanged;
  final VoidCallback onDelete;

  const StudentInquiryCard({
    super.key,
    required this.inquiry,
    required this.onSolvedChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Student Name: ${inquiry.studentName.isNotEmpty ? inquiry.studentName : 'Not Provided'}',
              style: textTheme.bodyMedium,
            ),
            Text(
              'Standard: ${inquiry.standard.isNotEmpty ? inquiry.standard : 'Not Provided'}',
              style: textTheme.bodyMedium,
            ),
            Text(
              'Inquiry Date: ${inquiry.inquiryDate != null ? inquiry.inquiryDate!.toLocal().toString() : 'Not Provided'}',
              style: textTheme.bodySmall,
            ),
            Text(
              'Inquiry Source: ${inquiry.inquirySource.isNotEmpty ? inquiry.inquirySource : 'Not Provided'}',
              style: textTheme.bodySmall,
            ),
            Row(
              children: [
                Checkbox(
                  value: inquiry.isSolved,
                  onChanged: onSolvedChanged,
                ),
                Expanded(
                  child: Text(
                    'Mark as Solved',
                    style: textTheme.bodySmall,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ImportStudentsScreen extends StatefulWidget {
  const ImportStudentsScreen({super.key});

  @override
  _ImportStudentsScreenState createState() => _ImportStudentsScreenState();
}

class _ImportStudentsScreenState extends State<ImportStudentsScreen> {
  String _fileName = 'No File Chosen'; // State variable to hold the file name

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Note
            const Text(
              'NOTE: Upload your existing students from excel file.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),

            // Import Student
            const Text(
              'Import Student',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),

            // Click Here to download excel file format
            ElevatedButton(
              onPressed: () {
                // Implement download functionality here
              },
              child: const Text('Click Here to download excel file format'),
            ),
            const SizedBox(height: 16.0),

            // Standard
            DropdownButtonFormField<String>(
              value: '-- Select --',
              items: <String>[
                '-- Select --',
                'Standard 1',
                'Standard 2',
                'Standard 3'
              ]
                  .map((String value) => DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              ))
                  .toList(),
              onChanged: (String? newValue) {
                // Handle dropdown selection change
              },
              decoration: const InputDecoration(
                labelText: 'Standard *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),

            // Course Type
            DropdownButtonFormField<String>(
              value: '-- Select --',
              items: <String>[
                '-- Select --',
                'Course Type 1',
                'Course Type 2',
                'Course Type 3'
              ]
                  .map((String value) => DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              ))
                  .toList(),
              onChanged: (String? newValue) {
                // Handle dropdown selection change
              },
              decoration: const InputDecoration(
                labelText: 'Course Type',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),

            // Class/Batch
            DropdownButtonFormField<String>(
              value: '-- Select --',
              items: <String>[
                '-- Select --',
                'Class/Batch 1',
                'Class/Batch 2',
                'Class/Batch 3'
              ]
                  .map((String value) => DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              ))
                  .toList(),
              onChanged: (String? newValue) {
                // Handle dropdown selection change
              },
              decoration: const InputDecoration(
                labelText: 'Class/Batch *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),

            // Upload Excel File
            ElevatedButton(
              onPressed: () async {
                // Open file picker
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['xlsx'],
                );

                if (result != null) {
                  PlatformFile file = result.files.first;

                  setState(() {
                    _fileName = file.name;
                  });

                  // Process the file if needed
                } else {
                  // User canceled the picker
                  setState(() {
                    _fileName = 'No File Chosen';
                  });
                }
              },
              child: const Text('Choose File'),
            ),
            const SizedBox(height: 8.0),
            Text(_fileName), // Display the chosen file name
            const SizedBox(height: 32.0),

            // Reset and Submit buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Implement reset functionality
                  },
                  child: const Text('Reset'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Implement submit functionality
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AddStudentRegistrationScreen extends StatefulWidget {
  const AddStudentRegistrationScreen({super.key});

  @override
  _AddStudentRegistrationScreenState createState() => _AddStudentRegistrationScreenState();
}

class _AddStudentRegistrationScreenState extends State<AddStudentRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedBirthDate = DateTime.now();
  DateTime _selectedJoinDate = DateTime.now();
  bool _printInquiry = false;
  File? _selectedImage;
  String? _fileName = 'No file chosen';

  // Controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _fatherNameController = TextEditingController();
  final TextEditingController _motherNameController = TextEditingController();
  final TextEditingController _fatherMobileController = TextEditingController();
  final TextEditingController _motherMobileController = TextEditingController();
  final TextEditingController _studentMobileController = TextEditingController();
  final TextEditingController _studentEmailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _schoolController = TextEditingController();
  final TextEditingController _universityController = TextEditingController();
  final TextEditingController _classBatchController = TextEditingController();

  String? _gender;
  String? _standard;
  String? _courseType;

  // Pick birth date or join date
  Future<void> _selectDate(BuildContext context, bool isBirthDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isBirthDate ? _selectedBirthDate : _selectedJoinDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isBirthDate) {
          _selectedBirthDate = picked;
        } else {
          _selectedJoinDate = picked;
        }
      });
    }
  }

  // Pick image
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _fileName = pickedFile.name;
      });
    }
  }

  // Save student function
  Future<void> _saveStudent() async {
    if (!_formKey.currentState!.validate()) return;

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${AppConfig.baseUrl}/api/registrationRoutes'),
    );

    // Add fields to the request
    request.fields['name'] =
    '${_firstNameController.text} ${_middleNameController.text} ${_lastNameController.text}';
    request.fields['fatherName'] = _fatherNameController.text;
    request.fields['motherName'] = _motherNameController.text;
    request.fields['fatherMobile'] = _fatherMobileController.text;
    request.fields['motherMobile'] = _motherMobileController.text;
    request.fields['studentMobile'] = _studentMobileController.text;
    request.fields['studentEmail'] = _studentEmailController.text;
    request.fields['address'] = _addressController.text;
    request.fields['state'] = _stateController.text;
    request.fields['city'] = _cityController.text;
    request.fields['school'] = _schoolController.text;
    request.fields['university'] = _universityController.text;
    request.fields['classBatch'] = _classBatchController.text;
    request.fields['birthDate'] = _selectedBirthDate.toIso8601String();
    request.fields['joinDate'] = _selectedJoinDate.toIso8601String();
    request.fields['gender'] = _gender ?? '';
    request.fields['standard'] = _standard ?? '';
    request.fields['courseType'] = _courseType ?? '';

    // Add image file
    if (_selectedImage != null) {
      request.files.add(await http.MultipartFile.fromPath('image', _selectedImage!.path));
    }

    try {
      final response = await request.send();
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student registered successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to register student')),
        );
        print('Failed to register student: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Exception caught: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                // Action for 'Registration Form' button
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent,
              ),
              child: const Text('Registration Form'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Create Student Registration',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildPersonalDetailsSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personal Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        Divider(thickness: 1.5, color: Colors.grey[300]),
        const SizedBox(height: 10),
        _buildImagePicker('Profile Picture'),
        _buildTextField('First Name *', _firstNameController),
        _buildTextField('Middle Name', _middleNameController),
        _buildTextField('Last Name *', _lastNameController),
        _buildDropdownField('Gender *', ['Male', 'Female', 'Other'], (value) {
          setState(() {
            _gender = value;
          });
        }),
        _buildDatePickerField('Birth Date *', true),
        _buildTextField('Father Name', _fatherNameController),
        _buildTextField('Mother Name', _motherNameController),
        _buildTextField('Father Mobile', _fatherMobileController),
        _buildTextField('Mother Mobile', _motherMobileController),
        _buildTextField('Student Mobile', _studentMobileController),
        _buildTextField('Student Email', _studentEmailController),
        _buildTextField('Address', _addressController),
        _buildTextField('State', _stateController),
        _buildTextField('City', _cityController),
        _buildTextField('School/College', _schoolController),
        _buildTextField('University', _universityController),
        _buildDropdownField(
          'Standard *',
          ['-- Select --', '1st', '2nd', '11th', '12th'],
              (value) {
            setState(() {
              _standard = value;
            });
          },
        ),
        _buildDropdownField(
          'Course Type *',
          ['-- Select --', 'Type1', 'Type2', 'Other'],
              (value) {
            setState(() {
              _courseType = value;
            });
          },
        ),
        _buildTextField('Class/Batch', _classBatchController),
        _buildDatePickerField('Join Date', false),
        _buildCheckbox('Do you want to print the submitted student\'s inquiry?'),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _saveStudent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text('Save'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Handle reset action
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text('Reset'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Widget for text field input
  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          validator: (value) {
            if (label.contains('*') && (value == null || value.isEmpty)) {
              return 'Please enter $label';
            }
            return null;
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  // Widget for dropdown field
  Widget _buildDropdownField(
      String label, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
          validator: (value) {
            if (label.contains('*') && (value == null || value == '-- Select --')) {
              return 'Please select $label';
            }
            return null;
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  // Widget for date picker input
  Widget _buildDatePickerField(String label, bool isBirthDate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 5),
        GestureDetector(
          onTap: () => _selectDate(context, isBirthDate),
          child: AbsorbPointer(
            child: TextFormField(
              decoration: InputDecoration(
                hintText: isBirthDate
                    ? DateFormat('dd/MM/yyyy').format(_selectedBirthDate)
                    : DateFormat('dd/MM/yyyy').format(_selectedJoinDate),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  // Widget for image picker
  Widget _buildImagePicker(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 5),
        Row(
          children: [
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Choose File'),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(_fileName ?? 'No file chosen')),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  // Checkbox widget
  Widget _buildCheckbox(String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Checkbox(
          value: _printInquiry,
          onChanged: (bool? value) {
            setState(() {
              _printInquiry = value ?? false;
            });
          },
        ),
        Text(label),
      ],
    );
  }
}

class ManageStudentScreen extends StatefulWidget {
  const ManageStudentScreen({super.key});

  @override
  _ManageStudentScreenState createState() => _ManageStudentScreenState();
}

class _ManageStudentScreenState extends State<ManageStudentScreen> {
  List<Student> students = [];

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    final response = await http.get(Uri.parse('${AppConfig.baseUrl}/api/registration'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        students = data.map((json) => Student.fromJson(json)).toList();
      });
    } else {
      // Handle the error
      print('Failed to load students');
    }
  }

  Future<void> _deleteStudent(int id, int index) async {
    final response = await http.delete(Uri.parse('${AppConfig.baseUrl}/api/registration/$id'));

    if (response.statusCode == 200) {
      setState(() {
        students.removeAt(index);
      });
    } else {
      // Handle the error
      print('Failed to delete student');
    }
  }

  Future<void> _updateStudent(Student student) async {
    final response = await http.put(
      Uri.parse('${AppConfig.baseUrl}/api/registration/${student.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(student.toJson()),
    );

    if (response.statusCode == 200) {
      _fetchStudents(); // Refresh the list
    } else {
      // Handle the error
      print('Failed to update student');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    // Implement search functionality here
                  },
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            // Student List
            Expanded(
              child: ListView.builder(
                itemCount: students.length,
                itemBuilder: (context, index) {
                  return StudentCard(
                    student: students[index],
                    onEdit: () {
                      _showEditDialog(context, students[index]);
                    },
                    onDelete: () {
                      _confirmDeleteStudent(context, students[index].id, index);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, Student student) {
    final nameController = TextEditingController(text: student.name);
    final standardController = TextEditingController(text: student.standard);
    final courseController = TextEditingController(text: student.course);
    final batchController = TextEditingController(text: student.classBatch);
    final joinDateController = TextEditingController(text: student.joinDate);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Student'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Student Name'),
              ),
              TextField(
                controller: standardController,
                decoration: const InputDecoration(labelText: 'Standard'),
              ),
              TextField(
                controller: courseController,
                decoration: const InputDecoration(labelText: 'Course Name'),
              ),
              TextField(
                controller: batchController,
                decoration: const InputDecoration(labelText: 'Class/Batch'),
              ),
              TextField(
                controller: joinDateController,
                decoration: const InputDecoration(labelText: 'Join Date'),
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
            TextButton(
              onPressed: () {
                final updatedStudent = Student(
                  id: student.id,
                  name: nameController.text,
                  standard: standardController.text,
                  course: courseController.text,
                  classBatch: batchController.text,
                  joinDate: joinDateController.text,
                );
                _updateStudent(updatedStudent);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteStudent(BuildContext context, int id, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this student?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteStudent(id, index);
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

// Model class for Student
class Student {
  int id; // Added id field
  String name;
  String standard;
  String course;
  String classBatch;
  String joinDate;

  Student({
    required this.id, // Added id parameter
    required this.name,
    required this.standard,
    required this.course,
    required this.classBatch,
    required this.joinDate,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      name: json['name'],
      standard: json['standard'],
      course: json['course'],
      classBatch: json['classBatch'],
      joinDate: json['joinDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'standard': standard,
      'course': course,
      'classBatch': classBatch,
      'joinDate': joinDate,
    };
  }
}

// Custom widget for each student
class StudentCard extends StatelessWidget {
  final Student student;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const StudentCard({
    super.key,
    required this.student,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${student.name}',
                style: Theme.of(context).textTheme.bodyMedium),
            Text('Standard: ${student.standard}',
                style: Theme.of(context).textTheme.bodyMedium),
            Text('Course: ${student.course}',
                style: Theme.of(context).textTheme.bodyMedium),
            Text('Batch: ${student.classBatch}',
                style: Theme.of(context).textTheme.bodyMedium),
            Text('Join Date: ${student.joinDate}',
                style: Theme.of(context).textTheme.bodyMedium),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AssignClassBatchScreen extends StatelessWidget {
  const AssignClassBatchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Assign Class/Batch to Student',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Total Strength:-'),
            const Text('Availability:-'),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              // This container would typically contain a list of classes/batches
            ),
            const SizedBox(height: 16),
            const Text(
              'Assigned Student:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              // This container would typically contain a list of assigned students
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Assign Class/Batch To Student'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Remove Student From Class/Batch'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StudentAttendanceScreen extends StatefulWidget {
  const StudentAttendanceScreen({super.key});

  @override
  _StudentAttendanceScreenState createState() =>
      _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState extends State<StudentAttendanceScreen> {
  // Initialize date variables with current date
  String _selectedMonth = DateFormat('MMMM').format(DateTime.now());
  String _day = DateFormat('d').format(DateTime.now());
  String _year = DateFormat('y').format(DateTime.now());
  bool _displayClassBatch = false;
  String? _selectedClassBatch;

  // State flag to switch between form and attendance table
  bool _attendanceTaken = false;
  bool _isEditable = false;

  DateTime? _fromDate;
  DateTime? _toDate;

  // Dummy attendance data (this would come from a backend or database)
  List<Map<String, String>> attendanceData = [
    {
      'srNo': '1',
      'date': '23/6/2024',
      'classBatch': '9th Morning',
      'student': 'User - 1',
      'attendance': 'Present'
    },
    {
      'srNo': '2',
      'date': '23/6/2024',
      'classBatch': '9th Morning',
      'student': 'User - 2',
      'attendance': 'Absent'
    },
    {
      'srNo': '3',
      'date': '23/6/2024',
      'classBatch': '9th Morning',
      'student': 'User - 3',
      'attendance': 'Present'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
        _attendanceTaken ? _buildAttendanceTable() : _buildAttendanceForm(),
      ),
    );
  }

  // Attendance form
  Widget _buildAttendanceForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Take Student Attendance',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16.0),

        // Attendance Date
        Row(
          children: [
            Flexible(
              flex:
              3, // Adjust the flex ratio to give more space to the month dropdown
              child: DropdownButtonFormField<String>(
                value: _selectedMonth,
                items: <String>[
                  'January',
                  'February',
                  'March',
                  'April',
                  'May',
                  'June',
                  'July',
                  'August',
                  'September',
                  'October',
                  'November',
                  'December'
                ]
                    .map((String value) => DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                ))
                    .toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedMonth = newValue!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Month',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8.0), // Reduced width
            Flexible(
              flex: 1,
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Day',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                initialValue: _day,
                onChanged: (value) {
                  setState(() {
                    _day = value;
                  });
                },
              ),
            ),
            const SizedBox(width: 8.0), // Reduced width
            Flexible(
              flex: 2, // Slightly more space for year
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Year',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                initialValue: _year,
                onChanged: (value) {
                  setState(() {
                    _year = value;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),

        // Display my Class/Batch (Time table wise)
        CheckboxListTile(
          title: const Text('Display my Class/Batch (Time table wise)'),
          value: _displayClassBatch,
          onChanged: (bool? value) {
            setState(() {
              _displayClassBatch = value!;
            });
          },
        ),
        const SizedBox(height: 16.0),

        // Class/Batch
        DropdownButtonFormField<String>(
          value: _selectedClassBatch,
          hint: const Text('-- Select --'),
          items: <String>['Class/Batch 1', 'Class/Batch 2', 'Class/Batch 3']
              .map((String value) => DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          ))
              .toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedClassBatch = newValue;
            });
          },
          decoration: const InputDecoration(
            labelText: 'Class/Batch*',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 32.0),

        // Take Attendance Button
        ElevatedButton(
          onPressed: () {
            // Toggle the attendance view
            setState(() {
              _attendanceTaken = true;
            });
          },
          child: const Text('Take Attendance'),
        ),
      ],
    );
  }

  // Attendance table after "Take Attendance" is pressed
  Widget _buildAttendanceTable() {
    return Column(
      children: [
        // Search bar (if needed)
        TextField(
          decoration: InputDecoration(
            hintText: 'Search',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16.0),

        // Date range selection
        Row(
          children: [
            Expanded(
              child: _buildDatePicker('From Date', onDateSelected: (date) {
                setState(() {
                  _fromDate = date;
                });
              }),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: _buildDatePicker('To Date', onDateSelected: (date) {
                setState(() {
                  _toDate = date;
                });
              }),
            ),
          ],
        ),
        const SizedBox(height: 16.0),

        // Attendance data table
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Sr. No.')),
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Class/Batch')),
                DataColumn(label: Text('Student')),
                DataColumn(label: Text('Attendance')),
              ],
              rows: attendanceData.map((data) {
                return DataRow(cells: [
                  DataCell(Text(data['srNo']!)),
                  DataCell(Text(data['date']!)),
                  DataCell(Text(data['classBatch']!)),
                  DataCell(Text(data['student']!)),
                  DataCell(
                    _isEditable
                        ? DropdownButton<String>(
                      value: data['attendance'],
                      items: ['Present', 'Absent'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          data['attendance'] = newValue!;
                        });
                      },
                    )
                        : Text(data['attendance']!),
                  ),
                ]);
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16.0),

        // Edit and Update buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isEditable = !_isEditable;
                });
              },
              icon: Icon(_isEditable ? Icons.lock : Icons.edit),
              label: Text(_isEditable ? 'Stop Edit' : 'Edit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              ),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: () {
                // Implement your 'Update Attendance' functionality here
                setState(() {
                  _isEditable = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              ),
              child: const Text(
                'Update Attendance',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Helper widget to build the date picker
  Widget _buildDatePicker(String label,
      {required Function(DateTime) onDateSelected}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText:
                  _formatDate(label == 'From Date' ? _fromDate : _toDate),
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  DateTime? selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (selectedDate != null && selectedDate != DateTime.now()) {
                    onDateSelected(selectedDate);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    return date != null ? DateFormat('dd/MM/yyyy').format(date) : 'Select Date';
  }
}

class ShareDocumentsScreen extends StatefulWidget {
  const ShareDocumentsScreen({super.key});

  @override
  _ShareDocumentsScreenState createState() => _ShareDocumentsScreenState();
}

class _ShareDocumentsScreenState extends State<ShareDocumentsScreen> {
  // Variables to hold selected values
  String _selectedStandard = '-- Select --';
  String _selectedShareOption = '-- Select --';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selection
            const Text('Selection',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16.0),

            // Select Standard to Share Document
            DropdownButtonFormField<String>(
              value: _selectedStandard,
              items: <String>[
                '-- Select --',
                'Standard 1',
                'Standard 2',
                'Standard 3'
              ]
                  .map((String value) => DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              ))
                  .toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedStandard = newValue!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Select Standard To Share Document',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),

            // How Would You Like To Share Document
            DropdownButtonFormField<String>(
              value: _selectedShareOption,
              items:
              <String>['-- Select --', 'Option 1', 'Option 2', 'Option 3']
                  .map((String value) => DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              ))
                  .toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedShareOption = newValue!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'How Would You Like To Share Document',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32.0),

            // Confirm Button
            ElevatedButton(
              onPressed: () {
                // Implement confirmation logic here
                if (_selectedStandard == '-- Select --' ||
                    _selectedShareOption == '-- Select --') {
                  // Show error or perform validation
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please select all required options')),
                  );
                } else {
                  // Proceed with confirmation logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Document sharing confirmed')),
                  );
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        ),
      ),
    );
  }
}

class ManageSharedDocumentsScreen extends StatefulWidget {
  const ManageSharedDocumentsScreen({super.key});

  @override
  _ManageSharedDocumentsScreenState createState() =>
      _ManageSharedDocumentsScreenState();
}

class _ManageSharedDocumentsScreenState
    extends State<ManageSharedDocumentsScreen> {
  // Dummy data for the shared documents list
  final List<Map<String, String>> _sharedDocuments = [
    {'standard': 'Standard 1', 'document': 'Document1.pdf'},
    {'standard': 'Standard 2', 'document': 'Document2.docx'},
    // Add more documents here
  ];

  void _editDocument(int index) {
    // Navigate to an edit screen or show a dialog to edit the document
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Document'),
          content:
          Text('Editing document: ${_sharedDocuments[index]['document']}'),
          actions: [
            TextButton(
              onPressed: () {
                // Implement save functionality
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _deleteDocument(int index) {
    // Implement delete functionality
    setState(() {
      _sharedDocuments.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Document deleted')),
    );
  }

  void _viewDocument(int index) {
    // Navigate to a view screen or show a dialog to view the document
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('View Document'),
          content:
          Text('Viewing document: ${_sharedDocuments[index]['document']}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    // Implement search functionality here
                  },
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            // Shared Documents List
            Expanded(
              child: ListView.builder(
                itemCount: _sharedDocuments.length,
                itemBuilder: (context, index) {
                  return SharedDocumentCard(
                    documentData: _sharedDocuments[index],
                    onEdit: () => _editDocument(index),
                    onDelete: () => _deleteDocument(index),
                    onView: () => _viewDocument(index),
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

// Custom widget for each shared document
class SharedDocumentCard extends StatelessWidget {
  final Map<String, String> documentData;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onView;

  const SharedDocumentCard({
    super.key,
    required this.documentData,
    required this.onEdit,
    required this.onDelete,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Standard: ${documentData['standard']}'),
            Text('Document Shared: ${documentData['document']}'),

            // Edit, Delete, and View buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: onDelete,
                ),
                IconButton(
                  icon: const Icon(Icons.visibility),
                  onPressed: onView,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ChatWithStudentsScreen extends StatelessWidget {
  const ChatWithStudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Chat With Students'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add New Chat
            const Text('Add New Chat',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16.0),

            // Subject/Topic
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Subject/Topic*',
                border: OutlineInputBorder(),
                contentPadding:
                EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              ),
            ),
            const SizedBox(height: 16.0),

            // Student Name
            DropdownButtonFormField<String>(
              value: null, // Changed to null to show default prompt
              items: <String>['Student 1', 'Student 2', 'Student 3']
                  .map((String value) => DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              ))
                  .toList(),
              onChanged: (String? newValue) {
                // Handle dropdown selection change
              },
              decoration: const InputDecoration(
                labelText: 'Student Name*',
                border: OutlineInputBorder(),
                contentPadding:
                EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              ),
            ),
            const SizedBox(height: 16.0),

            // Message
            TextFormField(
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Message*',
                border: OutlineInputBorder(),
                contentPadding:
                EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              ),
            ),
            const SizedBox(height: 32.0),

            // Send and Cancel buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        // Implement send message functionality
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, // Custom background color
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                      ),
                      child: const Text('Send', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        // Implement cancel functionality
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey, // Custom background color
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                      ),
                      child:
                      const Text('Cancel', style: TextStyle(fontSize: 16)),
                    ),
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

class StudentsFeedbackScreen extends StatelessWidget {
  const StudentsFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Student Feedback List'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    // Implement search functionality here
                  },
                ),
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
              ),
            ),
            const SizedBox(height: 16.0),

            // Student Feedback List
            Expanded(
              child: ListView.builder(
                itemCount: 1, // Replace with actual number of feedback
                itemBuilder: (context, index) {
                  return const StudentFeedbackCard(
                    // Pass feedback data here
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

// Custom widget for each student feedback
class StudentFeedbackCard extends StatelessWidget {
  const StudentFeedbackCard({super.key});

  // Add necessary properties for feedback data

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
          vertical: 8.0), // Adds vertical spacing between cards
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Student Name: XXXXXX',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Subject: XXXXXXXXXX',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'Feedback: Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
              style: TextStyle(
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16.0),

            // Action buttons (optional)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Implement view details functionality
                  },
                  child: const Text('View Details'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class StudentRightsScreen extends StatefulWidget {
  const StudentRightsScreen({super.key});

  @override
  _StudentRightsScreenState createState() => _StudentRightsScreenState();
}

class _StudentRightsScreenState extends State<StudentRightsScreen> {
  // Maps to hold the checked state for each item
  Map<String, bool> _activityChecks = {
    'Time Table': false,
    'My Document': false,
    'eStudy': false,
    'MCQ Exam': false,
    'My Class': false,
    'Chat With Tutor': false,
    'Feedback': false,
  };

  Map<String, bool> _reportChecks = {
    'Attendance Report': false,
    'Exam Performance Summary Report': false,
    'Exam Detail Report': false,
    'Fee Status Report': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Student Rights'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Assign Student Rights
            const Text('Assign Student Rights',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16.0),

            // My Activity
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('My Activity',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    _showAddItemDialog(context, 'Activity');
                  },
                ),
              ],
            ),
            Column(
              children: _activityChecks.keys.map((activity) {
                return CheckboxListTile(
                  title: Text(activity),
                  value: _activityChecks[activity],
                  onChanged: (bool? value) {
                    setState(() {
                      _activityChecks[activity] = value!;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16.0),

            // Reports
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Reports',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    _showAddItemDialog(context, 'Report');
                  },
                ),
              ],
            ),
            Column(
              children: _reportChecks.keys.map((report) {
                return CheckboxListTile(
                  title: Text(report),
                  value: _reportChecks[report],
                  onChanged: (bool? value) {
                    setState(() {
                      _reportChecks[report] = value!;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 32.0),

            // Save Button
            ElevatedButton(
              onPressed: () {
                // Implement save functionality
                _saveChanges();
              },
              child: const Text('SAVE'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddItemDialog(BuildContext context, String type) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New $type'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Enter $type'),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                setState(() {
                  if (type == 'Activity') {
                    _activityChecks[controller.text] = false;
                  } else {
                    _reportChecks[controller.text] = false;
                  }
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _saveChanges() {
    // Implement the logic to save the changes
    // For example, you could send the updated maps to a server or save them locally
    print('Activities: $_activityChecks');
    print('Reports: $_reportChecks');
  }
}
