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

class AssignClassBatchScreen extends StatefulWidget {
  const AssignClassBatchScreen ({super.key});
  @override
  _AssignClassBatchScreenState createState() => _AssignClassBatchScreenState();
}

class _AssignClassBatchScreenState extends State<AssignClassBatchScreen> {
  List<dynamic> students = [];
  List<dynamic> classBatches = [];
  String? selectedClassBatchId;
  String? selectedStudentId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  // Function to fetch students and class batches
  Future<void> fetchData() async {
    try {
      final allStudents = await getAllStudents();
      final allClassBatches = await getAllClassBatches();

      setState(() {
        students = allStudents;
        classBatches = allClassBatches;
        isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  // Fetch students from API
  Future<List<dynamic>> getAllStudents() async {
    final response = await http.get(Uri.parse('${AppConfig.baseUrl}/student/all'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load students');
    }
  }

  // Fetch class batches from API
  Future<List<dynamic>> getAllClassBatches() async {
    final response = await http.get(Uri.parse('${AppConfig.baseUrl}/class-batch/all'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load class batches');
    }
  }

  // Assign student to class/batch
  Future<void> assignStudentToClass() async {
    if (selectedStudentId != null && selectedClassBatchId != null) {
      try {
        final response = await http.post(
          Uri.parse('${AppConfig.baseUrl}/student/assign-class'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'studentId': selectedStudentId!,
            'classBatchId': selectedClassBatchId!,
          }),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Student assigned to class/batch successfully.')),
          );
        } else {
          throw Exception('Failed to assign student to class/batch');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to assign student to class/batch.')),
        );
      }
    }
  }

  // Remove student from class/batch
  Future<void> removeStudentFromClass() async {
    if (selectedStudentId != null && selectedClassBatchId != null) {
      try {
        final response = await http.post(
          Uri.parse('${AppConfig.baseUrl}/student/remove-class'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'studentId': selectedStudentId!,
            'classBatchId': selectedClassBatchId!,
          }),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Student removed from class/batch successfully.')),
          );
        } else {
          throw Exception('Failed to remove student from class/batch');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove student from class/batch.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Assign Class/Batch to Student'),
      automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Assign Class/Batch to Student',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Select Student',
                border: OutlineInputBorder(),
              ),
              items: students.map<DropdownMenuItem<String>>((student) {
                return DropdownMenuItem<String>(
                  value: student['_id'],
                  child: Text(student['name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedStudentId = value;
                });
              },
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Select Class/Batch',
                border: OutlineInputBorder(),
              ),
              items: classBatches.map<DropdownMenuItem<String>>((batch) {
                return DropdownMenuItem<String>(
                  value: batch['_id'],
                  child: Text(batch['classBatchName']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedClassBatchId = value;
                });
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: assignStudentToClass,
              child: Text('Assign Class/Batch To Student'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: removeStudentFromClass,
              child: Text('Remove Student From Class/Batch'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                padding: EdgeInsets.symmetric(vertical: 12),
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
  String _selectedMonth = DateFormat('MMMM').format(DateTime.now());
  String _day = DateFormat('d').format(DateTime.now());
  String _year = DateFormat('y').format(DateTime.now());
  bool _displayClassBatch = false;
  String? _selectedClassBatch;
  bool _attendanceTaken = false;
  bool _isEditable = false;
  DateTime? _fromDate;
  DateTime? _toDate;
  List<String> _classBatches = [];
  List<Map<String, dynamic>> attendanceData = [];  // Updated type

  @override
  void initState() {
    super.initState();
    _fetchClassBatches();
  }

  Future<void> _fetchClassBatches() async {
    try {
      final response = await http.get(Uri.parse('${AppConfig.baseUrl}/api/class-batch'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _classBatches = data.map((item) => item['name'] as String).toList();
        });
      }
    } catch (e) {
      print('Error fetching class batches: $e');
    }
  }

  Future<void> _fetchAttendanceData() async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/attendance-data'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'classBatchId': _selectedClassBatch,
          'date': DateFormat('yyyy-MM-dd').format(DateTime(
            int.parse(_year),
            DateFormat('MMMM').parse(_selectedMonth).month,
            int.parse(_day),
          )),
        }),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          attendanceData = data.map((item) {
            return {
              'id': item['_id'] ?? '',
              'date': DateFormat('dd/MM/yyyy').format(DateTime.parse(item['date'])),
              'classBatch': item['classBatch'] ?? '',
              'student': item['studentName'] ?? '',
              'attendance': item['status'] ?? 'Absent',
            };
          }).toList();
        });
      }
    } catch (e) {
      print('Error fetching attendance data: $e');
    }
  }

  Future<void> _updateAttendance() async {
    try {
      for (var data in attendanceData) {
        final response = await http.post(
          Uri.parse('${AppConfig.baseUrl}/api/update-attendance'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'attendanceId': data['id'],
            'status': data['attendance'],
          }),
        );
        if (response.statusCode != 200) {
          throw Exception('Failed to update attendance');
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Attendance updated successfully')));
    } catch (e) {
      print('Error updating attendance: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Attendance'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _attendanceTaken ? _buildAttendanceTable() : _buildAttendanceForm(),
      ),
    );
  }

  Widget _buildAttendanceForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Take Student Attendance', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16.0),
        Row(
          children: [
            Flexible(
              flex: 3,
              child: DropdownButtonFormField<String>(
                value: _selectedMonth,
                items: <String>[
                  'January', 'February', 'March', 'April', 'May', 'June',
                  'July', 'August', 'September', 'October', 'November', 'December'
                ].map((String value) => DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                )).toList(),
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
            const SizedBox(width: 8.0),
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
            const SizedBox(width: 8.0),
            Flexible(
              flex: 2,
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
        DropdownButtonFormField<String>(
          value: _selectedClassBatch,
          hint: const Text('-- Select --'),
          items: _classBatches.map((String value) => DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          )).toList(),
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
        const SizedBox(height: 16.0),
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                _fetchAttendanceData();
                setState(() {
                  _attendanceTaken = true;
                  _isEditable = false;
                });
              },
              child: const Text('Get Attendance'),
            ),
            const SizedBox(width: 16.0),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isEditable = true;
                });
              },
              child: const Text('Reset'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAttendanceTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Student Attendance', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16.0),
        Table(
          border: TableBorder.all(),
          children: [
            TableRow(
              children: [
                TableCell(child: Center(child: Text('Sr. No'))),
                TableCell(child: Center(child: Text('Date'))),
                TableCell(child: Center(child: Text('Class/Batch'))),
                TableCell(child: Center(child: Text('Student'))),
                TableCell(child: Center(child: Text('Attendance'))),
              ],
            ),
            for (int i = 0; i < attendanceData.length; i++)
              TableRow(
                children: [
                  TableCell(child: Center(child: Text('${i + 1}'))),
                  TableCell(child: Center(child: Text(attendanceData[i]['date'] as String))),
                  TableCell(child: Center(child: Text(attendanceData[i]['classBatch'] as String))),
                  TableCell(child: Center(child: Text(attendanceData[i]['student'] as String))),
                  TableCell(
                    child: Center(
                      child: DropdownButton<String>(
                        value: attendanceData[i]['attendance'] as String,
                        items: ['Present', 'Absent'].map((String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        )).toList(),
                        onChanged: _isEditable ? (String? newValue) {
                          setState(() {
                            attendanceData[i]['attendance'] = newValue!;
                          });
                        } : null,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 16.0),
        ElevatedButton(
          onPressed: _updateAttendance,
          child: const Text('Save Changes'),
        ),
      ],
    );
  }
}


class ShareDocumentsScreen extends StatefulWidget {
  const ShareDocumentsScreen({super.key});

  @override
  _ShareDocumentsScreenState createState() => _ShareDocumentsScreenState();
}

class _ShareDocumentsScreenState extends State<ShareDocumentsScreen> {
  // Variables to hold selected values
  String _selectedClassBatch = '-- Select --';
  File? _selectedFile;
  String _message = '';

  // List to hold class/batch from the backend
  List<String> _classBatchList = ['-- Select --'];

  @override
  void initState() {
    super.initState();
    _fetchClassBatchData(); // Fetch the class/batch data from the backend
  }

  // Method to fetch class/batch data from the backend
  Future<void> _fetchClassBatchData() async {
    try {
      final response = await http.get(Uri.parse('${AppConfig.baseUrl}/api/class-batch')); // Replace with your backend API URL
      if (response.statusCode == 200) {
        List<String> classBatches = List<String>.from(jsonDecode(response.body));
        setState(() {
          _classBatchList = ['-- Select --'] + classBatches;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load class/batch data')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Method to pick a file
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  // Method to upload data to the backend
  Future<void> _uploadDocument() async {
    if (_selectedClassBatch == '-- Select --' || _selectedFile == null || _message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    var request = http.MultipartRequest('POST', Uri.parse('${AppConfig.baseUrl}/api/documents')); // Replace with your API URL
    request.fields['class_batch'] = _selectedClassBatch;
    request.fields['message'] = _message;
    request.files.add(await http.MultipartFile.fromPath('file', _selectedFile!.path));

    var response = await request.send();
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document uploaded successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload document')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Document'),
        automaticallyImplyLeading: false, // Move this line to the AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Select Class/Batch
            const Text('Select Class/Batch',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: _selectedClassBatch,
              items: _classBatchList.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedClassBatch = newValue!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Select Class/Batch',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),

            // Select File to Upload
            const Text('Select File to Upload',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _pickFile,
              child: const Text('Choose File'),
            ),
            if (_selectedFile != null)
              Text('Selected File: ${_selectedFile!.path}'),

            const SizedBox(height: 16.0),

            // Message Input Field
            const Text('Message', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16.0),
            TextField(
              onChanged: (value) {
                setState(() {
                  _message = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Enter your message',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32.0),

            // Confirm Button
            ElevatedButton(
              onPressed: _uploadDocument,
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
  List<Map<String, dynamic>> _sharedDocuments = [];
  List<Map<String, dynamic>> _filteredDocuments = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchDocuments();
    _searchController.addListener(_filterDocuments);
  }

  Future<void> _fetchDocuments() async {
    try {
      final response = await http.get(Uri.parse('${AppConfig.baseUrl}/api/documents'));
      if (response.statusCode == 200) {
        final List<dynamic> documents = jsonDecode(response.body);
        setState(() {
          _sharedDocuments = documents.map((doc) => {
            'id': doc['_id'],
            'standard': doc['standard'],
            'document': doc['documentName'],
            'message': doc['message'] ?? ''
          }).toList();
          _filteredDocuments = _sharedDocuments;  // Initially, all documents are shown
        });
      } else {
        throw Exception('Failed to load documents');
      }
    } catch (e) {
      print(e);
    }
  }

  void _filterDocuments() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredDocuments = _sharedDocuments.where((doc) {
        final documentName = doc['document'].toLowerCase();
        final standard = doc['standard'].toLowerCase();
        return documentName.contains(query) || standard.contains(query);
      }).toList();
    });
  }

  void _editDocument(int index) {
    TextEditingController _messageController = TextEditingController();
    TextEditingController _standardController = TextEditingController();
    TextEditingController _documentController = TextEditingController();

    _messageController.text = _filteredDocuments[index]['message'] ?? '';
    _standardController.text = _filteredDocuments[index]['standard'];
    _documentController.text = _filteredDocuments[index]['document'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Document'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _standardController,
                decoration: const InputDecoration(labelText: 'Class/Batch'),
              ),
              TextField(
                controller: _documentController,
                decoration: const InputDecoration(labelText: 'Document Name'),
              ),
              TextField(
                controller: _messageController,
                decoration: const InputDecoration(labelText: 'Message'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await _updateDocument(
                  _filteredDocuments[index]['id'],
                  _standardController.text,
                  _documentController.text,
                  _messageController.text,
                );
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

  Future<void> _updateDocument(String id, String standard, String documentName, String message) async {
    try {
      final response = await http.put(
        Uri.parse('${AppConfig.baseUrl}/api/documents/$id'),
        body: jsonEncode({
          'standard': standard,
          'documentName': documentName,
          'message': message,
        }),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        _fetchDocuments(); // Refresh the list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document updated successfully')),
        );
      } else {
        throw Exception('Failed to update document');
      }
    } catch (e) {
      print(e);
    }
  }

  void _deleteDocument(int index) async {
    try {
      final response = await http.delete(
        Uri.parse('${AppConfig.baseUrl}/api/documents/${_filteredDocuments[index]['id']}'),
      );
      if (response.statusCode == 200) {
        setState(() {
          _filteredDocuments.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document deleted')),
        );
      } else {
        throw Exception('Failed to delete document');
      }
    } catch (e) {
      print(e);
    }
  }

  void _viewDocument(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('View Document'),
          content: Text('Viewing document: ${_filteredDocuments[index]['document']}'),
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
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _filterDocuments();  // Reset the list to original
                  },
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            // Shared Documents List
            Expanded(
              child: ListView.builder(
                itemCount: _filteredDocuments.length,
                itemBuilder: (context, index) {
                  return SharedDocumentCard(
                    documentData: _filteredDocuments[index],
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

class SharedDocumentCard extends StatelessWidget {
  final Map<String, dynamic> documentData;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onView;

  const SharedDocumentCard({
    required this.documentData,
    required this.onEdit,
    required this.onDelete,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(documentData['document']),
        subtitle: Text('Class/Batch: ${documentData['standard']}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.visibility),
              onPressed: onView,
            ),
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
      ),
    );
  }
}


class ChatWithStudentsScreen extends StatefulWidget {
  const ChatWithStudentsScreen({super.key});

  @override
  _ChatWithStudentsScreenState createState() => _ChatWithStudentsScreenState();
}

class _ChatWithStudentsScreenState extends State<ChatWithStudentsScreen> {
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _filteredStudents = [];
  String? _selectedStudent;
  TextEditingController _searchController = TextEditingController();
  TextEditingController _subjectController = TextEditingController();
  TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchStudents();
    _searchController.addListener(_filterStudents);
  }

  Future<void> _fetchStudents() async {
    try {
      final response = await http.get(Uri.parse('${AppConfig.baseUrl}/api/students')); //if this not works change it to (Uri.parse('${AppConfig.baseUrl}/api/users?role=Student'));
      if (response.statusCode == 200) {
        final List<dynamic> students = jsonDecode(response.body);
        setState(() {
          _students = students.map((student) => {
            'id': student['_id'],
            'name': student['name'],
          }).toList();
          _filteredStudents = _students;
        });
      } else {
        throw Exception('Failed to load students');
      }
    } catch (e) {
      print(e);
    }
  }

  void _filterStudents() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredStudents = _students.where((student) {
        return student['name'].toLowerCase().contains(query);
      }).toList();
    });
  }

  void _selectStudent(String studentName) {
    setState(() {
      _selectedStudent = studentName;
      _searchController.text = studentName; // Set the search bar with the selected student's name
    });
  }

  Future<void> _sendMessage() async {
    if (_selectedStudent != null && _subjectController.text.isNotEmpty && _messageController.text.isNotEmpty) {
      try {
        final student = _students.firstWhere((student) => student['name'] == _selectedStudent);
        final response = await http.post(
          Uri.parse('${AppConfig.baseUrl}/api/messageStudent'),
          body: jsonEncode({
            'studentId': student['id'],
            'subject': _subjectController.text,
            'message': _messageController.text,
          }),
          headers: {'Content-Type': 'application/json'},
        );
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Message sent successfully')),
          );
          _resetForm();
        } else {
          throw Exception('Failed to send message');
        }
      } catch (e) {
        print(e);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all the fields')),
      );
    }
  }

  void _resetForm() {
    setState(() {
      _selectedStudent = null;
      _subjectController.clear();
      _messageController.clear();
      _searchController.clear();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

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
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search Student',
                suffixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16.0),

            // Dropdown for Student Names
            DropdownButtonFormField<String>(
              value: _selectedStudent,
              items: _filteredStudents.map((student) {
                return DropdownMenuItem<String>(
                  value: student['name'],
                  child: Text(student['name']),
                );
              }).toList(),
              onChanged: (String? newValue) {
                _selectStudent(newValue!);
              },
              decoration: const InputDecoration(
                labelText: 'Student Name*',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              ),
            ),
            const SizedBox(height: 16.0),

            // Subject/Topic
            TextFormField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: 'Subject/Topic*',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              ),
            ),
            const SizedBox(height: 16.0),

            // Message
            TextFormField(
              controller: _messageController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Message*',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
                      onPressed: _sendMessage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
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
                      onPressed: _resetForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                      ),
                      child: const Text('Cancel', style: TextStyle(fontSize: 16)),
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

class StudentsFeedbackScreen extends StatefulWidget {
  const StudentsFeedbackScreen({super.key});

  @override
  _StudentsFeedbackScreenState createState() => _StudentsFeedbackScreenState();
}

class _StudentsFeedbackScreenState extends State<StudentsFeedbackScreen> {
  List<dynamic> _feedbacks = [];
  List<dynamic> _filteredFeedbacks = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchFeedbacks();
  }

  Future<void> _fetchFeedbacks() async {
    try {
      final response = await http.get(Uri.parse('${AppConfig.baseUrl}/api/feedbacks'));
      if (response.statusCode == 200) {
        final List<dynamic> feedbacks = jsonDecode(response.body);
        setState(() {
          _feedbacks = feedbacks;
          _filteredFeedbacks = feedbacks;
        });
      } else {
        throw Exception('Failed to load feedbacks');
      }
    } catch (e) {
      print(e);
    }
  }

  void _filterFeedbacks(String query) {
    setState(() {
      _searchQuery = query;
      _filteredFeedbacks = _feedbacks.where((feedback) {
        return feedback['studentName'].toLowerCase().contains(query.toLowerCase()) ||
            feedback['subject'].toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

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
              onChanged: _filterFeedbacks,
              decoration: InputDecoration(
                hintText: 'Search by Student Name or Subject',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    // Implement search functionality here if needed
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
                itemCount: _filteredFeedbacks.length,
                itemBuilder: (context, index) {
                  return StudentFeedbackCard(
                    feedback: _filteredFeedbacks[index],
                    onViewDetails: () {
                      // Implement view details functionality
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FeedbackDetailScreen(feedback: _filteredFeedbacks[index]),
                        ),
                      );
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
}

// Custom widget for each student feedback
class StudentFeedbackCard extends StatelessWidget {
  final Map<String, dynamic> feedback;
  final VoidCallback onViewDetails;

  const StudentFeedbackCard({super.key, required this.feedback, required this.onViewDetails});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Student Name: ${feedback['studentName']}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Subject: ${feedback['subject']}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Feedback: ${feedback['feedback']}',
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16.0),

            // Action button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: onViewDetails,
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

// Dummy feedback detail screen
class FeedbackDetailScreen extends StatelessWidget {
  final Map<String, dynamic> feedback;

  const FeedbackDetailScreen({super.key, required this.feedback});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feedback Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Student Name: ${feedback['studentName']}'),
            Text('Subject: ${feedback['subject']}'),
            Text('Feedback: ${feedback['feedback']}'),
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
    'Fee Status Report': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Rights to Student Role'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Assign Rights',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16.0),

            // My Activity
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('My Activity', style: TextStyle(fontWeight: FontWeight.bold)),
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
                const Text('Reports', style: TextStyle(fontWeight: FontWeight.bold)),
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
                // Save the selected rights to the backend
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

  Future<void> _saveChanges() async {
    try {
      // Combine selected rights from both activities and reports
      Map<String, bool> selectedRights = {
        ..._activityChecks,
        ..._reportChecks,
      };

      // Send to backend
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/assign-rights'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'role': 'Student', 'rights': selectedRights}),
      );

      if (response.statusCode == 200) {
        print('Rights saved successfully');
      } else {
        throw Exception('Failed to save rights');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}
