import 'package:delivery_rider_app/data/controller/totalEarningController.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class EarningPage extends StatefulWidget {
  const EarningPage({super.key});

  @override
  State<EarningPage> createState() => _EarningPageState();
}

class _EarningPageState extends State<EarningPage> {
  DateTime startDate = DateTime.now();
  late DateTime endDate;

  void previousWeek() {
    setState(() {
      startDate = startDate.subtract(Duration(days: 7));
      endDate = endDate.subtract(Duration(days: 7));
    });
  }

  void nextWeek() {
    setState(() {
      startDate = startDate.add(Duration(days: 7));
      endDate = endDate.add(Duration(days: 7));
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    endDate = startDate.add(Duration(days: 7));
  }

  double currentBalance = 750.45;
  int deliveries = 38;
  Duration timeSpent = const Duration(hours: 42, minutes: 32);
  bool showDetails = false;
  final List<double> weeklyData = [5000, 8200, 6100, 4200, 6900, 7200, 3100];

  @override
  Widget build(BuildContext context) {
    final dateFormate = DateFormat("MMM d");
    final rangeTxt =
        "${dateFormate.format(startDate)} - ${dateFormate.format(endDate)}";
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFFFFFFFF),
        title: Padding(
          padding: EdgeInsets.only(left: 15.w),
          child: Text(
            "Earnings",
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              fontWeight: FontWeight.w400,
              color: Color(0xFF091425),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10.h),
            Divider(color: Color(0xFFCBCBCB), thickness: 1),
            SizedBox(height: 25.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: previousWeek,
                  child: CircleAvatar(
                    backgroundColor: Color(0xFFF3F7F5),
                    child: Icon(Icons.arrow_back, color: Color(0xFF006970)),
                  ),
                ),
                SizedBox(width: 30.w),
                Text(
                  rangeTxt,
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF636363),
                  ),
                ),
                SizedBox(width: 30.w),
                InkWell(
                  onTap: nextWeek,
                  child: CircleAvatar(
                    backgroundColor: Color(0xFFF3F7F5),
                    child: Icon(Icons.arrow_forward, color: Color(0xFF006970)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30.h),
            Container(
              margin: EdgeInsets.only(left: 24.w, right: 24.w),
              padding: EdgeInsets.only(
                left: 15.w,
                right: 15.w,
                top: 20.h,
                bottom: 20.h,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.r),
                color: Color(0xFFD1E5E6),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Current Balance (₹)",
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF111111),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        "As at ${DateFormat("MMM d").format(startDate.add(Duration(days: 4)))}",
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF111111),
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  Text(
                    "₹${currentBalance.toStringAsFixed(2)}",
                    style: GoogleFonts.inter(
                      fontSize: 30.sp,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF111111),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            Center(
              child: Text(
                "Next Payout due on ${DateFormat("MMM d, yyy").format(endDate)}",
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF535353),
                ),
              ),
            ),
            SizedBox(height: 40.h),
            Padding(
              padding: EdgeInsetsGeometry.only(left: 24.w, right: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Time",
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF000000),
                        ),
                      ),
                      Text(
                        "42 Hours 32 Minutes",
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF000000),
                        ),
                      ),
                    ],
                  ),
                  Divider(color: Color(0xFFA2A1A1), thickness: 1),
                  SizedBox(height: 50.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Deliveries",
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF000000),
                        ),
                      ),
                      Text(
                        "38",
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF000000),
                        ),
                      ),
                    ],
                  ),
                  Divider(color: Color(0xFFA2A1A1), thickness: 1),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            if (showDetails) ...[
              Container(
                margin: EdgeInsets.only(left: 24.w, right: 24.w),
                height: 220,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 35,
                          getTitlesWidget: (value, meta) {
                            final days = [
                              "Mon",
                              "Tue",
                              "Wed",
                              "Thu",
                              "Fri",
                              "Sat",
                              "Sun",
                            ];
                            final dayIndex = value.toInt();
                            if (dayIndex >= 0 && dayIndex < days.length) {
                              final day = startDate.add(
                                Duration(days: dayIndex),
                              );
                              return Text(
                                "${DateFormat("d").format(day)}\n${days[dayIndex]}",
                                style: TextStyle(fontSize: 10),
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true),
                        sideTitleAlignment: SideTitleAlignment.outside,
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: 6,
                    minY: 0,
                    maxY: 9000,
                    lineBarsData: [
                      // LineChartBarData(
                      //   spots: [
                      //     FlSpot(0, 6),
                      //     FlSpot(0.6, 4),
                      //     FlSpot(1, 7),
                      //     FlSpot(3.2, 9),
                      //     FlSpot(3, 0),
                      //     FlSpot(0, 6),
                      //     FlSpot(0, 6),
                      //   ],
                      //   barWidth: 2,
                      //   dotData: FlDotData(show: true),
                      // ),
                      LineChartBarData(
                        spots: weeklyData
                            .asMap()
                            .entries
                            .map((e) => FlSpot(e.key.toDouble(), e.value))
                            .toList(),
                        isCurved: true,
                        barWidth: 2,
                        dotData: FlDotData(show: true),
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _infoCard(
                    icon: Icons.access_time,
                    title: "Time",
                    value:
                        "${timeSpent.inHours}h ${timeSpent.inMinutes.remainder(60)}m",
                  ),
                  _infoCard(
                    icon: Icons.local_shipping,
                    title: "Deliveries",
                    value: deliveries.toString(),
                  ),
                ],
              ),
            ],
            SizedBox(height: 35.h),
            Center(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    showDetails = !showDetails;
                  });
                },
                child: Text(
                  showDetails ? "Hide Details" : "See Details",
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF091425),
                    decoration: TextDecoration.underline,
                    decorationColor: Color(0xFF091425),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F6F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF006970),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
