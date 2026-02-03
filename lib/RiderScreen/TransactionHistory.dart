import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/controller/GetTransactionHistoryController.dart';
import '../data/model/GetTransactionListModel.dart'; // ← yeh file jo maine last mein di thi

class TransactionHistoryPage extends ConsumerWidget {
  const TransactionHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionAsync = ref.watch(getTransactionController);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Transaction History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF006970),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(getTransactionController.future),
        color: const Color(0xFF006970),
        child:

        transactionAsync.when(
          data: (response) {
            final allTx = response.transactions; // ← yeh helper use kar rahe hain

            if (allTx!.isEmpty) {
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
              itemCount: allTx.length,
              itemBuilder: (context, index) {
                final tx = allTx[index];

                final isCredit = _isCreditTransaction(tx);

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
                final formattedDate =
                DateFormat('dd MMM yyyy, hh:mm a').format(date);

                final statusColor = _getStatusColor(tx.status);
                final statusBg = _getStatusBackground(tx.status);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 1.5,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    leading: CircleAvatar(
                      backgroundColor:
                      isCredit ? Colors.green[50] : Colors.red[50],
                      radius: 28,
                      child: Icon(
                        isCredit
                            ? Icons.arrow_circle_up_rounded
                            : Icons.arrow_circle_down_rounded,
                        color: isCredit ? Colors.green[700] : Colors.red[700],
                        size: 32,
                      ),
                    ),
                    title: Text(
                      '${isCredit ? '+' : '-'} $formattedAmount',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: isCredit ? Colors.green[800] : Colors.red[800],
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          _getDisplayType(tx.txType),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formattedDate,
                          style:
                          TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        if (tx.razorpayOrderId?.isNotEmpty ?? false)
                          Text(
                            'Order: ${tx.razorpayOrderId}',
                            style: TextStyle(
                                fontSize: 11.5, color: Colors.grey[500]),
                          ),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getStatusText(tx.status),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
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
                Text('Error: $error'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => ref.refresh(getTransactionController),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006970),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────
  // Helper functions (txType aur status String hain ab)
  // ────────────────────────────────────────────────

  bool _isCreditTransaction(Transaction tx) {
    final type = tx.txType?.toLowerCase() ?? '';
    if (type == 'deposit') return true;
    if (type == 'withdraw') return false;
    if (type == 'wallet_transfer') {
      // receiver ke perspective se mostly credit
      return true;
    }
    return (tx.amount ?? 0) > 0;
  }

  String _getDisplayType(String? txType) {
    final type = txType?.toLowerCase() ?? '';
    switch (type) {
      case 'deposit':
        return 'Deposit';
      case 'withdraw':
        return 'Withdrawal';
      case 'wallet_transfer':
        return 'Wallet Transfer';
      default:
        return 'Transaction';
    }
  }

  String _getStatusText(String? status) {
    final s = status?.toLowerCase() ?? '';
    switch (s) {
      case 'completed':
        return 'COMPLETED';
      case 'pending':
        return 'PENDING';
      default:
        return 'UNKNOWN';
    }
  }

  Color _getStatusColor(String? status) {
    final s = status?.toLowerCase() ?? '';
    switch (s) {
      case 'completed':
        return Colors.green[800]!;
      case 'pending':
        return Colors.orange[800]!;
      default:
        return Colors.grey[800]!;
    }
  }

  Color _getStatusBackground(String? status) {
    final s = status?.toLowerCase() ?? '';
    switch (s) {
      case 'completed':
        return Colors.green[50]!;
      case 'pending':
        return Colors.orange[50]!;
      default:
        return Colors.grey[100]!;
    }
  }
}