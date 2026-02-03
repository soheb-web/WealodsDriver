

import 'package:delivery_rider_app/data/model/WithdrawBodyModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../config/network/api.state.dart';
import '../config/utils/pretty.dio.dart';
import '../data/model/CreateOrderModel.dart';

class WithdrawMoneyPage extends StatefulWidget {
  const WithdrawMoneyPage({super.key});

  @override
  State<WithdrawMoneyPage> createState() => _WithdrawMoneyPageState();
}

class _WithdrawMoneyPageState extends State<WithdrawMoneyPage> {
  final _depositController = TextEditingController();
  final _withdrawController = TextEditingController();
  final _formKeyDeposit = GlobalKey<FormState>();
  final _formKeyWithdraw = GlobalKey<FormState>();

  late Razorpay _razorpay;
  bool _isLoading = false;
  bool _isLoadingDeposit = false;
  String? _pendingOrderId;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
  }

  @override
  void dispose() {
    _depositController.dispose();
    _withdrawController.dispose();
    _razorpay.clear();
    super.dispose();
  }

  // ── DEPOSIT FLOW ────────────────────────────────────────────────

  Future<void> _startDeposit(int amountInRupees) async {
    if (amountInRupees < 10) return;

    setState(() => _isLoadingDeposit = true);

    try {
      final dio = await callDio(); // or callPrettyDio()
      final service = APIStateNetwork(dio);

      final orderRes = await service.createOrder(
        CreateOrderModel(
          amount: amountInRupees, // paise
          currency: "INR",
          // receipt: "wallet_topup_${DateTime.now().millisecondsSinceEpoch}",
        ),
      );

      if (orderRes.error == true || orderRes.data?.razorpayOrder?.id == null) {
        throw Exception(orderRes.message ?? "Failed to create order");
      }

      _pendingOrderId = orderRes.data!.razorpayOrder!.id;

      _openRazorpayCheckout(amountInRupees);
    } catch (e) {
      _showErrorToast(e.toString());
    } finally {
      if (mounted) setState(() => _isLoadingDeposit = false);
    }
  }

  void _openRazorpayCheckout(int amountInPaise) {
    if (_pendingOrderId == null) {
      _showErrorToast("No order ID found");
      return;
    }

    var options = {
      'key': 'rzp_live_SATOHYwE0so41p', // ← move to .env / config in production
      // 'key': 'rzp_test_S3KH88gvOeaAOh', // ← move to .env / config in production
      'amount': amountInPaise,
      'name': 'WeLoads',
      'description': 'Wallet Top-up',
      'order_id': _pendingOrderId,
      'prefill': {
        'contact': '9876543210', // ← fetch from user profile
        'email': 'rider@weloads.com',
      },
      'theme': {'color': '#006970'},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      _showErrorToast("Checkout failed: $e");
    }
  }

  Future<void> _onPaymentSuccess(PaymentSuccessResponse res) async {
    Fluttertoast.showToast(
      msg: "Payment Successful! 🎉",
      backgroundColor: Colors.green,
    );

    // IMPORTANT: Call your backend to verify + add money
    await _verifyPaymentAndCreditWallet(
      paymentId: res.paymentId ?? '',
      orderId: res.orderId ?? '',
      signature: res.signature ?? '',
      amount: int.tryParse(_depositController.text.trim()) ?? 0,
    );

    if (mounted) {
      _depositController.clear();
      _pendingOrderId = null;
      Navigator.pop(context, true);
    }
  }

  Future<void> _verifyPaymentAndCreditWallet({
    required String paymentId,
    required String orderId,
    required String signature,
    required int amount,
  }) async {
    try {
      final dio = await callDio();
      final service = APIStateNetwork(dio);

      // TODO: Call your backend verify endpoint
      // await service.verifyPayment({
      //   "razorpay_payment_id": paymentId,
      //   "razorpay_order_id": orderId,
      //   "razorpay_signature": signature,
      //   "amount": amount,
      // });

      Fluttertoast.showToast(
        msg: "₹$amount added to wallet!",
        backgroundColor: Colors.green,
      );
    } catch (e) {
      _showErrorToast("Wallet update failed – contact support");
    }
  }

  // ── WITHDRAWAL FLOW ─────────────────────────────────────────────

  Future<void> _submitWithdrawal(int amountInRupees) async {
    setState(() => _isLoading = true);

    try {
      final dio = await callDio();
      final service = APIStateNetwork(dio);

      final res = await service.withdrawRequest(
        WithdrawBodyModel(amount: amountInRupees), // rupees or paise – confirm!
      );

      if (res.error == true || res.code != 0) {
        throw Exception(res.message ?? "Withdrawal request failed");
      }

      Fluttertoast.showToast(
        msg: res.message ?? "Withdrawal request submitted!",
        backgroundColor: Colors.green,
      );

      if (mounted) {
        _withdrawController.clear();
        // Navigator.pop(context, true);
      }

    } catch (e) {
      _showErrorToast(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorToast(String msg) {
    Fluttertoast.showToast(
      msg: msg.length > 100 ? "${msg.substring(0, 97)}..." : msg,
      backgroundColor: Colors.red,
      toastLength: Toast.LENGTH_LONG,
    );
  }

  // ── BUTTON HANDLERS ─────────────────────────────────────────────

  void _handleDepositSubmit() {
    if (!_formKeyDeposit.currentState!.validate()) return;

    final text = _depositController.text.trim();
    final amount = int.tryParse(text);

    if (amount == null || amount < 10) {
      Fluttertoast.showToast(msg: "Minimum ₹10 required");
      return;
    }

    _startDeposit(amount);
  }

  void _handleWithdrawSubmit() {
    if (!_formKeyWithdraw.currentState!.validate()) return;

    final text = _withdrawController.text.trim();
    final amount = int.tryParse(text);

    if (amount == null || amount < 10) {
      Fluttertoast.showToast(msg: "Minimum ₹10 required");
      return;
    }

    _submitWithdrawal(amount);

  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF006970);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Wallet Operations"),
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── DEPOSIT SECTION ──
              Text("Add Money to Wallet", style: Theme.of(context).textTheme.titleLarge?.copyWith(color: primary, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text("Minimum: ₹10", style: TextStyle(color: Colors.grey[700])),
              const SizedBox(height: 20),

              Form(
                key: _formKeyDeposit,
                child: TextFormField(
                  controller: _depositController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    prefixText: "₹ ",
                    labelText: "Amount",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  validator: (v) {
                    if (v?.trim().isEmpty ?? true) return "Required";
                    final n = int.tryParse(v!.trim());
                    if (n == null || n < 10) return "Minimum ₹10";
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 24),

              if (_isLoadingDeposit)
                const Center(child: CircularProgressIndicator())
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleDepositSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("ADD MONEY", style: TextStyle(
                        color: Colors.white,
                        fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),

              const SizedBox(height: 48),
              const Divider(),
              const SizedBox(height: 32),

              // ── WITHDRAW SECTION ──
              Text("Withdraw to Bank", style: Theme.of(context).textTheme.titleLarge?.copyWith(color: primary, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text("Minimum: ₹10", style: TextStyle(color: Colors.grey[700])),
              const SizedBox(height: 20),

              Form(
                key: _formKeyWithdraw,
                child: TextFormField(
                  controller: _withdrawController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    prefixText: "₹ ",
                    labelText: "Amount",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  validator: (v) {
                    if (v?.trim().isEmpty ?? true) return "Required";
                    final n = int.tryParse(v!.trim());
                    if (n == null || n < 10) return "Minimum ₹10";
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 24),

              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleWithdrawSubmit, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("WITHDRAW", style: TextStyle(
                        color: Colors.white,
                        fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _onPaymentError(PaymentFailureResponse res) {
    Fluttertoast.showToast(msg: "Payment Failed\n${res.message ?? res.code}");
  }

  void _onExternalWallet(ExternalWalletResponse res) {
    Fluttertoast.showToast(msg: "External wallet: ${res.walletName}");
  }
}

