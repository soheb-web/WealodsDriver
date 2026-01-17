/*


import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:delivery_rider_app/RiderScreen/mapRequestDetails.page.dart';
import 'package:delivery_rider_app/data/model/DeliveryResponseModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class RequestDetailsPage extends StatefulWidget {
  final IO.Socket? socket;
  final Data deliveryData;
  final String txtID;
  bool data;

   RequestDetailsPage({
    super.key,
    required this.deliveryData,
    required this.txtID,
    this.socket,
    required this.data,
  });

  @override
  State<RequestDetailsPage> createState() => _RequestDetailsPageState();
}

class _RequestDetailsPageState extends State<RequestDetailsPage> {
  @override
  Widget build(BuildContext context) {
    final String recipientName =
    '${widget.deliveryData.customer?.firstName ?? ''} ${widget.deliveryData.customer?.lastName ?? ''}'
        .trim();
    final int completedOrders = widget.deliveryData.customer?.completedOrderCount ?? 0;
    final double averageRating = (widget.deliveryData.customer?.averageRating ?? 0).toDouble();
    final String phone = widget.deliveryData.customer?.phone ?? 'Unknown';
    final String packageType =
    widget.deliveryData.packageDetails?.fragile == true ? 'Fragile Package' : 'Standard Package';

    // Multiple Drop Locations (1 to 3)
    final List<Dropoff> dropLocations = widget.deliveryData.dropoff ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        leading: Container(
          margin: EdgeInsets.only(left: 15.w),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF111111)),
          ),
        ),
        title: Text(
          "Delivery Details",
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF111111),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h),

              // Customer Info Row
              Row(
                children: [
                  Container(
                    width: 56.w,
                    height: 56.h,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFA8DADC),
                    ),
                    child: Center(
                      child: Text(
                        recipientName.isNotEmpty ? recipientName[0].toUpperCase() : "D",
                        style: GoogleFonts.inter(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF4F4F4F),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipientName.isEmpty ? 'Unknown Recipient' : recipientName,
                          style: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '$completedOrders Deliveries',
                          style: GoogleFonts.inter(fontSize: 13.sp, color: const Color(0xFF4F4F4F)),
                        ),
                        Row(
                          children: [
                            Row(
                              children: List.generate(
                                5,
                                    (i) => Icon(Icons.star, size: 16, color: i < 4 ? Colors.amber : Colors.grey[300]),
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              averageRating.toStringAsFixed(1),
                              style: GoogleFonts.inter(fontSize: 12.sp, color: const Color(0xFF4F4F4F)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: SvgPicture.asset("assets/SvgImage/bikess.svg", width: 28.w),
                  ),
                ],
              ),

              SizedBox(height: 24.h),

              // Pickup + Multiple Drop Locations
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vertical Line + Icons
                  Column(
                    children: [
                      const Icon(Icons.location_on_outlined, color: Color(0xFFDE4B65), size: 26),
                      SizedBox(height: 8.h),
                      ...List.generate(dropLocations.length, (_) {
                        return Column(
                          children: [
                            Container(width: 2, height: 40.h, color: const Color(0xFF28B877)),
                            const CircleAvatar(radius: 3, backgroundColor: Color(0xFF28B877)),
                            SizedBox(height: 8.h),
                          ],
                        );
                      }),
                      if (dropLocations.isNotEmpty)
                        const Icon(Icons.circle_outlined, color: Color(0xFF28B877), size: 20),
                    ],
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Pickup
                        _buildLocationTile("Pickup Location", widget.deliveryData.pickup?.name ?? "Unknown"),
                        SizedBox(height: 20.h),

                        // All Drop Locations
                        ...dropLocations.asMap().entries.map((entry) {
                          int index = entry.key + 1;
                          Dropoff drop = entry.value;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLocationTile("Drop Location $index", drop.name ?? "Unknown Address"),
                              if (index < dropLocations.length) SizedBox(height: 20.h),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24.h),

              // Details Grid
              Row(
                children: [
                  Expanded(child: _buildInfoCard("What you are sending", packageType)),
                  SizedBox(width: 16.w),
                  Expanded(child: _buildInfoCard("Recipient", recipientName.isEmpty ? "Unknown" : recipientName)),
                ],
              ),
              SizedBox(height: 16.h),
              _buildInfoCard("Recipient contact number", phone),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(child: _buildInfoCard("Payment Method", widget.deliveryData.paymentMethod ?? "Cash")),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: _buildInfoCard(
                      "Delivery Fee",
                      "₹${widget.deliveryData.userPayAmount ?? 0}",
                      valueColor: const Color(0xFF006970),
                      boldValue: true,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 40.h),

              widget.data.toString()=="false"?
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006970),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => MapRequestDetailsPage(
                          socket: widget.socket,
                          deliveryData: widget.deliveryData,
                          pickupLat: widget.deliveryData.pickup?.lat,
                          pickupLong: widget.deliveryData.pickup?.long,
                          dropLats: dropLocations.map((d) => d.lat ?? 0.0).toList(),
                          dropLons: dropLocations.map((d) => d.long ?? 0.0).toList(),
                          dropNames: dropLocations.map((d) => d.name ?? "Drop Location").toList(),
                          txtid: widget.txtID,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    "Accept Delivery",
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ):Text(""),

              SizedBox(height: 50.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationTile(String title, String address) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(fontSize: 12.sp, color: const Color(0xFF77869E)),
        ),
        SizedBox(height: 4.h),
        Text(
          address,
          style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w500, color: const Color(0xFF111111)),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String value, {Color? valueColor, bool boldValue = false}) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(fontSize: 12.sp, color: const Color(0xFF77869E)),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: boldValue ? FontWeight.w600 : FontWeight.w500,
              color: valueColor ?? const Color(0xFF111111),
            ),
          ),
        ],
      ),
    );
  }
}*/


import 'dart:developer';

import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:delivery_rider_app/RiderScreen/mapRequestDetails.page.dart';
import 'package:delivery_rider_app/data/model/DeliveryResponseModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'home.page.dart';

class RequestDetailsPage extends StatefulWidget {
  // final IO.Socket? socket;
  // final Data deliveryData;
  // final String txtID;
  // final bool data; // true = new request, false = already accepted
  //
  // const RequestDetailsPage({
  //   super.key,
  //   required this.deliveryData,
  //   required this.txtID,
  //   this.socket,
  //   this.data = true,
  // });

  final IO.Socket? socket;
  final Data deliveryData;
  final String txtID;
  bool data;

  RequestDetailsPage(

  {

  super

      .

  key,
  required this.deliveryData,
  required this.txtID,
  this.socket,
  required this.data,
});

  @override
  State<RequestDetailsPage> createState() => _RequestDetailsPageState();
}

class _RequestDetailsPageState extends State<RequestDetailsPage> {
  late final String recipientName;
  late final int completedOrders;
  late final double averageRating;
  late final String phone;
  late final String packageType;
  late final List<Dropoff> dropLocations;

  @override
  void initState() {
    super.initState();
    recipientName = '${widget.deliveryData.customer?.firstName ?? ''} ${widget.deliveryData.customer?.lastName ?? ''}'.trim();
    completedOrders = widget.deliveryData.customer?.completedOrderCount ?? 0;
    averageRating = (widget.deliveryData.customer?.averageRating ?? 0).toDouble();
    phone = widget.deliveryData.customer?.phone ?? 'Unknown';
    packageType = widget.deliveryData.packageDetails?.fragile == true ? 'Fragile Package' : 'Standard Package';
    dropLocations = widget.deliveryData.dropoff ?? [];

    final payload = {"deliveryId": widget.deliveryData.id};
    widget.socket!.emit("delivery:status_update", payload);
    widget.socket!.on("delivery:status_update", (data) {
      log("Socket Event: $data");

      if (data is Map && data["status"] == "arrived") {


        final waitingTime =
        data["waitingTime"]; // ← Ye minutes mein aata hai (2, 4, 7, 10 etc)
        final arrivedAt = data["arrivedAt"];
        int freeMinutes = 5; // fallback
        if (waitingTime != null) {
          freeMinutes = int.tryParse(waitingTime.toString()) ?? 5;
        }
        int elapsedSeconds = 0;

        if (arrivedAt != null) {
          final serverTimestamp = arrivedAt is num
              ? arrivedAt.toInt()
              : int.tryParse(arrivedAt.toString()) ?? 0;
          if (serverTimestamp > 0) {
            elapsedSeconds =
                ((DateTime.now().millisecondsSinceEpoch - serverTimestamp) /
                    1000)
                    .floor();
          }
        }
        // Step 3: Timer ko perfect sync kar do
        // _startOrSyncWaitingTimer(
        //   fromSeconds: elapsedSeconds,
        //   freeMinutes: freeMinutes,
        // );
        log(
          "Perfect Sync → Free: $freeMinutes min | Elapsed: $elapsedSeconds sec",
        );


        // ... your existing arrived logic
      }
      else if (data is Map && data["status"] == "cancelled_by_user") {
        Navigator.pushAndRemoveUntil(
          context,
          CupertinoPageRoute(
            builder: (_) => HomePage(
              0,
              forceSocketRefresh: true,
            ),
          ),
              (route) => route.isFirst,
        );
      }
    });


  }

  @override
  Widget build(BuildContext context) {
    final int baseFare = widget.deliveryData.userPayAmount ?? 0;
    final int extraCharge = widget.deliveryData.extraWaitingCharge ?? 0;
    final int totalEarnings = baseFare + extraCharge;
    final int freeMins = widget.deliveryData.freeWaitingTime ?? 0;
    final int extraMins = widget.deliveryData.extraWaitingMinutes ?? 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Delivery Request", style: GoogleFonts.inter(fontSize: 20.sp, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h),

              // Customer Info
              Row(
                children: [
                  CircleAvatar(
                    radius: 28.r,
                    backgroundColor: const Color(0xFFE3F2FD),
                    child: Text(
                      recipientName.isNotEmpty ? recipientName[0].toUpperCase() : "C",
                      style: GoogleFonts.inter(fontSize: 24.sp, fontWeight: FontWeight.bold, color: const Color(0xFF006970)),
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(recipientName.isEmpty ? "Customer" : recipientName,
                            style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                        Text("$completedOrders completed deliveries",
                            style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.grey.shade600)),
                        Row(
                          children: [
                            ...List.generate(5, (i) => Icon(Icons.star, size: 16.sp,
                                color: i < (averageRating ~/ 1) ? Colors.amber : Colors.grey.shade300)),
                            SizedBox(width: 6.w),
                            Text(averageRating.toStringAsFixed(1),
                                style: GoogleFonts.inter(fontSize: 13.sp)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SvgPicture.asset("assets/SvgImage/bikess.svg", width: 36.w),
                ],
              ),

              SizedBox(height: 28.h),

              // Pickup & Drop Locations
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Icon(Icons.radio_button_checked, color: Colors.red.shade400, size: 28.sp),
                      ...List.generate(dropLocations.length, (_) => Column(
                        children: [
                          Container(width: 2, height: 50.h, color: const Color(0xFF006970)),
                          Icon(Icons.location_on, color: const Color(0xFF006970), size: 24.sp),
                        ],
                      )),
                    ],
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _locationTile("Pickup", widget.deliveryData.pickup?.name ?? "Not available"),
                        SizedBox(height: 16.h),
                        ...dropLocations.asMap().entries.map((e) {
                          int idx = e.key + 1;
                          return Padding(
                            padding: EdgeInsets.only(bottom: idx == dropLocations.length ? 0 : 16.h),
                            child: _locationTile("Drop $idx", e.value.name ?? "Not available"),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 28.h),

              // Info Cards
              _infoCard("Package Type", packageType, icon: Icons.card_giftcard),
              SizedBox(height: 12.h),
              _infoCard("Contact Number", phone, icon: Icons.phone),
              SizedBox(height: 12.h),
              _infoCard("Payment Method", widget.deliveryData.paymentMethod?.toUpperCase() ?? "CASH", icon: Icons.payment),

              SizedBox(height: 28.h),

              // EARNING BREAKDOWN CARD (Main Attraction)
              if (!widget.data)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Your Earnings", style: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                      SizedBox(height: 16.h),

                      earningRow("Base Delivery Fare", "₹$baseFare"),
                      earningRow("Free Waiting Time", "$freeMins min", icon: Icons.access_time, color: Colors.green),

                      if (extraMins > 0) ...[
                        earningRow("Extra Waiting Time", "$extraMins min", icon: Icons.timer, color: Colors.orange),
                        earningRow("Extra Bonus", "+₹$extraCharge", icon: Icons.add_circle, color: Colors.green),
                      ] else
                        earningRow("Extra Waiting", "No extra charge", color: Colors.grey.shade600),

                      Divider(height: 32.h, thickness: 1.5, color: const Color(0xFF006970)),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Total Earnings", style: GoogleFonts.inter(fontSize: 20.sp, fontWeight: FontWeight.w600)),
                          Text("₹$totalEarnings",
                              style: GoogleFonts.inter(fontSize: 20.sp, fontWeight: FontWeight.bold, color: const Color(0xFF006970))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 30.h),

              // Accept Button
              if (widget.data)
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF006970),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                      elevation: 6,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => MapRequestDetailsPage(
                            socket: widget.socket,
                            deliveryData: widget.deliveryData,
                            pickupLat: widget.deliveryData.pickup?.lat,
                            pickupLong: widget.deliveryData.pickup?.long,
                            dropLats: dropLocations.map((d) => d.lat ?? 0.0).toList(),
                            dropLons: dropLocations.map((d) => d.long ?? 0.0).toList(),
                            dropNames: dropLocations.map((d) => d.name ?? "").toList(),
                            txtid: widget.txtID,
                          ),
                        ),
                      );
                    },
                    child: Text("Accept Delivery",
                        style: GoogleFonts.inter(fontSize: 18.sp, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),

              SizedBox(height: 60.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _locationTile(String title, String address) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.grey.shade600)),
        SizedBox(height: 4.h),
        Text(address, style: GoogleFonts.inter(fontSize: 14.5.sp, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _infoCard(String title, String value, {IconData? icon}) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          if (icon != null) Icon(icon, size: 20.sp, color: const Color(0xFF006970)),
          if (icon != null) SizedBox(width: 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.inter(fontSize: 12.5.sp, color: Colors.grey.shade600)),
              SizedBox(height: 4.h),
              Text(value, style: GoogleFonts.inter(fontSize: 15.sp, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget earningRow(String label, String value, {IconData? icon, Color? color}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 9.h),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20.sp, color: color ?? Colors.grey.shade700),
            SizedBox(width: 10.w),
          ],
          Text(label, style: GoogleFonts.inter(fontSize: 14.sp, color: Colors.grey.shade700)),
          const Spacer(),
          Text(value,
              style: GoogleFonts.inter(fontSize: 17.sp, fontWeight: FontWeight.w600, color: color ?? Colors.black87)),
        ],
      ),
    );
  }
}