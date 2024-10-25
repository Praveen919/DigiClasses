import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:testing_app/screens/config.dart';

class Expense {
  final String id;
  final String name; // Expense type
  final String paymentMode;
  final String? chequeNo; // Nullable
  final DateTime date; // Change to DateTime
  final double amount;
  final String? remark; // Nullable

  Expense({
    required this.id,
    required this.name,
    required this.paymentMode,
    this.chequeNo,
    required this.date,
    required this.amount,
    this.remark,
  });

  // Factory constructor to create an Expense object from JSON
  factory Expense.fromJson(Map<String, dynamic> json) {
    String dateString = json['date'];
    DateTime parsedDate;

    // Handle different formats or use try-catch for safety
    try {
      parsedDate = DateTime.parse(dateString); // Assume ISO format
    } catch (e) {
      print('Error parsing date: $dateString, error: $e');
      parsedDate =
          DateTime.now(); // Fallback to current date or handle accordingly
    }

    return Expense(
      id: json['_id'] ?? '',
      name: json['type'] ?? 'Unknown', // Updated to use 'type' from backend
      paymentMode: json['paymentMode'] ?? 'Unknown',
      chequeNo: json['chequeNumber'], // Ensure this matches the backend schema
      date: parsedDate, // Use the parsed DateTime
      amount: (json['amount'] is int)
          ? (json['amount'] as int).toDouble()
          : json['amount'].toDouble(), // Ensure it's always a double
      remark: json['remark'], // Nullable
    );
  }

  // Converts an Expense object to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'type': name, // Sending as 'type' to match backend
      'paymentMode': paymentMode,
      'chequeNumber': chequeNo, // Ensure this matches the backend schema
      'date': date.toIso8601String(), // Convert DateTime to String
      'amount': amount,
      'remark': remark,
    };
  }
}

class ExpensesIncomeScreen extends StatefulWidget {
  final String option; // This allows you to specify what screen to load

  const ExpensesIncomeScreen({
    required this.option,
    super.key,
  });

  @override
  _ExpensesIncomeScreenState createState() => _ExpensesIncomeScreenState();
}

class _ExpensesIncomeScreenState extends State<ExpensesIncomeScreen> {
  List<Expense> expenses = [];

  // Function to add a new expense to the list
  void addExpense(Expense expense) {
    setState(() {
      expenses.add(expense);
    });
  }

  // Function to update an existing expense with the given ID
  Future<void> updateExpense(String id, Expense updatedExpense) async {
    final url = '${AppConfig.baseUrl}/api/expenses/$id';

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedExpense.toJson()),
      );

      if (response.statusCode == 200) {
        setState(() {
          // Update the expense in the local list after a successful response
          final index = expenses.indexWhere((expense) => expense.id == id);
          if (index != -1) {
            expenses[index] = updatedExpense;
          }
        });
        print('Expense updated successfully.');
      } else {
        print('Failed to update expense, status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating expense: $e');
    }
  }

  // Function to delete an expense with the given ID
  Future<void> deleteExpense(String expenseId) async {
    final url = '${AppConfig.baseUrl}/api/expenses/$expenseId';

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          // Remove the expense from the local list after a successful response
          expenses.removeWhere((expense) => expense.id == expenseId);
        });
        print('Expense deleted successfully.');
      } else {
        print('Failed to delete expense, status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting expense: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses & Income'),
      ),
      body: _buildContent(),
    );
  }

  // Function to switch between different content based on the option
  Widget _buildContent() {
    switch (widget.option) {
      case 'addExpense':
        return AddExpenseScreen(onAddExpense: addExpense);
      case 'manageExpense':
        return ManageExpenseScreen(
          expenses: expenses,
          onDeleteExpense: deleteExpense,
          onUpdateExpense:
              updateExpense, // Now accepts the correct function signature
        );
      case 'addExpenseType':
        return const AddExpenseTypeScreen();
      case 'manageExpenseType':
        return const ManageExpenseTypeScreen();
      case 'addIncome':
        return const AddIncomeScreen();
      case 'manageIncome':
        return const ManageIncomeScreen();
      default:
        return const Center(child: Text('Unknown Option'));
    }
  }
}

class AddExpenseScreen extends StatefulWidget {
  final Function(Expense) onAddExpense;

  const AddExpenseScreen({super.key, required this.onAddExpense});

  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  String? expenseType;
  String? paymentMode;
  TextEditingController chequeNoController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  TextEditingController amountController = TextEditingController();
  TextEditingController remarkController = TextEditingController();

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _submitForm() {
    if (expenseType == null ||
        paymentMode == null ||
        amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    if (double.tryParse(amountController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    final newExpense = Expense(
      id: '',
      name: expenseType!,
      paymentMode: paymentMode!,
      chequeNo:
          chequeNoController.text.isEmpty ? null : chequeNoController.text,
      date: selectedDate, // Keep as DateTime
      amount: double.parse(amountController.text),
      remark: remarkController.text.isEmpty ? null : remarkController.text,
    );

    _saveExpenseToBackend(newExpense);
  }

  Future<void> _saveExpenseToBackend(Expense expense) async {
    const url = '${AppConfig.baseUrl}/api/expenses';

    try {
      // Format the date as needed, for example: 'yyyy-MM-dd'
      String formattedDate = DateFormat('yyyy-MM-dd').format(expense.date);

      // Create a new JSON object with the formatted date and correct field name
      final expenseJson = {
        'type': expense.name, // Change from 'name' to 'type'
        'paymentMode': expense.paymentMode,
        'chequeNumber': expense.chequeNo,
        'date': formattedDate, // Use the formatted date string
        'amount': expense.amount,
        'remark': expense.remark,
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(expenseJson),
      );

      if (response.statusCode == 201) {
        widget.onAddExpense(expense);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense saved successfully!')),
        );
        _resetForm();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save expense: ${response.body}')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save expense: $error')),
      );
    }
  }

  void _resetForm() {
    setState(() {
      expenseType = null;
      paymentMode = null;
      chequeNoController.clear();
      selectedDate = DateTime.now();
      amountController.clear();
      remarkController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Daily Expense Setup',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Create New Daily Expense Setup',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Expense Type *',
              border: OutlineInputBorder(),
            ),
            value: expenseType,
            onChanged: (String? newValue) {
              setState(() {
                expenseType = newValue;
              });
            },
            items: <String>[
              '-- Select --',
              'Office Supplies',
              'Travel',
              'Meals',
              'Daily Expenses',
              'Infrastructure Upgrades',
              'Electricity Bills',
              'Salaries',
              'Rent',
              'Others'
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Payment Mode *',
              border: OutlineInputBorder(),
            ),
            value: paymentMode,
            onChanged: (String? newValue) {
              setState(() {
                paymentMode = newValue;
              });
            },
            items: <String>[
              '-- Select --',
              'Cash',
              'Credit Card',
              'Bank Transfer'
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: chequeNoController,
            decoration: const InputDecoration(
              labelText: 'Cheque No:',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _selectDate,
            child: AbsorbPointer(
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Date *',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                controller: TextEditingController(
                  text:
                      "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: amountController,
            decoration: const InputDecoration(
              labelText: 'Amount *',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: remarkController,
            decoration: const InputDecoration(
              labelText: 'Remark',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _resetForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                  ),
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                  ),
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ManageExpenseScreen extends StatefulWidget {
  final Function(String) onDeleteExpense;
  final Function(String, Expense) onUpdateExpense;

  const ManageExpenseScreen({
    required this.onDeleteExpense,
    required this.onUpdateExpense,
    super.key,
    required List<Expense> expenses,
  });

  @override
  _ManageExpenseScreenState createState() => _ManageExpenseScreenState();
}

class _ManageExpenseScreenState extends State<ManageExpenseScreen> {
  List<Expense> expenses = [];
  List<Expense> filteredExpenses = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchExpenses();
  }

  Future<void> fetchExpenses() async {
    const url = '${AppConfig.baseUrl}/api/expenses';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> expenseList = json.decode(response.body);
        setState(() {
          expenses = expenseList.map((json) {
            return Expense.fromJson(json);
          }).toList();
          filteredExpenses = expenses;
        });
      } else {
        print('Failed to fetch expenses, status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error while fetching expenses: $e');
    }
  }

  void _filterExpenses(String query) {
    setState(() {
      filteredExpenses = expenses.where((expense) {
        return expense.name.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  Future<void> _showEditDialog(BuildContext context, Expense expense) async {
    final TextEditingController nameController =
        TextEditingController(text: expense.name);
    final TextEditingController paymentModeController =
        TextEditingController(text: expense.paymentMode);
    final TextEditingController chequeNumberController =
        TextEditingController(text: expense.chequeNo);
    final TextEditingController dateController = TextEditingController(
        text: expense.date
            .toIso8601String()
            .split('T')[0]); // Display as date string
    final TextEditingController amountController =
        TextEditingController(text: expense.amount.toString());
    final TextEditingController remarkController =
        TextEditingController(text: expense.remark ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Expense'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Expense Type'),
                ),
                TextField(
                  controller: paymentModeController,
                  decoration: const InputDecoration(labelText: 'Payment Mode'),
                ),
                TextField(
                  controller: chequeNumberController,
                  decoration: const InputDecoration(labelText: 'Cheque Number'),
                ),
                TextField(
                  controller: dateController,
                  decoration:
                      const InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: expense.date,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      dateController.text =
                          pickedDate.toIso8601String().split('T')[0];
                    }
                  },
                ),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(labelText: 'Amount'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: remarkController,
                  decoration: const InputDecoration(labelText: 'Remark'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Prepare the updated expense data
                final updatedExpense = Expense(
                  id: expense.id,
                  name: nameController.text,
                  paymentMode: paymentModeController.text,
                  chequeNo: chequeNumberController.text.isNotEmpty
                      ? chequeNumberController.text
                      : null,
                  date: DateTime.parse(dateController.text),
                  amount: double.tryParse(amountController.text) ?? 0.0,
                  remark: remarkController.text.isNotEmpty
                      ? remarkController.text
                      : null,
                );

                // Send update request to the backend
                final url = '${AppConfig.baseUrl}/api/expenses/${expense.id}';
                final response = await http.patch(
                  Uri.parse(url),
                  headers: {'Content-Type': 'application/json'},
                  body: json.encode(updatedExpense.toJson()),
                );

                if (response.statusCode == 200) {
                  // Update the local state with the new expense data
                  setState(() {
                    expenses[expenses.indexWhere((e) => e.id == expense.id)] =
                        updatedExpense;
                    filteredExpenses[filteredExpenses.indexWhere(
                        (e) => e.id == expense.id)] = updatedExpense;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Expense updated successfully')),
                  );
                  Navigator.of(context).pop(); // Close the dialog
                } else {
                  print('Failed to update expense');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to update expense')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteConfirmationDialog(
      BuildContext context, String id) async {
    // Show a confirmation dialog before deleting
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this expense?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final url = '${AppConfig.baseUrl}/api/expenses/$id';
                final response = await http.delete(Uri.parse(url));
                if (response.statusCode == 200) {
                  setState(() {
                    expenses.removeWhere((expense) => expense.id == id);
                    filteredExpenses.removeWhere((expense) => expense.id == id);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Expense deleted successfully')),
                  );
                } else {
                  print('Failed to delete expense');
                }
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Manage Expenses'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Search...',
                border: OutlineInputBorder(),
              ),
              onChanged: _filterExpenses,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredExpenses.length,
              itemBuilder: (context, index) {
                final expense = filteredExpenses[index];
                return Card(
                  child: ListTile(
                    title: Text(expense.name),
                    subtitle: Text(
                      'Amount: \$${expense.amount.toStringAsFixed(2)}\nDate: ${expense.date.day}/${expense.date.month}/${expense.date.year}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showEditDialog(context, expense),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _showDeleteConfirmationDialog(
                              context, expense.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AddExpenseTypeScreen extends StatefulWidget {
  const AddExpenseTypeScreen({super.key});

  @override
  _AddExpenseTypeScreenState createState() => _AddExpenseTypeScreenState();
}

class _AddExpenseTypeScreenState extends State<AddExpenseTypeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _expenseTypeController = TextEditingController();

  Future<void> _saveExpenseType() async {
    if (_formKey.currentState?.validate() ?? false) {
      final expenseType = _expenseTypeController.text.trim();
      print('Expense Type to send: $expenseType'); // Debug print

      const url = '${AppConfig.baseUrl}/api/expense-types';

      try {
        final response = await http.post(
          Uri.parse(url),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'type': expenseType,
          }),
        );

        print('Response Status: ${response.statusCode}'); // Debug print
        print('Response Body: ${response.body}'); // Debug print

        if (response.statusCode == 201) {
          print('Expense Type Saved: $expenseType');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Expense Type saved successfully!')),
          );
          _resetForm();
        } else {
          _handleErrorResponse(response);
        }
      } catch (error) {
        print('Error: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save expense type')),
        );
      }
    }
  }

  void _handleErrorResponse(http.Response response) {
    String errorMessage = 'Failed to save expense type';
    if (response.body.isNotEmpty) {
      try {
        final responseBody = jsonDecode(response.body);
        if (responseBody['error'] != null) {
          errorMessage = responseBody['error'];
        }
      } catch (e) {
        // Handle JSON parsing error if needed
        print('Error parsing response body: $e');
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage)),
    );
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _expenseTypeController.clear();
  }

  @override
  void dispose() {
    _expenseTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 16.0),
              child: Text(
                'Create Expense Type',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextFormField(
              controller: _expenseTypeController,
              decoration: const InputDecoration(
                labelText: 'Expense Type*',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Expense Type cannot be empty';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveExpenseType,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('SAVE'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _resetForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: const Text('RESET'),
            ),
          ],
        ),
      ),
    );
  }
}

class ManageExpenseTypeScreen extends StatefulWidget {
  const ManageExpenseTypeScreen({super.key});

  @override
  _ManageExpenseTypeScreenState createState() =>
      _ManageExpenseTypeScreenState();
}

class _ManageExpenseTypeScreenState extends State<ManageExpenseTypeScreen> {
  List<Map<String, dynamic>> expenseTypes = [];

  @override
  void initState() {
    super.initState();
    _fetchExpenseTypes();
  }

  Future<void> _fetchExpenseTypes() async {
    // Replace with your backend URL
    const url = '${AppConfig.baseUrl}/api/expense-types';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        setState(() {
          expenseTypes = data
              .map((item) => {'id': item['id'], 'type': item['type']})
              .toList();
        });
      } else {
        throw Exception('Failed to fetch expense types');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _editExpenseType(BuildContext context, int index) async {
    final TextEditingController _editController =
        TextEditingController(text: expenseTypes[index]['type']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Expense Type'),
          content: TextField(
            controller: _editController,
            decoration: const InputDecoration(labelText: 'Expense Type'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (_editController.text.isNotEmpty) {
                  await _updateExpenseType(index, _editController.text);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Expense Type cannot be empty')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateExpenseType(int index, String newType) async {
    final expenseId = expenseTypes[index]['id'];

    // Print the ID to check if it's valid
    print('Expense ID: $expenseId');

    // Check if the id is valid
    if (expenseId == null || expenseId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid expense type ID')),
      );
      return;
    }

    final url = '${AppConfig.baseUrl}/api/expense-types/$expenseId';

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{'type': newType}),
      );

      if (response.statusCode == 200) {
        setState(() {
          expenseTypes[index]['type'] = newType;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense Type updated successfully!')),
        );
      } else {
        throw Exception('Failed to update expense type');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update expense type')),
      );
    }
  }

  Future<void> _deleteExpenseType(int index) async {
    final expenseId = expenseTypes[index]['id'];

    // Print the ID to check if it's valid
    print('Expense ID: $expenseId');

    // Check if the id is valid
    if (expenseId == null || expenseId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid expense type ID')),
      );
      return;
    }

    final url = '${AppConfig.baseUrl}/api/expense-types/$expenseId';

    try {
      final response = await http.delete(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          expenseTypes.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense Type deleted successfully!')),
        );
      } else {
        throw Exception('Failed to delete expense type');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete expense type')),
      );
    }
  }

  void _confirmDeleteExpenseType(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content:
              const Text('Are you sure you want to delete this expense type?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteExpenseType(index);
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Expense Type Setup',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: expenseTypes.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Text("${index + 1}."),
                  title: Text("Expense Type: ${expenseTypes[index]['type']}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editExpenseType(context, index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _confirmDeleteExpenseType(index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AddIncomeScreen extends StatefulWidget {
  const AddIncomeScreen({super.key});

  @override
  _AddIncomeScreenState createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  final TextEditingController _chequeNoController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  String? _selectedIncomeType;
  String? _selectedPaymentType;
  DateTime? _selectedDate;

  final List<String> _incomeTypes = ['Salary', 'Business', 'Investment'];
  final List<String> _paymentTypes = ['Cash', 'Cheque', 'UPI'];

  Future<void> _saveIncome() async {
    if (_selectedIncomeType != null &&
        _selectedIncomeType!.isNotEmpty &&
        _selectedPaymentType != null &&
        _selectedPaymentType!.isNotEmpty &&
        _selectedDate != null &&
        _amountController.text.isNotEmpty) {
      try {
        double? parsedAmount = double.tryParse(_amountController.text);
        if (parsedAmount == null) {
          throw Exception('Amount is not valid');
        }

        final Map<String, dynamic> requestBody = {
          'incomeType': _selectedIncomeType,
          'iPaymentType': _selectedPaymentType,
          'iChequeNumber': _chequeNoController.text.isEmpty
              ? null
              : _chequeNoController.text,
          'bankName': _bankNameController.text.isEmpty
              ? null
              : _bankNameController.text,
          'iDate': _selectedDate?.toIso8601String(),
          'iAmount': parsedAmount,
        };

        print('Request Body: ${json.encode(requestBody)}');

        final response = await http.post(
          Uri.parse('${AppConfig.baseUrl}/api/incomes'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(requestBody),
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Income Saved')),
          );
          _resetForm(); // Reset form after saving
        } else {
          final errorResponse = json.decode(response.body);
          throw Exception(errorResponse['error'] ?? 'Failed to save data');
        }
      } catch (e) {
        print('Error saving income: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save data')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
    }
  }

  void _resetForm() {
    setState(() {
      _selectedIncomeType = null;
      _selectedPaymentType = null;
      _selectedDate = null;
      _chequeNoController.clear();
      _bankNameController.clear();
      _amountController.clear();
    });
  }

  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.grey[200],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Create New Income Setup',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  _buildDropdown(
                    'Income Type *',
                    _incomeTypes,
                    _selectedIncomeType,
                    (String? newValue) {
                      setState(() {
                        _selectedIncomeType = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildDropdown(
                    'Payment Type *',
                    _paymentTypes,
                    _selectedPaymentType,
                    (String? newValue) {
                      setState(() {
                        _selectedPaymentType = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildTextField('Cheque No', _chequeNoController),
                  const SizedBox(height: 10),
                  _buildTextField('Bank Name', _bankNameController),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _selectDate,
                    child: AbsorbPointer(
                      child: _buildTextField(
                        'Date *',
                        TextEditingController(
                          text: _selectedDate != null
                              ? '${_selectedDate!.toLocal()}'.split(' ')[0]
                              : '',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildTextField('Amount *', _amountController,
                      isNumeric: true),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saveIncome,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text('SAVE'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _resetForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          child: const Text('RESET'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? selectedItem,
      ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        DropdownButtonFormField<String>(
          value: selectedItem,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isNumeric = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        TextField(
          controller: controller,
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}

class Income {
  final String id;
  final String incomeType; // Income type
  final String paymentType;
  final String? chequeNo; // Nullable
  final String? bankName; // Nullable
  final DateTime date; // Change to DateTime
  final double amount;

  Income({
    required this.id,
    required this.incomeType,
    required this.paymentType,
    this.chequeNo,
    this.bankName,
    required this.date,
    required this.amount,
  });

  // Factory constructor to create an Income object from JSON
  factory Income.fromJson(Map<String, dynamic> json) {
    String dateString = json['iDate'];
    DateTime parsedDate;

    // Handle different formats or use try-catch for safety
    try {
      parsedDate = DateTime.parse(dateString); // Assume ISO format
    } catch (e) {
      print('Error parsing date: $dateString, error: $e');
      parsedDate = DateTime.now(); // Fallback to current date
    }

    return Income(
      id: json['_id'] ?? '',
      incomeType: json['incomeType'] ?? 'Unknown',
      paymentType: json['iPaymentType'] ?? 'Unknown',
      chequeNo: json['iChequeNumber'],
      bankName: json['bankName'], // Nullable field for bank name
      date: parsedDate, // Use the parsed DateTime
      amount: (json['iAmount'] is int)
          ? (json['iAmount'] as int).toDouble()
          : json['iAmount'].toDouble(), // Ensure it's always a double
    );
  }

  // Converts an Income object to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'incomeType': incomeType,
      'iPaymentType': paymentType,
      'iChequeNumber': chequeNo,
      'bankName': bankName, // Nullable field for bank name
      'iDate': date.toIso8601String(), // Convert DateTime to String
      'iAmount': amount,
    };
  }
}

class ManageIncomeScreen extends StatefulWidget {
  const ManageIncomeScreen({super.key});

  @override
  _ManageIncomeScreenState createState() => _ManageIncomeScreenState();
}

class _ManageIncomeScreenState extends State<ManageIncomeScreen> {
  List<Income> incomes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchIncomes();
  }

  Future<void> _fetchIncomes() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/incomes'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          incomes = data.map((item) => Income.fromJson(item)).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load incomes');
      }
    } catch (e) {
      print('Error fetching incomes: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteIncome(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('${AppConfig.baseUrl}:3000/api/incomes/$id'),
      );

      if (response.statusCode == 200) {
        setState(() {
          incomes.removeWhere((income) => income.id == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Income Deleted')),
        );
      } else {
        throw Exception('Failed to delete income');
      }
    } catch (e) {
      print('Error deleting income: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Manage Income'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Handle settings action
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (query) {
                // Optionally implement search functionality
              },
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: incomes.length,
                      itemBuilder: (context, index) {
                        final income = incomes[index];
                        return ListTile(
                          title: Text('Income Type: ${income.incomeType}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Payment Type: ${income.paymentType}'),
                              Text('Cheque No.: ${income.chequeNo ?? 'N/A'}'),
                              Text('Bank Name: ${income.bankName ?? 'N/A'}'),
                              Text('Date: ${income.date.toLocal()}'),
                              Text('Amount: \$${income.amount}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  // Handle edit action
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteIncome(income.id),
                              ),
                            ],
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
}
