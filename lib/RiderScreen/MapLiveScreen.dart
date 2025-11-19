/*


import 'dart:developer';

import 'package:delivery_rider_app/RiderScreen/processDropOff.page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../data/model/DeliveryResponseModel.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'home.page.dart';

class MapLiveScreen extends StatefulWidget {
  final IO.Socket? socket;
  final Data deliveryData;
  final double? pickupLat;
  final double? pickupLong;
  final double? dropLat;
  final double? droplong;
  final String txtid;
  const MapLiveScreen({
    this.socket,
    this.pickupLat,
    this.pickupLong,
    this.dropLat,
    this.droplong,
    super.key,
    required this.deliveryData,
    required this.txtid,
  });

  @override
  State<MapLiveScreen> createState() => _MapLiveScreenState();
}

class _MapLiveScreenState extends State<MapLiveScreen> {
  GoogleMapController? _mapController;
  LatLng? _currentLatLng;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  List<LatLng> _routePoints = [];
  bool _routeFetched = false;
  String? toPickupDistance;
  late IO.Socket _socket;
  String? toPickupDuration;
  String? pickupToDropDistance;
  String? pickupToDropDuration;
  String? totalDistance;
  String? totalDuration;

  @override
  void initState() {
    super.initState();
    _socket = widget.socket!;
    _emitDriverArrivedAtPickup();
    _getCurrentLocation();
  }

  void _emitDriverArrivedAtPickup() {
    final payload = {"deliveryId": widget.deliveryData!.id};
    if (_socket.connected) {
      // Emit the event
      _socket.emit("delivery:status_update", payload);
      log("Emitted → $payload");
      // Listen for acknowledgment/response from server
      _socket.on("delivery:status_update", (data) {
        log("Status updated response: $data");
        // Handle success (e.g., update UI, stop loader, etc.)
        // Check if status is "completed"
        if (data['status'] == 'completed' ||
            data['status'] == 'cancelled_by_customer') {
          // Navigate to Home screen
          _navigateToHomeScreen();
        } else {
          // Handle other status updates
          _handleStatusUpdateSuccess(data);
        }
        _handleStatusUpdateSuccess(data);
      });
      // Optional: Listen for error
      _socket.on("delivery:status_error", (error) {
        log("Status update failed: $error");
        // Handle error
        // _handleStatusUpdateError(error);
      });
    } else {
      log("Socket not connected, retrying...");
      Future.delayed(const Duration(seconds: 2), _emitDriverArrivedAtPickup);
    }
  }

  void _navigateToHomeScreen() {
    Navigator.pushAndRemoveUntil(
      context,
      CupertinoPageRoute(builder: (_) => HomePage(0, forceSocketRefresh: true)),
      (route) => route.isFirst,
    );
  }

  Future<void> _handleStatusUpdateSuccess(dynamic payload) async {
    log("📩 Booking Request Received: $payload");
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Location permission denied")),
          );
        }
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Location permission permanently denied. Please enable it from settings.",
            ),
          ),
        );
      }
      return;
    }
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    if (mounted) {
      setState(() {
        _currentLatLng = LatLng(position.latitude, position.longitude);
      });
      _addMarkers();
    }
  }

  void _addMarkers() {
    _markers.clear(); // Clear previous markers to avoid duplicates
    if (_currentLatLng != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('current'),
          position: _currentLatLng!,
          infoWindow: const InfoWindow(title: 'Current Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
      );
    }
    if (widget.pickupLat != null && widget.pickupLong != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('pickup'),
          position: LatLng(widget.pickupLat!, widget.pickupLong!),
          infoWindow: const InfoWindow(title: 'Pickup Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }
    if (widget.dropLat != null && widget.droplong != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('drop'),
          position: LatLng(widget.dropLat!, widget.droplong!),
          infoWindow: const InfoWindow(title: 'Drop Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange,
          ),
        ),
      );
    }
    setState(() {});
  }

  Future<void> _fetchRoute() async {
    if (_currentLatLng == null) {
      print('Error: Current location is null');
      return;
    }
    if (widget.pickupLat == null || widget.pickupLong == null) {
      print('Error: Pickup location is null');
      return;
    }

    const String apiKey = 'AIzaSyC2UYnaHQEwhzvibI-86f8c23zxgDTEX3g';
    double totalDistKm = 0.0;
    int totalTimeMin = 0;
    List<LatLng> points1 = [];
    List<LatLng> points2 = [];

    // Fetch route to pickup
    String origin1 = '${_currentLatLng!.latitude},${_currentLatLng!.longitude}';
    String dest1 = '${widget.pickupLat!},${widget.pickupLong!}';

    Uri url1 = Uri.https('maps.googleapis.com', '/maps/api/directions/json', {
      'origin': origin1,
      'destination': dest1,
      'key': apiKey,
    });

    try {
      final response1 = await http.get(url1);
      if (response1.statusCode == 200) {
        final data1 = json.decode(response1.body);
        if (data1['status'] == 'OK' &&
            data1['routes'] != null &&
            data1['routes'].isNotEmpty) {
          final String poly1 =
              data1['routes'][0]['overview_polyline']['points'];
          points1 = _decodePolyline(poly1);
          final leg1 = data1['routes'][0]['legs'][0];
          toPickupDistance = leg1['distance']['text'];
          toPickupDuration = leg1['duration']['text'];
          totalDistKm += (leg1['distance']['value'] as num) / 1000.0;
          totalTimeMin += (leg1['duration']['value'] as int) ~/ 60;
        } else {
          print('Directions API error for to pickup: ${data1['status']}');
        }
      } else {
        print('HTTP error for to pickup: ${response1.statusCode}');
      }
    } catch (e) {
      print('Exception fetching route to pickup: $e');
    }

    // Fetch route from pickup to drop (if drop location available)
    if (widget.dropLat != null && widget.droplong != null) {
      String origin2 = dest1;
      String dest2 = '${widget.dropLat!},${widget.droplong!}';
      Uri url2 = Uri.https('maps.googleapis.com', '/maps/api/directions/json', {
        'origin': origin2,
        'destination': dest2,
        'key': apiKey,
      });

      try {
        final response2 = await http.get(url2);
        if (response2.statusCode == 200) {
          final data2 = json.decode(response2.body);
          if (data2['status'] == 'OK' &&
              data2['routes'] != null &&
              data2['routes'].isNotEmpty) {
            final String poly2 =
                data2['routes'][0]['overview_polyline']['points'];
            points2 = _decodePolyline(poly2);
            final leg2 = data2['routes'][0]['legs'][0];
            pickupToDropDistance = leg2['distance']['text'];
            pickupToDropDuration = leg2['duration']['text'];
            totalDistKm += (leg2['distance']['value'] as num) / 1000.0;
            totalTimeMin += (leg2['duration']['value'] as int) ~/ 60;
          } else {
            print(
              'Directions API error for pickup to drop: ${data2['status']}',
            );
          }
        } else {
          print('HTTP error for pickup to drop: ${response2.statusCode}');
        }
      } catch (e) {
        print('Exception fetching route from pickup to drop: $e');
      }
    }

    // Update UI
    if (mounted) {
      setState(() {
        _polylines.clear();

        if (points1.isNotEmpty) {
          _polylines.add(
            Polyline(
              polylineId: const PolylineId('toPickup'),
              points: points1,
              color: Colors.green,
              width: 5,
            ),
          );
        }

        if (points2.isNotEmpty) {
          _polylines.add(
            Polyline(
              polylineId: const PolylineId('toDrop'),
              points: points2,
              color: Colors.blue,
              width: 5,
            ),
          );
        }

        totalDistance = '${totalDistKm.toStringAsFixed(1)} km';
        totalDuration = '${totalTimeMin.toStringAsFixed(0)} min';
        _routePoints = [...points1, ...points2];
      });

      // Animate camera to fit the route
      if (_mapController != null && _routePoints.isNotEmpty) {
        LatLngBounds bounds = _calculateBounds(_routePoints);
        _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
      }
    }

    print(
      'Route loaded: ${points1.length} points to pickup, ${points2.length} points to drop',
    );
  }

  LatLngBounds _calculateBounds(List<LatLng> points) {
    if (points.isEmpty) {
      return LatLngBounds(
        southwest: _currentLatLng!,
        northeast: _currentLatLng!,
      );
    }

    double minLat = points[0].latitude;
    double maxLat = points[0].latitude;
    double minLng = points[0].longitude;
    double maxLng = points[0].longitude;

    for (LatLng point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    // Include pickup and drop if not in points
    if (widget.pickupLat != null && widget.pickupLong != null) {
      LatLng pickup = LatLng(widget.pickupLat!, widget.pickupLong!);
      if (pickup.latitude < minLat) minLat = pickup.latitude;
      if (pickup.latitude > maxLat) maxLat = pickup.latitude;
      if (pickup.longitude < minLng) minLng = pickup.longitude;
      if (pickup.longitude > maxLng) maxLng = pickup.longitude;
    }

    if (widget.dropLat != null && widget.droplong != null) {
      LatLng drop = LatLng(widget.dropLat!, widget.droplong!);
      if (drop.latitude < minLat) minLat = drop.latitude;
      if (drop.latitude > maxLat) maxLat = drop.latitude;
      if (drop.longitude < minLng) minLng = drop.longitude;
      if (drop.longitude > maxLng) maxLng = drop.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = <LatLng>[];
    int index = 0;
    final int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  bool isLoading = false;
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    await launchUrl(launchUri);
  }

  @override
  Widget build(BuildContext context) {
    final customer = widget.deliveryData.customer;
    final pickup = widget.deliveryData.pickup;
    final dropoff = widget.deliveryData.dropoff;
    final packageDetails = widget.deliveryData.packageDetails;
    final senderName = customer != null
        ? '${customer.firstName ?? ''} ${customer.lastName ?? ''}'
        : 'Unknown Sender';
    final deliveries = customer?.completedOrderCount ?? 0;
    final rating = customer?.averageRating ?? 0;
    final phone = customer?.phone ?? '';
    final packageType = packageDetails?.fragile == true
        ? 'Fragile Item'
        : 'Electronics/Gadgets';
    final pickupLocation = pickup?.name ?? 'Unknown Pickup';
    final dropLocation = dropoff?.name ?? 'Unknown Drop';

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(0, forceSocketRefresh: true),
            ),
          );
        }
      },
      child: Scaffold(
        // floatingActionButtonLocation: FloatingActionButtonLocation.miniStartTop,
        // floatingActionButton: FloatingActionButton(
        //   backgroundColor: const Color(0xFFFFFFFF),
        //   shape: const CircleBorder(),
        //   onPressed: () {
        //     Navigator.pop(context);
        //   },
        //   child: const Icon(Icons.arrow_back, color: Color(0xFF1D3557)),
        // ),
        body: _currentLatLng == null
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _currentLatLng!,
                      zoom: 15,
                    ),
                    onMapCreated: (controller) {
                      _mapController = controller;
                      if (_currentLatLng != null) {
                        _mapController!.animateCamera(
                          CameraUpdate.newLatLng(_currentLatLng!),
                        );
                      }
                      if (!_routeFetched &&
                          (widget.pickupLat != null ||
                              widget.dropLat != null)) {
                        _routeFetched = true;
                        _fetchRoute();
                      }
                    },
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    markers: _markers,
                    polylines: _polylines,
                  ),

                  if (toPickupDistance != null || pickupToDropDistance != null)
                    Positioned(
                      bottom: 70.h,
                      left: 16.w,
                      right: 16.w,
                      child: Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (toPickupDistance != null)
                              Text(
                                'To Pickup: $toPickupDistance | $toPickupDuration',
                                style: GoogleFonts.inter(fontSize: 14.sp),
                              ),
                            if (pickupToDropDistance != null)
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 4.h),
                                child: Text(
                                  'To Drop: $pickupToDropDistance | $pickupToDropDuration',
                                  style: GoogleFonts.inter(fontSize: 14.sp),
                                ),
                              ),
                            Text(
                              'Total: $totalDistance | $totalDuration',
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 15.h,
                    child: Container(
                      margin: EdgeInsets.only(left: 18.w, right: 18.w),
                      width: 340.w,
                      // height:
                      //     300.h, // Increased height to accommodate more content
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.r),
                        color: Color(0xFFFFFFFF),
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(0, 4),
                            blurRadius: 20,
                            spreadRadius: 0,
                            color: Color.fromARGB(114, 0, 0, 0),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: 20.w,
                          right: 20.w,
                          bottom: 10.h,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Container(
                                margin: EdgeInsets.only(top: 10.h),
                                width: 33.w,
                                height: 4.h,
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(127, 203, 205, 204),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Row(
                              children: [
                                Container(
                                  width: 56.w,
                                  height: 56.h,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFFA8DADC),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "${senderName.substring(0, 2).toUpperCase()}",
                                      style: GoogleFonts.inter(
                                        fontSize: 24.sp,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF4F4F4F),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        senderName,
                                        style: GoogleFonts.inter(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xFF111111),
                                        ),
                                      ),
                                      Text(
                                        "$deliveries Deliveries",
                                        style: GoogleFonts.inter(
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF4F4F4F),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          for (int i = 0; i < 5; i++)
                                            Icon(
                                              Icons.star,
                                              color: i < rating
                                                  ? Colors.yellow
                                                  : Colors.grey,
                                              size: 16.sp,
                                            ),
                                          SizedBox(width: 5.w),
                                          Text(
                                            "$rating",
                                            style: GoogleFonts.inter(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF4F4F4F),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              packageType,
                              style: GoogleFonts.inter(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF00122E),
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              "Pickup: $pickupLocation",
                              style: GoogleFonts.inter(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF545454),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              "Drop: $dropLocation",
                              style: GoogleFonts.inter(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF545454),
                              ),
                            ),
                            SizedBox(height: 8.h),
                            GestureDetector(
                              onTap: () => _makePhoneCall(phone),
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text:
                                          "Recipient: ${dropoff?.name ?? 'Unknown'}",
                                      style: GoogleFonts.inter(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFF545454),
                                      ),
                                    ),
                                    TextSpan(
                                      text: "   $phone",
                                      style: GoogleFonts.inter(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFF0945DE),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 15.h),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(306.w, 45.h),
                                backgroundColor: Color(0xFF006970),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(3.r),
                                  side: BorderSide.none,
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) =>
                                        ProcessDropOffPage(txtid: widget.txtid),
                                  ),
                                );
                              },
                              child: isLoading
                                  ? Center(
                                      child: SizedBox(
                                        width: 20.w,
                                        height: 20.h,

                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.w,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      "complete",
                                      style: GoogleFonts.inter(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
*/


import 'dart:developer';
import 'dart:ui' as ui;
import 'package:delivery_rider_app/RiderScreen/processDropOff.page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../config/network/api.state.dart';
import '../config/utils/pretty.dio.dart';
import '../data/model/DeliveryResponseModel.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'home.page.dart';

class MapLiveScreen extends StatefulWidget {
  final IO.Socket? socket;
  final Data deliveryData;
  final double? pickupLat;
  final double? pickupLong;
  final List<double> dropLats;      // Multiple
  final List<double> dropLons;      // Multiple
  final List<String> dropNames;     // Multiple
  final String txtid;

  const MapLiveScreen({
    super.key,
    this.socket,
    required this.deliveryData,
    this.pickupLat,
    this.pickupLong,
    required this.dropLats,
    required this.dropLons,
    required this.dropNames,
    required this.txtid,
  });

  @override
  State<MapLiveScreen> createState() => _MapLiveScreenState();
}

class _MapLiveScreenState extends State<MapLiveScreen> {
  GoogleMapController? _mapController;
  LatLng? _currentLatLng;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  List<LatLng> _routePoints = [];
  LatLng? _driverLatLng;
  String? toPickupDistance;
  String? toPickupDuration;
  List<String> dropDistances = [];
  List<String> dropDurations = [];
  String? totalDistance;
  String? totalDuration;
  late BitmapDescriptor _number1Icon;
  late BitmapDescriptor _number2Icon;
  late IO.Socket _socket;
  late BitmapDescriptor driverIcon;
  String? error;

  DeliveryResponseModel? deliveryData;
  bool isLoadingData = true;
  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _socket = widget.socket!;
    _fetchDeliveryData();
    _emitDriverPicked();

    _createNumberIcons();
    loadSimpleDriverIcon().then((_) {
      if (mounted) setState(() {});
    });
  }



  Future<void> _fetchDeliveryData() async {
    try {
      setState(() {
        isLoadingData = true;
        error = null;
      });
      final dio = await callDio();
      final service = APIStateNetwork(dio);
      final response = await service.getDeliveryById(
        widget.deliveryData!.id ?? "",
      );
      if (mounted) {
        setState(() {
          deliveryData = response;
          isLoadingData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = e.toString();
          isLoadingData = false;
        });
      }
    }
  }

  void _emitDriverPicked() async{
   await _fetchDeliveryData();
    final payload = {"deliveryId": widget.deliveryData.id, "status": "picked"};
    if (_socket.connected) {
      _socket.emit("delivery:status_update", payload);
      log("Emitted → Driver Picked: $payload");
    }

    _socket.emitWithAck(
      "driver:get_location",
      { "driverId": deliveryData!.data!.deliveryBoy },
      ack: (data) {
        print("Driver Location Response: $data");

        // data mostly Map ya List mein aata hai, safe check karo
        if (data is Map<String, dynamic>) {
          _handleDriverLocationResponse(data);
        } else if (data is List && data.isNotEmpty) {
          // Agar list mein aaya ho (kabhi kabhi aisa hota hai)
          _handleDriverLocationResponse(data[0]);
        }
      },
    );

  }



// Socket se jo response aaya usko yahan use karo
  void _handleDriverLocationResponse(Map<String, dynamic> response) {
    if (response["success"] == true) {
      double lat = double.parse(response["lat"].toString());
      double lon = double.parse(response["lon"].toString());
      _driverLatLng = LatLng(lat, lon);
      _addMarkersAndRoute();
      print("Driver Location Updated: $_driverLatLng");
      // // Agar map pe marker move karna hai to yahan call karo
      // _moveDriverMarker(_driverLatLng!);
      // UI update ke liye (if needed)
      setState(() {});
    } else {
      print("Driver location failed or not available");
      _driverLatLng = null;
    }
  }

  void _navigateToHome() {
    Navigator.pushAndRemoveUntil(
      context,
      CupertinoPageRoute(builder: (_) => HomePage(0, forceSocketRefresh: true)),
          (route) => route.isFirst,
    );
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    if (mounted) {
      setState(() => _currentLatLng = LatLng(pos.latitude, pos.longitude));
      _addMarkersAndRoute();
    }
  }

  Future<void> _createNumberIcons() async {
    _number1Icon = await _createNumberIcon("1", Colors.red);
    _number2Icon = await _createNumberIcon("2", Colors.orange);

  }

  Future<BitmapDescriptor> _createNumberIcon(String number, Color color) async {
    final size = 80.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.drawCircle(Offset(size / 2, size / 2), size / 2, Paint()..color = color);
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2 - 8, Paint()..color = Colors.white);

    final textPainter = TextPainter(textDirection: ui.TextDirection.ltr);
    textPainter.text = TextSpan(
      text: number,
      style: const TextStyle(color: Colors.black, fontSize: 40, fontWeight: FontWeight.bold),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset((size - textPainter.width) / 2, (size - textPainter.height) / 2));

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  Future<void> loadSimpleDriverIcon() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = 100.0;

    // White circle with black border
    // canvas.drawCircle(
    //   const Offset(size / 2, size / 2),
    //   size / 2,
    //   Paint()..color = Colors.white,
    // );
    // canvas.drawCircle(
    //   const Offset(size / 2, size / 2),
    //   size / 2,
    //   Paint()
    //     ..color = Colors.black
    //     ..style = PaintingStyle.stroke
    //     ..strokeWidth = 10,
    // );

    // Inner solid green circle (driver hai na!)

    canvas.drawCircle(
      const Offset(size / 2, size / 2),
      size / 2 - 18,
      Paint()..color = const Color(0xFF00C853), // Bright Green
    );

    // Chhota white dot in center (jaise real apps mein hota hai)
    canvas.drawCircle(
      const Offset(size / 2, size / 2),
      12,
      Paint()..color = Colors.white,
    );


    final picture = recorder.endRecording();
    final img = await picture.toImage(size.toInt(), size.toInt());
    final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);

    driverIcon = BitmapDescriptor.fromBytes(pngBytes!.buffer.asUint8List());

  }


  void _addMarkersAndRoute() {
    _markers.clear();
    // Current Location

    if (_driverLatLng != null) {
      _markers.add(Marker(
        markerId: const MarkerId('current'),
        position: _driverLatLng!,
        icon: driverIcon,
        infoWindow: const InfoWindow(title: "You are here"),
      ));
    }

    // Pickup
    if (widget.pickupLat != null && widget.pickupLong != null) {
      _markers.add(Marker(
        markerId: const MarkerId('pickup'),
        position: LatLng(widget.pickupLat!, widget.pickupLong!),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: InfoWindow(title: "Pickup", snippet: widget.deliveryData.pickup?.name),
      ));
    }

    // Multiple Drop Points with Numbers
    for (int i = 0; i < widget.dropLats.length; i++) {
      BitmapDescriptor icon;
      _markers.add(Marker(
        markerId: MarkerId('drop_$i'),
        position: LatLng(widget.dropLats[i], widget.dropLons[i]),
        icon:
        i==0?

          icon= _number1Icon

        :

            i==1?

                icon=_number2Icon:

            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        // i==1
        // BitmapDescriptor.defaultMarkerWithHue(
        //     // i == widget.dropLats.length - 1
        //     //     ? BitmapDescriptor.hueBlue
        //     //     : BitmapDescriptor.hueOrange
        // ),
        infoWindow: InfoWindow(title: "Drop ${i + 1}", snippet: widget.dropNames[i]),
      ));
    }

    setState(() {});
    _fetchFullRoute();
  }

  Future<void> _fetchFullRoute() async {
    if (_currentLatLng == null || widget.pickupLat == null || widget.dropLats.isEmpty) return;

    const apiKey = 'AIzaSyC2UYnaHQEwhzvibI-86f8c23zxgDTEX3g';
    List<LatLng> allPoints = [];
    double totalDist = 0.0;
    double totalTime = 0.0;

    String origin = '${_currentLatLng!.latitude},${_currentLatLng!.longitude}';
    String pickup = '${widget.pickupLat!},${widget.pickupLong!}';

    // Current → Pickup
    var leg1 = await _fetchLeg(origin, pickup, apiKey);
    if (leg1 != null) {
      allPoints.addAll(leg1['points']);
      toPickupDistance = leg1['distance'];
      toPickupDuration = leg1['duration'];
      totalDist += leg1['distValue'];
      totalTime += leg1['timeValue'];
    }

    // Pickup → Drop1 → Drop2 → Drop3
    String previous = pickup;
    for (int i = 0; i < widget.dropLats.length; i++) {
      String dest = '${widget.dropLats[i]},${widget.dropLons[i]}';
      var leg = await _fetchLeg(previous, dest, apiKey);
      if (leg != null) {
        allPoints.addAll(leg['points']);
        dropDistances.add(leg['distance']);
        dropDurations.add(leg['duration']);
        totalDist += leg['distValue'];
        totalTime += leg['timeValue'];
      }
      previous = dest;
    }

    if (mounted) {
      setState(() {
        _polylines.add(Polyline(
          polylineId: const PolylineId('full_route'),
          points: allPoints,
          color: Colors.blue,
          width: 6,
        ));

        totalDistance = '${(totalDist / 1000).toStringAsFixed(1)} km';
        totalDuration = '${(totalTime / 60).toStringAsFixed(0)} min';
        _routePoints = allPoints;
      });

      if (_mapController != null && allPoints.isNotEmpty) {
        final bounds = _calculateBounds(allPoints);
        _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
      }
    }
  }

  Future<Map<String, dynamic>?> _fetchLeg(String origin, String dest, String key) async {
    final url = Uri.https('maps.googleapis.com', '/maps/api/directions/json', {
      'origin': origin,
      'destination': dest,
      'key': key,
    });

    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
          final poly = data['routes'][0]['overview_polyline']['points'];
          final points = _decodePolyline(poly);
          final leg = data['routes'][0]['legs'][0];
          return {
            'points': points,
            'distance': leg['distance']['text'],
            'duration': leg['duration']['text'],
            'distValue': (leg['distance']['value'] as num).toDouble(),
            'timeValue': (leg['duration']['value'] as num).toDouble(),
          };
        }
      }
    } catch (e) {
      log("Route error: $e");
    }
    return null;
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;
    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;
      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;
      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  LatLngBounds _calculateBounds(List<LatLng> points) {
    double minLat = points[0].latitude, maxLat = points[0].latitude;
    double minLng = points[0].longitude, maxLng = points[0].longitude;
    for (var p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    return LatLngBounds(southwest: LatLng(minLat, minLng), northeast: LatLng(maxLat, maxLng));
  }

  Future<void> _makePhoneCall(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final customer = widget.deliveryData.customer!;
    final senderName = '${customer.firstName ?? ''} ${customer.lastName ?? ''}'.trim();
    final dropLocations = widget.dropNames;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) _navigateToHome();
      },
      child: Scaffold(
        body: _currentLatLng == null
            ? const Center(child: CircularProgressIndicator())
            : Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(target: _currentLatLng!, zoom: 14),
              onMapCreated: (c) => _mapController = c,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              markers: _markers,
              polylines: _polylines,
            ),

            // Distance Info Card
            // if (totalDistance != null)
            //   Positioned(
            //     top: 100.h,
            //     left: 16.w,
            //     right: 16.w,
            //     child: Card(
            //       child: Padding(
            //         padding: EdgeInsets.all(12.w),
            //         child: Column(
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: [
            //             if (toPickupDistance != null)
            //               Text("To Pickup: $toPickupDistance • $toPickupDuration"),
            //             ...dropDistances.asMap().entries.map((e) => Padding(
            //               padding: EdgeInsets.only(top: 4.h),
            //               child: Text("Drop ${e.key + 1}: ${e.value} • ${dropDurations[e.key]}"),
            //             )),
            //             const Divider(),
            //             Text("Total: $totalDistance • $totalDuration",
            //                 style: GoogleFonts.inter(fontSize: 15.sp, fontWeight: FontWeight.bold)),
            //           ],
            //         ),
            //       ),
            //     ),
            //   ),

            // Bottom Card



            Positioned(
              bottom: 20.h,
              left: 16.w,
              right: 16.w,
              child: Card(
                elevation: 12,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(senderName, style: GoogleFonts.inter(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8.h),
                      Text("Pickup: ${widget.deliveryData.pickup?.name ?? 'Unknown'}"),
                      ...dropLocations.asMap().entries.map((e) => Padding(
                        padding: EdgeInsets.only(top: 4.h),
                        child: Text("Drop ${e.key + 1}: ${e.value}"),
                      )),

                      SizedBox(height: 16.h),

                      SizedBox(
                        width: double.infinity,
                        height: 50.h,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006970)),
                          onPressed: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => ProcessDropOffPage(txtid: widget.txtid),
                              ),
                            );
                          },
                          child: Text(
                            "Complete Delivery",
                            style: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),



          ],
        ),
      ),
    );
  }
}