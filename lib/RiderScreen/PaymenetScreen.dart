import 'package:delivery_rider_app/data/model/WithdrawBodyModel.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../config/network/api.state.dart';
import '../config/utils/pretty.dio.dart';

class WithdrawMoneyPage extends StatefulWidget {
  const WithdrawMoneyPage({super.key});

  @override
  State<WithdrawMoneyPage> createState() => _WithdrawMoneyPageState();
}

class _WithdrawMoneyPageState extends State<WithdrawMoneyPage> {
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submitWithdrawRequest(int amountInRupees) async {
    setState(() => _isLoading = true);

    try {
      final dio = await callDio();
      final service = APIStateNetwork(dio);

      final response = await service.withdrawRequest(
        WithdrawBodyModel(
          amount: amountInRupees, // ← most wallet APIs expect rupees here
          // If your backend actually wants paise, change to: amount: amountInRupees * 100
        ),
      );

      // According to your log: success = error == false && code == 0
      if (response.error == true || response.code != 0) {
        throw Exception(response.message ?? "Withdraw request failed");
      }

      // Success
      if (!mounted) return;

      Fluttertoast.showToast(
        msg: response.message ?? "Withdraw request submitted successfully!",
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      // Optional: clear field + maybe pop or navigate
      _amountController.clear();

      // Most common patterns:
      // 1. Navigator.pop(context);                    // close screen
      // 2. Navigator.pop(context, true);              // signal success
      // 3. Go to history / wallet screen

      Navigator.pop(context, true); // ← recommended

    } catch (e) {
      if (!mounted) return;

      String msg = "Something went wrong";

      if (e.toString().contains("SocketException")) {
        msg = "No internet connection";
      } else if (e.toString().contains("Timeout")) {
        msg = "Request timed out";
      } else {
        msg = e.toString().split('\n').first.trim();
        if (msg.length > 120) msg = msg.substring(0, 120) + "...";
      }

      Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final amountText = _amountController.text.trim();
    final amount = int.tryParse(amountText);

    if (amount == null || amount < 10) {
      Fluttertoast.showToast(
        msg: "Please enter valid amount (minimum ₹10)",
        backgroundColor: Colors.orange,
      );
      return;
    }

    _submitWithdrawRequest(amount); // sending in rupees
    // If backend wants paise:   _submitWithdrawRequest(amount * 100);
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF006970);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Withdraw Money"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                Text(
                  "Enter Withdrawal Amount",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),
                Text(
                  "Minimum withdrawal: ₹10",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
                ),

                const SizedBox(height: 24),

                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    prefixText: "₹ ",
                    labelText: "Amount",
                    hintText: "e.g. 500",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: primaryColor, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please enter amount";
                    }
                    final n = int.tryParse(value.trim());
                    if (n == null || n < 10) {
                      return "Minimum amount is ₹10";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 40),

                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  ElevatedButton(
                    onPressed: _onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      "Submit Withdrawal Request",
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}