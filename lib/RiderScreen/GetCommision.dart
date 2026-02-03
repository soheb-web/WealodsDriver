// ... imports remain the same

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../data/controller/GetTransactionHistoryController.dart';

class GetCommissionPage extends ConsumerWidget {
  const GetCommissionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commissionAsync = ref.watch(getCommissionController);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'My Commission',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
        backgroundColor: const Color(0xFF006970),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(getCommissionController.future),
        color: const Color(0xFF006970),
        child: commissionAsync.when(
          data: (response) {
            if (response.error == true || response.data == null) {
              return _buildEmptyOrErrorState(
                icon: Icons.error_outline_rounded,
                title: 'Something went wrong',
                subtitle: response.message ?? 'Please try again later',
                ref: ref,
              );
            }

            final data = response.data!;

            // Use the correct fields now
            final commissionPercent = data.commission ?? 0;
            final TotalcommissionPercent = data.totalCommission ?? 0;
            final totalEarned = data.totalCommission ?? 0;
            // final pendingEarning = data.earning ?? 0; // if you want to show later

            final formattedTotal = NumberFormat.currency(
              locale: 'en_IN',
              symbol: '₹',
              decimalDigits: 0,
            ).format(totalEarned);

            final percentDisplay = commissionPercent > 0
                ? '$commissionPercent%'
                : '—%';

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    // Main commission card
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 420),
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF006970), Color(0xFF00838F)],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.teal.withOpacity(0.35),
                            blurRadius: 20,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.18),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.percent_rounded,
                                  color: Colors.white,
                                  size: 42,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                percentDisplay,
                                style: const TextStyle(
                                  fontSize: 52,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Your Commission Rate',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Divider(
                            color: Colors.white24,
                            height: 40,
                            thickness: 1.5,
                            indent: 40,
                            endIndent: 40,
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Total commission',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white60),
                              ),
                              SizedBox(width: 20.w,),
                              Text(
                              '₹${TotalcommissionPercent.toString()}',
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const Divider(
                            color: Colors.white24,
                            height: 40,
                            thickness: 1.5,
                            indent: 40,
                            endIndent: 40,
                          ),

                          SizedBox(height: 20.h,),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              const Text(
                                'Total Earned',
                                style: TextStyle(
                                    fontSize: 22, color: Colors.white70),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                formattedTotal,
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                        ],
                      ),
                    ),

                    
                    
                    const SizedBox(height: 40),

                    // Info box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline_rounded,
                              color: Color(0xFF006970)),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Commission is calculated on successful property transactions',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 60),
                  ],
                ),
              ),
            );
          },
          loading: () =>
          const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF006970)),
              strokeWidth: 5,
            ),
          ),
          error: (err, stack) =>
              _buildEmptyOrErrorState(
                icon: Icons.error_outline_rounded,
                title: 'Failed to load commission',
                subtitle: err.toString(),
                isError: true,
                ref: ref,
              ),
        ),
      ),
    );
  }

  Widget _buildEmptyOrErrorState({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isError = false,
    required WidgetRef ref,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 90,
              color: isError ? Colors.red[400] : Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: isError ? Colors.red[800] : Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: TextStyle(fontSize: 15, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () => ref.refresh(getCommissionController.future),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF006970),
                side: const BorderSide(color: Color(0xFF006970)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );

// _buildEmptyOrErrorState remains unchanged...
  }
}












