import 'package:flutter/material.dart';
//import 'package:file_picker/file_picker.dart';

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
        return ViewStudyMaterialScreen();
      case 'viewSharedStudyMaterial':
        return ViewSharedStudyMaterialScreen();
      default:
        return const Center(child: Text('Unknown Option'));
    }
  }
}

class ViewStudyMaterialScreen extends StatelessWidget {
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            const TextField(
              decoration: InputDecoration(
                hintText: 'Search study materials',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),

            // Study Material List
            Expanded(
              child: ListView.builder(
                itemCount: studyMaterials.length, // Replace with the actual count
                itemBuilder: (context, index) {
                  final material = studyMaterials[index];
                  return ListTile(
                    title: Text(material['title'] ?? 'No Title'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Type: ${material['type'] ?? 'Unknown'}'),
                        Text('Date Added: ${material['dateAdded'] ?? 'N/A'}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: () {
                        // Handle view action
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StudyMaterialDetailsScreen(material: material),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Sample data for demonstration
  final List<Map<String, String>> studyMaterials = [
    {'title': 'Math Notes', 'type': 'PDF', 'dateAdded': '01-09-2024'},
    {'title': 'Science Video Lecture', 'type': 'Video', 'dateAdded': '05-09-2024'},
    {'title': 'History Textbook', 'type': 'Link', 'dateAdded': '10-09-2024'},
  ];
}

class StudyMaterialDetailsScreen extends StatelessWidget {
  final Map<String, String> material;

  StudyMaterialDetailsScreen({required this.material});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Material Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Title: ${material['title'] ?? 'No Title'}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            Text('Type: ${material['type'] ?? 'Unknown'}'),
            const SizedBox(height: 16.0),
            Text('Date Added: ${material['dateAdded'] ?? 'N/A'}'),
            const SizedBox(height: 16.0),
            if (material['type'] == 'PDF') ...[
              ElevatedButton(
                onPressed: () {
                  // Handle view or download action
                },
                child: const Text('View PDF'),
              ),
            ] else if (material['type'] == 'Video') ...[
              ElevatedButton(
                onPressed: () {
                  // Handle watch action
                },
                child: const Text('Watch Video'),
              ),
            ] else if (material['type'] == 'Link') ...[
              ElevatedButton(
                onPressed: () {
                  // Handle open link action
                },
                child: const Text('Open Link'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}




class ViewSharedStudyMaterialScreen extends StatelessWidget {
  ViewSharedStudyMaterialScreen({super.key});

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            const TextField(
              decoration: InputDecoration(
                hintText: 'Search shared materials',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),

            // Shared Material List
            Expanded(
              child: ListView.builder(
                itemCount: sharedMaterials.length, // Replace with actual count
                itemBuilder: (context, index) {
                  final material = sharedMaterials[index];
                  return ListTile(
                    title: Text(material['title'] ?? 'No Title'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Type: ${material['type'] ?? 'Unknown'}'),
                        Text('Date Shared: ${material['dateShared'] ?? 'N/A'}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: () {
                        // Handle view action
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SharedMaterialDetailsScreen(material: material),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Sample data for demonstration
  final List<Map<String, String>> sharedMaterials = [
    {'title': 'Group Project Report', 'type': 'PDF', 'dateShared': '01-09-2024'},
    {'title': 'Lecture Notes on Biology', 'type': 'Link', 'dateShared': '03-09-2024'},
    {'title': 'Math Homework Solutions', 'type': 'Video', 'dateShared': '07-09-2024'},
  ];
}

class SharedMaterialDetailsScreen extends StatelessWidget {
  final Map<String, String> material;

  SharedMaterialDetailsScreen({required this.material});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared Material Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Title: ${material['title'] ?? 'No Title'}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            Text('Type: ${material['type'] ?? 'Unknown'}'),
            const SizedBox(height: 16.0),
            Text('Date Shared: ${material['dateShared'] ?? 'N/A'}'),
            const SizedBox(height: 16.0),
            if (material['type'] == 'PDF') ...[
              ElevatedButton(
                onPressed: () {
                  // Handle view or download action
                },
                child: const Text('View PDF'),
              ),
            ] else if (material['type'] == 'Video') ...[
              ElevatedButton(
                onPressed: () {
                  // Handle watch action
                },
                child: const Text('Watch Video'),
              ),
            ] else if (material['type'] == 'Link') ...[
              ElevatedButton(
                onPressed: () {
                  // Handle open link action
                },
                child: const Text('Open Link'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
