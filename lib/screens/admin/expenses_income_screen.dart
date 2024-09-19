import 'package:flutter/material.dart';
import 'dart:convert'; // For JSON encoding/decoding
import 'package:http/http.dart' as http; // For HTTP requests
import 'package:intl/intl.dart'; // For date formatting
import 'package:testing_app/screens/config.dart';
// Define the Expense class with JSON serialization
class Expense {
  final String expenseType;
  final String paymentMode;
  final String chequeNo;
  final DateTime date;
  final double amount;
  final String remark;

  Expense({
    required this.expenseType,
    required this.paymentMode,
    required this.chequeNo,
    required this.date,
    required this.amount,
    required this.remark,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      expenseType: json['expenseType'],
      paymentMode: json['paymentMode'],
      chequeNo: json['chequeNo'],
      date: DateTime.parse(json['date']),
      amount: json['amount'].toDouble(), // Ensure correct double conversion
      remark: json['remark'],
    );
  }

  get id => null;

  Map<String, dynamic> toJson() {
    return {
      'expenseType': expenseType,
      'paymentMode': paymentMode,
      'chequeNo': chequeNo,
      'date': date.toIso8601String(),
      'amount': amount,
      'remark': remark,
    };
  }
}
class ExpensesIncomeScreen extends StatefulWidget {
  final String option;

  const ExpensesIncomeScreen({super.key, this.option = 'addExpense'});

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
        title: const Text('Expenses & Income'),
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    switch (widget.option) {
      case 'addExpense':
        return AddExpenseScreen(onAddExpense: addExpense);
      case 'manageExpense':
        return ManageExpenseScreen(expenses: expenses, onDeleteExpense: deleteExpense, onUpdateExpense: updateExpense);
      case 'addExpenseType':
        return AddExpenseTypeScreen();
      case 'manageExpenseType':
        return ManageExpenseTypeScreen();
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
  final _formKey = GlobalKey<FormState>();

  String? expenseType;
  String? paymentMode;
  TextEditingController chequeNoController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  TextEditingController amountController = TextEditingController();
  TextEditingController remarkController = TextEditingController();

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final newExpense = {
          'expenseType': expenseType!,
          'paymentMode': paymentMode!,
          'chequeNo': chequeNoController.text,
          'date': selectedDate.toIso8601String(),
          'amount': double.parse(amountController.text),
          'remark': remarkController.text,
        };

        // Backend API URL
        const String apiUrl = '${AppConfig.baseUrl}/api/expenses';

        // Send POST request to the backend
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(newExpense),
        );

        if (response.statusCode == 201) {
          final responseData = jsonDecode(response.body);
          final expense = Expense.fromJson(responseData['expense']);
          widget.onAddExpense(expense);
          _resetForm();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Expense added successfully!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add expense: ${response.body}')),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }
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
      child: Form(
        key: _formKey,
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
              items: <String>['-- Select --', 'Food', 'Travel', 'Other']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              validator: (value) => value == null || value == '-- Select --'
                  ? 'Please select an expense type'
                  : null,
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
              items: <String>['-- Select --', 'Cash', 'Credit Card', 'Debit Card']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              validator: (value) => value == null || value == '-- Select --'
                  ? 'Please select a payment mode'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: chequeNoController,
              decoration: const InputDecoration(
                labelText: 'Cheque No:',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.isEmpty
                  ? 'Please enter a cheque number'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Amount *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) => value == null || value.isEmpty
                  ? 'Please enter an amount'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: remarkController,
              decoration: const InputDecoration(
                labelText: 'Remark:',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text('Save'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _resetForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
              ),
              child: const Text('Reset'),
            ),
          ],
        ),
      ),
    );
  }
}


// Screen for managing expenses


class ManageExpenseScreen extends StatefulWidget {
  final List<Expense> expenses;
  final void Function(int) onDeleteExpense;
  final void Function(int, Expense) onUpdateExpense;

  const ManageExpenseScreen({super.key,
    required this.expenses,
    required this.onDeleteExpense,
    required this.onUpdateExpense,
  });

  @override
  _ManageExpenseScreenState createState() => _ManageExpenseScreenState();
}

class _ManageExpenseScreenState extends State<ManageExpenseScreen> {
  List<Expense> _expenses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
  }

  Future<void> _fetchExpenses() async {
    try {
      final response = await http.get(Uri.parse('${AppConfig.baseUrl}/api/expenses'));
      if (response.statusCode == 200) {
        final List<dynamic> expenseData = jsonDecode(response.body)['expenses'];
        setState(() {
          _expenses = expenseData.map((json) => Expense.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load expenses');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $error')));
    }
  }

  Future<void> _deleteExpense(String id) async {
    try {
      final response = await http.delete(Uri.parse('${AppConfig.baseUrl}/api/expenses/$id'));
      if (response.statusCode == 200) {
        setState(() {
          _expenses.removeWhere((expense) => expense.id == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Expense deleted successfully')));
      } else {
        throw Exception('Failed to delete expense');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Manage Expenses'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _expenses.length,
        itemBuilder: (context, index) {
          final expense = _expenses[index];
          final formattedDate = DateFormat('yyyy-MM-dd').format(expense.date);
          return ListTile(
            title: Text('${expense.expenseType} - \$${expense.amount}'),
            subtitle: Text('Date: $formattedDate'),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteExpense(expense.id),
            ),
            onTap: () {
              // Handle edit expense
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add expense screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
// Define other screens like AddExpenseTypeScreen, ManageExpenseTypeScreen, AddIncomeScreen, and ManageIncomeScreen similarly.

class AddExpenseTypeScreen extends StatelessWidget {
  final TextEditingController _expenseTypeController = TextEditingController();

  AddExpenseTypeScreen({super.key});

  void _saveExpenseType() async {
    String expenseType = _expenseTypeController.text;
    if (expenseType.isNotEmpty) {
      // Send data to backend
      try {
        final response = await http.post(
          Uri.parse('${AppConfig.baseUrl}/api/expenseTypes'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'name': expenseType}),
        );

        if (response.statusCode == 200) {
          print("Expense Type Saved: $expenseType");
          _resetForm();
          // Optionally, navigate back or show a success message
        } else {
          print("Failed to save Expense Type");
        }
      } catch (e) {
        print("Error: $e");
      }
    } else {
      print("Expense Type cannot be empty");
    }
  }

  void _resetForm() {
    _expenseTypeController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
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
          TextField(
            controller: _expenseTypeController,
            decoration: const InputDecoration(
              labelText: 'Expense Type*',
              border: OutlineInputBorder(),
            ),
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
    );
  }
}

// Placeholder for other screens

class ManageExpenseTypeScreen extends StatefulWidget {
  const ManageExpenseTypeScreen({super.key});

  @override
  _ManageExpenseTypeScreenState createState() => _ManageExpenseTypeScreenState();
}

class _ManageExpenseTypeScreenState extends State<ManageExpenseTypeScreen> {
  List<String> expenseTypes = [];

  @override
  void initState() {
    super.initState();
    _fetchExpenseTypes();
  }

  Future<void> _fetchExpenseTypes() async {
    try {
      final response = await http.get(Uri.parse('${AppConfig.baseUrl}/api/expenseTypes'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          expenseTypes = data.map((e) => e['name'] as String).toList();
        });
      } else {
        print("Failed to fetch Expense Types");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void _editExpenseType(int index) {
    // Implement edit logic and make a PUT request to update data
    print("Edit Expense Type: ${expenseTypes[index]}");
  }

  void _deleteExpenseType(int index) async {
    try {
      final response = await http.delete(
        Uri.parse('${AppConfig.baseUrl}/api/expenseTypes/${expenseTypes[index]}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          expenseTypes.removeAt(index);
        });
        print("Deleted Expense Type: ${expenseTypes[index]}");
      } else {
        print("Failed to delete Expense Type");
      }
    } catch (e) {
      print("Error: $e");
    }
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
                  title: Text("Expense Type: ${expenseTypes[index]}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editExpenseType(index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
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
  const AddIncomeScreen({super.key});

  @override
  _AddIncomeScreenState createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  final TextEditingController _incomeTypeController = TextEditingController();
  final TextEditingController _paymentTypeController = TextEditingController();
  final TextEditingController _chequeNoController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  void _saveIncome() {
    if (_formKey.currentState!.validate()) {
      // Save income logic here
    }
  }

  void _resetForm() {
    _formKey.currentState!.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
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
                  _buildTextField(_incomeTypeController, 'Income Type *', 'e.g. 10th', true),
                  const SizedBox(height: 10),
                  _buildTextField(_paymentTypeController, 'Payment Type *', 'e.g. Cash/Cheque/UPI', true),
                  const SizedBox(height: 10),
                  _buildTextField(_chequeNoController, 'Cheque No', '', false),
                  const SizedBox(height: 10),
                  _buildTextField(_bankNameController, 'Bank Name', '', false),
                  const SizedBox(height: 10),
                  _buildTextField(_dateController, 'Date *', 'e.g. 24th June 2024', true),
                  const SizedBox(height: 10),
                  _buildTextField(_amountController, 'Amount *', '', true),
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

  _buildTextField(TextEditingController amountController, String s, String t, bool bool) {}
}
class ManageIncomeScreen extends StatefulWidget {
  const ManageIncomeScreen({super.key});

  @override
  _ManageIncomeScreenState createState() => _ManageIncomeScreenState();
}

class _ManageIncomeScreenState extends State<ManageIncomeScreen> {
  List<Map<String, dynamic>> incomes = [];

  @override
  void initState() {
    super.initState();
    _fetchIncomes();
  }

  Future<void> _fetchIncomes() async {
    try {
      final response = await http.get(Uri.parse('${AppConfig.baseUrl}/api/incomes'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          incomes = data.map((e) => e as Map<String, dynamic>).toList();
        });
      } else {
        print("Failed to fetch Incomes");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void _editIncome(int index) {
    // Implement edit logic and make a PUT request to update data
    print("Edit Income: ${incomes[index]}");
  }

  void _deleteIncome(int index) async {
    try {
      final response = await http.delete(
        Uri.parse('${AppConfig.baseUrl}/api/incomes/${incomes[index]['_id']}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          incomes.removeAt(index);
        });
        print("Deleted Income: ${incomes[index]}");
      } else {
        print("Failed to delete Income");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
            const TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: incomes.length,
                itemBuilder: (context, index) {
                  final income = incomes[index];
                  return ListTile(
                    title: Text('Income Type: ${income['incomeType']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Payment Type: ${income['paymentType']}'),
                        Text('Cheque No.: ${income['chequeNo']}'),
                        Text('Bank Name: ${income['bankName']}'),
                        Text('Date: ${income['date']}'),
                        Text('Amount: ${income['amount']}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editIncome(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteIncome(index),
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