import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../data/controller/GetTransactionHistoryController.dart';
import '../data/controller/getProfileController.dart';
import 'QrCode.dart';

// Make sure this provider exists in your controllers file
// final getWalletTransactionsController = ...

class QrTransactionHistory extends ConsumerWidget {
  const QrTransactionHistory({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionAsync = ref.watch(getWalletTransactionsController);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Wallet Transaction History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF006970),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Optional: Button or card to go to QR scanner
          // Padding(
          //   padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          //   child: Material(
          //     color: const Color(0xFF006970),
          //     borderRadius: BorderRadius.circular(12),
          //     child: InkWell(
          //       borderRadius: BorderRadius.circular(12),
          //       onTap: () {
          //         // TODO: Navigate to QR Scanner screen
          //         Navigator.push(context, MaterialPageRoute(builder: (_) =>  QRGeneratorScreen()));
          //         ScaffoldMessenger.of(context).showSnackBar(
          //           const SnackBar(content: Text('Open QR Scanner (implement navigation)')),
          //         );
          //       },
          //       child: Padding(
          //         padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          //         child: Row(
          //           mainAxisAlignment: MainAxisAlignment.center,
          //           children: const [
          //             Icon(Icons.qr_code_scanner, color: Colors.white, size: 28),
          //             SizedBox(width: 12),
          //             Text(
          //               'QR Code',
          //               style: TextStyle(
          //                 color: Colors.white,
          //                 fontSize: 16,
          //                 fontWeight: FontWeight.w600,
          //               ),
          //             ),
          //           ],
          //         ),
          //       ),
          //     ),
          //   ),
          // ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.refresh(getWalletTransactionsController.future),
              color: const Color(0xFF006970),
              child: transactionAsync.when(
                data: (response) {
                  final transactions = response.data?.data ?? [];

                  if (transactions.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No transactions yet',
                            style: TextStyle(fontSize: 20, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final tx = transactions[index];

                      final isCredit = (tx.txType?.toLowerCase() == 'credit') ||
                          (tx.amount ?? 0) > 0;

                      final amount = tx.amount ?? 0;
                      final displayAmount = amount.abs();
                      final formattedAmount = NumberFormat.currency(
                        locale: 'en_IN',
                        symbol: '₹',
                        decimalDigits: 0,
                      ).format(displayAmount);

                      final date = tx.createdAt != null
                          ? DateTime.fromMillisecondsSinceEpoch(tx.createdAt!)
                          : DateTime.now();
                      final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(date);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 1.5,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: isCredit ? Colors.green[50] : Colors.red[50],
                            radius: 28,
                            child: Icon(
                              isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                              color: isCredit ? Colors.green[700] : Colors.red[700],
                              size: 28,
                            ),
                          ),
                          title: Text(
                            '${isCredit ? '+' : '-'} $formattedAmount',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isCredit ?  Colors.green[800]:Colors.red[800]
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                (tx.txType ?? 'Transaction').toUpperCase(),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                formattedDate,
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getStatusColor(tx.status?.toLowerCase() ?? ''),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              (tx.status ?? 'PENDING').toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _getStatusTextColor(tx.status?.toLowerCase() ?? ''),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF006970)),
                  ),
                ),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 60, color: Colors.red),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'Error loading transactions\n$error',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => ref.refresh(getWalletTransactionsController),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF006970),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'success':
        return Colors.green[50]!;
      case 'failed':
        return Colors.red[50]!;
      default:
        return Colors.orange[50]!;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'success':
        return Colors.green[800]!;
      case 'failed':
        return Colors.red[800]!;
      default:
        return Colors.orange[800]!;
    }
  }
}
