import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // If using authentication

class WalletPage extends StatefulWidget {
  const WalletPage({Key? key}) : super(key: key);

  @override
  _WalletPageState createState() => _WalletPageState();
}

enum PaymentMethod { cash, salaryDeduction }

class _WalletPageState extends State<WalletPage> {
  PaymentMethod? _selectedMethod;

  // For demonstration, assuming a fixed wallet balance.
  // In a real app, fetch this from Firestore or another source.
  final double walletBalance = 1250.00;

  // Optional: If using authentication, get current user
  final User? user = FirebaseAuth.instance.currentUser;

  // Define the payment notes
  String _getPaymentNote(PaymentMethod? method) {
    switch (method) {
      case PaymentMethod.cash:
        return "Pay at the accounting office to claim your products.";
      case PaymentMethod.salaryDeduction:
        return "Payslip is provided in the accounting office.";
      default:
        return "";
    }
  }

  // Alternatively, using a map
  // final Map<PaymentMethod, String> _paymentNotes = {
  //   PaymentMethod.cash: "Pay at the accounting office to claim your products.",
  //   PaymentMethod.salaryDeduction: "Payslip is provided in the accounting office.",
  // };

  @override
  void initState() {
    super.initState();
    // Fetch user's selected payment method if using authentication
    if (user != null) {
      _fetchUserSelectedMethod();
    } else {
      // Default selection if not using authentication
      _selectedMethod = PaymentMethod.cash;
    }
  }

  Future<void> _fetchUserSelectedMethod() async {
    if (user == null) return;

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    if (userDoc.exists) {
      String method = userDoc.get('selectedPaymentMethod') as String;
      setState(() {
        _selectedMethod = method == 'cash'
            ? PaymentMethod.cash
            : PaymentMethod.salaryDeduction;
      });
    } else {
      // If no selection exists, default to cash
      setState(() {
        _selectedMethod = PaymentMethod.cash;
      });
    }
  }

  // Function to map enum to string
  String _paymentMethodToString(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'cash';
      case PaymentMethod.salaryDeduction:
        return 'salaryDeduction';
      default:
        return '';
    }
  }

  // Function to handle confirmation
  Future<void> _confirmSelection() async {
    if (_selectedMethod == null) return;

    String method = _paymentMethodToString(_selectedMethod!);

    // If using authentication, save to user's document
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .set({
        'selectedPaymentMethod': method,
      }, SetOptions(merge: true));
    }

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Selected Payment Method: ${method == 'cash' ? 'Cash' : 'Salary Deduction'}'),
        duration: const Duration(seconds: 2),
      ),
    );

    // Perform further actions as needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wallet'),
        backgroundColor: Colors.teal, // Enhanced AppBar color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Display Wallet Balance or Relevant Info
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.teal[50],
              child: ListTile(
                leading: Icon(
                  Icons.account_balance_wallet,
                  color: Colors.teal,
                  size: 40,
                ),
                title: const Text(
                  'Wallet Balance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  '\$${walletBalance.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Payment Method Selection
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Select Payment Method',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.teal[800],
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Fetch payment methods from Firestore
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('paymentMethods')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Parse payment methods
                  final methods = snapshot.data!.docs;

                  if (methods.isEmpty) {
                    return const Center(
                      child: Text('No payment methods available.'),
                    );
                  }

                  return ListView.separated(
                    itemCount: methods.length,
                    separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      var methodData =
                      methods[index].data() as Map<String, dynamic>;
                      String methodId = methods[index].id;
                      String methodName = methodData['name'] ?? 'Unnamed';
                      String iconName = methodData['icon'] ?? 'money';

                      // Map iconName to actual IconData
                      IconData icon;
                      switch (iconName) {
                        case 'money':
                          icon = Icons.money;
                          break;
                        case 'attach_money':
                          icon = Icons.attach_money;
                          break;
                      // Add more cases as needed
                        default:
                          icon = Icons.payment;
                      }

                      // Determine the selected payment method
                      PaymentMethod? methodEnum;
                      if (methodId == 'cash') {
                        methodEnum = PaymentMethod.cash;
                      } else if (methodId == 'salaryDeduction') {
                        methodEnum = PaymentMethod.salaryDeduction;
                      } else {
                        methodEnum = null;
                      }

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: _selectedMethod == methodEnum
                                ? Colors.teal
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: ListTile(
                          leading: Icon(
                            icon,
                            color: Colors.teal,
                          ),
                          title: Text(methodName),
                          trailing: Radio<PaymentMethod>(
                            value: methodEnum ?? PaymentMethod.cash,
                            groupValue: _selectedMethod,
                            onChanged: (PaymentMethod? value) {
                              setState(() {
                                _selectedMethod = value;
                              });
                            },
                            activeColor: Colors.teal,
                          ),
                          onTap: () {
                            setState(() {
                              _selectedMethod = methodEnum;
                            });
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            // Display the Note Based on Selected Payment Method
            if (_selectedMethod != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.teal[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.teal),
                ),
                child: Text(
                  _getPaymentNote(_selectedMethod),
                  style: TextStyle(
                    color: Colors.teal[800],
                    fontSize: 16,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            // Confirm Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedMethod == null ? null : _confirmSelection,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.teal, // Button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Confirm',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
