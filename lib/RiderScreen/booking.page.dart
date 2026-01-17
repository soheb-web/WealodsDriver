/*



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
        limit: 90,
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
            data: true,
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

*/


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
        limit: 90,
        key: "",
      );

      final response = await service.getDeliveryHistory(requestBody);

      log("API Response Code: ${response.code}");
      log("Deliveries Count: ${response.data?.deliveries?.length ?? 0}");

      if (response.code == 0 && response.data?.deliveries != null && response.data!.deliveries!.isNotEmpty) {
        setState(() {
          // Critical Fix: Always create a NEW list instance
          deliveryHistory = List.from(response.data!.deliveries!);
          log("UI Updated - Total Bookings: ${deliveryHistory.length}");
        });
      } else {
        setState(() {
          deliveryHistory = []; // Clear old data
        });
        Fluttertoast.showToast(msg: response.message ?? "No bookings found");
      }
    } catch (e, s) {
      log("Error in _fetchDeliveryHistory: $e", stackTrace: s);
      Fluttertoast.showToast(msg: "Error loading history");
      setState(() {
        deliveryHistory = [];
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'ongoing':
      case 'picked':
        return Colors.grey;
      case 'assigned':
        return const Color(0xFFFFF4C7);
      case 'completed':
        return const Color(0xFF27794D);
      default:
        return const Color(0xFFDF2940);
    }
  }

  Color _getStatusTextColor(String status) {
    return status.toLowerCase() == 'assigned'
        ? const Color(0xFF7E6604)
        : Colors.white;
  }

  String _formatDate(int timestampMs) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestampMs);
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final ampm = date.hour >= 12 ? 'PM' : 'AM';
    return "${date.day} ${months[date.month - 1]} ${date.year}, ${hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} $ampm";
  }

  List<double> _extractLats(dynamic dropoff) {
    final list = <double>[];
    if (dropoff == null) return list;

    if (dropoff is Dropoff) {
      list.add(dropoff.lat ?? 0.0);
    } else if (dropoff is List) {
      for (var d in dropoff.take(3)) {
        if (d is Dropoff) {
          list.add(d.lat ?? 0.0);
        } else if (d is Map<String, dynamic>) {
          list.add((d['lat'] ?? 0.0).toDouble());
        }
      }
    }
    return list;
  }

  List<double> _extractLons(dynamic dropoff) {
    final list = <double>[];
    if (dropoff == null) return list;

    if (dropoff is Dropoff) {
      list.add(dropoff.long ?? 0.0);
    } else if (dropoff is List) {
      for (var d in dropoff.take(3)) {
        if (d is Dropoff) {
          list.add(d.long ?? 0.0);
        } else if (d is Map<String, dynamic>) {
          list.add((d['long'] ?? 0.0).toDouble());
        }
      }
    }
    return list;
  }

  List<String> _extractNames(dynamic dropoff) {
    final list = <String>[];
    if (dropoff == null) return list;

    if (dropoff is Dropoff) {
      list.add(dropoff.name?.isNotEmpty == true ? dropoff.name! : "Drop Location");
    } else if (dropoff is List) {
      for (var d in dropoff.take(3)) {
        if (d is Dropoff) {
          list.add(d.name?.isNotEmpty == true ? d.name! : "Drop Location");
        } else if (d is Map<String, dynamic>) {
          final name = d['name']?.toString();
          list.add(name?.isNotEmpty == true ? name! : "Drop Location");
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
            data: false,
          );
        }

        if (mounted) {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => targetPage));
          _fetchDeliveryHistory(); // Refresh after coming back
        }
      } else {
        Fluttertoast.showToast(msg: response.message ?? "Failed to load details");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Booking History", style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : deliveryHistory.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 80, color: Colors.grey[400]),
            SizedBox(height: 16.h),
            Text(
              "No bookings yet",
              style: GoogleFonts.inter(fontSize: 18.sp, color: Colors.grey[600]),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _fetchDeliveryHistory,
        child: ListView.builder(
          key: ValueKey(deliveryHistory.length + DateTime.now().millisecondsSinceEpoch), // Force rebuild
          padding: EdgeInsets.only(top: 10.h, bottom: 80.h),
          itemCount: deliveryHistory.length,
          itemBuilder: (context, index) {
            final item = deliveryHistory[index];

            // Safe dropoff handling
            List<dynamic> dropoffs = [];
            if (item.dropoff != null && item.dropoff!.isNotEmpty) {
              dropoffs = item.dropoff!.take(3).toList();
            }

            String pretty(String s) => s
                .replaceAll('_', ' ')
                .split(' ')
                .map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1).toLowerCase())
                .join(' ');

            return GestureDetector(
              key: ValueKey(item.id ?? index), // Critical: Unique key
              onTap: () => _handleDeliveryTap(item.id!, item.status!),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.txId ?? "N/A",
                                style: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.black87),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                "Recipient: ${item.name ?? "Unknown"}",
                                style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.grey[700]),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: _getStatusBgColor(item.status ?? ''),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            pretty(item.status ?? ""),
                            style: GoogleFonts.inter(fontSize: 12.sp, fontWeight: FontWeight.w600, color: _getStatusTextColor(item.status ?? '')),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),

                    // Locations
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(color: const Color(0xFFF7F7F7), borderRadius: BorderRadius.circular(10.r)),
                          child: SvgPicture.asset("assets/SvgImage/bikess.svg", width: 28.w, color: const Color(0xFF006970)),
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Pickup
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.my_location, size: 18.sp, color: Colors.green),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Pickup", style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w500, color: Colors.grey[800])),
                                        SizedBox(height: 2.h),
                                        Text(
                                          item.pickup?.name ?? "Pickup Location",
                                          style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w500, color: Colors.black87),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),

                              // Dropoffs
                              // ...dropoffs.asMap().entries.map((entry) {
                              //   int idx = entry.key;
                              //   final drop = entry.value;
                              //   bool isFinal = idx == dropoffs.length - 1;
                              //   String name = drop is Dropoff
                              //       ? (drop.name?.isNotEmpty == true ? drop.name! : "Drop Location ${idx + 1}")
                              //       : (drop['name']?.toString().isNotEmpty == true ? drop['name'] : "Drop Location ${idx + 1}");
                              //
                              //   return Padding(
                              //     padding: EdgeInsets.only(bottom: 8.h),
                              //     child: Row(
                              //       crossAxisAlignment: CrossAxisAlignment.start,
                              //       children: [
                              //         Container(
                              //           width: 22.w,
                              //           height: 22.h,
                              //           decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                              //           child: Center(
                              //             child: Text("${idx + 1}", style: TextStyle(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.bold)),
                              //           ),
                              //         ),
                              //         SizedBox(width: 10.w),
                              //         Expanded(
                              //           child: RichText(
                              //             text: TextSpan(
                              //               style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w500, color: Colors.black87),
                              //               children: [
                              //                 TextSpan(text: name),
                              //                 if (isFinal)
                              //                   TextSpan(text: " (Final)", style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.red[700])),
                              //               ],
                              //             ),
                              //           ),
                              //         ),
                              //       ],
                              //     ),
                              //   );
                              // }).toList(),

                              ...dropoffs.asMap().entries.map((entry) {
                                int idx = entry.key;
                                dynamic drop = entry.value; // dynamic rakho
                                bool isFinal = idx == dropoffs.length - 1;

                                return Padding(
                                  padding: EdgeInsets.only(bottom: 8.h),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Red number circle
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
                                              TextSpan(text: _getDropoffName(drop, idx)),
                                              if (isFinal)
                                                TextSpan(
                                                  text: " (Final)",
                                                  style: GoogleFonts.inter(
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.red[700],
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
                              Text(_formatDate(item.createdAt!), style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.grey[600])),
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
        backgroundColor: Colors.cyan[700],
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  // Dropoff name extract karne ka perfect function
  String _getDropoffName(dynamic drop, int index) {
    if (drop == null) return "Drop Location ${index + 1}";

    // Case 1: Agar drop Pickup object hai (class instance)
    if (drop is Pickup) {
      return drop.name?.isNotEmpty == true ? drop.name! : "Drop Location ${index + 1}";
    }

    // Case 2: Agar drop Map hai (raw JSON)
    if (drop is Map<String, dynamic>) {
      final name = drop['name']?.toString();
      return name?.isNotEmpty == true ? name! : "Drop Location ${index + 1}";
    }

    // Fallback
    return "Drop Location ${index + 1}";
  }
}