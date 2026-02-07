import 'dart:developer';
import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:delivery_rider_app/RiderScreen/processDropOff.page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  final List<double> dropLats;
  final List<double> dropLons;
  final List<String> dropNames;
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
  String? totalCustomerDistance; // Pickup → Last Drop (Customer journey)
  String? totalCustomerDuration; // Pickup → Last Drop time
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

    final payload = {"deliveryId": widget.deliveryData.id};
    _socket.emit("delivery:status_update", payload);
    _socket.on("delivery:status_update", (data) {
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
      } else if (data is Map && data["status"] == "cancelled_by_user") {
        Navigator.pushAndRemoveUntil(
          context,
          CupertinoPageRoute(
            builder: (_) => HomePage(0, forceSocketRefresh: true),
          ),
          (route) => route.isFirst,
        );
      }
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

  void _emitDriverPicked() async {
    await _fetchDeliveryData();
    final payload = {"deliveryId": widget.deliveryData.id, "status": "picked"};
    if (_socket.connected) {
      _socket.emit("delivery:status_update", payload);
      log("Emitted → Driver Picked: $payload");
    }

    _socket.emitWithAck(
      "driver:get_location",
      {"driverId": deliveryData!.data!.deliveryBoy},
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

    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
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

    canvas.drawCircle(
      Offset(size / 2, size / 2),
      size / 2,
      Paint()..color = color,
    );
    canvas.drawCircle(
      Offset(size / 2, size / 2),
      size / 2 - 8,
      Paint()..color = Colors.white,
    );

    final textPainter = TextPainter(textDirection: ui.TextDirection.ltr);
    textPainter.text = TextSpan(
      text: number,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 40,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset((size - textPainter.width) / 2, (size - textPainter.height) / 2),
    );

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  Future<void> loadSimpleDriverIcon() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = 100.0;

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
      _markers.add(
        Marker(
          markerId: const MarkerId('current'),
          position: _driverLatLng!,
          icon: driverIcon,
          infoWindow: const InfoWindow(title: "You are here"),
        ),
      );
    }

    // Pickup
    if (widget.pickupLat != null && widget.pickupLong != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('pickup'),
          position: LatLng(widget.pickupLat!, widget.pickupLong!),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange,
          ),
          infoWindow: InfoWindow(
            title: "Pickup",
            snippet: widget.deliveryData.pickup?.name,
          ),
        ),
      );
    }

    // Multiple Drop Points with Numbers
    for (int i = 0; i < widget.dropLats.length; i++) {
      BitmapDescriptor icon;
      _markers.add(
        Marker(
          markerId: MarkerId('drop_$i'),
          position: LatLng(widget.dropLats[i], widget.dropLons[i]),
          icon: i == 0
              ? icon = _number1Icon
              : i == 1
              ? icon = _number2Icon
              : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          // i==1
          // BitmapDescriptor.defaultMarkerWithHue(
          //     // i == widget.dropLats.length - 1
          //     //     ? BitmapDescriptor.hueBlue
          //     //     : BitmapDescriptor.hueOrange
          // ),
          infoWindow: InfoWindow(
            title: "Drop ${i + 1}",
            snippet: widget.dropNames[i],
          ),
        ),
      );
    }

    setState(() {});
    _fetchFullRoute();
  }

  Future<void> _fetchFullRoute() async {
    if (_currentLatLng == null ||
        widget.pickupLat == null ||
        widget.dropLats.isEmpty)
      return;

    const apiKey = 'AIzaSyC2UYnaHQEwhzvibI-86f8c23zxgDTEX3g';
    List<LatLng> allPoints = [];

    double riderToPickupDist = 0.0;
    double riderToPickupTime = 0.0;

    double customerJourneyDist = 0.0; // Yeh customer ke liye
    double customerJourneyTime = 0.0; // Yeh customer ke liye

    String origin = '${_currentLatLng!.latitude},${_currentLatLng!.longitude}';
    String pickup = '${widget.pickupLat!},${widget.pickupLong!}';

    // 1. Rider → Pickup
    var leg1 = await _fetchLeg(origin, pickup, apiKey);
    if (leg1 != null) {
      allPoints.addAll(leg1['points']);
      toPickupDistance = leg1['distance'];
      toPickupDuration = leg1['duration'];
      riderToPickupDist += leg1['distValue'];
      riderToPickupTime += leg1['timeValue'];
    }

    // 2. Pickup → Drop1 → Drop2 → ... → Last Drop (Customer Journey)
    String previous = pickup;
    for (int i = 0; i < widget.dropLats.length; i++) {
      String dest = '${widget.dropLats[i]},${widget.dropLons[i]}';
      var leg = await _fetchLeg(previous, dest, apiKey);
      if (leg != null) {
        if (i > 0)
          allPoints.addAll(leg['points'].skip(1)); // avoid duplicate points
        else
          allPoints.addAll(leg['points']);

        dropDistances.add(leg['distance']);
        dropDurations.add(leg['duration']);

        // Customer ke liye add karo
        customerJourneyDist += leg['distValue'];
        customerJourneyTime += leg['timeValue'];
      }
      previous = dest;
    }

    if (mounted) {
      setState(() {
        _polylines.clear();
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('full_route'),
            points: allPoints,
            color: Colors.blue,
            width: 6,
          ),
        );

        // Rider ke liye total (current location se last drop tak)
        totalDistance =
            '${((riderToPickupDist + customerJourneyDist) / 1000).toStringAsFixed(1)} km';
        totalDuration =
            '${((riderToPickupTime + customerJourneyTime) / 60).toStringAsFixed(0)} min';

        // Customer ke liye (Pickup se Last Drop tak)
        totalCustomerDistance =
            '${(customerJourneyDist / 1000).toStringAsFixed(1)} km';
        totalCustomerDuration = customerJourneyTime < 60
            ? '${customerJourneyTime.toInt()} sec'
            : '${(customerJourneyTime / 60).toStringAsFixed(0)} min';

        _routePoints = allPoints;
      });

      if (_mapController != null && allPoints.isNotEmpty) {
        final bounds = _calculateBounds(allPoints);
        _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
      }
    }
  }

  Future<Map<String, dynamic>?> _fetchLeg(
    String origin,
    String dest,
    String key,
  ) async {
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
    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  Future<void> _makePhoneCall(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final customer = widget.deliveryData.customer;

    // Safely get image URL (fallback to empty string if null)
    final customerImage = customer?.image ?? '';
    final senderName = '${customer!.firstName ?? ''} ${customer.lastName ?? ''}'
        .trim();
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
                    padding: EdgeInsets.only(top: 40.h, right: 16.w),
                    initialCameraPosition: CameraPosition(
                      target: _currentLatLng!,
                      zoom: 14,
                    ),
                    onMapCreated: (c) => _mapController = c,
                    myLocationEnabled: false,
                    myLocationButtonEnabled: false,
                    markers: _markers,
                    polylines: _polylines,
                  ),

                  DraggableScrollableSheet(
                    initialChildSize: 0.40,
                    minChildSize: 0.30,
                    maxChildSize: 0.75,
                    builder: (context, scrollController) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20.r),
                          ),
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 10),
                          ],
                        ),
                        child: ListView(
                          controller: scrollController,
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 12.h,
                          ),
                          children: [
                            Center(
                              child: Container(
                                width: 40.w,
                                height: 5.h,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.r),
                                  color: Colors.grey[300],
                                ),
                              ),
                            ),
                            SizedBox(height: 10.h),

                            Row(
                              children: [
                                // CircleAvatar(
                                //   radius: 30.r,
                                //   backgroundColor: Colors.grey.shade200,
                                //   child: ClipOval(
                                //     child: CachedNetworkImage(
                                //       imageUrl: customerImage,
                                //       fit: BoxFit.cover,
                                //       width: 60.r,
                                //       height: 60.r,
                                //       placeholder: (context, url) => CircularProgressIndicator(strokeWidth: 2),
                                //       errorWidget: (context, url, error) => Icon(Icons.person, size: 30.r, color: Colors.grey),
                                //     ),
                                //   ),
                                // ),
                                CircleAvatar(
                                  radius: 30.r,
                                  backgroundColor: Colors.grey.shade200,
                                  child: ClipOval(
                                    child: CachedNetworkImage(
                                      imageUrl:
                                          customerImage, // safe: empty string if null
                                      fit: BoxFit.cover,
                                      width: 60.r,
                                      height: 60.r,
                                      placeholder: (context, url) =>
                                          const Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                      errorWidget: (context, url, error) =>
                                          Icon(
                                            Icons.person,
                                            size: 30.r,
                                            color: Colors.grey,
                                          ),
                                    ),
                                  ),
                                ),
                                // CircleAvatar(radius: 25, backgroundImage: NetworkImage(vehicalImage)),
                                SizedBox(width: 12.w),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      senderName,
                                      style: GoogleFonts.inter(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    // Text('${vehicleTypeName}'  , style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.grey[700])),
                                    // Row(children: [Icon(Icons.star, color: Colors.amber, size: 16), Text(averageRating, style: TextStyle(fontSize: 13))]),
                                  ],
                                ),

                                const Spacer(),

                                actionButton(
                                  "assets/SvgImage/calld.svg",
                                  widget.deliveryData.customer!.phone!,
                                ),
                              ],
                            ),

                            SizedBox(height: 10.h),

                            Row(
                              children: [
                                const Icon(
                                  Icons.my_location,
                                  color: Colors.green,
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: Text(
                                    "Pickup: ${widget.deliveryData.pickup?.name ?? 'Unknown'}",
                                  ),
                                ),
                              ],
                            ),

                            ...dropLocations.asMap().entries.map(
                              (e) => Padding(
                                padding: EdgeInsets.only(top: 4.h),
                                child: Text("Drop ${e.key + 1}: ${e.value}"),
                              ),
                            ),

                            SizedBox(height: 16.h),

                            SizedBox(height: 16.h),

                            // Total Distance & Time Box
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(16.r),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FFFB),
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(
                                  color: const Color(0xFF00C853),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Delivery Summary",
                                    style: GoogleFonts.inter(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF006970),
                                    ),
                                  ),
                                  SizedBox(height: 10.h),

                                  // Rider ke liye
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.directions_car,
                                        color: Colors.blue,
                                        size: 22.sp,
                                      ),
                                      SizedBox(width: 10.w),
                                      Text(
                                        "Your Total Trip: ",
                                        style: GoogleFonts.inter(
                                          fontSize: 14.sp,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      Spacer(),
                                      Text(
                                        totalDistance ?? "Calculating...",
                                        style: GoogleFonts.inter(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 8.h),

                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time_filled,
                                        color: Colors.green[700],
                                        size: 22.sp,
                                      ),
                                      SizedBox(width: 10.w),
                                      Text(
                                        "Estimated Time: ",
                                        style: GoogleFonts.inter(
                                          fontSize: 14.sp,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      Spacer(),
                                      Text(
                                        totalDuration ?? "Calculating...",
                                        style: GoogleFonts.inter(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green[700]!,
                                        ),
                                      ),
                                    ],
                                  ),

                                  Divider(
                                    height: 20.h,
                                    thickness: 1,
                                    color: Colors.grey[300],
                                  ),

                                  // Customer ke liye
                                  Text(
                                    "Customer Journey (Pickup → Last Drop)",
                                    style: GoogleFonts.inter(
                                      fontSize: 13.sp,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  SizedBox(height: 6.h),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.route,
                                        color: Colors.purple,
                                        size: 20.sp,
                                      ),
                                      SizedBox(width: 8.w),
                                      Text(
                                        "${totalCustomerDistance ?? "..."} km",
                                        style: GoogleFonts.inter(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.purple,
                                        ),
                                      ),
                                      SizedBox(width: 20.w),
                                      Icon(
                                        Icons.schedule,
                                        color: Colors.orange,
                                        size: 20.sp,
                                      ),
                                      SizedBox(width: 8.w),
                                      Text(
                                        totalCustomerDuration ?? "...",
                                        style: GoogleFonts.inter(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 20.h),
                            ElevatedButton.icon(
                              onPressed: _openCustomerLiveTracking,
                              icon: const Icon(
                                Icons.navigation,
                                color: Colors.white,
                              ),
                              label: const Text(
                                "Start Navigation",
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00C853),
                                minimumSize: const Size(double.infinity, 50),
                              ),
                            ),
                            SizedBox(height: 16.h),

                            SizedBox(
                              width: double.infinity,
                              height: 50.h,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF006970),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) => ProcessDropOffPage(
                                        txtid: widget.txtid,
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  "Complete Delivery",
                                  style: GoogleFonts.inter(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
      ),
    );
  }

  Widget actionButton(String icon, String phone) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            _makePhoneCall(phone);
          },
          child: Container(
            width: 45.w,
            height: 45.h,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFEEEDEF),
            ),
            child: Center(
              child: SvgPicture.asset(icon, width: 18.w, height: 18.h),
            ),
          ),
        ),
        SizedBox(height: 6.h),
      ],
    );
  }

  Future<void> _openCustomerLiveTracking() async {
    if (_currentLatLng == null || widget.dropLats.isEmpty) {
      Fluttertoast.showToast(msg: "Loading location...");
      return;
    }

    String waypoints = widget.pickupLat != null
        ? '${widget.pickupLat},${widget.pickupLong}'
        : '';

    for (int i = 0; i < widget.dropLats.length - 1; i++) {
      waypoints += '|${widget.dropLats[i]},${widget.dropLons[i]}';
    }

    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&origin=${_currentLatLng!.latitude},${_currentLatLng!.longitude}'
      '&destination=${widget.dropLats.last},${widget.dropLons.last}'
      '&waypoints=$waypoints'
      '&travelmode=driving'
      '&dir_action=navigate',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      Fluttertoast.showToast(msg: "Google Maps not installed");
    }
  }
}
