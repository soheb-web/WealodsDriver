// import 'package:delivery_rider_app/data/controller/totalEarningController.dart';
// import 'package:delivery_rider_app/data/model/totalEarningResModel.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:google_fonts/google_fonts.dart';

// class TotalEarningPage extends ConsumerWidget {
//   const TotalEarningPage({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final amountAsync = ref.watch(totalEarningProvider);
//     final dashAsync = ref.watch(totalEarningDashbordProvider);
//     final selectedType = ref.watch(earningTypeProvider);

//     return Scaffold(
//       backgroundColor: const Color(0xFFF4F6F8),
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.white,
//         leading: const BackButton(color: Colors.black),
//         centerTitle: true,
//         title: Text(
//           "Earnings",
//           style: GoogleFonts.inter(
//             color: Colors.black,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16.w),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             /// ================= BALANCE CARD =================
//             amountAsync.when(
//               loading: () => const Center(child: CircularProgressIndicator()),
//               error: (e, _) => Text("Error: $e"),
//               data: (res) {
//                 final amount = res.data ?? 0;
//                 return Container(
//                   width: double.infinity,
//                   padding: EdgeInsets.all(20.w),
//                   decoration: BoxDecoration(
//                     gradient: const LinearGradient(
//                       colors: [Color(0xFF0F2027), Color(0xFF2C5364)],
//                     ),
//                     borderRadius: BorderRadius.circular(18.r),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "Current Balance",
//                         style: TextStyle(
//                           color: Colors.white70,
//                           fontSize: 14.sp,
//                         ),
//                       ),
//                       SizedBox(height: 10.h),
//                       Text(
//                         "₹ $amount",
//                         style: TextStyle(
//                           fontSize: 34.sp,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),

//             SizedBox(height: 22.h),

//             /// ================= FILTER BUTTONS =================
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: ["day", "week", "year"].map((type) {
//                 final isSelected = selectedType == type;
//                 return GestureDetector(
//                   onTap: () {
//                     ref.read(earningTypeProvider.notifier).state = type;
//                     ref.read(earningDashbordProvider.notifier).state = type;
//                   },
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 250),
//                     padding: EdgeInsets.symmetric(
//                       horizontal: 22.w,
//                       vertical: 10.h,
//                     ),
//                     decoration: BoxDecoration(
//                       color: isSelected ? Colors.black : Colors.white,
//                       borderRadius: BorderRadius.circular(30.r),
//                       boxShadow: [
//                         if (isSelected)
//                           BoxShadow(color: Colors.black26, blurRadius: 8.r),
//                       ],
//                       border: Border.all(color: Colors.black12),
//                     ),
//                     child: Text(
//                       type.toUpperCase(),
//                       style: TextStyle(
//                         color: isSelected ? Colors.white : Colors.black,
//                         fontWeight: FontWeight.w600,
//                         fontSize: 12.sp,
//                       ),
//                     ),
//                   ),
//                 );
//               }).toList(),
//             ),

//             SizedBox(height: 28.h),

//             /// ================= DASHBOARD & GRAPH =================
//             dashAsync.when(
//               loading: () => const Center(child: CircularProgressIndicator()),
//               error: (e, _) => Text("Error: $e"),
//               data: (res) {
//                 final data = res.data;
//                 final totalTime = data?.totalTime ?? "0h";
//                 final deliveries = data?.totalDeliveries ?? 0;
//                 final graphData = data?.graph ?? [];

//                 // Logic for Graph Normalization (0.0 to 1.0)
//                 final List<double> rawEarnings = graphData
//                     .map((e) => (e.earning ?? 0).toDouble())
//                     .toList();
//                 final List<String> labels = graphData
//                     .map((e) => e.label ?? "")
//                     .toList();

//                 double maxEarning = rawEarnings.isEmpty
//                     ? 1.0
//                     : rawEarnings.reduce((a, b) => a > b ? a : b);
//                 if (maxEarning == 0) maxEarning = 1.0;

//                 final List<double> normalizedValues = rawEarnings
//                     .map((v) => v / maxEarning)
//                     .toList();

//                 return Column(
//                   children: [
//                     WeeklyPillGraph(
//                       values: normalizedValues,
//                       rawValues: rawEarnings,
//                       labels: labels,
//                       type: selectedType,
//                     ),
//                     SizedBox(height: 28.h),

//                     /// ================= STATS CARDS =================
//                     Row(
//                       children: [
//                         _statCard(Icons.access_time, "Time", totalTime),
//                         SizedBox(width: 14.w),
//                         _statCard(
//                           Icons.local_shipping,
//                           "Deliveries",
//                           deliveries.toString(),
//                         ),
//                       ],
//                     ),
//                   ],
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _statCard(IconData icon, String title, String value) {
//     return Expanded(
//       child: Container(
//         padding: EdgeInsets.all(18.w),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16.r),
//           boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6.r)],
//         ),
//         child: Column(
//           children: [
//             Icon(icon, color: Colors.teal, size: 28.sp),
//             SizedBox(height: 10.h),
//             Text(
//               title,
//               style: TextStyle(color: Colors.black54, fontSize: 12.sp),
//             ),
//             SizedBox(height: 6.h),
//             Text(
//               value,
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class WeeklyPillGraph extends StatelessWidget {
//   final List<double> values;
//   final List<double> rawValues;
//   final List<String> labels;
//   final String type;

//   const WeeklyPillGraph({
//     super.key,
//     required this.values,
//     required this.rawValues,
//     required this.labels,
//     required this.type,
//   });

//   @override
//   Widget build(BuildContext context) {
//     String title = type == "day"
//         ? "Daily Stats"
//         : type == "week"
//         ? "Weekly Earnings"
//         : "Yearly Report";

//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(18.w),
//       decoration: BoxDecoration(
//         color: const Color(0xFF63F2C2),
//         borderRadius: BorderRadius.circular(20.r),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
//           ),
//           Text(
//             "Earnings overview per $type",
//             style: TextStyle(fontSize: 12.sp, color: Colors.black54),
//           ),
//           SizedBox(height: 20.h),
//           SizedBox(
//             height: 180.h,
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               physics: const BouncingScrollPhysics(),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: List.generate(values.length, (index) {
//                   return Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 10.w),
//                     child: _PillBar(
//                       value: values[index],
//                       amount: rawValues[index].toInt().toString(),
//                       label: labels[index],
//                       color: index % 2 == 0 ? Colors.black : Colors.white,
//                     ),
//                   );
//                 }),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _PillBar extends StatelessWidget {
//   final double value;
//   final String amount;
//   final Color color;
//   final String label;

//   const _PillBar({
//     required this.value,
//     required this.amount,
//     required this.color,
//     required this.label,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.end,
//       children: [
//         Text(
//           "₹$amount",
//           style: TextStyle(
//             fontSize: 9.sp,
//             fontWeight: FontWeight.bold,
//             color: Colors.black87,
//           ),
//         ),
//         SizedBox(height: 6.h),
//         Expanded(
//           child: Stack(
//             alignment: Alignment.bottomCenter,
//             children: [
//               Container(
//                 width: 20.w,
//                 decoration: BoxDecoration(
//                   color: Colors.black12,
//                   borderRadius: BorderRadius.circular(10.r),
//                 ),
//               ),
//               FractionallySizedBox(
//                 heightFactor: value.clamp(0.05, 1.0),
//                 child: Container(
//                   width: 20.w,
//                   decoration: BoxDecoration(
//                     color: color,
//                     borderRadius: BorderRadius.circular(10.r),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         SizedBox(height: 10.h),
//         Text(
//           label,
//           style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600),
//         ),
//       ],
//     );
//   }
// }

import 'package:delivery_rider_app/data/controller/totalEarningController.dart';
import 'package:delivery_rider_app/data/model/totalEarningResModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class TotalEarningPage extends ConsumerStatefulWidget {
  const TotalEarningPage({super.key});

  // Aapka Primary Color
  static const Color primaryColor = Color(0xFF006970);

  @override
  ConsumerState<TotalEarningPage> createState() => _TotalEarningPageState();
}

class _TotalEarningPageState extends ConsumerState<TotalEarningPage> {
 

  @override
  Widget build(BuildContext context) {
    final amountAsync = ref.watch(totalEarningProvider);
    final dashAsync = ref.watch(totalEarningDashbordProvider);
    final selectedType = ref.watch(earningTypeProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB), // Soft background
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          "Earnings",
          style: GoogleFonts.inter(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 18.sp,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ================= BALANCE CARD (Primary Gradient) =================
            amountAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: TotalEarningPage.primaryColor,
                ),
              ),
              error: (e, _) => Text("Error: $e"),
              data: (res) {
                final amount = res.data ?? 0;
                return Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        TotalEarningPage.primaryColor,
                        Color(0xFF004D52),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24.r),
                    boxShadow: [
                      BoxShadow(
                        color: TotalEarningPage.primaryColor.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Current Balance",
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 14.sp,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "₹ $amount",
                        style: GoogleFonts.inter(
                          fontSize: 36.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            SizedBox(height: 24.h),

            /// ================= FILTER BUTTONS (Themed) =================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ["day", "week", "year"].map((type) {
                final isSelected = selectedType == type;
                return GestureDetector(
                  onTap: () {
                    ref.read(earningTypeProvider.notifier).state = type;
                    ref.read(earningDashbordProvider.notifier).state = type;
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? TotalEarningPage.primaryColor
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isSelected
                            ? TotalEarningPage.primaryColor
                            : Colors.black12,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: TotalEarningPage.primaryColor
                                    .withOpacity(0.2),
                                blurRadius: 8,
                              ),
                            ]
                          : [],
                    ),
                    child: Text(
                      type.toUpperCase(),
                      style: GoogleFonts.inter(
                        color: isSelected ? Colors.white : Colors.black54,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: 28.h),

            /// ================= GRAPH CONTAINER (Themed) =================
            dashAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: TotalEarningPage.primaryColor,
                ),
              ),
              error: (e, _) => Text("Error: $e"),
              data: (res) {
                final data = res.data;
                final totalTime = data?.totalTime ?? "0h";
                final deliveries = data?.totalDeliveries ?? 0;
                final graphData = data?.graph ?? [];

                final List<double> rawEarnings = graphData
                    .map((e) => (e.earning ?? 0).toDouble())
                    .toList();
                final List<String> labels = graphData
                    .map((e) => e.label ?? "")
                    .toList();

                double maxEarning = rawEarnings.isEmpty
                    ? 1.0
                    : rawEarnings.reduce((a, b) => a > b ? a : b);
                if (maxEarning == 0) maxEarning = 1.0;

                final List<double> normalizedValues = rawEarnings
                    .map((v) => v / maxEarning)
                    .toList();

                return Column(
                  children: [
                    WeeklyPillGraph(
                      values: normalizedValues,
                      rawValues: rawEarnings,
                      labels: labels,
                      type: selectedType,
                      primaryColor: TotalEarningPage.primaryColor,
                    ),
                    SizedBox(height: 24.h),

                    /// ================= STATS CARDS (Themed Icon) =================
                    Row(
                      children: [
                        _statCard(
                          Icons.timer_outlined,
                          "Total Time",
                          totalTime,
                        ),
                        SizedBox(width: 16.w),
                        _statCard(
                          Icons.local_shipping_outlined,
                          "Deliveries",
                          deliveries.toString(),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(IconData icon, String title, String value) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: TotalEarningPage.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: TotalEarningPage.primaryColor,
                size: 24.sp,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              style: GoogleFonts.inter(color: Colors.black54, fontSize: 12.sp),
            ),
            SizedBox(height: 4.h),
            Text(
              value,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 16.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WeeklyPillGraph extends StatelessWidget {
  final List<double> values;
  final List<double> rawValues;
  final List<String> labels;
  final String type;
  final Color primaryColor;

  const WeeklyPillGraph({
    super.key,
    required this.values,
    required this.rawValues,
    required this.labels,
    required this.type,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type == "year" ? "Annual Earnings" : "Performance Graph",
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    "Data filtered by $type",
                    style: TextStyle(fontSize: 11.sp, color: Colors.black45),
                  ),
                ],
              ),
              Icon(
                Icons.bar_chart_rounded,
                color: primaryColor.withOpacity(0.5),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          SizedBox(
            height: 180.h,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(values.length, (index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: _PillBar(
                      value: values[index],
                      amount: rawValues[index].toInt().toString(),
                      label: labels[index],
                      // Alternating colors for better UI
                      color: index % 2 == 0
                          ? primaryColor
                          : primaryColor.withOpacity(0.6),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PillBar extends StatelessWidget {
  final double value;
  final String amount;
  final Color color;
  final String label;

  const _PillBar({
    required this.value,
    required this.amount,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          "₹$amount",
          style: GoogleFonts.inter(
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        Expanded(
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                width: 18.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F2F5),
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
              FractionallySizedBox(
                heightFactor: value.clamp(0.08, 1.0),
                child: Container(
                  width: 18.w,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}
