import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart'; // For picking images
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:testing_app/screens/config.dart';

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
            title: const Text('Profile Settings Screen'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ProfileSettings()),
              );
            },
          ),
          ListTile(
            title: const Text('Change Password Screen'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChangePassword()),
              );
            },
          ),
          ListTile(
            title: const Text('Auto Notification Settings Screen'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const AutoNotificationSettingsScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('Auto Whatsapp Setting Screen'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AutoWhatsappSettingScreen()),
              );
            },
          ),
          // Add more ListTile items if needed
        ],
      ),
    );
  }
}

// Screen for Profile Settings
class ProfileSettings extends StatefulWidget {
  const ProfileSettings({super.key});

  @override
  _ProfileSettingsScreenState createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettings> {
  TextEditingController instituteNameController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController branchNameController = TextEditingController();
  TextEditingController branchAddressController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  String logoDisplay = 'Yes';
  String chatOption = 'Yes';
  XFile? selectedImage; // Store the picked image file

  final String apiUrl = '${AppConfig.baseUrl}/api/profile-settings';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Wrap the screen with Scaffold
      appBar: AppBar(
        title: const Text('Profile Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Coaching Class Detail',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildTextField('Institute Name', instituteNameController, true),
              _buildTextField('Country', countryController, true),
              _buildTextField('City', cityController, true),
              _buildTextField('Branch Name', branchNameController, true),
              _buildTextField('Branch Address', branchAddressController, true),
              const SizedBox(height: 20),
              const Text(
                'Profile Logo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
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
              _buildTextField('Name', nameController, true),
              _buildTextField('Mobile No.', mobileController, true,
                  isNumeric: true),
              _buildTextField('Email', emailController, true, isEmail: true),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _submitData(); // Call the submit function
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitData() async {
    final uri = Uri.parse(apiUrl);
    final request = http.MultipartRequest('POST', uri);

    // Add text fields
    request.fields['instituteName'] = instituteNameController.text;
    request.fields['country'] = countryController.text;
    request.fields['city'] = cityController.text;
    request.fields['branchName'] = branchNameController.text;
    request.fields['branchAddress'] = branchAddressController.text;
    request.fields['logoDisplay'] = logoDisplay;
    request.fields['chatOption'] = chatOption;
    request.fields['name'] = nameController.text;
    request.fields['mobile'] = mobileController.text;
    request.fields['email'] = emailController.text;

    // Add image file if selected
    if (selectedImage != null) {
      final fileBytes = await selectedImage!.readAsBytes();
      final mimeType =
          lookupMimeType(selectedImage!.path); // Determine mime type
      request.files.add(
        http.MultipartFile.fromBytes(
          'profileLogo',
          fileBytes,
          contentType:
              MediaType.parse(mimeType!), // Use the determined mime type
          filename:
              basename(selectedImage!.path), // Use the file name from path
        ),
      );
    }

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          const SnackBar(
              content: Text('Profile settings updated successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          const SnackBar(content: Text('Failed to update profile settings.')),
        );
      }
    } catch (error) {
      print('Error: $error');
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        const SnackBar(content: Text('An error occurred. Please try again.')),
      );
    }
  }

  void _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        selectedImage = pickedFile;
      });
    }
  }

  // Build TextField widget with validation
  Widget _buildTextField(
    String label,
    TextEditingController controller,
    bool isRequired, {
    bool isNumeric = false,
    bool isEmail = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return '$label is required';
        }
        if (isEmail && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value!)) {
          return 'Enter a valid email';
        }
        return null;
      },
    );
  }

  // Build Dropdown widget
  Widget _buildDropdown(
    String label,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        DropdownButton<String>(
          value: value,
          onChanged: onChanged,
          items: options.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false; // To show loading indicator when submitting

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Start loading
      });
      final currentPassword = currentPasswordController.text;
      final newPassword = newPasswordController.text;
      // Simulated token from authentication system (replace this with actual token retrieval logic)
      const token = 'user_jwt_token';
      try {
        final response = await http.post(
          Uri.parse('${AppConfig.baseUrl}/api/password'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode({
            'currentPassword': currentPassword,
            'newPassword': newPassword,
          }),
        );

        // Log the response body for debugging
        print(response.body);

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context as BuildContext).showSnackBar(
            const SnackBar(content: Text('Password changed successfully')),
          );
        } else {
          // Handle non-200 status codes
          print('Error: Status code ${response.statusCode}');
          ScaffoldMessenger.of(context as BuildContext).showSnackBar(
            const SnackBar(content: Text('An error occurred')),
          );
        }
      } catch (e) {
        // Handle parsing errors and other exceptions
        print('Error: $e');
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          const SnackBar(content: Text('An error occurred')),
        );
      } finally {
        setState(() {
          _isLoading = false;
          // Stop loading
        });
      }
    }
  }

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              controller: currentPasswordController,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your current password';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: newPasswordController,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a new password';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              validator: (value) {
                if (value != newPasswordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator()) // Show loading indicator
                : ElevatedButton(
                    onPressed: _changePassword,
                    child: const Text('Change Password'),
                  ),
          ],
        ),
      ),
    );
  }
}

class AutoNotificationSettingsScreen extends StatefulWidget {
  const AutoNotificationSettingsScreen({super.key});

  @override
  _AutoNotificationSettingsState createState() =>
      _AutoNotificationSettingsState();
}

class _AutoNotificationSettingsState
    extends State<AutoNotificationSettingsScreen> {
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
  void initState() {
    super.initState();
    loadNotificationSettings();
  }

  // Fetch settings from the backend

  Future<void> loadNotificationSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      Map<String, dynamic> decodedToken =
          JwtDecoder.decode(token); // Decode the JWT to extract user ID
      String userId =
          decodedToken['id']; // Extract the user ID from the decoded token

      try {
        final response = await http.get(
          Uri.parse(
              '${AppConfig.baseUrl}/api/notification-settings/$userId'), // Use userId in the URL
          headers: {
            'Authorization': 'Bearer $token',
          },
        );
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          setState(() {
            notificationSettings['Student Absent Attendance Notification'] =
                data['studentAbsentAttendanceNotification'] ?? false;
            notificationSettings['Attendance Performance Status Notification'] =
                data['attendancePerformanceStatusNotification'] ?? false;
            notificationSettings['Fee Reminder Notification'] =
                data['feeReminderNotification'] ?? false;
            notificationSettings['New Manual Exam Scheduled Notification'] =
                data['newManualExamScheduledNotification'] ?? false;
            notificationSettings['Student Absent in Exam'] =
                data['studentAbsentInExamNotification'] ?? false;
            notificationSettings['Student Exam Marks Notification'] =
                data['studentExamMarksNotification'] ?? false;
            notificationSettings['New MCQ Exam assigned Notification'] =
                data['newMcqExamAssignedNotification'] ?? false;
            notificationSettings['Student absent in MCQ Exam Notification'] =
                data['studentAbsentInMcqExamNotification'] ?? false;
            notificationSettings['Student MCQ Exam Marks Notification'] =
                data['studentMcqExamMarksNotification'] ?? false;
            notificationSettings['New Assignment shared Notification'] =
                data['newAssignmentSharedNotification'] ?? false;
            notificationSettings['New Document Shared Notification'] =
                data['newDocumentSharedNotification'] ?? false;
          });
        } else {
          print('Failed to load settings');
        }
      } catch (error) {
        print('Error loading notification settings: $error');
      }
    }
  }

// Save updated notification settings
  Future<void> saveNotificationSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      Map<String, dynamic> decodedToken =
          JwtDecoder.decode(token); // Decode the JWT to extract user ID
      String userId =
          decodedToken['id']; // Extract the user ID from the decoded token

      try {
        final response = await http.post(
          Uri.parse(
              '${AppConfig.baseUrl}/api/notification-settings/$userId'), // Use userId in the URL
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'studentAbsentAttendanceNotification':
                notificationSettings['Student Absent Attendance Notification'],
            'attendancePerformanceStatusNotification': notificationSettings[
                'Attendance Performance Status Notification'],
            'feeReminderNotification':
                notificationSettings['Fee Reminder Notification'],
            'newManualExamScheduledNotification':
                notificationSettings['New Manual Exam Scheduled Notification'],
            'studentAbsentInExamNotification':
                notificationSettings['Student Absent in Exam'],
            'studentExamMarksNotification':
                notificationSettings['Student Exam Marks Notification'],
            'newMcqExamAssignedNotification':
                notificationSettings['New MCQ Exam assigned Notification'],
            'studentAbsentInMcqExamNotification':
                notificationSettings['Student absent in MCQ Exam Notification'],
            'studentMcqExamMarksNotification':
                notificationSettings['Student MCQ Exam Marks Notification'],
            'newAssignmentSharedNotification':
                notificationSettings['New Assignment shared Notification'],
            'newDocumentSharedNotification':
                notificationSettings['New Document Shared Notification'],
          }),
        );
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context as BuildContext).showSnackBar(
              const SnackBar(content: Text('Settings saved successfully')));
        } else {
          ScaffoldMessenger.of(context as BuildContext).showSnackBar(
              const SnackBar(content: Text('Failed to save settings')));
        }
      } catch (error) {
        print('Error saving notification settings: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            const NoteSection(
              noteText:
                  'You can set auto Notifications to ON & the system will send Notifications accordingly to student or parents.',
            ),
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
            ElevatedButton(
              onPressed: saveNotificationSettings,
              child: const Text('Save Settings'),
            ),
          ],
        ),
      ),
    );
  }
}

class NoteSection extends StatelessWidget {
  final String noteText;

  const NoteSection({super.key, required this.noteText});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.yellow[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        noteText,
        style: const TextStyle(color: Colors.black54),
      ),
    );
  }
}

class AutoWhatsappSettingScreen extends StatefulWidget {
  const AutoWhatsappSettingScreen({super.key});

  @override
  _AutoWhatsappSettingScreenState createState() =>
      _AutoWhatsappSettingScreenState();
}

class _AutoWhatsappSettingScreenState extends State<AutoWhatsappSettingScreen> {
  final Map<String, bool> whatsappSettings = {
    'Inquiry Welcome Message to Student': false,
    'Welcome Message to Student': false,
    'Account ID/Password Message to Student': false,
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
    'New Study Material Shared Notification': false,
  };

  @override
  void initState() {
    super.initState();
    loadWhatsappSettings();
  }

  // Fetch settings from the backend
  Future<void> loadWhatsappSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      Map<String, dynamic> decodedToken =
          JwtDecoder.decode(token); // Decode the JWT to extract user ID
      String userId =
          decodedToken['id']; // Extract the user ID from the decoded token

      try {
        final response = await http.get(
          Uri.parse(
              '${AppConfig.baseUrl}/api/whatsapp-settings/$userId'), // Use userId in the URL
          headers: {
            'Authorization': 'Bearer $token',
          },
        );
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          setState(() {
            whatsappSettings['Inquiry Welcome Message to Student'] =
                data['inquiryWelcomeMessageToStudent'] ?? false;
            whatsappSettings['Welcome Message to Student'] =
                data['welcomeMessageToStudent'] ?? false;
            whatsappSettings['Account ID/Password Message to Student'] =
                data['accountIdPasswordMessageToStudent'] ?? false;
            whatsappSettings['Student Absent Attendance Notification'] =
                data['studentAbsentAttendanceNotification'] ?? false;
            whatsappSettings['Attendance Performance Status Notification'] =
                data['attendancePerformanceStatusNotification'] ?? false;
            whatsappSettings['Fee Reminder Notification'] =
                data['feeReminderNotification'] ?? false;
            whatsappSettings['New Manual Exam Scheduled Notification'] =
                data['newManualExamScheduledNotification'] ?? false;
            whatsappSettings['Student Absent in Exam'] =
                data['studentAbsentInExamNotification'] ?? false;
            whatsappSettings['Student Exam Marks Notification'] =
                data['studentExamMarksNotification'] ?? false;
            whatsappSettings['New MCQ Exam assigned Notification'] =
                data['newMcqExamAssignedNotification'] ?? false;
            whatsappSettings['Student absent in MCQ Exam Notification'] =
                data['studentAbsentInMcqExamNotification'] ?? false;
            whatsappSettings['Student MCQ Exam Marks Notification'] =
                data['studentMcqExamMarksNotification'] ?? false;
            whatsappSettings['New Assignment shared Notification'] =
                data['newAssignmentSharedNotification'] ?? false;
            whatsappSettings['New Document Shared Notification'] =
                data['newDocumentSharedNotification'] ?? false;
            whatsappSettings['New Study Material Shared Notification'] =
                data['newStudyMaterialSharedNotification'] ?? false;
          });
        } else {
          print('Failed to load settings');
        }
      } catch (error) {
        print('Error loading WhatsApp settings: $error');
      }
    }
  }

  // Save updated WhatsApp settings
  Future<void> saveWhatsappSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      Map<String, dynamic> decodedToken =
          JwtDecoder.decode(token); // Decode the JWT to extract user ID
      String userId =
          decodedToken['id']; // Extract the user ID from the decoded token

      try {
        final response = await http.post(
          Uri.parse(
              '${AppConfig.baseUrl}/api/whatsapp-settings/$userId'), // Use userId in the URL
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'inquiryWelcomeMessageToStudent':
                whatsappSettings['Inquiry Welcome Message to Student'],
            'welcomeMessageToStudent':
                whatsappSettings['Welcome Message to Student'],
            'accountIdPasswordMessageToStudent':
                whatsappSettings['Account ID/Password Message to Student'],
            'studentAbsentAttendanceNotification':
                whatsappSettings['Student Absent Attendance Notification'],
            'attendancePerformanceStatusNotification':
                whatsappSettings['Attendance Performance Status Notification'],
            'feeReminderNotification':
                whatsappSettings['Fee Reminder Notification'],
            'newManualExamScheduledNotification':
                whatsappSettings['New Manual Exam Scheduled Notification'],
            'studentAbsentInExamNotification':
                whatsappSettings['Student Absent in Exam'],
            'studentExamMarksNotification':
                whatsappSettings['Student Exam Marks Notification'],
            'newMcqExamAssignedNotification':
                whatsappSettings['New MCQ Exam assigned Notification'],
            'studentAbsentInMcqExamNotification':
                whatsappSettings['Student absent in MCQ Exam Notification'],
            'studentMcqExamMarksNotification':
                whatsappSettings['Student MCQ Exam Marks Notification'],
            'newAssignmentSharedNotification':
                whatsappSettings['New Assignment shared Notification'],
            'newDocumentSharedNotification':
                whatsappSettings['New Document Shared Notification'],
            'newStudyMaterialSharedNotification':
                whatsappSettings['New Study Material Shared Notification'],
          }),
        );
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context as BuildContext).showSnackBar(
              const SnackBar(content: Text('Settings saved successfully')));
        } else {
          ScaffoldMessenger.of(context as BuildContext).showSnackBar(
              const SnackBar(content: Text('Failed to save settings')));
        }
      } catch (error) {
        print('Error saving WhatsApp settings: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            const NoteSection(
                noteText:
                    'You can set auto WhatsApp messages to ON & the system will send messages accordingly.'),
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
            ElevatedButton(
              onPressed: saveWhatsappSettings,
              child: const Text('Save Settings'),
            ),
          ],
        ),
      ),
    );
  }
}
