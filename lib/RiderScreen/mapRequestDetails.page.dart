import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:developer';
import 'dart:ui' as ui;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:delivery_rider_app/RiderScreen/home.page.dart';
import 'package:delivery_rider_app/config/utils/pretty.dio.dart';
import 'package:delivery_rider_app/data/model/deliveryOnGoingBodyModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../config/network/api.state.dart';
import '../data/model/DeliveryResponseModel.dart';
import '../data/model/DriverArivedModel.dart';
import '../data/model/DriverCancelDeliveryBodyModel.dart';
import 'Chat/chat.dart';
import 'MapLiveScreen.dart';

class MapRequestDetailsPage extends StatefulWidget {
  final IO.Socket? socket;
  final Data deliveryData;
  final double? pickupLat;
  final double? pickupLong;
  final List<double> dropLats;
  final List<double> dropLons;
  final List<String> dropNames;
  final String txtid;

  const MapRequestDetailsPage({
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
  State<MapRequestDetailsPage> createState() => _MapRequestDetailsPageState();
}

class _MapRequestDetailsPageState extends State<MapRequestDetailsPage> {
  GoogleMapController? _mapController;
  LatLng? _currentLatLng;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  List<LatLng> _routePoints = [];
  bool _routeFetched = false;
  int? cancelTab;
  String? toPickupDistance;
  String? toPickupDuration;
  List<String> dropDistances = [];
  List<String> dropDurations = [];
  String? totalDistance;
  String? totalDuration;
  final TextEditingController _controller = TextEditingController();
  bool isLoading = false;
  String? error;
  DeliveryResponseModel? deliveryData;
  bool isLoadingData = true;
  late BitmapDescriptor _number1Icon;
  late BitmapDescriptor _number2Icon;
  late BitmapDescriptor driverIcon;
  /////////////////////////////////////////////////////////////////////////////
  String? totalCustomerDistance; // Pickup → Last Drop
  String? totalCustomerDuration; // Total time for customer journey
  late IO.Socket _socket;
  bool _isArrived = false;
  int _waitingSeconds = 0;
  String _waitingTimeText = "00:00";
  Timer? _waitingTimer;
  void _updateWaitingTimeText() {
    int mins = _waitingSeconds ~/ 60;
    int secs = _waitingSeconds % 60;
    _waitingTimeText =
        "${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }
  void _startWaitingTimerFromSeconds(int startSeconds) {
    if (!mounted) return;
    setState(() {
      _isArrived = true;
      _waitingSeconds = startSeconds;
      _updateWaitingTimeText();
    });
    _waitingTimer?.cancel();
    _waitingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _waitingSeconds++;
        _updateWaitingTimeText();
      });
    });
  }
  int _maxFreeWaitingSeconds = 300; // डिफ़ॉल्ट 5 मिनट (fallback)
  DateTime? _localArrivedAt; // Jab driver ne button dabaya tab ka time
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
            _startOrSyncWaitingTimer(
              fromSeconds: elapsedSeconds,
              freeMinutes: freeMinutes,
            );
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
  void dispose() {
    _waitingTimer?.cancel();
    super.dispose();
  }
  void _startOrSyncWaitingTimer({
    required int fromSeconds,
    required int freeMinutes,
  }) {
    _maxFreeWaitingSeconds = freeMinutes * 60;
    setState(() {
      _isArrived = true;
      _waitingSeconds = fromSeconds;
      _updateWaitingTimeText();
    });
    _waitingTimer?.cancel();
    _waitingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _waitingSeconds++;
        _updateWaitingTimeText();
      });
    });
  }

  void _emitDriverPicked() async {
    await _fetchDeliveryData();
    final payload = {"deliveryId": widget.deliveryData.id, "status": "picked"};
    if (_socket.connected) {
      _socket.emit("delivery:status_update", payload);
    }
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
        widget.deliveryData.id ?? "",
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
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(msg: "Please enable location service");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(msg: "Location permission required");
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    if (mounted) {
      setState(() {
        _currentLatLng = LatLng(position.latitude, position.longitude);
      });
      _addMarkersAndRoute();
    }
  }
  void _addMarkersAndRoute() {
    _markers.clear();
    if (_currentLatLng != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('current'),
          position: _currentLatLng!,
          icon: driverIcon,
          // BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
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
    // Multiple Drop Points
    for (int i = 0; i < widget.dropLats.length; i++) {
      BitmapDescriptor icon;
      final lat = widget.dropLats[i];
      final lon = widget.dropLons[i];
      final name = widget.dropNames[i];
      _markers.add(
        Marker(
          markerId: MarkerId('drop_$i'),
          position: LatLng(lat, lon),
          icon: i == 0
              ? icon = _number1Icon
              : i == 1
              ? icon = _number2Icon
              : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(title: "Drop ${i + 1}", snippet: name),
        ),
      );
    }

    setState(() {});
    _fetchFullRoute();
  }
  Future<void> _fetchFullRoute() async {
    if (_currentLatLng == null || widget.pickupLat == null) return;

    const apiKey = 'AIzaSyC2UYnaHQEwhzvibI-86f8c23zxgDTEX3g';
    List<LatLng> allPoints = [];

    double riderToPickupDist = 0.0;
    int riderToPickupTime = 0;

    double customerJourneyDist = 0.0; // Pickup → Last Drop
    int customerJourneyTime = 0;

    String origin = '${_currentLatLng!.latitude},${_currentLatLng!.longitude}';
    String pickup = '${widget.pickupLat!},${widget.pickupLong!}';

    // Rider → Pickup
    var leg1 = await _fetchLeg(origin, pickup, apiKey);
    if (leg1 != null) {
      allPoints.addAll(leg1['points']);
      toPickupDistance = leg1['distance'];
      toPickupDuration = leg1['duration'];

      riderToPickupDist += (leg1['distValue'] as num).toDouble();
      riderToPickupTime += (leg1['timeValue'] as num).toInt();
    }

    // Pickup → Drop1 → Drop2 → ...
    String previous = pickup;
    for (int i = 0; i < widget.dropLats.length; i++) {
      String dest = '${widget.dropLats[i]},${widget.dropLons[i]}';
      var leg = await _fetchLeg(previous, dest, apiKey);
      if (leg != null) {
        // Avoid duplicating first point of next leg
        if (i > 0) {
          allPoints.addAll(
            leg['points'].skip(1),
          ); // skip first point (already added)
        } else {
          allPoints.addAll(leg['points']);
        }

        dropDistances.add(leg['distance']);
        dropDurations.add(leg['duration']);

        // Add to customer journey
        customerJourneyDist += (leg['distValue'] as num).toDouble();
        customerJourneyTime += (leg['timeValue'] as num).toInt();
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
            patterns: [
              PatternItem.dash(20),
              PatternItem.gap(10),
            ], // optional: dotted feel
          ),
        );

        // Total for Rider (You → Last Drop)
        totalDistance =
            '${((riderToPickupDist + customerJourneyDist) / 1000).toStringAsFixed(1)} km';
        totalDuration =
            '${((riderToPickupTime + customerJourneyTime) / 60).toStringAsFixed(0)} min';

        // Customer ke liye (Pickup → Last Drop)
        totalCustomerDistance =
            '${(customerJourneyDist / 1000).toStringAsFixed(1)} km';
        totalCustomerDuration = customerJourneyTime < 60
            ? '$customerJourneyTime sec'
            : '${(customerJourneyTime / 60).toStringAsFixed(0)} min';

        _routeFetched = true;
      });

      if (_mapController != null && allPoints.isNotEmpty) {
        LatLngBounds bounds = _calculateBounds(allPoints);
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
            'distValue': leg['distance']['value'] as num,
            'timeValue': leg['duration']['value'] as int,
          };
        }
      }
    } catch (e) {
      log("Route fetch error: $e");
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
  void _showOTPDialog() {
    TextEditingController otpController = TextEditingController();
    bool isVerifying = false;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Enter OTP'),
              content: TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                decoration: InputDecoration(
                  labelText: 'OTP',
                  border: OutlineInputBorder(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),

                ElevatedButton(
                  onPressed: () async {
                    String otp = otpController.text;

                    if (otp.length != 4) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Please enter 4 digit valid OTP"),
                        ),
                      );
                      return;
                    }

                    setDialogState(() {
                      isVerifying = true;
                    });

                    try {
                      final body = DeliveryOnGoingBodyModel(
                        txId: widget.txtid,
                        otp: otp,
                      );
                      final service = APIStateNetwork(callDio());
                      final response = await service.deliveryOnGoing(body);

                      if (response.code == 0) {
                        Fluttertoast.showToast(msg: response.message);
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => MapLiveScreen(
                              socket: widget.socket,
                              deliveryData: widget.deliveryData!,
                              pickupLat: widget.pickupLat,
                              pickupLong: widget.pickupLong,
                              dropLats: widget.dropLats,
                              dropLons: widget.dropLons,
                              dropNames: widget.dropNames,
                              txtid: widget.txtid.toString(),
                            ),
                          ),
                        );
                      } else {
                        Fluttertoast.showToast(msg: response.message);
                      }
                    } catch (e, st) {
                      log(e.toString());
                      log(st.toString());
                      Fluttertoast.showToast(msg: e.toString());
                    } finally {
                      // ✅ Stop loading
                      setDialogState(() {
                        isVerifying = false;
                      });
                      otpController.clear();
                    }
                  },
                  child: isVerifying
                      ? SizedBox(
                          width: 20.w,
                          height: 20.h,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text('Verify'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  Future<void> _makePhoneCall(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
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
  @override
  Widget build(BuildContext context) {
    // Safely get customer (fallback to null if missing)
    final customer = widget.deliveryData.customer;

    // Safely get image URL (fallback to empty string if null)
    final customerImage = customer?.image ?? '';
    final senderName = '${customer!.firstName ?? ''} ${customer.lastName ?? ''}'
        .trim();
    final dropLocations = widget.dropNames;
    return Scaffold(
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
                  initialChildSize: 0.50,
                  minChildSize: 0.50,
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
                                    placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => Icon(
                                      Icons.person,
                                      size: 30.r,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),

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
                          // ← Yeh Naya Section Add Karo
                          Container(
                            padding: EdgeInsets.all(16.r),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Journey Summary",
                                  style: GoogleFonts.inter(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.route,
                                      color: Colors.blue,
                                      size: 20.sp,
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      "Total Distance: ",
                                      style: GoogleFonts.inter(fontSize: 14.sp),
                                    ),
                                    Text(
                                      totalCustomerDistance ?? "Calculating...",
                                      style: GoogleFonts.inter(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4.h),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      color: Colors.green,
                                      size: 20.sp,
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      "Estimated Time: ",
                                      style: GoogleFonts.inter(fontSize: 14.sp),
                                    ),
                                    Text(
                                      totalCustomerDuration ?? "Calculating...",
                                      style: GoogleFonts.inter(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 16.h),

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

                          SizedBox(height: 12.h),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatingPage(
                                          name:
                                              deliveryData!
                                                  .data!
                                                  .customer!
                                                  .firstName ??
                                              "",
                                          socket: widget.socket!,
                                          senderId:
                                              deliveryData!.data!.deliveryBoy ??
                                              "",

                                          receiverId:
                                              deliveryData!
                                                  .data!
                                                  .customer!
                                                  .id ??
                                              "",
                                          deliveryId:
                                              deliveryData!.data!.id ?? "",
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(
                                      top: 15.h,
                                      bottom: 20.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEEEDEF),
                                      borderRadius: BorderRadius.circular(40.r),
                                    ),
                                    child: TextField(
                                      enabled: false,
                                      controller: _controller,
                                      decoration: InputDecoration(
                                        hintText:
                                            "Send a message to your driver...",
                                        hintStyle: GoogleFonts.inter(
                                          fontSize: 12.sp,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 20.w,
                                          vertical: 12.h,
                                        ),
                                        suffixIcon: IconButton(
                                          icon: const Icon(
                                            Icons.send,
                                            color: Colors.black,
                                          ),
                                          onPressed: () {},
                                        ),
                                      ),
                                      // onSubmitted:(){}
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(width: 20.w),

                              SizedBox(width: 20.w),
                            ],
                          ),

                          SizedBox(height: 12.h),
                          if (!_isArrived)
                            GestureDetector(
                              onTap: () async {
                                try {
                                  final service = APIStateNetwork(
                                    await callDio(),
                                  );
                                  final response = await service.driverArrived(
                                    DriverArivedModel(txId: widget.txtid),
                                  );

                                  if (response.code == 0) {
                                    int startSec = 0;
                                    final arrivedAt =
                                        response.data?.delivery?.arrivedAt;
                                    if (arrivedAt != null) {
                                      final now =
                                          DateTime.now().millisecondsSinceEpoch;
                                      startSec = ((now - arrivedAt) / 1000)
                                          .floor();
                                    }
                                    _startWaitingTimerFromSeconds(
                                      startSec > 0 ? startSec : 0,
                                    );
                                    Fluttertoast.showToast(
                                      msg: "Arrived!",
                                      backgroundColor: Colors.green,
                                    );
                                  }
                                } catch (e) {
                                  Fluttertoast.showToast(
                                    msg: "Failed to mark arrived",
                                  );
                                }
                              },
                              child: Container(
                                height: 45.h,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(12.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.orange.withOpacity(0.3),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "Arrived",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 19.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                          else
                            // Arrived हो चुका है → Timer दिखेगा + Color Change Logic
                            Container(
                              height: 56.h,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: _waitingSeconds >= _maxFreeWaitingSeconds
                                    ? Colors.red.shade600
                                    : Colors.blue.shade600,
                                borderRadius: BorderRadius.circular(12.r),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        (_waitingSeconds >=
                                                    _maxFreeWaitingSeconds
                                                ? Colors.red
                                                : Colors.blue)
                                            .withOpacity(0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _waitingSeconds >= 300
                                        ? Icons.warning_amber_rounded
                                        : Icons.access_time_filled,
                                    color: Colors.white,
                                    size: 28.sp,
                                  ),
                                  SizedBox(width: 12.w),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "Waiting Time",
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13.sp,
                                        ),
                                      ),
                                      Text(
                                        _waitingTimeText,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 24.sp,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                          SizedBox(height: 12.h),

                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: isLoading
                                      ? null
                                      : () {
                                          if (_isArrived) _showOTPDialog();
                                          if (!_isArrived) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  "Please Arrived then after Pickup",
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: Size(140.w, 45.h),
                                    backgroundColor: const Color(0xFF006970),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.r),
                                      side: BorderSide.none,
                                    ),
                                  ),
                                  child: isLoading
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      : const Text(
                                          "Pickup",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: Size(140.w, 45.h),
                                    backgroundColor: Colors.red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.r),
                                      side: BorderSide.none,
                                    ),
                                  ),
                                  onPressed: () async {
                                    bool isSubmit = false;
                                    int? localCancelTab =
                                        cancelTab; // local copy for bottom sheet
                                    TextEditingController reasonController =
                                        TextEditingController();

                                    showModalBottomSheet(
                                      useSafeArea:
                                          true, // ← Yeh add karo (sabse important!)
                                      context: context,
                                      isScrollControlled: true,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(20.r),
                                        ),
                                      ),
                                      backgroundColor: Colors.white,
                                      builder: (context) {
                                        return StatefulBuilder(
                                          builder: (context, setModalState) {
                                            return SafeArea(
                                              // ← Yeh bhi add karo (double protection)
                                              top: false,
                                              child: SingleChildScrollView(
                                                child: Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                    16.w,
                                                    20.h,
                                                    16.w,
                                                    24.h,
                                                  ), // Better spacing
                                                  child: Stack(
                                                    clipBehavior: Clip.none,
                                                    children: [
                                                      // Close button top
                                                      Positioned(
                                                        top: -55,
                                                        left: 0,
                                                        right: 0,
                                                        child: Container(
                                                          width: 50.w,
                                                          height: 50.h,
                                                          decoration:
                                                              const BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                          child: IconButton(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                  context,
                                                                ),
                                                            icon: const Icon(
                                                              Icons.close,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Center(
                                                            child: Container(
                                                              width: 50.w,
                                                              height: 5.h,
                                                              decoration: BoxDecoration(
                                                                color: Colors
                                                                    .grey[300],
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      10.r,
                                                                    ),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 15.h,
                                                          ),
                                                          Text(
                                                            "Cancel Delivery",
                                                            style:
                                                                GoogleFonts.inter(
                                                                  fontSize:
                                                                      18.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                          ),
                                                          SizedBox(height: 5.h),
                                                          Text(
                                                            "Please select a reason for cancellation:",
                                                            style:
                                                                GoogleFonts.inter(
                                                                  fontSize:
                                                                      14.sp,
                                                                  color: Colors
                                                                      .black54,
                                                                ),
                                                          ),
                                                          SizedBox(
                                                            height: 20.h,
                                                          ),

                                                          // --- Options ---
                                                          for (
                                                            int i = 0;
                                                            i < 5;
                                                            i++
                                                          )
                                                            InkWell(
                                                              onTap: () {
                                                                setModalState(
                                                                  () =>
                                                                      localCancelTab =
                                                                          i,
                                                                );
                                                              },
                                                              child: Container(
                                                                margin:
                                                                    EdgeInsets.only(
                                                                      bottom:
                                                                          10.h,
                                                                    ),
                                                                padding:
                                                                    EdgeInsets.symmetric(
                                                                      vertical:
                                                                          12.h,
                                                                      horizontal:
                                                                          10.w,
                                                                    ),
                                                                decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        10.r,
                                                                      ),
                                                                  color:
                                                                      localCancelTab ==
                                                                          i
                                                                      ? const Color(
                                                                          0xFF006970,
                                                                        ).withOpacity(
                                                                          0.1,
                                                                        )
                                                                      : Colors
                                                                            .grey[100],
                                                                  border: Border.all(
                                                                    color:
                                                                        localCancelTab ==
                                                                            i
                                                                        ? const Color(
                                                                            0xFF006970,
                                                                          )
                                                                        : Colors
                                                                              .transparent,
                                                                    width: 1.2,
                                                                  ),
                                                                ),
                                                                child: Row(
                                                                  children: [
                                                                    Icon(
                                                                      localCancelTab ==
                                                                              i
                                                                          ? Icons.radio_button_checked
                                                                          : Icons.radio_button_off,
                                                                      color:
                                                                          localCancelTab ==
                                                                              i
                                                                          ? const Color(
                                                                              0xFF006970,
                                                                            )
                                                                          : Colors.grey,
                                                                      size:
                                                                          20.sp,
                                                                    ),
                                                                    SizedBox(
                                                                      width:
                                                                          12.w,
                                                                    ),
                                                                    Text(
                                                                      [
                                                                        "Change my mind",
                                                                        "Long waiting time",
                                                                        "Emergency / Health issue",
                                                                        "Vehicle issue",
                                                                        "Other Reason",
                                                                      ][i],
                                                                      style: GoogleFonts.inter(
                                                                        fontSize:
                                                                            15.sp,
                                                                        color:
                                                                            localCancelTab ==
                                                                                i
                                                                            ? const Color(
                                                                                0xFF006970,
                                                                              )
                                                                            : Colors.black,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),

                                                          SizedBox(
                                                            height: 10.h,
                                                          ),

                                                          // TextField for "Other Reason"
                                                          if (localCancelTab ==
                                                              4)
                                                            TextField(
                                                              controller:
                                                                  reasonController,
                                                              decoration: InputDecoration(
                                                                contentPadding:
                                                                    EdgeInsets.symmetric(
                                                                      vertical:
                                                                          10.h,
                                                                      horizontal:
                                                                          15.w,
                                                                    ),
                                                                enabledBorder: OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        10.r,
                                                                      ),
                                                                  borderSide: BorderSide(
                                                                    color: Colors
                                                                        .blueGrey,
                                                                    width: 1.w,
                                                                  ),
                                                                ),
                                                                focusedBorder: OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        10.r,
                                                                      ),
                                                                  borderSide: const BorderSide(
                                                                    color: Color(
                                                                      0xFF006970,
                                                                    ),
                                                                    width: 1,
                                                                  ),
                                                                ),
                                                                hintText:
                                                                    "Reason",
                                                                hintStyle:
                                                                    GoogleFonts.inter(
                                                                      fontSize:
                                                                          15.sp,
                                                                      color: Colors
                                                                          .grey,
                                                                    ),
                                                              ),
                                                            ),

                                                          SizedBox(
                                                            height: 15.h,
                                                          ),

                                                          // Submit button
                                                          SizedBox(
                                                            width:
                                                                double.infinity,
                                                            child: ElevatedButton(
                                                              style: ElevatedButton.styleFrom(
                                                                backgroundColor:
                                                                    Colors
                                                                        .redAccent,
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        10.r,
                                                                      ),
                                                                ),
                                                              ),
                                                              onPressed: () async {
                                                                setState(
                                                                  () => cancelTab =
                                                                      localCancelTab,
                                                                );

                                                                String
                                                                selectedReason;
                                                                if (localCancelTab ==
                                                                    4) {
                                                                  selectedReason =
                                                                      reasonController
                                                                          .text
                                                                          .trim()
                                                                          .isEmpty
                                                                      ? "Other Reason"
                                                                      : reasonController
                                                                            .text
                                                                            .trim();
                                                                } else if (localCancelTab !=
                                                                    null) {
                                                                  selectedReason = [
                                                                    "Change my mind",
                                                                    "Long waiting time",
                                                                    "Emergency / Health issue",
                                                                    "Vehicle issue",
                                                                    "Other Reason",
                                                                  ][localCancelTab!];
                                                                } else {
                                                                  selectedReason =
                                                                      "No reason selected";
                                                                }

                                                                setState(
                                                                  () =>
                                                                      isSubmit =
                                                                          true,
                                                                );

                                                                try {
                                                                  final body = DriverCancelDeliveryBodyModel(
                                                                    txId: widget
                                                                        .txtid,
                                                                    cancellationReason:
                                                                        selectedReason,
                                                                  );
                                                                  final service =
                                                                      APIStateNetwork(
                                                                        callDio(),
                                                                      );
                                                                  final response =
                                                                      await service
                                                                          .driverCancelDelivery(
                                                                            body,
                                                                          );

                                                                  if (response
                                                                          .code ==
                                                                      0) {
                                                                    Fluttertoast.showToast(
                                                                      msg: response
                                                                          .message,
                                                                    );
                                                                    Navigator.pushAndRemoveUntil(context,
                                                                      CupertinoPageRoute(
                                                                        builder: (_) => HomePage(
                                                                          0,
                                                                          forceSocketRefresh:
                                                                              true,
                                                                        ),
                                                                      ),
                                                                      (
                                                                        route,
                                                                      ) => route
                                                                          .isFirst,
                                                                    );
                                                                  } else {
                                                                    Fluttertoast.showToast(
                                                                      msg: response
                                                                          .message,
                                                                    );
                                                                  }
                                                                } catch (
                                                                  e,
                                                                  st
                                                                ) {
                                                                  log(
                                                                    e.toString(),
                                                                  );
                                                                  log(
                                                                    st.toString(),
                                                                  );
                                                                } finally {
                                                                  setState(
                                                                    () => isSubmit =
                                                                        false,
                                                                  );
                                                                  Navigator.pop(
                                                                    context,
                                                                  );
                                                                }
                                                              },
                                                              child: isSubmit
                                                                  ? Center(
                                                                      child: SizedBox(
                                                                        width:
                                                                            20.w,
                                                                        height:
                                                                            20.h,
                                                                        child: CircularProgressIndicator(
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                      ),
                                                                    )
                                                                  : Text(
                                                                      "Submit",
                                                                      style: GoogleFonts.inter(
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                    ),
                                                            ),
                                                          ),



                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    );
                                  },
                                  child: Text(
                                    "Cancel",
                                    style: GoogleFonts.inter(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                // ElevatedButton(
                                //   onPressed: () => _showCancelBottomSheet(),
                                //   style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                //   child: const Text("Cancel", style: TextStyle(color: Colors.white)),
                                // ),
                              ),
                            ],
                          ),
                          SizedBox(height: 40.h),
                        ],
                      ),
                    );
                  },
                ),
              ],
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
}
