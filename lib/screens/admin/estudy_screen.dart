import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:testing_app/screens/config.dart';

class EstudyScreen extends StatelessWidget {
  final String option;

  const EstudyScreen({this.option = 'createStudyMaterial'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('EStudy'),
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    switch (option) {
      case 'createStudyMaterial':
        return CreateStudyMaterialScreen();
      case 'manageStudyMaterial':
        return ManageStudyMaterialScreen();
      case 'manageSharedStudyMaterial':
        return ManageSharedStudyMaterialScreen();
      default:
        return Center(child: Text('Unknown Option'));
    }
  }
}

class CreateStudyMaterialScreen extends StatefulWidget {
  @override
  _CreateStudyMaterialScreenState createState() => _CreateStudyMaterialScreenState();
}

class _CreateStudyMaterialScreenState extends State<CreateStudyMaterialScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _courseNameController = TextEditingController();
  final TextEditingController _standardController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  File? _file;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png', 'doc', 'docx', 'txt'],
    );

    if (result != null) {
      setState(() {
        _file = File(result.files.single.path!);
      });
    }
  }

  Future<void> _saveStudyMaterial() async {
    if (_formKey.currentState!.validate()) {
      final courseName = _courseNameController.text;
      final standard = _standardController.text;
      final subject = _subjectController.text;

      if (courseName.isEmpty || standard.isEmpty || subject.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please fill in all required fields.')),
        );
        return;
      }

      try {
        final uri = Uri.parse('${AppConfig.baseUrl}/api/study-material');
        var request = http.MultipartRequest('POST', uri)
          ..fields['courseName'] = courseName
          ..fields['standard'] = standard
          ..fields['subject'] = subject;

        if (_file != null) {
          request.files.add(await http.MultipartFile.fromPath('file', _file!.path));
        }

        final response = await request.send();
        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Study material created successfully')),
          );
          _resetForm();
          Navigator.pop(context, true); // Pass true to indicate success
        } else {
          throw Exception('Failed to create study material');
        }
      } catch (e) {
        print('Error saving study material: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving study material: $e')),
        );
      }
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _courseNameController.clear();
    _standardController.clear();
    _subjectController.clear();
    setState(() {
      _file = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create Study Material',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              _buildTextField('Course Name *', _courseNameController),
              SizedBox(height: 16),
              _buildDropdownField('Standard *', _standardController),
              SizedBox(height: 16),
              _buildDropdownField('Subject *', _subjectController),
              SizedBox(height: 16),
              _buildFileUploader(),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveStudyMaterial,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: Text('SAVE'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _resetForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                      ),
                      child: Text('RESET'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            border: OutlineInputBorder(),
          ),
          items: [
            DropdownMenuItem(
              value: 'option1',
              child: Text('Option 1'),
            ),
            DropdownMenuItem(
              value: 'option2',
              child: Text('Option 2'),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              controller.text = value;
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            return null;
          },
          hint: Text('-- Select --'),
        ),
      ],
    );
  }

  Widget _buildFileUploader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload File *',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        InkWell(
          onTap: _pickFile,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 10.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _file != null ? _file!.path.split('/').last : 'No file selected',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                Icon(Icons.upload_file, color: Colors.grey[600]),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


class ManageStudyMaterialScreen extends StatefulWidget {
  @override
  _ManageStudyMaterialScreenState createState() => _ManageStudyMaterialScreenState();
}

class _ManageStudyMaterialScreenState extends State<ManageStudyMaterialScreen> {
  List<dynamic> _studyMaterials = [];

  @override
  void initState() {
    super.initState();
    _fetchStudyMaterials();
  }

  Future<void> _fetchStudyMaterials() async {
    try {
      final response = await http.get(Uri.parse('${AppConfig.baseUrl}/api/study-material'));
      if (response.statusCode == 200) {
        setState(() {
          _studyMaterials = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load study materials');
      }
    } catch (e) {
      print('Error fetching study materials: $e');
    }
  }

  Future<void> _deleteStudyMaterial(String id) async {
    try {
      final response = await http.delete(Uri.parse('${AppConfig.baseUrl}/api/study-material/$id'));
      if (response.statusCode == 200) {
        _fetchStudyMaterials(); // Refresh the list after deletion
      } else {
        throw Exception('Failed to delete study material');
      }
    } catch (e) {
      print('Error deleting study material: $e');
    }
  }

  Future<void> _showEditDialog(Map<String, dynamic> material) async {
    final _formKey = GlobalKey<FormState>();
    String _courseName = material['courseName'];
    String _standard = material['standard'];
    String _subject = material['subject'];

    await showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissal by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Study Material'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    initialValue: _courseName,
                    decoration: InputDecoration(labelText: 'Course Name'),
                    onChanged: (value) => _courseName = value,
                    validator: (value) => value!.isEmpty ? 'Please enter course name' : null,
                  ),
                  TextFormField(
                    initialValue: _standard,
                    decoration: InputDecoration(labelText: 'Standard'),
                    onChanged: (value) => _standard = value,
                    validator: (value) => value!.isEmpty ? 'Please enter standard' : null,
                  ),
                  TextFormField(
                    initialValue: _subject,
                    decoration: InputDecoration(labelText: 'Subject'),
                    onChanged: (value) => _subject = value,
                    validator: (value) => value!.isEmpty ? 'Please enter subject' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  try {
                    final response = await http.put(
                      Uri.parse('${AppConfig.baseUrl}/api/study-material/${material['_id']}'),
                      headers: {'Content-Type': 'application/json'},
                      body: json.encode({
                        'courseName': _courseName,
                        'standard': _standard,
                        'subject': _subject,
                      }),
                    );

                    if (response.statusCode == 200) {
                      Navigator.of(context).pop(true); // Return true to refresh the list
                    } else {
                      throw Exception('Failed to update study material');
                    }
                  } catch (e) {
                    print('Error updating study material: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error updating study material')),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    ).then((result) {
      if (result == true) { // Check if the result is true
        _fetchStudyMaterials(); // Refresh data
      }
    });
  }

  void _navigateToCreateStudyMaterial() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateStudyMaterialScreen()),
    );

    if (result == true) { // Check if the result is true
      _fetchStudyMaterials(); // Refresh data
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Manage Study Materials'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchStudyMaterials, // Add a refresh button
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: _studyMaterials.length,
                itemBuilder: (context, index) {
                  final material = _studyMaterials[index];
                  return ListTile(
                    title: Text('Course Name: ${material['courseName']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Standard: ${material['standard']}'),
                        Text('Subject: ${material['subject']}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _showEditDialog(material);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _deleteStudyMaterial(material['_id']);
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateStudyMaterial,
        child: Icon(Icons.add),
        tooltip: 'Add Study Material',
      ),
    );
  }
}


class ManageSharedStudyMaterialScreen extends StatefulWidget {
  @override
  _ManageSharedStudyMaterialScreenState createState() => _ManageSharedStudyMaterialScreenState();
}

class _ManageSharedStudyMaterialScreenState extends State<ManageSharedStudyMaterialScreen> {
  List<dynamic> _studyMaterials = [];

  @override
  void initState() {
    super.initState();
    _fetchStudyMaterials();
  }

  Future<void> _fetchStudyMaterials() async {
    try {
      final response = await http.get(Uri.parse('${AppConfig.baseUrl}/api/study-material'));
      if (response.statusCode == 200) {
        setState(() {
          _studyMaterials = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load study materials');
      }
    } catch (e) {
      print('Error fetching study materials: $e');
    }
  }

  Future<void> _deleteStudyMaterial(String id) async {
    try {
      final response = await http.delete(Uri.parse('${AppConfig.baseUrl}/api/study-material/$id'));
      if (response.statusCode == 200) {
        _fetchStudyMaterials(); // Refresh the list after deletion
      } else {
        throw Exception('Failed to delete study material');
      }
    } catch (e) {
      print('Error deleting study material: $e');
    }
  }

  Future<void> _showEditDialog(Map<String, dynamic> material) async {
    final _formKey = GlobalKey<FormState>();
    String _courseName = material['courseName'];
    String _standard = material['standard'];
    String _subject = material['subject'];

    await showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissal by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Study Material'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    initialValue: _courseName,
                    decoration: InputDecoration(labelText: 'Course Name'),
                    onChanged: (value) => _courseName = value,
                    validator: (value) => value!.isEmpty ? 'Please enter course name' : null,
                  ),
                  TextFormField(
                    initialValue: _standard,
                    decoration: InputDecoration(labelText: 'Standard'),
                    onChanged: (value) => _standard = value,
                    validator: (value) => value!.isEmpty ? 'Please enter standard' : null,
                  ),
                  TextFormField(
                    initialValue: _subject,
                    decoration: InputDecoration(labelText: 'Subject'),
                    onChanged: (value) => _subject = value,
                    validator: (value) => value!.isEmpty ? 'Please enter subject' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  try {
                    final response = await http.put(
                      Uri.parse('${AppConfig.baseUrl}/api/study-material/${material['_id']}'),
                      headers: {'Content-Type': 'application/json'},
                      body: json.encode({
                        'courseName': _courseName,
                        'standard': _standard,
                        'subject': _subject,
                      }),
                    );

                    if (response.statusCode == 200) {
                      Navigator.of(context).pop(true); // Return true to refresh the list
                    } else {
                      throw Exception('Failed to update study material');
                    }
                  } catch (e) {
                    print('Error updating study material: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error updating study material')),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    ).then((result) {
      if (result == true) { // Check if the result is true
        _fetchStudyMaterials(); // Refresh data
      }
    });
  }

  void _navigateToCreateStudyMaterial() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateStudyMaterialScreen()),
    );

    if (result == true) { // Check if the result is true
      _fetchStudyMaterials(); // Refresh data
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Manage Shared Study Materials'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchStudyMaterials, // Add a refresh button
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: _studyMaterials.length,
                itemBuilder: (context, index) {
                  final material = _studyMaterials[index];
                  return ListTile(
                    title: Text('Course Name: ${material['courseName']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Standard: ${material['standard']}'),
                        Text('Subject: ${material['subject']}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _showEditDialog(material);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _deleteStudyMaterial(material['_id']);
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateStudyMaterial,
        child: Icon(Icons.add),
        tooltip: 'Add Study Material',
      ),
    );
  }
}
