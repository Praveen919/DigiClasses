import 'package:flutter/material.dart';
import 'dart:convert'; // For JSON encoding/decoding
import 'package:http/http.dart' as http; // For HTTP requests
import 'package:testing_app/screens/config.dart';

// Define the Expense class with JSON serialization
class Expense {
  final String id;
  final String name;
  final String paymentMode;
  final String chequeNo;
  final String date;
  final double amount;
  final String remark;

  Expense({
    required this.id,
    required this.name,
    required this.paymentMode,
    required this.chequeNo,
    required this.date,
    required this.amount,
    required this.remark,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['_id'],
      name: json['name'],
      paymentMode: json['paymentMode'],
      chequeNo: json['chequeNo'],
      date: json['date'],
      amount: json['amount'].toDouble(),
      remark: json['remark'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'paymentMode': paymentMode,
      'chequeNo': chequeNo,
      'date': date,
      'amount': amount,
      'remark': remark,
    };
  }
}

class ExpensesIncomeScreen extends StatefulWidget {
  final String option;

  const ExpensesIncomeScreen({this.option = 'addExpense'});

  @override
  _ExpensesIncomeScreenState createState() => _ExpensesIncomeScreenState();
}

class _ExpensesIncomeScreenState extends State<ExpensesIncomeScreen> {
  List<Expense> expenses = [];

  void addExpense(Expense expense) {
    setState(() {
      expenses.add(expense);
    });
  }

  void updateExpense(int index, Expense updatedExpense) {
    setState(() {
      expenses[index] = updatedExpense;
    });
  }

  void deleteExpense(int index) {
    setState(() {
      expenses.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expenses & Income'),
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    switch (widget.option) {
      case 'addExpense':
        return AddExpenseScreen(onAddExpense: addExpense);
      case 'manageExpense':
        return ManageExpenseScreen();
      case 'addExpenseType':
        return AddExpenseTypeScreen();
      case 'manageExpenseType':
        return ManageExpenseTypeScreen();
      case 'addIncome':
        return AddIncomeScreen();
      case 'manageIncome':
        return ManageIncomeScreen();
      default:
        return Center(child: Text('Unknown Option'));
    }
  }
}

class AddExpenseScreen extends StatefulWidget {
  final Function(Expense) onAddExpense;

  AddExpenseScreen({required this.onAddExpense});

  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  String? expenseType;
  String? paymentMode;
  TextEditingController chequeNoController = TextEditingController();
  TextEditingController chequeInFavorOfController = TextEditingController();
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
        SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    if (double.tryParse(amountController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    final newExpense = Expense(
      name: expenseType!,
      paymentMode: paymentMode!,
      chequeNo: chequeNoController.text,
      date: "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
      amount: double.parse(amountController.text),
      remark: remarkController.text,
      id: '',
    );

    _saveExpenseToBackend(newExpense);
  }

  Future<void> _saveExpenseToBackend(Expense expense) async {
    const url =
        'http://192.168.0.108:3000/api/expenses-incomes/expenses'; // Ensure this URL is correct
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': expense.name,
          'paymentMode': expense.paymentMode,
          'chequeNo': expense.chequeNo,
          'date': expense.date,
          'amount': expense.amount,
          'remark': expense.remark,
        }),
      );

      if (response.statusCode == 201) {
        // Changed from 200 to 201 for creation
        widget.onAddExpense(
            expense); // This triggers adding to the list or refreshing the ManageExpenseScreen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Expense saved successfully!')),
        );
        _resetForm(); // Only reset the form if saving was successful
      } else {
        // If the response status is not 201, display an error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save expense: ${response.body}')),
        );
      }
    } catch (error) {
      // If the request fails entirely (e.g., network error), show a general error
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
      chequeInFavorOfController.clear();
      selectedDate = DateTime.now();
      amountController.clear();
      remarkController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Daily Expense Setup',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text(
            'Create New Daily Expense Setup',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
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
              'Meals'
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
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
          SizedBox(height: 16),
          TextFormField(
            controller: chequeNoController,
            decoration: InputDecoration(
              labelText: 'Cheque No:',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: chequeInFavorOfController,
            decoration: InputDecoration(
              labelText: 'Cheque in favour of:',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),
          GestureDetector(
            onTap: _selectDate,
            child: AbsorbPointer(
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Date *',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                controller: TextEditingController(
                    text:
                        "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}"),
              ),
            ),
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: amountController,
            decoration: InputDecoration(
              labelText: 'Amount *',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: remarkController,
            decoration: InputDecoration(
              labelText: 'Remark',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _resetForm,
                  child: Text('Reset'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('Submit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                  ),
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
    fetchExpenses(); // Fetch expenses on screen load
  }

  // Fetch expenses from the API
  Future<void> fetchExpenses() async {
    final url = '${AppConfig.baseUrl}/api/expenses';
    try {
      final response = await http.get(Uri.parse(url));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}'); // For debugging

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> expenseList = jsonResponse['expenses'];

        setState(() {
          expenses = expenseList.map((json) => Expense.fromJson(json)).toList();
          filteredExpenses = expenses; // Initialize filtered list
        });
      } else {
        print('Failed to fetch expenses');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Delete an expense by ID
  Future<void> deleteExpense(String id) async {
    final url = '${AppConfig.baseUrl}/api/expenses/$id';
    try {
      final response = await http.delete(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          expenses.removeWhere((expense) => expense.id == id);
          filteredExpenses = expenses; // Update filtered list
        });
      } else {
        print('Failed to delete expense');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Update an expense by ID
  Future<void> updateExpense(int index, Expense updatedExpense) async {
    final url = '${AppConfig.baseUrl}/api/expenses/${updatedExpense.id}';

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedExpense.toJson()),
      );

      // Debugging lines
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          expenses[index] = updatedExpense;
          filteredExpenses = List.from(
              expenses); // Ensure new list is created for filteredExpenses
        });
      } else {
        // Improved error handling
        print('Failed to update expense. Status code: ${response.statusCode}');
        final responseData = json.decode(response.body);
        print(
            'Error message: ${responseData['error'] ?? 'No error message provided'}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _filterExpenses(String query) {
    setState(() {
      filteredExpenses = expenses.where((expense) {
        return expense.name.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  void _showEditDialog(BuildContext context, Expense expense, int index) {
    final TextEditingController nameController =
        TextEditingController(text: expense.name);
    final TextEditingController paymentModeController =
        TextEditingController(text: expense.paymentMode);
    final TextEditingController chequeNoController =
        TextEditingController(text: expense.chequeNo);
    final TextEditingController dateController =
        TextEditingController(text: expense.date);
    final TextEditingController amountController =
        TextEditingController(text: expense.amount.toString());
    final TextEditingController remarkController =
        TextEditingController(text: expense.remark);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Expense'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField(nameController, 'Expense Name'),
              _buildTextField(paymentModeController, 'Payment Mode'),
              _buildTextField(chequeNoController, 'Cheque No'),
              _buildTextField(dateController, 'Date'),
              _buildTextField(amountController, 'Amount',
                  keyboardType: TextInputType.number),
              _buildTextField(remarkController, 'Remark'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final updatedExpense = Expense(
                id: expense.id,
                name: nameController.text,
                paymentMode: paymentModeController.text,
                chequeNo: chequeNoController.text,
                date: dateController.text,
                amount: double.tryParse(amountController.text) ?? 0.0,
                remark: remarkController.text,
              );
              updateExpense(index, updatedExpense); // Call update function
              Navigator.of(context).pop();
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete this expense?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              deleteExpense(id); // Call delete function
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              labelText: 'Search',
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
              return ListTile(
                title: Text(expense.name),
                subtitle: Text('${expense.date} - \$${expense.amount}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showEditDialog(context, expense, index),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () =>
                          _showDeleteConfirmationDialog(context, expense.id),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
      ),
    );
  }
}

class AddExpenseTypeScreen extends StatefulWidget {
  @override
  _AddExpenseTypeScreenState createState() => _AddExpenseTypeScreenState();
}

class _AddExpenseTypeScreenState extends State<AddExpenseTypeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _expenseTypeController = TextEditingController();

  Future<void> _saveExpenseType() async {
    if (_formKey.currentState?.validate() ?? false) {
      final expenseType = _expenseTypeController.text;
      // Replace with your backend URL
      const url = 'http://192.168.0.108:3000/expense-types';

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

        if (response.statusCode == 201) {
          // Success
          print('Expense Type Saved: $expenseType');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Expense Type saved successfully!')),
          );
          _resetForm();
        } else {
          // Failure
          throw Exception('Failed to save expense type');
        }
      } catch (e) {
        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save expense type')),
        );
      }
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _expenseTypeController.clear();
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
  @override
  _ManageExpenseTypeScreenState createState() =>
      _ManageExpenseTypeScreenState();
}

class _ManageExpenseTypeScreenState extends State<ManageExpenseTypeScreen> {
  List<String> expenseTypes = [];

  @override
  void initState() {
    super.initState();
    _fetchExpenseTypes();
  }

  Future<void> _fetchExpenseTypes() async {
    // Replace with your backend URL
    const url = 'http://192.168.0.108:3000/expense-types';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        setState(() {
          expenseTypes = data.map((item) => item['type'] as String).toList();
        });
      } else {
        throw Exception('Failed to fetch expense types');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _editExpenseType(BuildContext context, int index) async {
    // Implement edit logic
    print("Edit Expense Type: ${expenseTypes[index]}");
  }

  Future<void> _deleteExpenseType(int index) async {
    // Replace with your backend URL
    final url =
        'http://192.168.0.108:3000/expense-types/${expenseTypes[index]}';

    try {
      final response = await http.delete(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          expenseTypes.removeAt(index);
        });
        print("Delete Expense Type: ${expenseTypes[index]}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Expense Type deleted successfully!')),
        );
      } else {
        throw Exception('Failed to delete expense type');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete expense type')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
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
              prefixIcon: Icon(Icons.search),
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
                  title: Text("Expense Type: ${expenseTypes[index]}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _editExpenseType(context, index),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteExpenseType(index),
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

  final List<String> _incomeTypes = [
    'Salary',
    'Business',
    'Investment'
  ]; // Example types
  final List<String> _paymentTypes = ['Cash', 'Cheque', 'UPI']; // Example types

  Future<void> _saveIncome() async {
    if (_selectedIncomeType != null &&
        _selectedPaymentType != null &&
        _selectedDate != null &&
        _amountController.text.isNotEmpty) {
      try {
        final response = await http.post(
          Uri.parse('http://192.168.0.108:3000/api/incomes'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'type': _selectedIncomeType,
            'paymentType': _selectedPaymentType,
            'chequeNumber': _chequeNoController.text,
            'bankName': _bankNameController.text,
            'date': _selectedDate?.toIso8601String(),
            'amount': double.tryParse(_amountController.text),
          }),
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Income Saved')),
          );
          _resetForm(); // Reset form after saving
        } else {
          throw Exception('Failed to save data');
        }
      } catch (e) {
        print('Error saving income: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save data')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
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
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.grey[200],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create New Income Setup',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                _buildDropdown(
                    'Income Type *', _incomeTypes, _selectedIncomeType,
                    (String? newValue) {
                  setState(() {
                    _selectedIncomeType = newValue;
                  });
                }),
                SizedBox(height: 10),
                _buildDropdown(
                    'Payment Type *', _paymentTypes, _selectedPaymentType,
                    (String? newValue) {
                  setState(() {
                    _selectedPaymentType = newValue;
                  });
                }),
                SizedBox(height: 10),
                _buildTextField('Cheque No', _chequeNoController),
                SizedBox(height: 10),
                _buildTextField('Bank Name', _bankNameController),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: _selectDate,
                  child: AbsorbPointer(
                    child: _buildTextField(
                      'Date *',
                      TextEditingController(
                          text: _selectedDate != null
                              ? '${_selectedDate!.toLocal()}'.split(' ')[0]
                              : ''),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                _buildTextField('Amount *', _amountController, isNumeric: true),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveIncome,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: Text('SAVE'),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _resetForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        child: Text('RESET'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
          style: TextStyle(fontWeight: FontWeight.bold),
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
          decoration: InputDecoration(
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
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextField(
          controller: controller,
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}

class ManageIncomeScreen extends StatefulWidget {
  @override
  _ManageIncomeScreenState createState() => _ManageIncomeScreenState();
}

class _ManageIncomeScreenState extends State<ManageIncomeScreen> {
  List<dynamic> incomes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchIncomes();
  }

  Future<void> _fetchIncomes() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://192.168.0.108:3000/api/incomes'), // Update with your backend URL
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          incomes = data;
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
        Uri.parse(
            'http://192.168.0.108:3000/api/incomes/$id'), // Update with your backend URL
      );

      if (response.statusCode == 200) {
        setState(() {
          incomes.removeWhere((income) => income['_id'] == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Income Deleted')),
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
        title: Text('Manage Income'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // Handle settings action
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (query) {
                // Optionally implement search functionality
              },
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: incomes.length,
                      itemBuilder: (context, index) {
                        final income = incomes[index];
                        return ListTile(
                          title: Text('Income Type: ${income['type']}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Payment Type: ${income['paymentType']}'),
                              Text('Cheque No.: ${income['chequeNo']}'),
                              Text('Date: ${income['date']}'),
                              Text('Amount: ${income['amount']}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  // Handle edit action
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () => _deleteIncome(income['_id']),
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
