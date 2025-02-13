// check_out_page.dart
import 'package:flutter/material.dart';
import 'cart_item.dart';
import 'cart_page.dart'; // Ensure this import is present
// If integrating with Provider for Wallet
// import 'package:provider/provider.dart';
// import 'wallet.dart';

class CheckOutPage extends StatefulWidget {
  const CheckOutPage({Key? key}) : super(key: key);

  @override
  _CheckOutPageState createState() => _CheckOutPageState();
}

class _CheckOutPageState extends State<CheckOutPage> {
  // Define an enum for payment methods
  PaymentMethod? _selectedPaymentMethod;

  @override
  Widget build(BuildContext context) {
    double totalPrice = 0.0;
    for (var item in CartPage.cartItems) {
      totalPrice += item.price * item.quantity;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green, Colors.teal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Display cart items or summary
            Expanded(
              child: ListView.builder(
                itemCount: CartPage.cartItems.length,
                itemBuilder: (context, index) {
                  final item = CartPage.cartItems[index];
                  return ListTile(
                    leading: Image.network(
                      item.imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.error),
                    ),
                    title: Text(item.productName),
                    subtitle:
                    Text("\$${item.price.toStringAsFixed(2)} x ${item.quantity}"),
                    trailing: Text(
                      "\$${(item.price * item.quantity).toStringAsFixed(2)}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            // Total Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total:",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  "\$${totalPrice.toStringAsFixed(2)}",
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Payment Method Selection
            PaymentMethodSelection(
              selectedMethod: _selectedPaymentMethod,
              onChanged: (PaymentMethod? method) {
                setState(() {
                  _selectedPaymentMethod = method;
                });
              },
            ),
            const SizedBox(height: 20),
            // Proceed to Payment or Confirmation
            ElevatedButton(
              onPressed: _selectedPaymentMethod == null
                  ? null
                  : () {
                // Implement your payment or confirmation logic here
                String paymentText;
                if (_selectedPaymentMethod == PaymentMethod.cash) {
                  paymentText = "Payment by Cash Successful!";
                } else {
                  // Implement salary deduction logic here
                  // For demonstration, we'll just show a success message
                  paymentText = "Salary Deduction Successful!";
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(paymentText)),
                );

                // Optionally, clear the cart after successful checkout
                CartPage.cartItems.clear();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                padding:
                const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                "Confirm Purchase",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Define an enum for payment methods
enum PaymentMethod { cash, salaryDeduction }

// Widget for Payment Method Selection
class PaymentMethodSelection extends StatelessWidget {
  final PaymentMethod? selectedMethod;
  final ValueChanged<PaymentMethod?> onChanged;

  const PaymentMethodSelection({
    Key? key,
    required this.selectedMethod,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select Payment Method:",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        RadioListTile<PaymentMethod>(
          title: const Text("Cash"),
          value: PaymentMethod.cash,
          groupValue: selectedMethod,
          onChanged: onChanged,
        ),
        RadioListTile<PaymentMethod>(
          title: const Text("Salary Deduction"),
          value: PaymentMethod.salaryDeduction,
          groupValue: selectedMethod,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
