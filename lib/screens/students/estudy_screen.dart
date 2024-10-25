import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart'; // For handling permissions
import 'package:testing_app/screens/config.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';

class EstudyScreen extends StatelessWidget {
  final String option;

  const EstudyScreen({super.key, this.option = 'viewStudyMaterial'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('eStudy'),
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    switch (option) {
      case 'viewStudyMaterial':
        return const ViewStudyMaterialScreen();
      case 'viewSharedStudyMaterial':
        return const ViewSharedStudyMaterialScreen();
      default:
        return const Center(child: Text('Unknown Option'));
    }
  }
}

class ViewStudyMaterialScreen extends StatefulWidget {
  const ViewStudyMaterialScreen({super.key});

  @override
  _ViewStudyMaterialScreenState createState() =>
      _ViewStudyMaterialScreenState();
}

class _ViewStudyMaterialScreenState extends State<ViewStudyMaterialScreen> {
  List<dynamic> studyMaterials = [];
  bool isLoading = true;
  final Dio dio = Dio(); // Instance of Dio for file downloading

  @override
  void initState() {
    super.initState();
    fetchStudyMaterials();
  }

  Future<void> fetchStudyMaterials() async {
    try {
      final response =
          await http.get(Uri.parse('${AppConfig.baseUrl}/api/study-material'));
      if (response.statusCode == 200) {
        setState(() {
          studyMaterials = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load study materials');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching materials: $e');
    }
  }

  Future<void> downloadFile(String filePath, String fileName) async {
    try {
      // Request storage permission
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Storage permission is required')));
        return;
      }

      // Format file path and construct the download URL
      final String normalizedFilePath = filePath.replaceAll('\\', '/');
      final String fileUrl = '${AppConfig.baseUrl}/$normalizedFilePath';

      print('Attempting to download from: $fileUrl');

      // Get the path for the Downloads directory
      Directory? downloadsDirectory = Directory('/storage/emulated/0/Download');

      // Ensure the Downloads directory exists
      if (!downloadsDirectory.existsSync()) {
        downloadsDirectory.createSync();
      }

      final String filePathToSave = "${downloadsDirectory.path}/$fileName";

      await dio.download(fileUrl, filePathToSave,
          onReceiveProgress: (received, total) {
        if (total != -1) {
          print('Downloading: ${(received / total * 100).toStringAsFixed(0)}%');
        }
      });

      print('Download complete: $filePathToSave');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download complete: $fileName')));

      // Show toast and optionally open the file
      Fluttertoast.showToast(
          msg: "File downloaded to: $filePathToSave",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM);

      OpenFile.open(filePathToSave);
    } catch (e) {
      print('Download failed: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Download failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Study Material'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Handle search action
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: studyMaterials.length,
                itemBuilder: (context, index) {
                  final material = studyMaterials[index];
                  final fileUrl = material['filePath'];
                  final fileName = material['fileName'] ?? 'unknown_file';

                  return ListTile(
                    title: Text(material['courseName'] ?? 'No Title'),
                    subtitle: Text('Subject: ${material['subject'] ?? 'N/A'}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.download),
                      onPressed: () {
                        downloadFile(fileUrl, fileName);
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class ViewSharedStudyMaterialScreen extends StatefulWidget {
  const ViewSharedStudyMaterialScreen({super.key});

  @override
  _ViewSharedStudyMaterialScreenState createState() =>
      _ViewSharedStudyMaterialScreenState();
}

class _ViewSharedStudyMaterialScreenState
    extends State<ViewSharedStudyMaterialScreen> {
  List<dynamic> sharedMaterials = [];
  bool isLoading = true;
  final Dio dio = Dio(); // Instance of Dio for file downloading

  @override
  void initState() {
    super.initState();
    fetchSharedMaterials();
  }

  Future<void> fetchSharedMaterials() async {
    try {
      final response = await http.get(Uri.parse(
          '${AppConfig.baseUrl}/api/study-material')); // Ensure the correct endpoint is used
      if (response.statusCode == 200) {
        setState(() {
          sharedMaterials = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load shared study materials');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching shared materials: $e');
    }
  }

  Future<void> downloadFile(String filePath, String fileName) async {
    try {
      // Request storage permission
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Storage permission is required')));
        return;
      }

      // Normalize file path and construct the download URL
      final String normalizedFilePath = filePath.replaceAll('\\', '/');
      final String fileUrl = '${AppConfig.baseUrl}/$normalizedFilePath';

      print('Attempting to download from: $fileUrl');

      // Get the path for the application documents directory
      Directory? downloadsDirectory = Directory('/storage/emulated/0/Download');

      // Ensure the Downloads directory exists
      if (!downloadsDirectory.existsSync()) {
        downloadsDirectory.createSync();
      }

      final String filePathToSave = "${downloadsDirectory.path}/$fileName";

      await dio.download(fileUrl, filePathToSave,
          onReceiveProgress: (received, total) {
        if (total != -1) {
          print('Downloading: ${(received / total * 100).toStringAsFixed(0)}%');
        }
      });

      print('Download complete: $filePathToSave');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download complete: $fileName')));

      // Show toast and optionally open the file
      Fluttertoast.showToast(
          msg: "File downloaded to: $filePathToSave",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM);

      OpenFile.open(filePathToSave);
    } catch (e) {
      print('Download failed: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Download failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Shared Study Material'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Handle search action
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: sharedMaterials.length,
                itemBuilder: (context, index) {
                  final material = sharedMaterials[index];
                  final fileUrl = material[
                      'filePath']; // Ensure this is the correct field for the file URL
                  final fileName = material['fileName'] ??
                      'unknown_file'; // Ensure this field exists

                  return ListTile(
                    title: Text(material['courseName'] ?? 'No Title'),
                    subtitle: Text('Subject: ${material['subject'] ?? 'N/A'}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.download),
                      onPressed: () {
                        downloadFile(fileUrl, fileName);
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }
}
