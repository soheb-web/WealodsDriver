
import 'package:delivery_rider_app/data/model/DeliveryResponseModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailPage extends StatefulWidget {
  final Data deliveryData;
  final String txtID;

  const DetailPage({
    super.key,
    required this.deliveryData,
    required this.txtID,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  List<Dropoff> _getDropLocations() {
    final drops = <Dropoff>[];
    if (widget.deliveryData.dropoff == null) return drops;
    if (widget.deliveryData.dropoff is Dropoff) {
      drops.add(widget.deliveryData.dropoff as Dropoff);
    } else if (widget.deliveryData.dropoff is List) {
      final list = widget.deliveryData.dropoff as List;
      for (var item in list.take(3)) {
        if (item is Dropoff) {
          drops.add(item);
        } else if (item is Map<String, dynamic>) {
          drops.add(Dropoff(
            name: item['name'] ?? "Drop Location",
            lat: (item['lat'] ?? 0.0).toDouble(),
            long: (item['long'] ?? 0.0).toDouble(),
          ));
        }
      }
    }

    // Minimum 1 drop guaranteed
    if (drops.isEmpty) {
      drops.add(Dropoff(name: "Drop Location", lat: 0.0, long: 0.0));
    }

    return drops;
  }

  @override
  Widget build(BuildContext context) {
    final customer = widget.deliveryData.customer;
    final recipientName = '${customer?.firstName ?? ''} ${customer?.lastName ?? ''}'.trim();
    final completedOrders = customer?.completedOrderCount ?? 0;
    final averageRating = (customer?.averageRating ?? 4.1).toDouble();
    final phone = customer?.phone ?? 'Unknown';
    final packageType = widget.deliveryData.packageDetails?.fragile == true ? 'Fragile Package' : 'Standard Package';
    final pickupLocation = widget.deliveryData.pickup?.name ?? "Unknown Pickup";
    final dropLocations = _getDropLocations();

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        leading: Padding(
          padding: EdgeInsets.only(left: 15.w),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF111111)),
          ),
        ),
        title: Text(
          "Delivery Details",
          style: GoogleFonts.inter(fontSize: 20.sp, fontWeight: FontWeight.w600, color: const Color(0xFF111111)),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h),

              Row(
                children: [
                  CircleAvatar(
                    radius: 28.r,
                    backgroundColor: const Color(0xFFA8DADC),
                    child: Text(
                      recipientName.isNotEmpty ? recipientName[0].toUpperCase() : "D",
                      style: GoogleFonts.inter(fontSize: 28.sp, fontWeight: FontWeight.w600, color: const Color(0xFF4F4F4F)),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipientName.isEmpty ? 'Unknown Recipient' : recipientName,
                          style: GoogleFonts.inter(fontSize: 17.sp, fontWeight: FontWeight.w600),
                        ),
                        Text('$completedOrders Deliveries', style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.grey[600])),
                        Row(
                          children: [
                            ...List.generate(5, (i) => Icon(Icons.star, size: 16.sp, color: i < averageRating ? Colors.amber : Colors.grey)),
                            SizedBox(width: 4.w),
                            Text(averageRating.toStringAsFixed(1), style: GoogleFonts.inter(fontSize: 13.sp)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(color: const Color(0xFFF7F7F7), borderRadius: BorderRadius.circular(8.r)),
                    child: SvgPicture.asset("assets/SvgImage/bikess.svg", width: 28.w),
                  ),
                ],
              ),

              SizedBox(height: 24.h),

              // Route: Pickup + Multiple Drops
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vertical Line + Icons
                  Column(
                    children: [
                      Icon(Icons.location_on, color: const Color(0xFFDE4B65), size: 26.sp),
                      ...List.generate(dropLocations.length, (_) => Column(
                        children: [
                          SizedBox(height: 8.h),
                          Container(width: 2, height: 40.h, color: const Color(0xFF28B877)),
                          SizedBox(height: 8.h),
                          CircleAvatar(radius: 4, backgroundColor: const Color(0xFF28B877)),
                        ],
                      )),
                      if (dropLocations.length < 3)
                        ...List.generate(3 - dropLocations.length, (_) => SizedBox(height: 56.h)),
                    ],
                  ),

                  SizedBox(width: 16.w),

                  // Locations Text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLocationRow("Pickup Location", pickupLocation, isPickup: true),
                        ...dropLocations.asMap().entries.map((entry) {
                          int idx = entry.key + 1;
                          return Padding(
                            padding: EdgeInsets.only(top: 16.h),
                            child: _buildLocationRow("Drop $idx Location", entry.value.name!),
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
                  Expanded(child: _buildInfoCard("Package Type", packageType)),
                  SizedBox(width: 20.w),
                  Expanded(child: _buildInfoCard("Recipient", recipientName.isEmpty ? "Unknown" : recipientName)),
                ],
              ),
              SizedBox(height: 16.h),

              _buildInfoCard("Contact Number", phone),
              SizedBox(height: 16.h),

              Row(
                children: [
                  Expanded(child: _buildInfoCard("Payment Method", widget.deliveryData.paymentMethod ?? "COD")),
                  SizedBox(width: 20.w),
                  Expanded(child: _buildInfoCard("Earning", "₹${widget.deliveryData.userPayAmount ?? 0}")),
                ],
              ),

              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationRow(String title, String address, {bool isPickup = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(fontSize: 12.sp, fontWeight: FontWeight.w400, color: const Color(0xFF77869E)),
        ),
        SizedBox(height: 4.h),
        Text(
          address,
          style: GoogleFonts.inter(fontSize: 15.sp, fontWeight: FontWeight.w600, color: const Color(0xFF111111)),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.grey[600])),
          SizedBox(height: 4.h),
          Text(value, style: GoogleFonts.inter(fontSize: 15.sp, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}