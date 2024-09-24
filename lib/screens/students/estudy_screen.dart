import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
// import 'dart:io';

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
      final response = await http
          .get(Uri.parse('http://192.168.0.108:3000/api/study-material'));
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
      const String baseUrl = 'http://192.168.0.108:3000/';

      // Ensure the filePath uses forward slashes
      final String normalizedFilePath = filePath.replaceAll('\\', '/');
      final String fileUrl = '$baseUrl$normalizedFilePath';

      print('Attempting to download from: $fileUrl'); // Debugging line

      final directory = await getApplicationDocumentsDirectory();
      final filePathToSave = "${directory.path}/$fileName";

      await dio.download(fileUrl, filePathToSave,
          onReceiveProgress: (received, total) {
        if (total != -1) {
          print('Downloading: ${(received / total * 100).toStringAsFixed(0)}%');
        }
      });

      print('Download complete: $filePathToSave');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download complete: $fileName')));
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
                  final fileUrl = material[
                      'filePath']; // Assuming `filePath` is the URL of the file
                  final fileName = material['fileName'] ??
                      'unknown_file'; // Assuming `fileName` is available

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
      final response = await http
          .get(Uri.parse('http://192.168.0.108:3000/api/study-material'));
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
      const String baseUrl = 'http://192.168.0.108:3000/';

      // Ensure the filePath uses forward slashes
      final String normalizedFilePath = filePath.replaceAll('\\', '/');
      final String fileUrl = '$baseUrl$normalizedFilePath';

      print('Attempting to download from: $fileUrl'); // Debugging line

      final directory = await getApplicationDocumentsDirectory();
      final filePathToSave = "${directory.path}/$fileName";

      await dio.download(fileUrl, filePathToSave,
          onReceiveProgress: (received, total) {
        if (total != -1) {
          print('Downloading: ${(received / total * 100).toStringAsFixed(0)}%');
        }
      });

      print('Download complete: $filePathToSave');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download complete: $fileName')));
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
                      'filePath']; // Assuming `filePath` is the URL of the file
                  final fileName = material['fileName'] ??
                      'unknown_file'; // Assuming `fileName` is available

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
