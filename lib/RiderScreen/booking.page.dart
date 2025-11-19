/*

import 'package:delivery_rider_app/RiderScreen/MapLiveScreen.dart';
import 'package:delivery_rider_app/RiderScreen/requestDetails.page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:delivery_rider_app/config/utils/pretty.dio.dart'; // Assuming this provides callDio()
import 'package:delivery_rider_app/config/network/api.state.dart'; // For APIStateNetwork
import 'package:delivery_rider_app/data/model/DeliveryHistoryResponseModel.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/model/DeliveryHistoryDataModel.dart';
import 'DetailPage.dart';
import 'mapRequestDetails.page.dart'; // For request model
import 'package:socket_io_client/socket_io_client.dart' as IO;


class BookingPage extends StatefulWidget {
  final IO.Socket? socket;
  const BookingPage(   this.socket,{super.key});
  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {

  List<Delivery> deliveryHistory = []; // List of Delivery models
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDeliveryHistory();
  }
  Future<void> _fetchDeliveryHistory() async {
    try {
      setState(() => isLoading = true);
      final dio = await callDio();
      final service = APIStateNetwork(dio);
      final requestBody = DeliveryHistoryRequestModel(
        page: 1,
        limit: 10,
        key: "",
      );
      final response = await service.getDeliveryHistory(requestBody);
      print("Response code: ${response.code}, error: ${response.error}, data: ${response.data != null}");
      if (response.code == 0 && !response.error && response.data != null) {
        setState(() {
          deliveryHistory = response.data.deliveries; // Access the deliveries list from Data
        });
        print("Loaded ${deliveryHistory.length} deliveries");
      } else {
        Fluttertoast.showToast(msg: "Failed to load delivery history");
      }
    } catch (e) {
      print("Error fetching delivery history: $e");
      Fluttertoast.showToast(msg: "Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }
  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'ongoing':
        return "Ongoing";
      case 'assigned':
        return "Assigned";
      case 'completed':
        return "Complete";
      default:
        return status;
    }
  }
  Color _getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'ongoing':
        return const Color(0xFFDF2940);
      case 'assigned':
        return const Color(0xFFFFF4C7);
      case 'completed':
        return const Color(0xFF27794D);
      default:
        return const Color(0xFF27794D);
    }
  }
  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'ongoing':
        return const Color(0xFFFFFFFF);
      case 'assigned':
        return const Color(0xFF7E6604);
      case 'completed':
        return const Color(0xFFFFFFFF);
      default:
        return const Color(0xFFFFFFFF);
    }
  }
  String _formatDate(int timestampMs) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestampMs);
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return "${date.day} ${months[date.month - 1]} ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} ${date.hour >= 12 ? 'pm' : 'am'}";
  }
  Future<void> _handleAssigned(
  final IO.Socket? socket,
      String id,
      String status,
      ) async {
    try {
      final dio = await callDio();
      final service = APIStateNetwork(dio);
      final response = await service.getDeliveryById(id);

      if (response.error == false && response.data != null) {
        final data = response.data!;

        Widget targetPage;

        if (status == "assigned") {
          targetPage = RequestDetailsPage(
            socket:   widget.socket,
            deliveryData: data,
            txtID: data.txId.toString(),
          );
        } else if (status == "ongoing") {
          targetPage = MapLiveScreen(
            socket: widget.socket,
            deliveryData: data,
            pickupLat: data.pickup?.lat,
            pickupLong: data.pickup?.long,
            dropLat: data.dropoff?.lat,
            droplong: data.dropoff?.long,
            txtid: data.txId.toString(),
          );
        } else if (status == "picked") {
          targetPage = RequestDetailsPage(
          socket:   widget.socket,
            deliveryData: data,
            txtID: data.txId.toString(),
          );
          // targetPage = MapRequestDetailsPage(
          //   socket: widget.,
          //   deliveryData: data,
          //   pickupLat: data.pickup?.lat,
          //   pickupLong: data.pickup?.long,
          //   dropLat: data.dropoff?.lat,
          //   droplong: data.dropoff?.long,
          //   txtid: data.txId.toString(),
          // );
        } else {
          // targetPage = DetailPage(
          //
          //   deliveryData: data,
          //   txtID: data.txId.toString(),
          //
          //
          // );
          targetPage = RequestDetailsPage(
            socket:   widget.socket,
            deliveryData: data,
            txtID: data.txId.toString(),
          );
        }

        // Navigate
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => targetPage),
        );

        print('🔙 Back from details | Refreshing profile');
        // Optionally refresh after returning
        // getDriverProfile();
      } else {
        Fluttertoast.showToast(
          msg: response.message ?? "Failed to fetch delivery details",
        );
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error fetching delivery details");
      debugPrint('❌ Error in _handleAssigned: $e');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Booking History")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : deliveryHistory.isEmpty
          ? const Center(child: Text("No bookings available"))
          : ListView.builder(
        itemCount: deliveryHistory.length,
        itemBuilder: (context, index) {
          final item = deliveryHistory[index];
          return GestureDetector(
            onTap: () {
              _handleAssigned(
                  widget.socket,
                  item.id,
                  item.status
              );


              // item.status=="assigned"?
              //     Navigator.push(context, MaterialPageRoute(builder: (context)=>
              //
              //         MapRequestDetailsPage(
              //           pickupLat: item.pickup.lat,
              //           pickupLong: item.pickup.long,
              //           dropLat:item.dropoff.lat,
              //           droplong: item.dropoff.long,
              //           txtid:item.txId,
              //
              //         ))):

              // Navigate to details page or show dialog with more info
              // _showDeliveryDetails(item);

            },
            child: Padding(
              padding: EdgeInsets.only(
                bottom: 15.h,
                left: 25.w,
                right: 25.w,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.txId,
                            style: GoogleFonts.inter(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF0C341F),
                            ),
                          ),
                          Text(
                            "Recipient: ${item.name}",
                            style: GoogleFonts.inter(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF545454),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.only(
                          left: 6.w,
                          right: 6.w,
                          top: 2.h,
                          bottom: 2.h,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3.r),
                          color: _getStatusBgColor(item.status),
                        ),
                        child: Center(
                          child: Text(
                            _getStatusText(item.status),
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: _getStatusTextColor(item.status),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Container(
                        width: 35.w,
                        height: 35.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.r),
                          color: const Color(0xFFF7F7F7),
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            "assets/SvgImage/bikess.svg",
                          ),
                        ),
                      ),

                      SizedBox(width: 10.w),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 16.sp,
                                  color: const Color(0xFF27794D),
                                ),
                                SizedBox(width: 5.w),
                                Text(
                                  "Drop off",
                                  style: GoogleFonts.inter(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF545454),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 3.w, top: 2.h),
                              child: Text(
                                item.dropoff.name,
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF0C341F),
                                ),
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              _formatDate(item.createdAt),
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF545454),
                              ),
                            ),
                          ],
                        ),
                      ),

                    ],
                  ),
                  SizedBox(height: 12.h),
                  Divider(color: const Color(0xFFDCE8E9)),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchDeliveryHistory, // Refresh button
        child: const Icon(Icons.refresh),
      ),
    );
  }

  void _showDeliveryDetails(Delivery delivery) {
    // Helper to format timestamp to readable date (assuming timestamps in ms)
    String formatDate(int timestampMs) {
      final date = DateTime.fromMillisecondsSinceEpoch(timestampMs);
      return "${date.day}/${date.month}/${date.year}";
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delivery Details - ${delivery.txId}"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Pickup: ${delivery.pickup.name} (${delivery.pickup.lat}, ${delivery.pickup.long})"),
              Text("Dropoff: ${delivery.dropoff.name} (${delivery.dropoff.lat}, ${delivery.dropoff.long})"),
              Text("Package: ${delivery.packageDetails.fragile ? 'Fragile' : 'Standard'}"),
              Text("Amount: \$${delivery.userPayAmount}"),
              Text("Date: ${formatDate(delivery.createdAt)}"), // Use createdAt for actual date
              if (delivery.image != null) Text("Image: ${delivery.image}"),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }


}*/

import 'dart:developer';

import 'package:delivery_rider_app/RiderScreen/MapLiveScreen.dart';
import 'package:delivery_rider_app/RiderScreen/mapRequestDetails.page.dart';
import 'package:delivery_rider_app/RiderScreen/requestDetails.page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:delivery_rider_app/config/utils/pretty.dio.dart';
import 'package:delivery_rider_app/config/network/api.state.dart';
import 'package:delivery_rider_app/data/model/DeliveryHistoryResponseModel.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../data/model/DeliveryHistoryDataModel.dart';
import '../data/model/DeliveryResponseModel.dart';

class BookingPage extends StatefulWidget {
  final IO.Socket? socket;
  const BookingPage(this.socket, {super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  List<Delivery> deliveryHistory = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDeliveryHistory();
  }

  Future<void> _fetchDeliveryHistory() async {
    try {
      setState(() => isLoading = true);
      final dio = await callDio();
      final service = APIStateNetwork(dio);
      final requestBody = DeliveryHistoryRequestModel(
        page: 1,
        limit: 50,
        key: "",
      );
      final response = await service.getDeliveryHistory(requestBody);

      if (response.code == 0 && response.data != null) {
        setState(() {
          deliveryHistory = response.data!.deliveries!;
        });
      } else {
        Fluttertoast.showToast(msg: "No bookings found");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error loading history");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Safe way to get drop name (handles both single Dropoff & List<Dropoff>)
  String? _getDropName(dynamic dropoff) {
    if (dropoff == null) return "Unknown Drop";

    if (dropoff is Dropoff) {
      return dropoff.name!.isNotEmpty ? dropoff.name : "Drop Location";
    }

    if (dropoff is List && dropoff.isNotEmpty) {
      final first = dropoff[0];
      if (first is Dropoff) {
        return first.name!.isNotEmpty ? first.name : "Drop Location 1";
      }
      if (first is Map<String, dynamic>) {
        return first['name']?.toString().isNotEmpty == true
            ? first['name']
            : "Drop Location 1";
      }
    }

    return "Drop Location";
  }

  String _getStatusText(String status) {
    switch (status.toString()) {
      case 'ongoing':
      case 'picked':
        return "Ongoing";
      case 'assigned':
        return "New Request";
      case 'completed':
        return "Completed";
      default:
        return status.toString();
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status.toString()) {
      case 'ongoing':
      case 'picked':
        return Colors.grey;
      case 'assigned':
        return const Color(0xFFFFF4C7);
      case 'completed':
        return const Color(0xFF27794D);
      default:
        return Color(0xFFDF2940);
    }
  }

  Color _getStatusTextColor(String status) {
    return status.toString() == 'assigned'
        ? const Color(0xFF7E6604)
        : Colors.white;
  }

  String _formatDate(int timestampMs) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestampMs);
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final hour = date.hour > 12
        ? date.hour - 12
        : (date.hour == 0 ? 12 : date.hour);
    final ampm = date.hour >= 12 ? 'PM' : 'AM';
    return "${date.day} ${months[date.month - 1]} ${date.year}, ${hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} $ampm";
  }

  // Safe extraction of multiple drops (1 to 3)
  List<double> _extractLats(dynamic dropoff) {
    final list = <double>[];
    if (dropoff == null) return list;

    if (dropoff is Dropoff) {
      list.add(dropoff.lat!);
    } else if (dropoff is List) {
      for (var d in dropoff.take(3)) {
        if (d is Dropoff)
          list.add(d.lat!);
        else if (d is Map<String, dynamic>)
          list.add((d['lat'] ?? 0.0).toDouble());
      }
    }
    return list;
  }

  List<double> _extractLons(dynamic dropoff) {
    final list = <double>[];
    if (dropoff == null) return list;

    if (dropoff is Dropoff) {
      list.add(dropoff.long!);
    } else if (dropoff is List) {
      for (var d in dropoff.take(3)) {
        if (d is Dropoff)
          list.add(d.long!);
        else if (d is Map<String, dynamic>)
          list.add((d['long'] ?? 0.0).toDouble());
      }
    }
    return list;
  }

  List<String> _extractNames(dynamic dropoff) {
    final list = <String>[];
    if (dropoff == null) return list;

    if (dropoff is Dropoff) {
      list.add(dropoff.name!.isNotEmpty ? dropoff.name! : "Drop Location");
    } else if (dropoff is List) {
      for (var d in dropoff.take(3)) {
        if (d is Dropoff) {
          list.add(d.name!.isNotEmpty ? d.name! : "Drop Location");
        } else if (d is Map<String, dynamic>) {
          list.add(
            (d['name']?.toString().isNotEmpty == true)
                ? d['name']
                : "Drop Location",
          );
        }
      }
    }
    return list;
  }

  Future<void> _handleDeliveryTap(String deliveryId, String status) async {
    try {
      final dio = await callDio();
      final service = APIStateNetwork(dio);
      final response = await service.getDeliveryById(deliveryId);

      if (response.error == false && response.data != null) {
        final data = response.data!;

        final dropLats = _extractLats(data.dropoff);
        final dropLons = _extractLons(data.dropoff);
        final dropNames = _extractNames(data.dropoff);

        Widget targetPage;

        if (status == "assigned") {
          targetPage = MapRequestDetailsPage(
            socket: widget.socket,
            deliveryData: data,
            pickupLat: data.pickup?.lat,
            pickupLong: data.pickup?.long,
            dropLats: dropLats,
            dropLons: dropLons,
            dropNames: dropNames,
            txtid: data.txId.toString(),
          );
        } else if (status == "ongoing" || status == "picked") {
          targetPage = MapLiveScreen(
            socket: widget.socket,
            deliveryData: data,
            pickupLat: data.pickup?.lat,
            pickupLong: data.pickup?.long,
            dropLats: dropLats,
            dropLons: dropLons,
            dropNames: dropNames,
            txtid: data.txId.toString(),
          );
        } else {
          targetPage = RequestDetailsPage(
            socket: widget.socket,
            deliveryData: data,
            txtID: data.txId.toString(),
          );
        }

        if (mounted) {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => targetPage),
          );
          _fetchDeliveryHistory(); // Refresh on back
        }
      } else {
        Fluttertoast.showToast(
          msg: response.message ?? "Failed to load details",
        );
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Booking History",
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : deliveryHistory.isEmpty
          ? Center(
              child: Text(
                "No bookings yet",
                style: GoogleFonts.inter(fontSize: 16.sp),
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchDeliveryHistory,
              child: ListView.builder(
                padding: EdgeInsets.only(top: 10.h, bottom: 80.h),
                itemCount: deliveryHistory.length,
                itemBuilder: (context, index) {
                  final item = deliveryHistory[index];

                  // Safe extraction of dropoff list
                  List<Pickup> dropoffs = [];
                  if (item.dropoff != null && item.dropoff!.isNotEmpty) {
                    dropoffs = item.dropoff!.take(3).toList(); // Max 3
                  }
                  log(item.name.toString());
                  log(item.status.toString());

                  String pretty(String s) => s
                      .replaceAll('_', ' ')
                      .split(' ')
                      .map((w) => w[0].toUpperCase() + w.substring(1))
                      .join(' ');

                  return GestureDetector(
                    onTap: () => _handleDeliveryTap(item.id!, item.status!),
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 8.h,
                      ),
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Row: TXID + Status
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.txId ?? "N/A",
                                      style: GoogleFonts.inter(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      "Recipient: ${item.name ?? "Unknown"}",
                                      style: GoogleFonts.inter(
                                        fontSize: 13.sp,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 6.h,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusBgColor(item.status!),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  pretty(item.status ?? ""),
                                  // _getStatusText(item.status!),
                                  style: GoogleFonts.inter(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: _getStatusTextColor(item.status!),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 14.h),

                          // Pickup + Dropoff Locations
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Vehicle Icon
                              Container(
                                padding: EdgeInsets.all(10.w),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF7F7F7),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: SvgPicture.asset(
                                  "assets/SvgImage/bikess.svg",
                                  width: 28.w,
                                  color: const Color(0xFF006970),
                                ),
                              ),

                              SizedBox(width: 14.w),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Pickup Location
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.my_location,
                                          size: 18.sp,
                                          color: Colors.green,
                                        ),
                                        SizedBox(width: 8.w),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Pickup",
                                                style: GoogleFonts.inter(
                                                  fontSize: 13.sp,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.grey[800],
                                                ),
                                              ),
                                              SizedBox(height: 2.h),
                                              Text(
                                                item.pickup?.name ??
                                                    "Pickup Location",
                                                style: GoogleFonts.inter(
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black87,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: 12.h),

                                    // // Multiple Drop Locations (1 to 3)
                                    // ...dropoffs.asMap().entries.map((entry) {
                                    //   int idx = entry.key;
                                    //   final drop = entry.value;
                                    //   bool isFinal = idx == dropoffs.length - 1;
                                    //
                                    //   return Padding(
                                    //     padding: EdgeInsets.only(bottom: 8.h),
                                    //     child: Row(
                                    //       crossAxisAlignment: CrossAxisAlignment.start,
                                    //       children: [
                                    //         // Numbered Red Circle
                                    //         Container(
                                    //           width: 22.w,
                                    //           height: 22.h,
                                    //           decoration: const BoxDecoration(
                                    //             color: Colors.red,
                                    //             shape: BoxShape.circle,
                                    //           ),
                                    //           child: Center(
                                    //             child: Text(
                                    //               "${idx + 1}",
                                    //               style: TextStyle(
                                    //                 color: Colors.white,
                                    //                 fontSize: 11.sp,
                                    //                 fontWeight: FontWeight.bold,
                                    //               ),
                                    //             ),
                                    //           ),
                                    //         ),
                                    //         SizedBox(width: 10.w),
                                    //         Expanded(
                                    //           child: Column(
                                    //             crossAxisAlignment: CrossAxisAlignment.start,
                                    //             children: [
                                    //           Text(
                                    //           "Drop ${idx + 1}${isFinal ? " (Final)" : ""}",
                                    //             style: GoogleFonts.inter(
                                    //               fontSize: 13.sp,
                                    //               fontWeight: FontWeight.w500,
                                    //               color: Colors.grey[800],
                                    //             ),
                                    //           ),
                                    //           SizedBox(height: 2.h,
                                    //             child: Text(
                                    //               drop.name ?? "Drop Location ${idx + 1}",
                                    //               style: GoogleFonts.inter(
                                    //                 fontSize: 14.sp,
                                    //                 fontWeight: FontWeight.w500,
                                    //                 color: Colors.black87,
                                    //               ),
                                    //               maxLines: 2,
                                    //               overflow: TextOverflow.ellipsis,
                                    //             ),
                                    //           ),],
                                    //           ),
                                    //         ),
                                    //       ],
                                    //     ),
                                    //   );
                                    // }).toList(),

                                    // Multiple Drop Locations (1 to 3) - Fixed Version
                                    ...dropoffs.asMap().entries.map((entry) {
                                      int idx = entry.key;
                                      final drop = entry.value;
                                      bool isFinal = idx == dropoffs.length - 1;

                                      return Padding(
                                        padding: EdgeInsets.only(bottom: 8.h),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Numbered Red Circle
                                            Container(
                                              width: 22.w,
                                              height: 22.h,
                                              decoration: const BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  "${idx + 1}",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 11.sp,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 10.w),
                                            Expanded(
                                              child: RichText(
                                                text: TextSpan(
                                                  style: GoogleFonts.inter(
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black87,
                                                  ),
                                                  children: [
                                                    TextSpan(
                                                      text:
                                                          drop.name ??
                                                          "Drop Location ${idx + 1}",
                                                    ),
                                                    if (isFinal)
                                                      TextSpan(
                                                        text: " (Final)",
                                                        style:
                                                            GoogleFonts.inter(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: Colors
                                                                  .red[700],
                                                            ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),

                                    SizedBox(height: 10.h),

                                    // Date & Time
                                    Text(
                                      _formatDate(item.createdAt!),
                                      style: GoogleFonts.inter(
                                        fontSize: 12.sp,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchDeliveryHistory,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
