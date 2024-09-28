import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:testing_app/screens/config.dart';

class FeeScreen extends StatelessWidget {
  final String option;

  const FeeScreen({super.key, this.option = 'createFeeStructure'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fee'),
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    switch (option) {
      case 'createFeeStructure':
        return CreateFeeStructureScreen();
      case 'manageFeeStructure':
        return ManageFeeStructureScreen();
      default:
        return const Center(child: Text('Unknown Option'));
    }
  }
}

class CreateFeeStructureScreen extends StatefulWidget {
  const CreateFeeStructureScreen({super.key});

  @override
  _CreateFeeStructureScreenState createState() =>
      _CreateFeeStructureScreenState();
}

class _CreateFeeStructureScreenState extends State<CreateFeeStructureScreen> {
  String? selectedStandard;
  String? selectedCourseType;
  List<String> alreadyAssignedStandards = []; // To hold fetched standards

  final TextEditingController feeAmountController = TextEditingController();
  final TextEditingController remarkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAlreadyAssignedStandards(); // Fetch standards on init
  }

  Future<void> _fetchAlreadyAssignedStandards() async {
    try {
      final url =
          Uri.parse('${AppConfig.baseUrl}/api/assignStandard/alreadyAssigned');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['standards'] is List) {
          setState(() {
            alreadyAssignedStandards = List<String>.from(data['standards']);
          });
        } else {
          _showMessage('Unexpected data format');
        }
      } else {
        _showMessage(
            'Failed to load already assigned standards: ${response.reasonPhrase}');
      }
    } catch (e) {
      _showMessage('Error loading assigned standards: $e');
    }
  }

  Future<void> _saveFeeStructure() async {
    // Call the API to save fee structure
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/api/fee-structures'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'standard': selectedStandard ?? '',
        'courseType': selectedCourseType ?? '',
        'feeAmount': feeAmountController.text,
        'remark': remarkController.text,
      }),
    );

    if (response.statusCode == 201) {
      // Fee structure saved successfully
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fee structure saved successfully')),
      );
      _resetForm(); // Reset form after successful save
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save fee structure')),
      );
    }
  }

  void _resetForm() {
    setState(() {
      selectedStandard = null; // Reset selected standard
      selectedCourseType = null; // Reset selected course type
      feeAmountController.clear(); // Clear fee amount text
      remarkController.clear(); // Clear remark text
      // alreadyAssignedStandards remains unchanged
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create Fee Structure',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDropdownField('Standard *', alreadyAssignedStandards,
                (value) {
              setState(() {
                selectedStandard = value;
              });
            }),
            const SizedBox(height: 16),
            _buildDropdownField(
                'Course Type *', ['Course Type 1', 'Course Type 2'], (value) {
              setState(() {
                selectedCourseType = value; // Update selected course type
              });
            }),
            const SizedBox(height: 16),
            _buildTextField('Fee Amount *', feeAmountController),
            const SizedBox(height: 16),
            _buildTextField('Remark:', remarkController),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveFeeStructure,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('SAVE'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _resetForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                    ),
                    child: const Text('RESET'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField(
      String label, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: DropdownButtonFormField<String>(
            isExpanded: true, // Make it expand to fit the container
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            ),
            items: items.map((String item) {
              return DropdownMenuItem(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
            hint: const Text('-- Select --'),
            value: items.contains(selectedStandard)
                ? selectedStandard
                : items.contains(selectedCourseType)
                    ? selectedCourseType
                    : null, // Ensure the value is valid
            validator: (value) =>
                value == null ? 'Please select an option' : null,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          keyboardType: label.contains('Amount')
              ? TextInputType.number
              : TextInputType.text,
        ),
      ],
    );
  }
}

class ManageFeeStructureScreen extends StatefulWidget {
  const ManageFeeStructureScreen({super.key});

  @override
  _ManageFeeStructureScreenState createState() =>
      _ManageFeeStructureScreenState();
}

class _ManageFeeStructureScreenState extends State<ManageFeeStructureScreen> {
  List<Map<String, dynamic>> feeStructures = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFeeStructures();
  }

  Future<void> _fetchFeeStructures() async {
    try {
      final response =
          await http.get(Uri.parse('${AppConfig.baseUrl}/api/fee-structures'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          feeStructures = data.map((item) {
            return {
              '_id': item['_id'] as String,
              'standard': item['standard'] as String,
              'courseType': item['courseType'] as String,
              'feeAmount': item['feeAmount'] as String,
              'remark': item['remark'] as String,
            };
          }).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load fee structures');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _editFeeStructure(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditFeeStructureScreen(
          feeStructure: feeStructures[index],
          onSave: (updatedFeeStructure) {
            setState(() {
              feeStructures[index] = updatedFeeStructure;
            });
          },
        ),
      ),
    ).then((_) {
      // Fetch data again after editing to ensure it is updated
      _fetchFeeStructures();
    });
  }

  void _confirmDeleteFeeStructure(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content:
              const Text('Are you sure you want to delete this fee structure?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteFeeStructure(index); // Proceed to delete
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteFeeStructure(int index) async {
    final id = feeStructures[index]['_id'];
    try {
      final response = await http
          .delete(Uri.parse('${AppConfig.baseUrl}/api/fee-structures/$id'));

      if (response.statusCode == 200) {
        setState(() {
          feeStructures.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fee Structure deleted')),
        );
      } else {
        throw Exception('Failed to delete fee structure');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: feeStructures.length,
        itemBuilder: (context, index) {
          final feeStructure = feeStructures[index];
          return Card(
            child: ListTile(
              title: Text(
                'Standard: ${feeStructure['standard']}\n'
                'Course Type: ${feeStructure['courseType']}\n'
                'Fee Amount: ${feeStructure['feeAmount']}',
              ),
              subtitle: Text('Remark: ${feeStructure['remark']}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _editFeeStructure(index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _confirmDeleteFeeStructure(
                        index), // Show confirmation dialog
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class EditFeeStructureScreen extends StatefulWidget {
  final Map<String, dynamic> feeStructure;
  final void Function(Map<String, dynamic>) onSave;

  const EditFeeStructureScreen(
      {super.key, required this.feeStructure, required this.onSave});

  @override
  _EditFeeStructureScreenState createState() => _EditFeeStructureScreenState();
}

class _EditFeeStructureScreenState extends State<EditFeeStructureScreen> {
  late String selectedStandard;
  late String selectedCourseType;
  late String feeAmount;
  late String remark;
  List<String> alreadyAssignedStandards = []; // To hold fetched standards

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    selectedStandard = widget.feeStructure['standard'] ?? '';
    selectedCourseType = widget.feeStructure['courseType'] ?? '';
    feeAmount = widget.feeStructure['feeAmount'] ?? '';
    remark = widget.feeStructure['remark'] ?? '';
    _fetchAlreadyAssignedStandards(); // Fetch standards on init
  }

  Future<void> _fetchAlreadyAssignedStandards() async {
    try {
      final url =
          Uri.parse('${AppConfig.baseUrl}/api/assignStandard/alreadyAssigned');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['standards'] is List) {
          setState(() {
            alreadyAssignedStandards = List<String>.from(data['standards']);
          });
        } else {
          _showMessage('Unexpected data format');
        }
      } else {
        _showMessage(
            'Failed to load already assigned standards: ${response.reasonPhrase}');
      }
    } catch (e) {
      _showMessage('Error loading assigned standards: $e');
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final updatedFeeStructure = {
        'standard': selectedStandard,
        'courseType': selectedCourseType,
        'feeAmount': feeAmount,
        'remark': remark,
      };

      try {
        final response = await http.put(
          Uri.parse(
              '${AppConfig.baseUrl}/api/fee-structures/${widget.feeStructure['_id']}'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(updatedFeeStructure),
        );

        if (response.statusCode == 200) {
          widget.onSave(updatedFeeStructure);
          Navigator.pop(context);
        } else {
          throw Exception('Failed to update fee structure');
        }
      } catch (e) {
        _showMessage('Error: ${e.toString()}');
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Fee Structure'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDropdownField('Standard *', alreadyAssignedStandards,
                  (value) {
                setState(() {
                  selectedStandard = value!;
                });
              }, selectedStandard),
              const SizedBox(height: 16),
              _buildDropdownField(
                  'Course Type *', ['Course Type 1', 'Course Type 2'], (value) {
                setState(() {
                  selectedCourseType = value!;
                });
              }, selectedCourseType),
              const SizedBox(height: 16),
              _buildTextField('Fee Amount *', (value) {
                setState(() {
                  feeAmount = value;
                });
              }, feeAmount),
              const SizedBox(height: 16),
              _buildTextField('Remark:', (value) {
                setState(() {
                  remark = value;
                });
              }, remark),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text('SAVE'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> items,
      Function(String?) onChanged, String currentValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          items: items.map((String item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
          value: currentValue,
          validator: (value) =>
              value == null || value.isEmpty ? 'This field is required' : null,
        ),
      ],
    );
  }

  Widget _buildTextField(
      String label, Function(String) onChanged, String currentValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: currentValue,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          onChanged: onChanged,
          validator: (value) =>
              value == null || value.isEmpty ? 'This field is required' : null,
        ),
      ],
    );
  }
}
