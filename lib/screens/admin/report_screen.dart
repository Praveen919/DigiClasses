import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting dates
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:testing_app/screens/config.dart';
import 'package:testing_app/screens/admin/expenses_income_screen.dart';

class ReportScreen extends StatefulWidget {
  final String option;

  const ReportScreen({super.key, required this.option});

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report'),
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    switch (widget.option) {
      case 'studentInquiry':
        return const StudentInquiryReportScreen();
      case 'expense':
        return const ExpenseReportScreen();
      case 'income':
        return const IncomeReportScreen();
      case 'appAccessRights':
        return const AppAccessRightsScreen();
      default:
        return const Center(child: Text('Unknown Option'));
    }
  }
}

// Below are the placeholder widgets for each report screen.
// Replace these with your actual implementation.

class StudentInquiryReportScreen extends StatefulWidget {
  const StudentInquiryReportScreen({super.key});

  @override
  _StudentInquiryReportScreenState createState() =>
      _StudentInquiryReportScreenState();
}

class _StudentInquiryReportScreenState
    extends State<StudentInquiryReportScreen> {
  DateTime? fromDate;
  DateTime? toDate;
  TextEditingController searchController = TextEditingController();
  bool isLoading = false;
  List<Map<String, dynamic>> inquiries = []; // Store inquiries data

  // Method to select a date
  Future<void> _selectDate(BuildContext context, DateTime? initialDate,
      Function(DateTime) onDateSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != initialDate) {
      onDateSelected(picked);
    }
  }

  // Method to fetch data from the database
  Future<void> _getInquiries() async {
    setState(() {
      isLoading = true;
    });

    // Fetch the data based on the fromDate and toDate
    final results =
        await fetchInquiriesFromDB(fromDate, toDate, searchController.text);

    setState(() {
      inquiries = results;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Student Inquiry Report'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            TextFormField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _getInquiries(); // Search filter when typing
              },
            ),
            const SizedBox(height: 16),
            // Date pickers
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(context, fromDate, (date) {
                      setState(() {
                        fromDate = date;
                      });
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        fromDate != null
                            ? DateFormat.yMMMd().format(fromDate!)
                            : 'From Date',
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(context, toDate, (date) {
                      setState(() {
                        toDate = date;
                      });
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        toDate != null
                            ? DateFormat.yMMMd().format(toDate!)
                            : 'To Date',
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _getInquiries,
                  child: const Text('Get Data'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Inquiry list
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: inquiries.isNotEmpty
                        ? ListView.builder(
                            itemCount: inquiries.length,
                            itemBuilder: (context, index) {
                              final inquiry = inquiries[index];
                              return ListTile(
                                title: Text(
                                    'Student Name: ${inquiry['studentName']}\nStandard: ${inquiry['standard']}\nInquiry Date: ${inquiry['inquiryDate']}\nInquiry Source: ${inquiry['inquirySource']}'),
                              );
                            },
                          )
                        : const Center(child: Text('No inquiries found')),
                  ),
            const SizedBox(height: 16),
            // View Report button
          ],
        ),
      ),
    );
  }

  // Method to fetch inquiries from the database
  Future<List<Map<String, dynamic>>> fetchInquiriesFromDB(
      DateTime? fromDate, DateTime? toDate, String search) async {
    const String apiUrl = '${AppConfig.baseUrl}/api/inquiries';

    try {
      // Create query parameters
      Map<String, String> queryParams = {
        'search': search,
        'fromDate':
            fromDate != null ? DateFormat('yyyy-MM-dd').format(fromDate) : '',
        'toDate': toDate != null ? DateFormat('yyyy-MM-dd').format(toDate) : '',
      };

      // Make the HTTP GET request
      final response = await http
          .get(Uri.parse('$apiUrl?${Uri(queryParameters: queryParams).query}'));

      // Log the HTTP response for debugging
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Parse the JSON response
        List<dynamic> data = json.decode(response.body);

        // Convert JSON data to a list of maps
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        print(
            'Error: Failed to fetch inquiries with status code: ${response.statusCode}');
        throw Exception('Failed to load inquiries');
      }
    } catch (e) {
      print('Error fetching inquiries: $e');
      return [];
    }
  }
}

class ExpenseReportScreen extends StatefulWidget {
  const ExpenseReportScreen({super.key});

  @override
  _ExpenseReportScreenState createState() => _ExpenseReportScreenState();
}

class _ExpenseReportScreenState extends State<ExpenseReportScreen> {
  DateTime? fromDate;
  DateTime? toDate;
  List<Expense> expenseData = []; // Change to List<Expense>
  List<Expense> filteredData = []; // Change to List<Expense>
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // Method to fetch data from the database
  Future<void> _fetchData() async {
    try {
      final response =
          await http.get(Uri.parse('${AppConfig.baseUrl}/api/expenses'));
      if (response.statusCode == 200) {
        setState(() {
          // Parse the response into a list of Expense objects
          expenseData = (json.decode(response.body) as List)
              .map((json) => Expense.fromJson(json))
              .toList();
          filteredData = expenseData;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  // Method to filter data based on dates and search query
  void _filterData() {
    setState(() {
      filteredData = expenseData.where((expense) {
        final isInDateRange = (fromDate == null ||
                expense.date.isAfter(fromDate!) ||
                expense.date.isAtSameMomentAs(fromDate!)) &&
            (toDate == null ||
                expense.date.isBefore(toDate!) ||
                expense.date.isAtSameMomentAs(toDate!));
        final matchesSearchQuery =
            expense.name.toLowerCase().contains(searchQuery.toLowerCase());
        return isInDateRange && matchesSearchQuery;
      }).toList();
    });
  }

  // Method to select a date
  Future<void> _selectDate(BuildContext context, DateTime? initialDate,
      Function(DateTime) onDateSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != initialDate) {
      onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Expense Report'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                  _filterData();
                });
              },
              decoration: const InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(context, fromDate, (date) {
                      setState(() {
                        fromDate = date;
                      });
                      _filterData();
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        fromDate != null
                            ? DateFormat.yMMMd().format(fromDate!)
                            : 'From Date',
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(context, toDate, (date) {
                      setState(() {
                        toDate = date;
                      });
                      _filterData();
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        toDate != null
                            ? DateFormat.yMMMd().format(toDate!)
                            : 'To Date',
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    _filterData(); // Filter data on button click
                  },
                  child: const Text('Get Data'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('Expense Type')),
                    DataColumn(label: Text('Payment Mode')),
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Amount')),
                  ],
                  rows: List<DataRow>.generate(
                    filteredData.length,
                    (index) => DataRow(
                      cells: [
                        DataCell(Text(filteredData[index].id)),
                        DataCell(Text(
                          filteredData[index]
                              .name, // Use the name from the Expense object
                        )),
                        DataCell(Text(
                          filteredData[index].paymentMode,
                        )),
                        DataCell(Text(
                          DateFormat.yMMMd().format(filteredData[index]
                              .date), // Format date using DateTime
                        )),
                        DataCell(Text(
                          filteredData[index].amount.toString(),
                        )),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Income {
  String? id;
  String incomeType;
  String paymentType;
  String? chequeNumber; // Allow null values
  String? bankName; // Allow null values
  DateTime date;
  double amount;

  Income({
    required this.id,
    required this.incomeType,
    required this.paymentType,
    this.chequeNumber,
    this.bankName,
    required this.date,
    required this.amount,
  });

  factory Income.fromJson(Map<String, dynamic> json) {
    return Income(
      id: json['_id'] ?? '',
      incomeType: json['incomeType'] ?? 'Unknown',
      paymentType: json['iPaymentType'] ?? 'Unknown',
      chequeNumber: json['iChequeNumber'] != null
          ? json['iChequeNumber'] as String
          : null, // Handle null
      bankName: json['bankName'] != null
          ? json['bankName'] as String
          : null, // Handle null
      date: DateTime.parse(json['iDate']),
      amount: (json['iAmount'] as num).toDouble(),
    );
  }
}

class IncomeReportScreen extends StatefulWidget {
  const IncomeReportScreen({super.key});

  @override
  _IncomeReportScreenState createState() => _IncomeReportScreenState();
}

class _IncomeReportScreenState extends State<IncomeReportScreen> {
  DateTime? fromDate;
  DateTime? toDate;
  List<Income> incomeData = []; // List of Income objects
  List<Income> filteredData = []; // Filtered list
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // Method to fetch data from the database
  Future<void> _fetchData() async {
    try {
      final response =
          await http.get(Uri.parse('${AppConfig.baseUrl}/api/incomes'));
      if (response.statusCode == 200) {
        print('API Response: ${response.body}'); // Log the raw response
        setState(() {
          // Parse the response into a list of Income objects
          incomeData = (json.decode(response.body) as List)
              .map((json) => Income.fromJson(json))
              .toList();
          filteredData = incomeData; // Initially show all data
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  // Method to filter data based on dates and search query
  void _filterData() {
    setState(() {
      filteredData = incomeData.where((income) {
        final isInDateRange = (fromDate == null ||
                income.date.isAfter(fromDate!) ||
                income.date.isAtSameMomentAs(fromDate!)) &&
            (toDate == null ||
                income.date.isBefore(toDate!) ||
                income.date.isAtSameMomentAs(toDate!));
        final matchesSearchQuery =
            income.incomeType.toLowerCase().contains(searchQuery.toLowerCase());
        return isInDateRange && matchesSearchQuery;
      }).toList();
    });
  }

  // Method to select a date
  Future<void> _selectDate(BuildContext context, DateTime? initialDate,
      Function(DateTime) onDateSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != initialDate) {
      onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Income Report'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                  _filterData();
                });
              },
              decoration: const InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(context, fromDate, (date) {
                      setState(() {
                        fromDate = date;
                      });
                      _filterData();
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        fromDate != null
                            ? DateFormat.yMMMd().format(fromDate!)
                            : 'From Date',
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(context, toDate, (date) {
                      setState(() {
                        toDate = date;
                      });
                      _filterData();
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        toDate != null
                            ? DateFormat.yMMMd().format(toDate!)
                            : 'To Date',
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    _filterData(); // Filter data on button click
                  },
                  child: const Text('Get Data'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('Income Type')),
                    DataColumn(label: Text('Payment Mode')),
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Amount')),
                  ],
                  rows: List<DataRow>.generate(
                    filteredData.length,
                    (index) => DataRow(
                      cells: [
                        DataCell(Text(filteredData[index].id ?? 'N/A')),
                        DataCell(Text(filteredData[index].incomeType)),
                        DataCell(Text(filteredData[index].paymentType)),
                        DataCell(Text(
                          DateFormat.yMMMd().format(filteredData[index].date),
                        )),
                        DataCell(Text(
                          filteredData[index].amount.toString(),
                        )),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppAccessRightsScreen extends StatefulWidget {
  const AppAccessRightsScreen({super.key});

  @override
  _AppAccessRightsScreenState createState() => _AppAccessRightsScreenState();
}

class _AppAccessRightsScreenState extends State<AppAccessRightsScreen> {
  String selectedRights = 'Admin';
  List<Map<String, dynamic>> users = []; // Changed to hold user data
  bool isLoading = false;

  Future<void> _fetchUsers() async {
    const url = '${AppConfig.baseUrl}/api/staff-rights/rights'; // Updated URL

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          users = data
              .where((user) =>
                  user['role'] == selectedRights && user['staffId'] != null)
              .map((user) => {
                    'id': user['staffId']
                        ['_id'], // Adjust based on your structure
                    'firstName': user['staffId']['firstName'] ?? '',
                    'middleName': user['staffId']['middleName'] ?? '',
                    'lastName': user['staffId']['lastName'] ?? '',
                    'role': user['role'] ?? '', // Ensure role is captured
                  })
              .toList();
        });
      } else {
        print('Error fetching users: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'App Access Rights',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _fetchUsers(); // Fetch users when the button is pressed
              },
              style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black, backgroundColor: Colors.white),
              child: const Text('Check App Access Rights'),
            ),
            const SizedBox(height: 16),
            const Text('Check Rights:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            RadioListTile(
              title: const Text('Check Admin Rights'),
              value: 'Admin',
              groupValue: selectedRights,
              onChanged: (value) => setState(() {
                selectedRights = value.toString();
              }),
            ),
            RadioListTile(
              title: const Text('Check Teacher Rights'),
              value: 'Teacher',
              groupValue: selectedRights,
              onChanged: (value) => setState(() {
                selectedRights = value.toString();
              }),
            ),
            RadioListTile(
              title: const Text('Check Student Rights'),
              value: 'Student',
              groupValue: selectedRights,
              onChanged: (value) => setState(() {
                selectedRights = value.toString();
              }),
            ),
            const SizedBox(height: 16),
            const Text('Users with Rights:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (users.isEmpty)
              const Center(child: Text('No users found'))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  final fullName =
                      '${user['firstName']} ${user['middleName']} ${user['lastName']}';
                  return ListTile(
                    leading: CircleAvatar(child: Text('U${index + 1}')),
                    title: Text(fullName.isNotEmpty
                        ? fullName
                        : 'Unnamed User'), // Handle null names
                    subtitle: Text('Role: ${user['role']}'),
                  );
                },
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
