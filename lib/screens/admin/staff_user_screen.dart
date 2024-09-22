import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:testing_app/screens/config.dart';

class StaffUserScreen extends StatefulWidget {
  final String option;

  const StaffUserScreen({super.key, this.option = 'createStaff'});

  @override
  _StaffUserScreenState createState() => _StaffUserScreenState();
}

class _StaffUserScreenState extends State<StaffUserScreen> {
  List<Map<String, dynamic>> staffList = [];

  void addStaff(Map<String, dynamic> staff) {
    setState(() {
      staffList.add(staff);
    });
  }

  void editStaff(int index, Map<String, dynamic> staff) {
    setState(() {
      staffList[index] = staff;
    });
  }

  void deleteStaff(int index) {
    setState(() {
      staffList.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff/User'),
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    switch (widget.option) {
      case 'createStaff':
        return CreateStaffScreen(onSave: addStaff);
      case 'manageStaff':
        return ManageStaffScreen();
      case 'manageStaffRights':
        return ManageStaffRightsScreen(); // Pass the staff list here
      case 'staffAttendance':
        return const StaffAttendanceScreen();
      default:
        return const Center(child: Text('Unknown Option'));
    }
  }
}

class CreateStaffScreen extends StatefulWidget {
  final Map<String, dynamic>? staff; // Optional parameter for editing staff
  final void Function(Map<String, dynamic>) onSave;

  const CreateStaffScreen({Key? key, this.staff, required this.onSave})
      : super(key: key);

  @override
  _CreateStaffScreenState createState() => _CreateStaffScreenState();
}

class _CreateStaffScreenState extends State<CreateStaffScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController(); // Password controller
  XFile? _profilePicture;
  bool _isEditable = true;
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    if (widget.staff != null) {
      // Initialize controllers with staff data if available
      final staff = widget.staff!;
      _firstNameController.text = staff['firstName'] ?? '';
      _middleNameController.text = staff['middleName'] ?? '';
      _lastNameController.text = staff['lastName'] ?? '';
      _selectedGender = staff['gender'] ?? '';
      _mobileController.text = staff['mobile'] ?? '';
      _emailController.text = staff['email'] ?? '';
      _addressController.text = staff['address'] ?? '';
      _profilePicture = staff['profilePicture'] != null
          ? XFile(staff['profilePicture'])
          : null;
      _isEditable = false; // Set editable state based on staff data
    }
  }

  void _resetForm() {
    if (widget.staff == null) {
      setState(() {
        _isEditable = true;
        _firstNameController.clear();
        _middleNameController.clear();
        _lastNameController.clear();
        _selectedGender = null;
        _mobileController.clear();
        _emailController.clear();
        _addressController.clear();
        _passwordController.clear(); // Clear password field
        _profilePicture = null;
      });
    }
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      final staffData = {
        'firstName': _firstNameController.text,
        'middleName': _middleNameController.text,
        'lastName': _lastNameController.text,
        'gender': _selectedGender,
        'mobile': _mobileController.text,
        'email': _emailController.text,
        'address': _addressController.text,
        'profilePicture': _profilePicture?.path, // Save image path
      };

      final staffUrl = widget.staff == null
          ? '${AppConfig.baseUrl}/api/staff' // URL for creating staff
          : '${AppConfig.baseUrl}/api/staff/${widget.staff!['id']}'; // URL for updating staff

      final staffResponse = await http.post(
        Uri.parse(staffUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(staffData),
      );

      // If new staff, create user in users collection
      if (widget.staff == null) {
        final usersData = {
          'email': _emailController.text,
          'password': _passwordController.text,
          'role': 'staff', // Define role as staff
        };

        final usersUrl = '${AppConfig.baseUrl}/api/auth/register';

        final usersResponse = await http.post(
          Uri.parse(usersUrl),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(usersData),
        );

        if (staffResponse.statusCode == 201 &&
            usersResponse.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Staff details saved successfully')),
          );
          widget.onSave(staffData); // Notify parent widget with saved data
          _resetForm();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save staff details')),
          );
        }
      } else {
        if (staffResponse.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Staff details updated successfully')),
          );
          widget.onSave(staffData); // Notify parent widget with saved data
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update staff details')),
          );
        }
      }
    }
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool readOnly = false}) {
    return TextFormField(
      controller: controller,
      readOnly: !_isEditable || readOnly,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label is required';
        }
        return null;
      },
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      hint: const Text('Select Gender*'),
      items: const [
        DropdownMenuItem(value: 'Male', child: Text('Male')),
        DropdownMenuItem(value: 'Female', child: Text('Female')),
        DropdownMenuItem(value: 'Other', child: Text('Other')),
      ],
      onChanged: _isEditable
          ? (value) {
              setState(() {
                _selectedGender = value;
              });
            }
          : null,
      validator: (value) {
        if (value == null) {
          return 'Gender is required';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    if (widget.staff != null)
      return Container(); // Don't show password field for existing staff
    return TextFormField(
      controller: _passwordController,
      obscureText: true,
      decoration: const InputDecoration(
        labelText: 'Password',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Password is required';
        }
        return null;
      },
    );
  }

  Widget _buildProfilePicturePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Profile Picture:'),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _isEditable ? _pickImage : null,
          child: Container(
            height: 150,
            width: 150,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
            ),
            child: _profilePicture == null
                ? const Center(child: Text('No image selected'))
                : Image.file(File(_profilePicture!.path), fit: BoxFit.cover),
          ),
        ),
      ],
    );
  }

  void _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _profilePicture = image;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.staff == null ? 'Create Staff' : 'Edit Staff'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField('First Name*', _firstNameController),
              const SizedBox(height: 16),
              _buildTextField('Middle Name', _middleNameController),
              const SizedBox(height: 16),
              _buildTextField('Last Name*', _lastNameController),
              const SizedBox(height: 16),
              _buildGenderDropdown(),
              const SizedBox(height: 16),
              _buildTextField('Mobile No*', _mobileController,
                  readOnly: !_isEditable),
              const SizedBox(height: 16),
              _buildTextField('Email', _emailController),
              const SizedBox(height: 16),
              _buildTextField('Address', _addressController),
              const SizedBox(height: 16),
              _buildPasswordField(), // Include password field for new staff
              const SizedBox(height: 20),
              _buildProfilePicturePicker(),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _resetForm,
                    child: const Text('Reset'),
                  ),
                  ElevatedButton(
                    onPressed: _saveForm,
                    child: Text(
                        widget.staff == null ? 'Create Staff' : 'Update Staff'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ManageStaffScreen extends StatefulWidget {
  @override
  _ManageStaffScreenState createState() => _ManageStaffScreenState();
}

class _ManageStaffScreenState extends State<ManageStaffScreen> {
  List<Map<String, dynamic>> staffList = [];
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  int? _editingIndex;
  String? _profilePicturePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchStaffList();
  }

  Future<void> _fetchStaffList() async {
    final url = '${AppConfig.baseUrl}/api/staff';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          staffList = data
              .map((staff) => {
                    'id': staff['_id'],
                    'firstName': staff['firstName'],
                    'lastName': staff['lastName'],
                    'email': staff['email'],
                    'mobile': staff['mobile'],
                    'gender': staff['gender'],
                    'address': staff['address'],
                    'profilePicture': staff['profilePicture'],
                  })
              .toList();
        });
      } else {
        print('Failed to load staff');
      }
    } catch (e) {
      print('Error fetching staff list: $e');
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profilePicturePath = pickedFile.path;
      });
    }
  }

  void _onEdit(int index, Map<String, dynamic> staff) {
    setState(() {
      _editingIndex = index;
      _firstNameController.text = staff['firstName'];
      _lastNameController.text = staff['lastName'];
      _emailController.text = staff['email'] ?? '';
      _mobileController.text = staff['mobile'] ?? '';
      _genderController.text = staff['gender'] ?? '';
      _addressController.text = staff['address'] ?? '';
      _profilePicturePath = staff['profilePicture'];
    });
  }

  Future<void> _onSave() async {
    if (_editingIndex == null) return;

    final updatedStaff = {
      'firstName': _firstNameController.text,
      'lastName': _lastNameController.text,
      'email': _emailController.text,
      'mobile': _mobileController.text,
      'gender': _genderController.text,
      'address': _addressController.text,
    };

    final url =
        '${AppConfig.baseUrl}/api/staff/${staffList[_editingIndex!]['id']}'; // Adjust the endpoint
    final request = http.MultipartRequest('PUT', Uri.parse(url));
    request.fields
        .addAll(updatedStaff.map((key, value) => MapEntry(key, value)));

    if (_profilePicturePath != null) {
      request.files.add(await http.MultipartFile.fromPath(
          'profilePicture', _profilePicturePath!));
    }

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await http.Response.fromStream(response);
      setState(() {
        staffList[_editingIndex!] = json.decode(responseData.body);
        _editingIndex = null;
        _clearControllers();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Staff updated successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update staff')),
      );
    }
  }

  Future<void> _onDelete(int index) async {
    final url =
        '${AppConfig.baseUrl}/api/staff/${staffList[index]['id']}'; // Adjust the endpoint
    final response = await http.delete(Uri.parse(url));

    if (response.statusCode == 200) {
      setState(() {
        staffList.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Staff deleted successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete staff')),
      );
    }
  }

  void _clearControllers() {
    _firstNameController.clear();
    _lastNameController.clear();
    _emailController.clear();
    _mobileController.clear();
    _genderController.clear();
    _addressController.clear();
    _profilePicturePath = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Staff')),
      body: staffList.isEmpty
          ? Center(child: Text('No staff members currently'))
          : ListView.builder(
              itemCount: staffList.length,
              itemBuilder: (context, index) {
                final staff = staffList[index];
                return ListTile(
                  leading: staff['profilePicture'] != null
                      ? CircleAvatar(
                          backgroundImage:
                              NetworkImage(staff['profilePicture']),
                        )
                      : const CircleAvatar(child: Icon(Icons.person)),
                  title: _editingIndex == index
                      ? TextField(
                          controller: _firstNameController,
                          decoration:
                              const InputDecoration(labelText: 'First Name'),
                        )
                      : Text('${staff['firstName']} ${staff['lastName']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _editingIndex == index
                          ? TextField(
                              controller: _lastNameController,
                              decoration:
                                  const InputDecoration(labelText: 'Last Name'),
                            )
                          : Text('Email: ${staff['email']}'),
                      _editingIndex == index
                          ? TextField(
                              controller: _emailController,
                              decoration:
                                  const InputDecoration(labelText: 'Email'),
                            )
                          : Text('Mobile: ${staff['mobile']}'),
                      _editingIndex == index
                          ? TextField(
                              controller: _mobileController,
                              decoration:
                                  const InputDecoration(labelText: 'Mobile'),
                            )
                          : Text('Gender: ${staff['gender']}'),
                      _editingIndex == index
                          ? TextField(
                              controller: _genderController,
                              decoration:
                                  const InputDecoration(labelText: 'Gender'),
                            )
                          : Text('Address: ${staff['address']}'),
                      _editingIndex == index
                          ? TextField(
                              controller: _addressController,
                              decoration:
                                  const InputDecoration(labelText: 'Address'),
                            )
                          : Container(),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_editingIndex == index)
                        IconButton(
                          icon: const Icon(Icons.save),
                          onPressed: _onSave,
                        )
                      else
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _onEdit(index, staff),
                        ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _onDelete(index),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }
}

class ManageStaffRightsScreen extends StatefulWidget {
  @override
  _ManageStaffRightsScreenState createState() =>
      _ManageStaffRightsScreenState();
}

class _ManageStaffRightsScreenState extends State<ManageStaffRightsScreen> {
  List<Map<String, dynamic>> staffList = [];
  String? _selectedStaff;
  String? _selectedRight;

  @override
  void initState() {
    super.initState();
    _fetchTeachers(); // Fetch teachers on initialization
  }

  Future<void> _fetchTeachers() async {
    final url =
        '${AppConfig.baseUrl}/api/users/teachers'; // Replace with your backend URL

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          staffList = data
              .map((staff) => {
                    'id': staff['_id'],
                    'firstName': staff['firstName'],
                    'middleName': staff['middleName'],
                    'lastName': staff['lastName'],
                  })
              .toList();
        });
      } else {
        print('Failed to load staff');
      }
    } catch (e) {
      print('Error fetching staff list: $e');
    }
  }

  Future<void> _grantRights() async {
    if (_selectedStaff != null && _selectedRight != null) {
      final selectedStaffId = _selectedStaff;
      String newRole;

      switch (_selectedRight) {
        case 'Grant Admin Rights':
          newRole = 'Admin';
          break;
        case 'Grant Teacher Rights':
          newRole = 'Teacher';
          break;
        case 'Grant Student Rights':
          newRole = 'Student';
          break;
        default:
          newRole = 'Teacher'; // Default case
      }

      // Send the request to update the user role
      final url =
          '${AppConfig.baseUrl}/api/users/updateRole/$selectedStaffId'; // Replace with your backend URL

      try {
        final response = await http.put(
          Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          body: json.encode({'role': newRole}),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                '$_selectedRight granted to ${staffList.firstWhere((staff) => staff['id'] == _selectedStaff)['firstName']}'),
          ));
        } else {
          print('Failed to update role');
        }
      } catch (e) {
        print('Error updating user role: $e');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please select both staff and rights'),
      ));
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
            Text(
              'Assign Staff Action Rights',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Staff Name*',
                border: OutlineInputBorder(),
              ),
              value: _selectedStaff,
              items: staffList.map((staff) {
                return DropdownMenuItem<String>(
                  value: staff['id'],
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person),
                    ),
                    title: Text(
                        '${staff['firstName']} ${staff['middleName']} ${staff['lastName']}'),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStaff = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a staff member';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            Text(
              'Grant Rights:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            _buildRightsRadioButton('Grant Admin Rights'),
            _buildRightsRadioButton('Grant Teacher Rights'),
            _buildRightsRadioButton('Grant Student Rights'),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _grantRights,
                child: Text('Grant Rights'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRightsRadioButton(String title) {
    return RadioListTile<String>(
      title: Text(title),
      value: title,
      groupValue: _selectedRight,
      onChanged: (value) {
        setState(() {
          _selectedRight = value;
        });
      },
    );
  }
}

class StaffAttendanceScreen extends StatefulWidget {
  const StaffAttendanceScreen({super.key});

  @override
  _ManageStaffAttendanceScreenState createState() =>
      _ManageStaffAttendanceScreenState();
}

class _ManageStaffAttendanceScreenState extends State<StaffAttendanceScreen> {
  DateTime? selectedDate;
  bool _attendanceTaken = false;
  bool _isEditable = false;

  // Replace dummy data with actual data from the server
  List<Map<String, dynamic>> attendanceData = [];

  // Fetch teacher data from the server
  Future<void> fetchTeachers() async {
    try {
      final response =
          await http.get(Uri.parse('http://192.168.0.104/api/users/teachers'));
      if (response.statusCode == 200) {
        setState(() {
          attendanceData =
              List<Map<String, dynamic>>.from(json.decode(response.body));
          // Add 'attendance' field if not present
          for (var teacher in attendanceData) {
            teacher['attendance'] = 'Present'; // Default value
          }
        });
      } else {
        print('Failed to load teachers');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  // Update attendance on the server
  Future<void> updateAttendance() async {
    try {
      final response = await http.put(
        Uri.parse('http://your-server-address/api/users/attendance'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'attendance': attendanceData}),
      );
      if (response.statusCode == 200) {
        print('Attendance updated successfully');
      } else {
        print('Failed to update attendance');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchTeachers(); // Fetch teacher data when the screen loads
  }

  // Select the main attendance date
  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: _attendanceTaken
              ? _buildAttendanceTable()
              : _buildAttendanceForm(),
        ),
      ),
    );
  }

  // Attendance form with date selection
  Widget _buildAttendanceForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Take Staff Attendance',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Attendance Date: ',
              style: TextStyle(fontSize: 18),
            ),
            InkWell(
              onTap: () => _selectDate(context),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  selectedDate != null
                      ? DateFormat('dd/MM/yyyy').format(selectedDate!)
                      : 'Select Date',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _attendanceTaken = true;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
          ),
          child: const Text(
            'Take Attendance',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ],
    );
  }

  // Attendance table grid after clicking "Take Attendance"
  Widget _buildAttendanceTable() {
    return Column(
      children: [
        const SizedBox(height: 20),
        if (selectedDate != null)
          Text(
            'Attendance Date: ${DateFormat('dd/MM/yyyy').format(selectedDate!)}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        const SizedBox(height: 20),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Sr. No.')),
                DataColumn(label: Text('Staff Name')),
                DataColumn(label: Text('Attendance')),
              ],
              rows: attendanceData.asMap().entries.map((entry) {
                int index = entry.key;
                var data = entry.value;

                return DataRow(cells: [
                  DataCell(Text('${index + 1}')),
                  DataCell(Text(data['firstName'] + ' ' + data['lastName'])),
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
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ElevatedButton.icon(
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
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
                ),
              ),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: () {
                updateAttendance(); // Call the update attendance method
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
}
