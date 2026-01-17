import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Assuming you're using flutter_riverpod
import 'package:intl/intl.dart';
import '../data/controller/GetTransactionHistoryController.dart';
import '../data/controller/getProfileController.dart'; // Add this package for date formatting: intl: ^0.19.0 (pubspec.yaml mein add karo)




class TransactionHistoryPage extends ConsumerWidget { // Changed to ConsumerWidget for riverpod
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
        child: transactionAsync.when(
          data: (response) {
            final transactions = response.data ?? [];

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
                final isCredit = (tx.txType?.toLowerCase() == 'credit' ||
                    (tx.amount ?? 0) > 0); // Adjust logic based on your txType

                final amount = tx.amount ?? 0;
                final formattedAmount = NumberFormat.currency(
                  locale: 'en_IN',
                  symbol: '₹',
                  decimalDigits: 0,
                ).format(amount.abs());

                final date = tx.createdAt != null
                    ? DateTime.fromMillisecondsSinceEpoch(tx.createdAt!)
                    : DateTime.now();
                final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(date);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: isCredit ? Colors.green[100] : Colors.red[100],
                      radius: 28,
                      child: Icon(
                        isCredit ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                        color: isCredit ? Colors.green[800] : Colors.red[800],
                        size: 28,
                      ),
                    ),
                    title: Text(
                      '${isCredit ? '+' : '-'} $formattedAmount',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isCredit ? Colors.green[800] : Colors.red[800],
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          tx.txType?.toUpperCase() ?? 'Transaction',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formattedDate,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        if (tx.razorpayOrderId != null && tx.razorpayOrderId!.isNotEmpty)
                          Text(
                            'Order: ${tx.razorpayOrderId}',
                            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                          ),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: tx.status?.toLowerCase() == 'success'
                            ? Colors.green[50]
                            : Colors.orange[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tx.status?.toUpperCase() ?? 'PENDING',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: tx.status?.toLowerCase() == 'success'
                              ? Colors.green[800]
                              : Colors.orange[800],
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
                const SizedBox(height: 8),
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
}