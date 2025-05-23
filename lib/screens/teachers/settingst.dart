import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // For picking images
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:testing_app/screens/config.dart';

class SettingsT extends StatelessWidget {
  final String option;

  const SettingsT({super.key, required this.option});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    switch (option) {
      case 'profileSetting':
        return const ProfileSettings();
      case 'changePassword':
        return const ChangePassword();
      case 'autoNotification':
        return const AutoNotificationSettingsScreen();
      case 'autoWhatsApp':
        return const AutoWhatsappSettingScreen();
      default:
        return const Center(child: Text('Unknown Option'));
    }
  }
}

class SettingsScreen extends StatelessWidget {
  final String option;

  const SettingsScreen({super.key, required this.option});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    switch (option) {
      case 'profileSetting':
        return const ProfileSettings();
      case 'changePassword':
        return const ChangePassword();
      case 'autoNotification':
        return const AutoNotificationSettingsScreen();
      case 'autoWhatsApp':
        return const AutoWhatsappSettingScreen();
      default:
        return const Center(child: Text('Unknown Option'));
    }
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
  TextEditingController feeRecHeaderController = TextEditingController();
  TextEditingController branchAddressController = TextEditingController();
  TextEditingController taxNoController = TextEditingController();
  TextEditingController feeFooterController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  String logoDisplay = 'Yes';
  String feeStatusDisplay = 'Yes';
  String chatOption = 'Yes';
  XFile? selectedImage;

  final String apiUrl = '${AppConfig.baseUrl}/api/profile-settings';
  String? authToken;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchToken();
  }

  Future<void> fetchToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      authToken = prefs.getString('authToken');
    });
    print('Fetched auth token: $authToken'); // Log the fetched token
    fetchProfileData();
  }

  Future<void> fetchProfileData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      print(
          'Profile data fetch response status: ${response.statusCode}'); // Log response status

      if (response.statusCode == 200) {
        final profileData = json.decode(response.body);
        print(
            'Profile data fetched successfully: $profileData'); // Log the profile data

        setState(() {
          instituteNameController.text = profileData['instituteName'] ?? '';
          countryController.text = profileData['country'] ?? '';
          cityController.text = profileData['city'] ?? '';
          branchNameController.text = profileData['branchName'] ?? '';
          feeRecHeaderController.text = profileData['feeRecHeader'] ?? '';
          branchAddressController.text = profileData['branchAddress'] ?? '';
          taxNoController.text = profileData['taxNo'] ?? '';
          feeFooterController.text = profileData['feeFooter'] ?? '';
          logoDisplay = profileData['logoDisplay'] ?? 'Yes';
          feeStatusDisplay = profileData['feeStatusDisplay'] ?? 'Yes';
          chatOption = profileData['chatOption'] ?? 'Yes';
          nameController.text = profileData['name'] ?? '';
          mobileController.text = profileData['mobile'] ?? '';
          emailController.text = profileData['email'] ?? '';
          isLoading = false;
        });
      } else {
        print(
            'Failed to fetch profile data: ${response.body}'); // Log error message
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch profile data')),
        );
      }
    } catch (error) {
      print('Error fetching profile data: $error'); // Log any error that occurs
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('An error occurred while fetching profile data')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
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
                  _buildTextField(
                      'Institute Name', instituteNameController, true),
                  _buildTextField('Country', countryController, true),
                  _buildTextField('City', cityController, true),
                  _buildTextField('Branch Name', branchNameController, true),
                  _buildTextField(
                      'Fee Rec. Header', feeRecHeaderController, true),
                  _buildTextField(
                      'Branch Address', branchAddressController, true),
                  _buildTextField('Tax No.', taxNoController, true),
                  _buildTextField('Fee Footer', feeFooterController, true),
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
                      'Display logo on receipt?', logoDisplay, ['Yes', 'No'],
                      (value) {
                    setState(() {
                      logoDisplay = value!;
                    });
                  }),
                  _buildDropdown('Display fee status on receipt?',
                      feeStatusDisplay, ['Yes', 'No'], (value) {
                    setState(() {
                      feeStatusDisplay = value!;
                    });
                  }),
                  _buildDropdown(
                      'Allow students to chat?', chatOption, ['Yes', 'No'],
                      (value) {
                    setState(() {
                      chatOption = value!;
                    });
                  }),
                  const SizedBox(height: 20),
                  const Text(
                    'Personal Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  _buildTextField('Name', nameController, true),
                  _buildTextField('Mobile No.', mobileController, true,
                      isNumeric: true),
                  _buildTextField('Email', emailController, true,
                      isEmail: true),
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
    request.fields['feeRecHeader'] = feeRecHeaderController.text;
    request.fields['branchAddress'] = branchAddressController.text;
    request.fields['taxNo'] = taxNoController.text;
    request.fields['feeFooter'] = feeFooterController.text;
    request.fields['logoDisplay'] = logoDisplay;
    request.fields['feeStatusDisplay'] = feeStatusDisplay;
    request.fields['chatOption'] = chatOption;
    request.fields['name'] = nameController.text;
    request.fields['mobile'] = mobileController.text;
    request.fields['email'] = emailController.text;

    // Add image file if selected
    if (selectedImage != null) {
      final fileBytes = await selectedImage!.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'profileLogo',
          fileBytes,
          contentType: MediaType('image', 'jpeg'),
          filename: selectedImage!.name,
        ),
      );
      print(
          'Image file added to request: ${selectedImage!.name}'); // Log the image file info
    } else {
      print('No image selected for upload.'); // Log if no image is selected
    }

    // Include the token in the request headers if needed
    if (authToken != null) {
      request.headers['Authorization'] = 'Bearer $authToken';
      print('Authorization header added to request.'); // Log if token is added
    }

    try {
      final response = await request.send();
      print(
          'Profile settings update response status: ${response.statusCode}'); // Log the response status

      if (response.statusCode == 200) {
        final responseBody = await http.Response.fromStream(response);
        print(
            'Profile settings updated successfully: ${responseBody.body}'); // Log the successful update
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Profile settings updated successfully!')),
        );
      } else {
        print(
            'Failed to update profile settings: ${response.statusCode} - ${await response.stream.bytesToString()}'); // Log the error response
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile settings.')),
        );
      }
    } catch (error) {
      print(
          'Error updating profile settings: $error'); // Log any error that occurs
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('An error occurred while updating profile settings.')),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      selectedImage = image;
    });
    print(
        'Image selected: ${selectedImage?.path}'); // Log the selected image path
  }

  Widget _buildTextField(
      String label, TextEditingController controller, bool required,
      {bool isNumeric = false, bool isEmail = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: isNumeric
          ? TextInputType.number
          : (isEmail ? TextInputType.emailAddress : TextInputType.text),
      validator: (value) {
        if (required && (value == null || value.isEmpty)) {
          return 'This field is required';
        }
        if (isEmail &&
            value != null &&
            !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
          return 'Please enter a valid email address';
        }
        return null;
      },
    );
  }

  Widget _buildDropdown(String label, String currentValue, List<String> items,
      Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        DropdownButton<String>(
          value: currentValue,
          onChanged: onChanged,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
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
  bool _isLoading = false;

  Future<void> _changePassword(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final currentPassword = currentPasswordController.text;
      final newPassword = newPasswordController.text;

      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? token = prefs.getString('authToken');

        if (token == null) {
          _showSnackBar(context, 'Authorization token not found');
          setState(() {
            _isLoading = false;
          });
          return;
        }

        final response = await http.post(
          Uri.parse('${AppConfig.baseUrl}/api/password/resetPassword'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode({
            'currentPassword': currentPassword,
            'newPassword': newPassword,
          }),
        );

        print(response.body);

        if (response.statusCode == 200) {
          _showSnackBar(context, 'Password changed successfully');
          currentPasswordController.clear();
          newPasswordController.clear();
          confirmPasswordController.clear();
        } else {
          final responseBody = json.decode(response.body);
          _showSnackBar(
              context, responseBody['message'] ?? 'An error occurred');
        }
      } catch (e) {
        _showSnackBar(context, 'An error occurred: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Change Password'),
      ),
      body: Padding(
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
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
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
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () => _changePassword(context),
                      child: const Text('Change Password'),
                    ),
            ],
          ),
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
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Settings saved successfully')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
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
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Settings saved successfully')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
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
