import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:testing_app/screens/config.dart';
class FeeScreen extends StatelessWidget {
  final String option;

  const FeeScreen({this.option = 'createFeeStructure'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fee'),
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
        return Center(child: Text('Unknown Option'));
    }
  }
}

class CreateFeeStructureScreen extends StatefulWidget {
  @override
  _CreateFeeStructureScreenState createState() =>
      _CreateFeeStructureScreenState();
}

class _CreateFeeStructureScreenState extends State<CreateFeeStructureScreen> {
  String? selectedStandard;
  String? selectedCourseType;

  final TextEditingController feeAmountController = TextEditingController();
  final TextEditingController remarkController = TextEditingController();

  Future<void> _saveFeeStructure() async {
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
        SnackBar(content: Text('Fee structure saved successfully')),
      );
      _resetForm(); // Optionally reset form after successful save
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save fee structure')),
      );
    }
  }

  void _resetForm() {
    setState(() {
      selectedStandard = null;
      selectedCourseType = null;
      feeAmountController.clear(); // Clear fee amount text
      remarkController.clear(); // Clear remark text
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create Fee Structure',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildDropdownField('Standard *', '-- Select --', (value) {
              setState(() {
                selectedStandard = value;
              });
            }),
            SizedBox(height: 16),
            _buildDropdownField('Course Type *', '-- Select --', (value) {
              setState(() {
                selectedCourseType = value;
              });
            }),
            SizedBox(height: 16),
            _buildTextField('Fee Amount *', feeAmountController),
            SizedBox(height: 16),
            _buildTextField('Remark:', remarkController),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveFeeStructure,
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
    );
  }

  Widget _buildDropdownField(
      String label, String hint, Function(String?) onChanged) {
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
              value: 'Standard 1',
              child: Text('Standard 1'),
            ),
            DropdownMenuItem(
              value: 'Standard 2',
              child: Text('Standard 2'),
            ),
            // Add more items as needed
          ],
          onChanged: onChanged,
          hint: Text(hint),
          value: selectedStandard,
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
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
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
          SnackBar(content: Text('Fee Structure deleted')),
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
      return Center(child: CircularProgressIndicator());
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
                    icon: Icon(Icons.edit),
                    onPressed: () => _editFeeStructure(index),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _deleteFeeStructure(index),
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

  EditFeeStructureScreen({required this.feeStructure, required this.onSave});

  @override
  _EditFeeStructureScreenState createState() => _EditFeeStructureScreenState();
}

class _EditFeeStructureScreenState extends State<EditFeeStructureScreen> {
  late String selectedStandard;
  late String selectedCourseType;
  late String feeAmount;
  late String remark;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    selectedStandard = widget.feeStructure['standard'] ?? '';
    selectedCourseType = widget.feeStructure['courseType'] ?? '';
    feeAmount = widget.feeStructure['feeAmount'] ?? '';
    remark = widget.feeStructure['remark'] ?? '';
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Fee Structure'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDropdownField('Standard *', (value) {
                setState(() {
                  selectedStandard = value!;
                });
              }, selectedStandard),
              SizedBox(height: 16),
              _buildDropdownField('Course Type *', (value) {
                setState(() {
                  selectedCourseType = value!;
                });
              }, selectedCourseType),
              SizedBox(height: 16),
              _buildTextField('Fee Amount *', (value) {
                setState(() {
                  feeAmount = value;
                });
              }, feeAmount),
              SizedBox(height: 16),
              _buildTextField('Remark:', (value) {
                setState(() {
                  remark = value;
                });
              }, remark),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: Text('SAVE'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(
      String label, Function(String?) onChanged, String currentValue) {
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
              value: 'Standard 1',
              child: Text('Standard 1'),
            ),
            DropdownMenuItem(
              value: 'Standard 2',
              child: Text('Standard 2'),
            ),
            // Add more items as needed
          ],
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
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        TextFormField(
          initialValue: currentValue,
          decoration: InputDecoration(
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
