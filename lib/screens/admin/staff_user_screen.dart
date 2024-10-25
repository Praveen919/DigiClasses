import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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
        return const ManageStaffScreen();
      case 'manageStaffRights':
        return const ManageStaffRightsScreen(); // Pass the staff list here
      default:
        return const Center(child: Text('Unknown Option'));
    }
  }
}

class CreateStaffScreen extends StatefulWidget {
  final Map<String, dynamic>? staff; // Optional parameter for editing staff
  final void Function(Map<String, dynamic>) onSave;

  const CreateStaffScreen({super.key, this.staff, required this.onSave});

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

      // Send staff data to the server
      final staffResponse = await http.post(
        Uri.parse(staffUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(staffData),
      );

      if (widget.staff == null) {
        // If this is a new staff member, create a user in the auth system
        final usersData = {
          'email': _emailController.text,
          'password': _passwordController.text,
          'role': 'staff', // Define role as staff
        };

        const usersUrl = '${AppConfig.baseUrl}/api/auth/register';

        final usersResponse = await http.post(
          Uri.parse(usersUrl),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(usersData),
        );

        if (staffResponse.statusCode == 201 ||
            staffResponse.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Staff Created Successfully')),
          );
          widget.onSave(staffData); // Notify parent widget with saved data
          _resetForm();
        } else {
          print('Staff creation failed: ${staffResponse.body}');
        }

        // Log the users response for debugging
        if (usersResponse.statusCode != 201 &&
            usersResponse.statusCode != 200) {
          print('User creation failed: ${usersResponse.body}');
        }
      } else {
        // Update existing staff
        if (staffResponse.statusCode == 200 ||
            staffResponse.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Staff details updated successfully')),
          );
          widget.onSave(staffData); // Notify parent widget with saved data
        } else {
          print('Staff update response: ${staffResponse.body}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Failed to update staff details. Status: ${staffResponse.statusCode}')),
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
    if (widget.staff != null) {
      return Container(); // Don't show password field for existing staff
    }
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
        automaticallyImplyLeading: false,
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
  const ManageStaffScreen({super.key});

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
    const url = '${AppConfig.baseUrl}/api/staff';
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
                    'profilePicture': staff['profilePicture'] != null
                        ? '${AppConfig.baseUrl}/${staff['profilePicture']}'
                        : null,
                  })
              .toList();
        });
      } else {
        print('Failed to load staff: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching staff list: $e');
    }
  }

  void _onEdit(int index, Map<String, dynamic> staff) {
    setState(() {
      _editingIndex = index;
      _firstNameController.text = staff['firstName'] ?? '';
      _lastNameController.text = staff['lastName'] ?? '';
      _emailController.text = staff['email'] ?? '';
      _mobileController.text = staff['mobile'] ?? '';
      _genderController.text = staff['gender'] ?? '';
      _addressController.text = staff['address'] ?? '';
      _profilePicturePath = staff['profilePicture'];
    });
  }

  Future<void> _onSave() async {
    if (_editingIndex == null) return;

    final updatedStaff = <String, dynamic>{};
    if (_firstNameController.text.isNotEmpty) {
      updatedStaff['firstName'] = _firstNameController.text;
    }
    if (_lastNameController.text.isNotEmpty) {
      updatedStaff['lastName'] = _lastNameController.text;
    }
    if (_emailController.text.isNotEmpty) {
      updatedStaff['email'] = _emailController.text;
    }
    if (_mobileController.text.isNotEmpty) {
      updatedStaff['mobile'] = _mobileController.text;
    }
    if (_genderController.text.isNotEmpty) {
      updatedStaff['gender'] = _genderController.text;
    }
    if (_addressController.text.isNotEmpty) {
      updatedStaff['address'] = _addressController.text;
    }

    // Get the staff ID from the staffList
    final staffId = staffList[_editingIndex!]['id'];

    if (staffId == null) {
      print('Error: Staff ID is null');
      return;
    }

    final url = '${AppConfig.baseUrl}/api/staff/$staffId';
    final request = http.MultipartRequest('PUT', Uri.parse(url));

    request.fields
        .addAll(updatedStaff.map((key, value) => MapEntry(key, value)));

    if (_profilePicturePath != null) {
      request.files.add(await http.MultipartFile.fromPath(
          'profilePicture', _profilePicturePath!));
    }

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await http.Response.fromStream(response);
        setState(() {
          // Update the specific staff in the list
          staffList[_editingIndex!] = json.decode(responseData.body)['staff'];
          _editingIndex = null;
          _clearControllers();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Staff updated successfully')),
        );
        _fetchStaffList(); // Refetch staff list after update
      } else {
        print('Failed to update staff: ${response.reasonPhrase}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update staff')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _onDelete(int index) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content:
              const Text('Are you sure you want to delete this staff member?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmDelete) {
      final url = '${AppConfig.baseUrl}/api/staff/${staffList[index]['id']}';
      final response = await http.delete(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          staffList.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Staff deleted successfully')),
        );
        _fetchStaffList(); // Refetch staff list after deletion
      } else {
        print('Failed to delete staff: ${response.reasonPhrase}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete staff')),
        );
      }
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
      appBar: AppBar(
          automaticallyImplyLeading: false, title: const Text('Manage Staff')),
      body: staffList.isEmpty
          ? const Center(child: Text('No staff members currently'))
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
                              controller: _addressController,
                              decoration:
                                  const InputDecoration(labelText: 'Address'),
                            )
                          : Text('Address: ${staff['address']}'),
                    ],
                  ),
                  trailing: _editingIndex == index
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.save),
                              onPressed: _onSave,
                            ),
                            IconButton(
                              icon: const Icon(Icons.cancel),
                              onPressed: () {
                                setState(() {
                                  _editingIndex = null;
                                  _clearControllers();
                                });
                              },
                            ),
                          ],
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
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
    );
  }
}

class ManageStaffRightsScreen extends StatefulWidget {
  const ManageStaffRightsScreen({super.key});

  @override
  _ManageStaffRightsScreenState createState() =>
      _ManageStaffRightsScreenState();
}

class _ManageStaffRightsScreenState extends State<ManageStaffRightsScreen> {
  List<Map<String, dynamic>> staffList = [];
  List<Map<String, dynamic>> adminList = [];
  List<Map<String, dynamic>> teacherList = [];
  List<Map<String, dynamic>> studentList = [];
  String? _selectedStaff;
  String? _selectedRight;

  @override
  void initState() {
    super.initState();
    _fetchStaff(); // Fetch staff members on initialization
    _fetchStaffRights(); // Fetch rights on initialization
  }

  Future<void> _fetchStaff() async {
    const url = '${AppConfig.baseUrl}/api/staff'; // Corrected API URL

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          staffList = data
              .map((staff) => {
                    'id': staff['_id'],
                    'firstName': staff['firstName'] ?? '',
                    'middleName': staff['middleName'] ?? '',
                    'lastName': staff['lastName'] ?? '',
                  })
              .toList();
        });
      } else {
        print('Failed to load staff: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching staff list: $e');
    }
  }

  Future<void> _fetchStaffRights() async {
    const url = '${AppConfig.baseUrl}/api/staff-rights/rights';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          adminList = data
              .where((staff) =>
                  staff['role'] == 'Admin' && staff['staffId'] != null)
              .map((staff) => {
                    'id': staff['staffId']['_id'],
                    'firstName': staff['staffId']['firstName'] ?? '',
                    'middleName': staff['staffId']['middleName'] ?? '',
                    'lastName': staff['staffId']['lastName'] ?? '',
                  })
              .toList();

          teacherList = data
              .where((staff) =>
                  staff['role'] == 'Teacher' && staff['staffId'] != null)
              .map((staff) => {
                    'id': staff['staffId']['_id'],
                    'firstName': staff['staffId']['firstName'] ?? '',
                    'middleName': staff['staffId']['middleName'] ?? '',
                    'lastName': staff['staffId']['lastName'] ?? '',
                  })
              .toList();

          studentList = data
              .where((staff) =>
                  staff['role'] == 'Student' && staff['staffId'] != null)
              .map((staff) => {
                    'id': staff['staffId']['_id'],
                    'firstName': staff['staffId']['firstName'] ?? '',
                    'middleName': staff['staffId']['middleName'] ?? '',
                    'lastName': staff['staffId']['lastName'] ?? '',
                  })
              .toList();
        });
      } else {
        print('Failed to load staff rights: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching staff rights: $e');
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
          newRole = 'Teacher';
      }

      const url =
          '${AppConfig.baseUrl}/api/staff-rights/assignRights'; // Corrected API URL

      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          body: json.encode({'staffId': selectedStaffId, 'role': newRole}),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                '$_selectedRight granted to ${staffList.firstWhere((staff) => staff['id'] == _selectedStaff)['firstName']}'),
          ));

          // Ensure rights are updated and list is fetched again
          await _fetchStaffRights(); // Fetch the latest rights

          // Reset the dropdown and radio buttons
          setState(() {
            _selectedStaff = null;
            _selectedRight = null;
          });
        } else {
          print('Failed to update role: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
      } catch (e) {
        print('Error updating user role: $e');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please select both staff and rights'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Manage Staff Rights'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Assign Staff Action Rights',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Staff Name*',
                border: OutlineInputBorder(),
              ),
              isDense: true, // Makes the dropdown smaller
              isExpanded: false, // Prevents the dropdown from taking full width
              value: _selectedStaff,
              items: staffList.map((staff) {
                return DropdownMenuItem<String>(
                  value: staff['id'],
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.person),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '${staff['firstName']} ${staff['middleName']} ${staff['lastName']}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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
            const SizedBox(height: 20),
            const Text(
              'Grant Rights:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildRightsRadioButton('Grant Admin Rights'),
            _buildRightsRadioButton('Grant Teacher Rights'),
            _buildRightsRadioButton('Grant Student Rights'),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _grantRights,
                child: const Text('Grant Rights'),
              ),
            ),
            const SizedBox(height: 20),
            _buildRightsList('Admin Rights granted to:', adminList),
            _buildRightsList('Teacher Rights granted to:', teacherList),
            _buildRightsList('Student Rights granted to:', studentList),
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

  Widget _buildRightsList(String title, List<Map<String, dynamic>> rightsList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (rightsList.isEmpty)
          const Text('No rights granted yet.')
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(), // Prevent scrolling
            itemCount: rightsList.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(
                    '${rightsList[index]['firstName']} ${rightsList[index]['middleName']} ${rightsList[index]['lastName']}'),
              );
            },
          ),
        const SizedBox(height: 20),
      ],
    );
  }
}
