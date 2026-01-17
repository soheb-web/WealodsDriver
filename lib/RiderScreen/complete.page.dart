import 'package:delivery_rider_app/RiderScreen/home.page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CompletePage extends StatefulWidget {
  final int previousAmount;           // Base amount driver को मिला
  final int freeWaitingTime;          // Free minutes
  final int extraWaitingMinutes;      // Extra minutes
  final int extraWaitingCharge;       // Extra charge driver को मिला

  const CompletePage({
    super.key,
    required this.previousAmount,
    required this.freeWaitingTime,
    required this.extraWaitingMinutes,
    required this.extraWaitingCharge,
  });

  @override
  State<CompletePage> createState() => _CompletePageState();
}

class _CompletePageState extends State<CompletePage> {
  GoogleMapController? _mapController;
  LatLng? _currentLatLng;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    Position pos = await Geolocator.getCurrentPosition();
    setState(() {
      _currentLatLng = LatLng(pos.latitude, pos.longitude);
    });
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_currentLatLng!, 15));
  }

  Widget _earningRow(String label, String value, {IconData? icon, Color? color}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20.sp, color: color),
            SizedBox(width: 8.w),
          ],
          Expanded(
            child: Text(label, style: GoogleFonts.inter(fontSize: 16.sp, color: Colors.grey.shade700)),
          ),
          Text(value,
              style: GoogleFonts.inter(fontSize: 17.sp, fontWeight: FontWeight.w600, color: color ?? Colors.black87)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int totalWaiting = widget.freeWaitingTime + widget.extraWaitingMinutes;
    final int totalEarning = widget.previousAmount + widget.extraWaitingCharge;

    return Scaffold(
      body: _currentLatLng == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [

          GoogleMap(
            initialCameraPosition: CameraPosition(target: _currentLatLng!, zoom: 15),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (c) => _mapController = c,
          ),

          // Back Button
          Positioned(
            top: 50.h,
            left: 16.w,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Color(0xFF1D3557)),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // Bottom Earning Card – Customer जैसा ही लुक
          Positioned(
            bottom: 30.h,
            left: 20.w,
            right: 20.w,
            child: Material(
              elevation: 15,
              borderRadius: BorderRadius.circular(20.r),
              child: Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: Color(0xFFE8F5E8),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.check_circle, color: Colors.green, size: 32.sp),
                        ),
                        SizedBox(width: 16.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Delivery Completed!",
                                style: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                            Text("₹$totalEarning earned",
                                style: GoogleFonts.inter(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF006970))),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: 24.h),

                    Text("Earning Details", style: GoogleFonts.inter(fontSize: 18.sp, fontWeight: FontWeight.w600)),

                    SizedBox(height: 16.h),

                    _earningRow("Base Delivery Amount", "₹${widget.previousAmount}"),
                    _earningRow("Free Waiting Time", "${widget.freeWaitingTime} min",
                        icon: Icons.access_time, color: Colors.green.shade600),
                    _earningRow("Total Waiting Time", "$totalWaiting min",
                        icon: Icons.timer, color: Colors.blue.shade700),

                    if (widget.extraWaitingMinutes > 0) ...[
                      _earningRow("Extra Waiting Time", "${widget.extraWaitingMinutes} min",
                          icon: Icons.warning_amber_rounded, color: Colors.orange),
                      _earningRow("Extra Waiting Bonus", "+₹${widget.extraWaitingCharge}",
                          icon: Icons.add_circle, color: Colors.green),
                    ] else
                      _earningRow("Extra Waiting", "No extra time", color: Colors.grey.shade600),

                    Divider(height: 36.h, thickness: 1.5, color: Color(0xFF006970)),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Total Earnings",
                            style: GoogleFonts.inter(fontSize: 18.sp, fontWeight: FontWeight.w600)),
                        Text("₹$totalEarning",
                            style: GoogleFonts.inter(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF006970))),
                      ],
                    ),

                    SizedBox(height: 24.h),

                    SizedBox(
                      width: double.infinity,
                      height: 45.h,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            CupertinoPageRoute(
                              builder: (_) =>  HomePage(0, forceSocketRefresh: true),
                            ),
                                (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF006970),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                        ),
                        child: Text("Go to Home",
                            style: GoogleFonts.inter(fontSize: 18.sp, fontWeight: FontWeight.w600, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}