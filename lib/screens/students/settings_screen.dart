import 'package:flutter/material.dart';
import 'dart:io'; // For File class
import 'package:image_picker/image_picker.dart'; // For picking images

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Change Password Screen'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('Profile Settings Screen'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileSettingsScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('Auto Notification Settings Screen'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AutoNotificationSettingsScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('Auto Whatsapp Setting Screen'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AutoWhatsappSettingScreen()),
              );
            },
          ),
          // Add more ListTile items if needed
        ],
      ),
    );
  }
}

// Screen for Change Password
class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const TextField(
              decoration: InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            const TextField(
              decoration: InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle change password logic
              },
              child: const Text('Change Password'),
            ),
          ],
        ),
      ),
    );
  }
}

// Screen for Profile Settings
class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  _ProfileSettingsScreenState createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  // Controllers for the input fields
  final TextEditingController instituteNameController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController branchNameController = TextEditingController();
  final TextEditingController feeRecHeaderController = TextEditingController();
  final TextEditingController branchAddressController = TextEditingController();
  final TextEditingController taxNoController = TextEditingController();
  final TextEditingController feeFooterController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  // For dropdown selection
  String logoDisplay = 'Yes';
  String feeStatusDisplay = 'Yes';
  String chatOption = 'Yes';

  // For image selection
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? selectedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (selectedImage != null) {
      setState(() {
        _image = File(selectedImage.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Coaching Class Detail',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildTextField('Institute Name', instituteNameController),
            _buildTextField('Country', countryController),
            _buildTextField('City', cityController),
            _buildTextField('Branch Name', branchNameController),
            _buildTextField('Fee Rec. Header', feeRecHeaderController),
            _buildTextField('Branch Address', branchAddressController),
            _buildTextField('Tax No.', taxNoController),
            _buildTextField('Fee Footer', feeFooterController),
            const SizedBox(height: 20),
            const Text(
              'Profile Logo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _image == null
                ? const Text('No image selected.')
                : Image.file(_image!, height: 100, width: 100),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Select Image'),
            ),
            const SizedBox(height: 20),
            _buildDropdown(
              'Display logo on receipt?',
              logoDisplay,
              ['Yes', 'No'],
                  (value) {
                setState(() {
                  logoDisplay = value!;
                });
              },
            ),
            _buildDropdown(
              'Display fee status on receipt?',
              feeStatusDisplay,
              ['Yes', 'No'],
                  (value) {
                setState(() {
                  feeStatusDisplay = value!;
                });
              },
            ),
            _buildDropdown(
              'Allow students to chat?',
              chatOption,
              ['Yes', 'No'],
                  (value) {
                setState(() {
                  chatOption = value!;
                });
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Personal Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            _buildTextField('Name', nameController),
            _buildTextField('Mobile No.', mobileController),
            _buildTextField('Email', emailController),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle form submission
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build a text field
  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  // Helper method to build a dropdown
  Widget _buildDropdown(
      String label,
      String currentValue,
      List<String> options,
      ValueChanged<String?> onChanged,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 10),
          DropdownButton<String>(
            value: currentValue,
            isExpanded: true,
            onChanged: onChanged,
            items: options.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// NoteSection widget
class NoteSection extends StatelessWidget {
  final String noteText;

  const NoteSection({super.key, required this.noteText});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      color: Colors.yellow[100],
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.black54),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              noteText,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

// Screen for Auto Notification Settings
class AutoNotificationSettingsScreen extends StatefulWidget {
  const AutoNotificationSettingsScreen({super.key});

  @override
  _AutoNotificationSettingsState createState() => _AutoNotificationSettingsState();
}

class _AutoNotificationSettingsState extends State<AutoNotificationSettingsScreen> {
  // Map to store the state of each checkbox
  final Map<String, bool> notificationSettings = {
    'Student Absent Attendance Notification': false,
    'Attendance Performance Status Notification': false,
    'Fee Reminder Notification': false,
    'New Manual Exam Scheduled Notification': false,
    'Student Absent in Exam': false,
    'Student Exam Marks Notification': false,
    'New MCQ Exam assigned Notification': false,
    'Student absent in MCQ Exam Notification': false,
    'Student MCQ Exam Marks Notification': false,
    'New Assignment shared Notification': false,
    'New Document Shared Notification': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Auto Notification Settings')),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            const NoteSection(noteText: 'You can set auto Notifications to ON & the system will send Notifications accordingly to student or parents.'),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: notificationSettings.keys.map((String key) {
                  return CheckboxListTile(
                    title: Text(key),
                    value: notificationSettings[key],
                    onChanged: (bool? value) {
                      setState(() {
                        notificationSettings[key] = value!;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Screen for Auto Whatsapp Settings
class AutoWhatsappSettingScreen extends StatefulWidget {
  const AutoWhatsappSettingScreen({super.key});

  @override
  _AutoWhatsappSettingScreenState createState() => _AutoWhatsappSettingScreenState();
}

class _AutoWhatsappSettingScreenState extends State<AutoWhatsappSettingScreen> {
  // Map to track checkbox states
  Map<String, bool> whatsappSettings = {
    "Inquiry Welcome Message to Student": false,
    "Welcome Message to Student": false,
    "Account ID/Password Message to Student": false,
    "Student Absent Attendance Notification": false,
    "Attendance Performance Status Notification": false,
    "Fee Reminder Notification": false,
    "New Manual Exam Scheduled Notification": false,
    "Student Absent in Exam": false,
    "Student Exam Marks Notification": false,
    "New MCQ Exam assigned Notification": false,
    "Student absent in MCQ Exam Notification": false,
    "Student MCQ Exam Marks Notification": false,
    "New Assignment shared Notification": false,
    "New Document Shared Notification": false,
    "New Study Material Shared Notification": false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Auto Whatsapp Settings')),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            const NoteSection(noteText: 'You can set auto Notifications to ON & the system will send Notifications accordingly to student or parents.'),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: whatsappSettings.keys.map((String key) {
                  return CheckboxListTile(
                    title: Text(key),
                    value: whatsappSettings[key],
                    onChanged: (bool? value) {
                      setState(() {
                        whatsappSettings[key] = value!;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}