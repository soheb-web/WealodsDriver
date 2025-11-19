// import 'dart:developer';
// import 'package:socket_io_client/socket_io_client.dart' as IO;
// import 'package:delivery_rider_app/RiderScreen/home.page.dart';
// import 'package:delivery_rider_app/config/utils/pretty.dio.dart';
// import 'package:delivery_rider_app/data/model/deliveryOnGoingBodyModel.dart';
// import 'package:delivery_rider_app/data/model/deliveryPickedReachedBodyModel.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:url_launcher/url_launcher.dart';
// import '../config/network/api.state.dart';
// import '../data/model/DeliveryResponseModel.dart';
// import '../data/model/DriverCancelDeliveryBodyModel.dart';
// import 'Chat/chat.dart';
// import 'MapLiveScreen.dart';
//
// class MapRequestDetailsPage extends StatefulWidget {
//   final IO.Socket? socket;
//   final Data? deliveryData;
//   final double? pickupLat;
//   final double? pickupLong;
//   final double? dropLat;
//   final double? droplong;
//   final String txtid;
//
//   const MapRequestDetailsPage({
//     this.socket,
//     this.pickupLat,
//     this.pickupLong,
//     this.dropLat,
//     this.droplong,
//     super.key,
//     this.deliveryData,
//     required this.txtid,
//   });
//
//   @override
//   State<MapRequestDetailsPage> createState() => _MapRequestDetailsPageState();
// }
//
// class _MapRequestDetailsPageState extends State<MapRequestDetailsPage> {
//   GoogleMapController? _mapController;
//   LatLng? _currentLatLng;
//   final Set<Marker> _markers = {};
//   final Set<Polyline> _polylines = {};
//   List<LatLng> _routePoints = [];
//   bool _routeFetched = false;
//   late IO.Socket _socket;
//   String? toPickupDistance;
//   String? toPickupDuration;
//   String? pickupToDropDistance;
//   String? pickupToDropDuration;
//   String? totalDistance;
//   String? totalDuration;
//   bool isLoading = false;
//   int? cancelTab;
//   String? error;
//   DeliveryResponseModel? deliveryData;
//   bool isLoadingData = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _socket = widget.socket!;
//     _emitDriverArrivedAtPickup();
//     _getCurrentLocation();
//     _fetchDeliveryData();
//   }
//
//   void _emitDriverArrivedAtPickup() {
//     final payload = {"deliveryId": widget.deliveryData!.id};
//     if (_socket.connected) {
//       // Emit the event
//       _socket.emit("delivery:status_update", payload);
//       log("Emitted → $payload");
//       // Listen for acknowledgment/response from server
//       _socket.on("delivery:status_update", (data) {
//         log("Status updated response: $data");
//         // Handle success (e.g., update UI, stop loader, etc.)
//         // Check if status is "completed"
//         if (data['status'] == 'completed' ||
//             data['status'] == 'cancelled_by_user') {
//           // Navigate to Home screen
//           _navigateToHomeScreen();
//         } else {
//           // Handle other status updates
//           _handleStatusUpdateSuccess(data);
//         }
//         _handleStatusUpdateSuccess(data);
//       });
//       // Optional: Listen for error
//       _socket.on("delivery:status_error", (error) {
//         log("Status update failed: $error");
//         // Handle error
//         // _handleStatusUpdateError(error);
//       });
//     } else {
//       log("Socket not connected, retrying...");
//       Future.delayed(const Duration(seconds: 2), _emitDriverArrivedAtPickup);
//     }
//   }
//
//   void _navigateToHomeScreen() {
//     Navigator.pushAndRemoveUntil(
//       context,
//       CupertinoPageRoute(builder: (_) => HomePage(0, forceSocketRefresh: true)),
//       (route) => route.isFirst,
//     );
//   }
//
//   Future<void> _handleStatusUpdateSuccess(dynamic payload) async {
//     log("📩 Booking Request Received: $payload");
//   }
//
//   Future<void> _fetchDeliveryData() async {
//     try {
//       setState(() {
//         isLoadingData = true;
//         error = null;
//       });
//       final dio = await callDio();
//       final service = APIStateNetwork(dio);
//       final response = await service.getDeliveryById(
//         widget.deliveryData!.id ?? "",
//       );
//       if (mounted) {
//         setState(() {
//           deliveryData = response;
//           isLoadingData = false;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           error = e.toString();
//           isLoadingData = false;
//         });
//       }
//     }
//   }
//
//   Future<void> _getCurrentLocation() async {
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("Location permission denied")),
//           );
//         }
//         return;
//       }
//     }
//     if (permission == LocationPermission.deniedForever) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text(
//               "Location permission permanently denied. Please enable it from settings.",
//             ),
//           ),
//         );
//       }
//       return;
//     }
//     Position position = await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.high,
//     );
//     if (mounted) {
//       setState(() {
//         _currentLatLng = LatLng(position.latitude, position.longitude);
//       });
//       _addMarkers();
//     }
//   }
//
//   void _addMarkers() {
//     _markers.clear(); // Clear previous markers to avoid duplicates
//     if (_currentLatLng != null) {
//       _markers.add(
//         Marker(
//           markerId: const MarkerId('current'),
//           position: _currentLatLng!,
//           infoWindow: const InfoWindow(title: 'Current Location'),
//           icon: BitmapDescriptor.defaultMarkerWithHue(
//             BitmapDescriptor.hueGreen,
//           ),
//         ),
//       );
//     }
//     if (widget.pickupLat != null && widget.pickupLong != null) {
//       _markers.add(
//         Marker(
//           markerId: const MarkerId('pickup'),
//           position: LatLng(widget.pickupLat!, widget.pickupLong!),
//           infoWindow: const InfoWindow(title: 'Pickup Location'),
//           icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
//         ),
//       );
//     }
//     if (widget.dropLat != null && widget.droplong != null) {
//       _markers.add(
//         Marker(
//           markerId: const MarkerId('drop'),
//           position: LatLng(widget.dropLat!, widget.droplong!),
//           infoWindow: const InfoWindow(title: 'Drop Location'),
//           icon: BitmapDescriptor.defaultMarkerWithHue(
//             BitmapDescriptor.hueOrange,
//           ),
//         ),
//       );
//     }
//     setState(() {});
//   }
//
//   Future<void> _fetchRoute() async {
//     if (_currentLatLng == null) {
//       print('Error: Current location is null');
//       return;
//     }
//     if (widget.pickupLat == null || widget.pickupLong == null) {
//       print('Error: Pickup location is null');
//       return;
//     }
//
//     const String apiKey = 'AIzaSyC2UYnaHQEwhzvibI-86f8c23zxgDTEX3g';
//     double totalDistKm = 0.0;
//     int totalTimeMin = 0;
//     List<LatLng> points1 = [];
//     List<LatLng> points2 = [];
//
//     // Fetch route to pickup
//     String origin1 = '${_currentLatLng!.latitude},${_currentLatLng!.longitude}';
//     String dest1 = '${widget.pickupLat!},${widget.pickupLong!}';
//
//     Uri url1 = Uri.https('maps.googleapis.com', '/maps/api/directions/json', {
//       'origin': origin1,
//       'destination': dest1,
//       'key': apiKey,
//     });
//
//     try {
//       final response1 = await http.get(url1);
//       if (response1.statusCode == 200) {
//         final data1 = json.decode(response1.body);
//         if (data1['status'] == 'OK' &&
//             data1['routes'] != null &&
//             data1['routes'].isNotEmpty) {
//           final String poly1 =
//               data1['routes'][0]['overview_polyline']['points'];
//           points1 = _decodePolyline(poly1);
//           final leg1 = data1['routes'][0]['legs'][0];
//           toPickupDistance = leg1['distance']['text'];
//           toPickupDuration = leg1['duration']['text'];
//           totalDistKm += (leg1['distance']['value'] as num) / 1000.0;
//           totalTimeMin += (leg1['duration']['value'] as int) ~/ 60;
//         } else {
//           print('Directions API error for to pickup: ${data1['status']}');
//         }
//       } else {
//         print('HTTP error for to pickup: ${response1.statusCode}');
//       }
//     } catch (e) {
//       print('Exception fetching route to pickup: $e');
//     }
//
//     // Fetch route from pickup to drop (if drop location available)
//     if (widget.dropLat != null && widget.droplong != null) {
//       String origin2 = dest1;
//       String dest2 = '${widget.dropLat!},${widget.droplong!}';
//       Uri url2 = Uri.https('maps.googleapis.com', '/maps/api/directions/json', {
//         'origin': origin2,
//         'destination': dest2,
//         'key': apiKey,
//       });
//
//       try {
//         final response2 = await http.get(url2);
//         if (response2.statusCode == 200) {
//           final data2 = json.decode(response2.body);
//           if (data2['status'] == 'OK' &&
//               data2['routes'] != null &&
//               data2['routes'].isNotEmpty) {
//             final String poly2 =
//                 data2['routes'][0]['overview_polyline']['points'];
//             points2 = _decodePolyline(poly2);
//             final leg2 = data2['routes'][0]['legs'][0];
//             pickupToDropDistance = leg2['distance']['text'];
//             pickupToDropDuration = leg2['duration']['text'];
//             totalDistKm += (leg2['distance']['value'] as num) / 1000.0;
//             totalTimeMin += (leg2['duration']['value'] as int) ~/ 60;
//           } else {
//             print(
//               'Directions API error for pickup to drop: ${data2['status']}',
//             );
//           }
//         } else {
//           print('HTTP error for pickup to drop: ${response2.statusCode}');
//         }
//       } catch (e) {
//         print('Exception fetching route from pickup to drop: $e');
//       }
//     }
//
//     // Update UI
//     if (mounted) {
//       setState(() {
//         _polylines.clear();
//
//         if (points1.isNotEmpty) {
//           _polylines.add(
//             Polyline(
//               polylineId: const PolylineId('toPickup'),
//               points: points1,
//               color: Colors.green,
//               width: 5,
//             ),
//           );
//         }
//
//         if (points2.isNotEmpty) {
//           _polylines.add(
//             Polyline(
//               polylineId: const PolylineId('toDrop'),
//               points: points2,
//               color: Colors.blue,
//               width: 5,
//             ),
//           );
//         }
//
//         totalDistance = '${totalDistKm.toStringAsFixed(1)} km';
//         totalDuration = '${totalTimeMin.toStringAsFixed(0)} min';
//         _routePoints = [...points1, ...points2];
//       });
//
//       // Animate camera to fit the route
//       if (_mapController != null && _routePoints.isNotEmpty) {
//         LatLngBounds bounds = _calculateBounds(_routePoints);
//         _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
//       }
//     }
//
//     print(
//       'Route loaded: ${points1.length} points to pickup, ${points2.length} points to drop',
//     );
//   }
//
//   LatLngBounds _calculateBounds(List<LatLng> points) {
//     if (points.isEmpty) {
//       return LatLngBounds(
//         southwest: _currentLatLng!,
//         northeast: _currentLatLng!,
//       );
//     }
//     double minLat = points[0].latitude;
//     double maxLat = points[0].latitude;
//     double minLng = points[0].longitude;
//     double maxLng = points[0].longitude;
//
//     for (LatLng point in points) {
//       if (point.latitude < minLat) minLat = point.latitude;
//       if (point.latitude > maxLat) maxLat = point.latitude;
//       if (point.longitude < minLng) minLng = point.longitude;
//       if (point.longitude > maxLng) maxLng = point.longitude;
//     }
//
//     // Include pickup and drop if not in points
//     if (widget.pickupLat != null && widget.pickupLong != null) {
//       LatLng pickup = LatLng(widget.pickupLat!, widget.pickupLong!);
//       if (pickup.latitude < minLat) minLat = pickup.latitude;
//       if (pickup.latitude > maxLat) maxLat = pickup.latitude;
//       if (pickup.longitude < minLng) minLng = pickup.longitude;
//       if (pickup.longitude > maxLng) maxLng = pickup.longitude;
//     }
//
//     if (widget.dropLat != null && widget.droplong != null) {
//       LatLng drop = LatLng(widget.dropLat!, widget.droplong!);
//       if (drop.latitude < minLat) minLat = drop.latitude;
//       if (drop.latitude > maxLat) maxLat = drop.latitude;
//       if (drop.longitude < minLng) minLng = drop.longitude;
//       if (drop.longitude > maxLng) maxLng = drop.longitude;
//     }
//
//     return LatLngBounds(
//       southwest: LatLng(minLat, minLng),
//       northeast: LatLng(maxLat, maxLng),
//     );
//   }
//
//   List<LatLng> _decodePolyline(String encoded) {
//     List<LatLng> points = <LatLng>[];
//     int index = 0;
//     final int len = encoded.length;
//     int lat = 0;
//     int lng = 0;
//
//     while (index < len) {
//       int b;
//       int shift = 0;
//       int result = 0;
//       do {
//         b = encoded.codeUnitAt(index++) - 63;
//         result |= (b & 0x1f) << shift;
//         shift += 5;
//       } while (b >= 0x20);
//       final int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
//       lat += dlat;
//
//       shift = 0;
//       result = 0;
//       do {
//         b = encoded.codeUnitAt(index++) - 63;
//         result |= (b & 0x1f) << shift;
//         shift += 5;
//       } while (b >= 0x20);
//       final int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
//       lng += dlng;
//
//       points.add(LatLng(lat / 1E5, lng / 1E5));
//     }
//
//     return points;
//   }
//
//   void _showOTPDialog() {
//     TextEditingController otpController = TextEditingController();
//     bool isVerifying = false;
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (context, setDialogState) {
//             return AlertDialog(
//               title: Text('Enter OTP'),
//               content: TextField(
//                 controller: otpController,
//                 keyboardType: TextInputType.number,
//                 maxLength: 4,
//                 decoration: InputDecoration(
//                   labelText: 'OTP',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                   child: Text('Cancel'),
//                 ),
//                 ElevatedButton(
//                   onPressed: () async {
//                     String otp = otpController.text;
//                     if (otp.length != 4) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           content: Text("Please enter 4 digit valid OTP"),
//                         ),
//                       );
//                       return;
//                     }
//
//                     // ✅ Local dialog state update
//                     setDialogState(() {
//                       isVerifying = true;
//                     });
//
//                     try {
//                       final body = DeliveryOnGoingBodyModel(
//                         txId: widget.txtid,
//                         otp: otp,
//                       );
//                       final service = APIStateNetwork(callDio());
//                       final response = await service.deliveryOnGoing(body);
//
//                       if (response.code == 0) {
//                         Fluttertoast.showToast(msg: response.message);
//                         Navigator.of(context).pop();
//                         Navigator.push(
//                           context,
//                           CupertinoPageRoute(
//                             builder: (context) => MapLiveScreen(
//                               socket: widget.socket,
//                               pickupLat: widget.pickupLat,
//                               pickupLong: widget.pickupLong,
//                               dropLat: widget.dropLat,
//                               droplong: widget.droplong,
//                               deliveryData: widget.deliveryData!,
//                               txtid: widget.txtid,
//                             ),
//                           ),
//                         );
//                       } else {
//                         Fluttertoast.showToast(msg: response.message);
//                       }
//                     } catch (e, st) {
//                       log(e.toString());
//                       log(st.toString());
//                       Fluttertoast.showToast(msg: e.toString());
//                     } finally {
//                       // ✅ Stop loading
//                       setDialogState(() {
//                         isVerifying = false;
//                       });
//                       otpController.clear();
//                     }
//                   },
//                   child: isVerifying
//                       ? SizedBox(
//                           width: 20.w,
//                           height: 20.h,
//                           child: CircularProgressIndicator(strokeWidth: 2),
//                         )
//                       : Text('Verify'),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }
//   Widget _buildInitialsAvatar() {
//     String senderName = widget.deliveryData!.customer!.firstName ?? "User";
//     String initials = senderName.isNotEmpty
//         ? senderName.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase()
//         : "NA";
//
//     return Center(
//       child: Text(
//         initials,
//         style: GoogleFonts.inter(
//           fontSize: 20.sp,
//           fontWeight: FontWeight.w600,
//           color: const Color(0xFF4F4F4F),
//         ),
//       ),
//     );
//   }
//   Future<void> _makePhoneCall(String phoneNumber) async {
//     final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
//     await launchUrl(launchUri);
//   }
//
//   final TextEditingController _controller = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     final customer = widget.deliveryData!.customer!;
//     final pickup = widget.deliveryData!.pickup!;
//     final dropoff = widget.deliveryData!.dropoff;
//     final packageDetails = widget.deliveryData!.packageDetails;
//     final senderName = customer != null
//         ? '${customer.firstName ?? ''} ${customer.lastName ?? ''}'
//         : 'Unknown Sender';
//     final deliveries = customer?.completedOrderCount ?? 0;
//     final rating = customer?.averageRating ?? 0;
//     final phone = customer?.phone ?? '';
//     final packageType = packageDetails?.fragile == true
//         ? 'Fragile Item'
//         : 'Electronics/Gadgets';
//     final pickupLocation = pickup?.name ?? 'Unknown Pickup';
//     final dropLocation = dropoff?.name ?? 'Unknown Drop';
//     return PopScope(
//       canPop: false,
//       onPopInvoked: (didPop) {
//         if (!didPop) {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => HomePage(0, forceSocketRefresh: true),
//             ),
//           );
//         }
//       },
//       child: Scaffold(
//         // floatingActionButtonLocation: FloatingActionButtonLocation.miniStartTop,
//         //
//         // floatingActionButton: FloatingActionButton(
//         //   backgroundColor: const Color(0xFFFFFFFF),
//         //   shape: const CircleBorder(),
//         //   onPressed: () {
//         //     Navigator.pop(context);
//         //   },
//         //   child: const Icon(Icons.arrow_back, color: Color(0xFF1D3557)),
//         // ),
//         body: _currentLatLng == null
//             ? const Center(child: CircularProgressIndicator())
//             : Stack(
//                 children: [
//                   GoogleMap(
//                     padding: EdgeInsets.only(
//                       top: 40.h, // ऊपर से दूरी
//                       right: 16.w, // दाएँ से थोड़ा अंदर
//                     ),
//                     initialCameraPosition: CameraPosition(
//                       target: _currentLatLng!,
//                       zoom: 15,
//                     ),
//
//                     onMapCreated: (controller) {
//                       _mapController = controller;
//                       if (_currentLatLng != null) {
//                         _mapController!.animateCamera(
//                           CameraUpdate.newLatLng(_currentLatLng!),
//                         );
//                       }
//                       if (!_routeFetched &&
//                           (widget.pickupLat != null ||
//                               widget.dropLat != null)) {
//                         _routeFetched = true;
//                         _fetchRoute();
//                       }
//                     },
//
//                     myLocationEnabled: true,
//                     myLocationButtonEnabled: true,
//                     markers: _markers,
//                     polylines: _polylines,
//                   ),
//
//                   if (toPickupDistance != null || pickupToDropDistance != null)
//                     Positioned(
//                       bottom: 70.h,
//                       left: 16.w,
//                       right: 16.w,
//                       child: Container(
//                         padding: EdgeInsets.all(12.w),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(8.r),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.1),
//                               blurRadius: 4,
//                               offset: const Offset(0, 2),
//                             ),
//                           ],
//                         ),
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             if (toPickupDistance != null)
//                               Text(
//                                 'To Pickup: $toPickupDistance | $toPickupDuration',
//                                 style: GoogleFonts.inter(fontSize: 14.sp),
//                               ),
//                             if (pickupToDropDistance != null)
//                               Padding(
//                                 padding: EdgeInsets.symmetric(vertical: 4.h),
//                                 child: Text(
//                                   'To Drop: $pickupToDropDistance | $pickupToDropDuration',
//                                   style: GoogleFonts.inter(fontSize: 14.sp),
//                                 ),
//                               ),
//                             Text(
//                               'Total: $totalDistance | $totalDuration',
//                               style: GoogleFonts.inter(
//                                 fontSize: 14.sp,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//
//                   Positioned(
//                     bottom: 15.h,
//                     child: Container(
//                       margin: EdgeInsets.only(left: 18.w, right: 18.w),
//                       width: 340.w,
//                       // height:
//                       //     450.h, // Increased height to accommodate more content
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(15.r),
//                         color: Color(0xFFFFFFFF),
//                         boxShadow: [
//                           BoxShadow(
//                             offset: Offset(0, 4),
//                             blurRadius: 20,
//                             spreadRadius: 0,
//                             color: Color.fromARGB(114, 0, 0, 0),
//                           ),
//                         ],
//                       ),
//                       child: Padding(
//                         padding: EdgeInsets.only(
//                           left: 20.w,
//                           right: 20.w,
//                           bottom: 10.h,
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Center(
//                               child: Container(
//                                 margin: EdgeInsets.only(top: 10.h),
//                                 width: 33.w,
//                                 height: 4.h,
//                                 decoration: BoxDecoration(
//                                   color: Color.fromARGB(127, 203, 205, 204),
//                                   borderRadius: BorderRadius.circular(10.r),
//                                 ),
//                               ),
//                             ),
//                             SizedBox(height: 10.h),
//                             Row(
//                               children: [
//                              /*   Container(
//                                   width: 56.w,
//                                   height: 56.h,
//                                   decoration: BoxDecoration(
//                                     shape: BoxShape.circle,
//                                     color: Color(0xFFA8DADC),
//                                   ),
//                                   child: Center(
//                                     child:
//                                       Image.network(widget.deliveryData!.customer!.image??"")
//                                     // Text(
//                                     //   "${senderName.substring(0, 2).toUpperCase()}",
//                                     //   style: GoogleFonts.inter(
//                                     //     fontSize: 24.sp,
//                                     //     fontWeight: FontWeight.w500,
//                                     //     color: Color(0xFF4F4F4F),
//                                     //   ),
//                                     // ),
//                                   ),
//                                 ),*/
//
//                                 Container(
//                                   width: 56.w,
//                                   height: 56.h,
//                                   decoration: const BoxDecoration(
//                                     shape: BoxShape.circle,
//                                     color: Color(0xFFA8DADC),
//                                   ),
//                                   child: ClipOval(  // Yeh zaroori hai perfect circle ke liye
//                                     child: widget.deliveryData!.customer!.image != null &&
//                                         widget.deliveryData!.customer!.image!.isNotEmpty
//                                         ? Image.network(
//                                       widget.deliveryData!.customer!.image!,
//                                       fit: BoxFit.cover,
//                                       width: 56.w,
//                                       height: 56.h,
//                                       loadingBuilder: (context, child, loadingProgress) {
//                                         if (loadingProgress == null) return child;
//                                         return Center(
//                                           child: CircularProgressIndicator(
//                                             strokeWidth: 2,
//                                             valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                                           ),
//                                         );
//                                       },
//                                       errorBuilder: (context, error, stackTrace) {
//                                         // Image load fail → fallback to initials
//                                         return _buildInitialsAvatar();
//                                       },
//                                     )
//                                         : _buildInitialsAvatar(), // Image null ya empty → initials
//                                   ),
//                                 ),
//                                 SizedBox(width: 10.w),
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         senderName,
//                                         style: GoogleFonts.inter(
//                                           fontSize: 16.sp,
//                                           fontWeight: FontWeight.w400,
//                                           color: Color(0xFF111111),
//                                         ),
//                                       ),
//                                       Text(
//                                         "$deliveries Deliveries",
//                                         style: GoogleFonts.inter(
//                                           fontSize: 13.sp,
//                                           fontWeight: FontWeight.w500,
//                                           color: Color(0xFF4F4F4F),
//                                         ),
//                                       ),
//                                       Row(
//                                         children: [
//                                           for (int i = 0; i < 5; i++)
//                                             Icon(
//                                               Icons.star,
//                                               color: i < rating
//                                                   ? Colors.yellow
//                                                   : Colors.grey,
//                                               size: 16.sp,
//                                             ),
//                                           SizedBox(width: 5.w),
//                                           Text(
//                                             "$rating",
//                                             style: GoogleFonts.inter(
//                                               fontSize: 12.sp,
//                                               fontWeight: FontWeight.w500,
//                                               color: Color(0xFF4F4F4F),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             SizedBox(height: 10.h),
//                             Text(
//                               packageType,
//                               style: GoogleFonts.inter(
//                                 fontSize: 15.sp,
//                                 fontWeight: FontWeight.w400,
//                                 color: Color(0xFF00122E),
//                               ),
//                             ),
//                             SizedBox(height: 8.h),
//                             Text(
//                               "Pickup: $pickupLocation",
//                               style: GoogleFonts.inter(
//                                 fontSize: 13.sp,
//                                 fontWeight: FontWeight.w400,
//                                 color: Color(0xFF545454),
//                               ),
//                             ),
//                             SizedBox(height: 4.h),
//                             Text(
//                               "Drop: $dropLocation",
//                               style: GoogleFonts.inter(
//                                 fontSize: 13.sp,
//                                 fontWeight: FontWeight.w400,
//                                 color: Color(0xFF545454),
//                               ),
//                             ),
//                             SizedBox(height: 8.h),
//                             GestureDetector(
//                               onTap: () => _makePhoneCall(phone),
//                               child: Text.rich(
//                                 TextSpan(
//                                   children: [
//                                     TextSpan(
//                                       text:
//                                           "Recipient: ${dropoff?.name ?? 'Unknown'}",
//                                       style: GoogleFonts.inter(
//                                         fontSize: 12.sp,
//                                         fontWeight: FontWeight.w400,
//                                         color: Color(0xFF545454),
//                                       ),
//                                     ),
//                                     TextSpan(
//                                       text: "    $phone",
//                                       style: GoogleFonts.inter(
//                                         fontSize: 12.sp,
//                                         fontWeight: FontWeight.w400,
//                                         color: Color(0xFF0945DE),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             SizedBox(height: 10.h),
//                             Padding(
//                               padding: EdgeInsets.symmetric(
//                                 horizontal: 10.w,
//                               ), // ← यही लेफ्ट-राइट मार्जिन
//                               child: ElevatedButton.icon(
//                                 onPressed: _openCustomerLiveTracking,
//                                 icon: Icon(
//                                   Icons.navigation_rounded,
//                                   color: Colors.white,
//                                   size: 28.sp,
//                                 ),
//                                 label: Text(
//                                   "Start Navigation on Google Maps",
//                                   style: GoogleFonts.inter(
//                                     fontSize: 12.sp,
//                                     fontWeight: FontWeight.w700,
//                                     color: Colors.white,
//                                     letterSpacing: 0.5,
//                                   ),
//                                 ),
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: const Color(
//                                     0xFF00C853,
//                                   ), // Ola जैसा हरा
//                                   foregroundColor: Colors.white,
//                                   padding: EdgeInsets.symmetric(
//                                     vertical: 6.h,
//                                     horizontal: 12.w,
//                                   ),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(
//                                       30.r,
//                                     ), // गोल कोने
//                                   ),
//                                   elevation: 8,
//                                   shadowColor: Colors.green.withOpacity(0.4),
//                                   minimumSize: Size(150.w, 50.h),
//                                 ),
//                               ),
//                             ),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                               children: [
//                                 Expanded(
//                                   child: GestureDetector(
//                                     onTap: () {
//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (context) => ChatingPage(
//                                             name:
//                                                 deliveryData!
//                                                     .data!
//                                                     .customer!
//                                                     .firstName ??
//                                                 "",
//                                             socket: widget.socket!,
//                                             senderId:
//                                                 deliveryData!
//                                                     .data!
//                                                     .deliveryBoy ??
//                                                 "",
//
//                                             receiverId:
//                                                 deliveryData!
//                                                     .data!
//                                                     .customer!
//                                                     .id ??
//                                                 "",
//                                             deliveryId:
//                                                 deliveryData!.data!.id ?? "",
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                     child: Container(
//                                       margin: EdgeInsets.only(
//                                         top: 15.h,
//                                         bottom: 20.h,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         color: const Color(0xFFEEEDEF),
//                                         borderRadius: BorderRadius.circular(
//                                           40.r,
//                                         ),
//                                       ),
//                                       child: TextField(
//                                         enabled: false,
//                                         controller: _controller,
//                                         decoration: InputDecoration(
//                                           hintText:
//                                               "Send a message to your driver...",
//                                           hintStyle: GoogleFonts.inter(
//                                             fontSize: 12.sp,
//                                           ),
//                                           border: InputBorder.none,
//                                           contentPadding: EdgeInsets.symmetric(
//                                             horizontal: 20.w,
//                                             vertical: 12.h,
//                                           ),
//                                           suffixIcon: IconButton(
//                                             icon: const Icon(
//                                               Icons.send,
//                                               color: Colors.black,
//                                             ),
//                                             onPressed: () {},
//                                           ),
//                                         ),
//                                         // onSubmitted:(){}
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//
//                                 SizedBox(width: 20.w),
//
//                                 actionButton(
//                                   "assets/SvgImage/calld.svg",
//                                   phone,
//                                 ),
//                               ],
//                             ),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 ElevatedButton(
//                                   style: ElevatedButton.styleFrom(
//                                     minimumSize: Size(140.w, 45.h),
//                                     backgroundColor: Color(0xFF006970),
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(15.r),
//                                       side: BorderSide.none,
//                                     ),
//                                   ),
//                                   onPressed: () async {
//                                     setState(() {
//                                       isLoading = true;
//                                     });
//                                     try {
//                                       final body =
//                                           DeliveryPickedReachedBodyModel(
//                                             txId: widget.txtid,
//                                           );
//                                       final service = APIStateNetwork(
//                                         callDio(),
//                                       );
//
//                                       final response = await service
//                                           .pickedOrReachedDelivery(body);
//                                       if (response.code == 0) {
//                                         Fluttertoast.showToast(
//                                           msg: response.message,
//                                         );
//                                         _showOTPDialog();
//                                         setState(() {
//                                           isLoading = false;
//                                         });
//                                       } else {
//                                         Fluttertoast.showToast(
//                                           msg: response.message,
//                                         );
//                                         setState(() {
//                                           isLoading = false;
//                                         });
//                                       }
//                                     } catch (e, st) {
//                                       log(e.toString());
//                                       log(st.toString());
//                                       Fluttertoast.showToast(msg: e.toString());
//                                       setState(() {
//                                         isLoading = false;
//                                       });
//                                     }
//                                   },
//                                   child: isLoading
//                                       ? Center(
//                                           child: SizedBox(
//                                             width: 20.w,
//                                             height: 20.h,
//
//                                             child: CircularProgressIndicator(
//                                               color: Colors.white,
//                                               strokeWidth: 2.w,
//                                             ),
//                                           ),
//                                         )
//                                       : Text(
//                                           "Pickup",
//                                           style: GoogleFonts.inter(
//                                             fontSize: 15.sp,
//                                             fontWeight: FontWeight.w500,
//                                             color: Colors.white,
//                                           ),
//                                         ),
//                                 ),
//                                 SizedBox(width: 10.w),
//                                 ElevatedButton(
//                                   style: ElevatedButton.styleFrom(
//                                     minimumSize: Size(140.w, 45.h),
//                                     backgroundColor: Colors.red,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(15.r),
//                                       side: BorderSide.none,
//                                     ),
//                                   ),
//                                   onPressed: () async {
//                                     bool isSubmit = false;
//                                     int? localCancelTab =
//                                         cancelTab; // local copy for bottom sheet
//                                     TextEditingController reasonController =
//                                         TextEditingController();
//
//                                     showModalBottomSheet(
//                                       context: context,
//                                       isScrollControlled: true,
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.vertical(
//                                           top: Radius.circular(20.r),
//                                         ),
//                                       ),
//                                       backgroundColor: Colors.white,
//                                       builder: (context) {
//                                         return StatefulBuilder(
//                                           builder: (context, setModalState) {
//                                             return SingleChildScrollView(
//                                               child: Padding(
//                                                 padding: EdgeInsets.only(
//                                                   bottom: MediaQuery.of(
//                                                     context,
//                                                   ).viewInsets.bottom,
//                                                   left: 16.w,
//                                                   right: 16.w,
//                                                   top: 10.h,
//                                                 ),
//                                                 child: Stack(
//                                                   clipBehavior: Clip.none,
//                                                   children: [
//                                                     // Close button top
//                                                     Positioned(
//                                                       top: -55,
//                                                       left: 0,
//                                                       right: 0,
//                                                       child: Container(
//                                                         width: 50.w,
//                                                         height: 50.h,
//                                                         decoration:
//                                                             const BoxDecoration(
//                                                               shape: BoxShape
//                                                                   .circle,
//                                                               color:
//                                                                   Colors.white,
//                                                             ),
//                                                         child: IconButton(
//                                                           onPressed: () =>
//                                                               Navigator.pop(
//                                                                 context,
//                                                               ),
//                                                           icon: const Icon(
//                                                             Icons.close,
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ),
//                                                     Column(
//                                                       mainAxisSize:
//                                                           MainAxisSize.min,
//                                                       crossAxisAlignment:
//                                                           CrossAxisAlignment
//                                                               .start,
//                                                       children: [
//                                                         Center(
//                                                           child: Container(
//                                                             width: 50.w,
//                                                             height: 5.h,
//                                                             decoration:
//                                                                 BoxDecoration(
//                                                                   color: Colors
//                                                                       .grey[300],
//                                                                   borderRadius:
//                                                                       BorderRadius.circular(
//                                                                         10.r,
//                                                                       ),
//                                                                 ),
//                                                           ),
//                                                         ),
//                                                         SizedBox(height: 15.h),
//                                                         Text(
//                                                           "Cancel Delivery",
//                                                           style:
//                                                               GoogleFonts.inter(
//                                                                 fontSize: 18.sp,
//                                                                 fontWeight:
//                                                                     FontWeight
//                                                                         .bold,
//                                                               ),
//                                                         ),
//                                                         SizedBox(height: 5.h),
//                                                         Text(
//                                                           "Please select a reason for cancellation:",
//                                                           style:
//                                                               GoogleFonts.inter(
//                                                                 fontSize: 14.sp,
//                                                                 color: Colors
//                                                                     .black54,
//                                                               ),
//                                                         ),
//                                                         SizedBox(height: 20.h),
//
//                                                         // --- Options ---
//                                                         for (
//                                                           int i = 0;
//                                                           i < 5;
//                                                           i++
//                                                         )
//                                                           InkWell(
//                                                             onTap: () {
//                                                               setModalState(
//                                                                 () =>
//                                                                     localCancelTab =
//                                                                         i,
//                                                               );
//                                                             },
//                                                             child: Container(
//                                                               margin:
//                                                                   EdgeInsets.only(
//                                                                     bottom:
//                                                                         10.h,
//                                                                   ),
//                                                               padding:
//                                                                   EdgeInsets.symmetric(
//                                                                     vertical:
//                                                                         12.h,
//                                                                     horizontal:
//                                                                         10.w,
//                                                                   ),
//                                                               decoration: BoxDecoration(
//                                                                 borderRadius:
//                                                                     BorderRadius.circular(
//                                                                       10.r,
//                                                                     ),
//                                                                 color:
//                                                                     localCancelTab ==
//                                                                         i
//                                                                     ? const Color(
//                                                                         0xFF006970,
//                                                                       ).withOpacity(
//                                                                         0.1,
//                                                                       )
//                                                                     : Colors
//                                                                           .grey[100],
//                                                                 border: Border.all(
//                                                                   color:
//                                                                       localCancelTab ==
//                                                                           i
//                                                                       ? const Color(
//                                                                           0xFF006970,
//                                                                         )
//                                                                       : Colors
//                                                                             .transparent,
//                                                                   width: 1.2,
//                                                                 ),
//                                                               ),
//                                                               child: Row(
//                                                                 children: [
//                                                                   Icon(
//                                                                     localCancelTab ==
//                                                                             i
//                                                                         ? Icons
//                                                                               .radio_button_checked
//                                                                         : Icons
//                                                                               .radio_button_off,
//                                                                     color:
//                                                                         localCancelTab ==
//                                                                             i
//                                                                         ? const Color(
//                                                                             0xFF006970,
//                                                                           )
//                                                                         : Colors
//                                                                               .grey,
//                                                                     size: 20.sp,
//                                                                   ),
//                                                                   SizedBox(
//                                                                     width: 12.w,
//                                                                   ),
//                                                                   Text(
//                                                                     [
//                                                                       "Change my mind",
//                                                                       "Long waiting time",
//                                                                       "Emergency / Health issue",
//                                                                       "Vehicle issue",
//                                                                       "Other Reason",
//                                                                     ][i],
//                                                                     style: GoogleFonts.inter(
//                                                                       fontSize:
//                                                                           15.sp,
//                                                                       color:
//                                                                           localCancelTab ==
//                                                                               i
//                                                                           ? const Color(
//                                                                               0xFF006970,
//                                                                             )
//                                                                           : Colors.black,
//                                                                     ),
//                                                                   ),
//                                                                 ],
//                                                               ),
//                                                             ),
//                                                           ),
//
//                                                         SizedBox(height: 10.h),
//
//                                                         // TextField for "Other Reason"
//                                                         if (localCancelTab == 4)
//                                                           TextField(
//                                                             controller:
//                                                                 reasonController,
//                                                             decoration: InputDecoration(
//                                                               contentPadding:
//                                                                   EdgeInsets.symmetric(
//                                                                     vertical:
//                                                                         10.h,
//                                                                     horizontal:
//                                                                         15.w,
//                                                                   ),
//                                                               enabledBorder: OutlineInputBorder(
//                                                                 borderRadius:
//                                                                     BorderRadius.circular(
//                                                                       10.r,
//                                                                     ),
//                                                                 borderSide: BorderSide(
//                                                                   color: Colors
//                                                                       .blueGrey,
//                                                                   width: 1.w,
//                                                                 ),
//                                                               ),
//                                                               focusedBorder: OutlineInputBorder(
//                                                                 borderRadius:
//                                                                     BorderRadius.circular(
//                                                                       10.r,
//                                                                     ),
//                                                                 borderSide:
//                                                                     const BorderSide(
//                                                                       color: Color(
//                                                                         0xFF006970,
//                                                                       ),
//                                                                       width: 1,
//                                                                     ),
//                                                               ),
//                                                               hintText:
//                                                                   "Reason",
//                                                               hintStyle:
//                                                                   GoogleFonts.inter(
//                                                                     fontSize:
//                                                                         15.sp,
//                                                                     color: Colors
//                                                                         .grey,
//                                                                   ),
//                                                             ),
//                                                           ),
//
//                                                         SizedBox(height: 15.h),
//
//                                                         // Submit button
//                                                         SizedBox(
//                                                           width:
//                                                               double.infinity,
//                                                           child: ElevatedButton(
//                                                             style: ElevatedButton.styleFrom(
//                                                               backgroundColor:
//                                                                   Colors
//                                                                       .redAccent,
//                                                               shape: RoundedRectangleBorder(
//                                                                 borderRadius:
//                                                                     BorderRadius.circular(
//                                                                       10.r,
//                                                                     ),
//                                                               ),
//                                                             ),
//                                                             onPressed: () async {
//                                                               setState(
//                                                                 () => cancelTab =
//                                                                     localCancelTab,
//                                                               );
//
//                                                               String
//                                                               selectedReason;
//                                                               if (localCancelTab ==
//                                                                   4) {
//                                                                 selectedReason =
//                                                                     reasonController
//                                                                         .text
//                                                                         .trim()
//                                                                         .isEmpty
//                                                                     ? "Other Reason"
//                                                                     : reasonController
//                                                                           .text
//                                                                           .trim();
//                                                               } else if (localCancelTab !=
//                                                                   null) {
//                                                                 selectedReason = [
//                                                                   "Change my mind",
//                                                                   "Long waiting time",
//                                                                   "Emergency / Health issue",
//                                                                   "Vehicle issue",
//                                                                   "Other Reason",
//                                                                 ][localCancelTab!];
//                                                               } else {
//                                                                 selectedReason =
//                                                                     "No reason selected";
//                                                               }
//
//                                                               setState(
//                                                                 () => isSubmit =
//                                                                     true,
//                                                               );
//
//                                                               try {
//                                                                 final body = DriverCancelDeliveryBodyModel(
//                                                                   txId: widget
//                                                                       .txtid,
//                                                                   cancellationReason:
//                                                                       selectedReason,
//                                                                 );
//                                                                 final service =
//                                                                     APIStateNetwork(
//                                                                       callDio(),
//                                                                     );
//                                                                 final response =
//                                                                     await service
//                                                                         .driverCancelDelivery(
//                                                                           body,
//                                                                         );
//
//                                                                 if (response
//                                                                         .code ==
//                                                                     0) {
//                                                                   Fluttertoast.showToast(
//                                                                     msg: response
//                                                                         .message,
//                                                                   );
//                                                                   Navigator.pushAndRemoveUntil(
//                                                                     context,
//                                                                     CupertinoPageRoute(
//                                                                       builder: (_) => HomePage(
//                                                                         0,
//                                                                         forceSocketRefresh:
//                                                                             true,
//                                                                       ),
//                                                                     ),
//                                                                     (
//                                                                       route,
//                                                                     ) => route
//                                                                         .isFirst,
//                                                                   );
//                                                                 } else {
//                                                                   Fluttertoast.showToast(
//                                                                     msg: response
//                                                                         .message,
//                                                                   );
//                                                                 }
//                                                               } catch (e, st) {
//                                                                 log(
//                                                                   e.toString(),
//                                                                 );
//                                                                 log(
//                                                                   st.toString(),
//                                                                 );
//                                                               } finally {
//                                                                 setState(
//                                                                   () =>
//                                                                       isSubmit =
//                                                                           false,
//                                                                 );
//                                                                 Navigator.pop(
//                                                                   context,
//                                                                 );
//                                                               }
//                                                             },
//                                                             child: isSubmit
//                                                                 ? Center(
//                                                                     child: SizedBox(
//                                                                       width:
//                                                                           20.w,
//                                                                       height:
//                                                                           20.h,
//                                                                       child: CircularProgressIndicator(
//                                                                         color: Colors
//                                                                             .white,
//                                                                       ),
//                                                                     ),
//                                                                   )
//                                                                 : Text(
//                                                                     "Submit",
//                                                                     style: GoogleFonts.inter(
//                                                                       color: Colors
//                                                                           .white,
//                                                                     ),
//                                                                   ),
//                                                           ),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                             );
//                                           },
//                                         );
//                                       },
//                                     );
//                                   },
//                                   child: Text(
//                                     "Cancel",
//                                     style: GoogleFonts.inter(
//                                       fontSize: 15.sp,
//                                       fontWeight: FontWeight.w500,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//       ),
//     );
//   }
//
//   Widget actionButton(String icon, String phone) {
//     return Column(
//       children: [
//         GestureDetector(
//           onTap: () {
//             _makePhoneCall(phone);
//           },
//           child: Container(
//             width: 45.w,
//             height: 45.h,
//             decoration: const BoxDecoration(
//               shape: BoxShape.circle,
//               color: Color(0xFFEEEDEF),
//             ),
//             child: Center(
//               child: SvgPicture.asset(icon, width: 18.w, height: 18.h),
//             ),
//           ),
//         ),
//         SizedBox(height: 6.h),
//         // Text(
//         //   label,
//         //   style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.black),
//         // ),
//       ],
//     );
//   }
//   Future<void> _openCustomerLiveTracking() async {
//     if (_currentLatLng == null ||
//         widget.pickupLat == null ||
//         widget.dropLat == null) {
//       Fluttertoast.showToast(msg: "Location loading…");
//       return;
//     }
//
//     final url = Uri.parse(
//       'https://www.google.com/maps/dir/?api=1'
//       '&origin=${_currentLatLng!.latitude},${_currentLatLng!.longitude}'
//       '&destination=${widget.dropLat!},${widget.droplong!}'
//       '&waypoints=${widget.pickupLat!},${widget.pickupLong!}'
//       '&travelmode=driving'
//       '&dir_action=navigate',
//     );
//
//     if (await canLaunchUrl(url)) {
//       await launchUrl(url, mode: LaunchMode.externalApplication);
//     } else {
//       Fluttertoast.showToast(msg: "Google Maps not installed");
//     }
//   }
//
// }


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
  @override
  void initState() {
    super.initState();
    _getCurrentLocation();

    _fetchDeliveryData();

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
        desiredAccuracy: LocationAccuracy.high);
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
      _markers.add(Marker(
        markerId: const MarkerId('current'),
        position: _currentLatLng!,
        icon: driverIcon,
        // BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
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

    // Multiple Drop Points
    for (int i = 0; i < widget.dropLats.length; i++) {
      BitmapDescriptor icon;
      final lat = widget.dropLats[i];
      final lon = widget.dropLons[i];
      final name = widget.dropNames[i];

      _markers.add(Marker(
        markerId: MarkerId('drop_$i'),
        position: LatLng(lat, lon),


        icon:
        i==0?

        icon= _number1Icon

            :

        i==1?

        icon=_number2Icon:

        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),

        // icon: BitmapDescriptor.defaultMarkerWithHue(
        //     i == widget.dropLats.length - 1 ? BitmapDescriptor.hueBlue : BitmapDescriptor.hueOrange),
        infoWindow: InfoWindow(title: "Drop ${i + 1}", snippet: name),
      ));
    }

    setState(() {});
    _fetchFullRoute();
  }
  Future<void> _fetchFullRoute() async {
    if (_currentLatLng == null || widget.pickupLat == null) return;
    const apiKey = 'AIzaSyC2UYnaHQEwhzvibI-86f8c23zxgDTEX3g'; // Replace with your key
    List<LatLng> allPoints = [];
    double totalDist = 0;
    int totalTime = 0;

    String origin = '${_currentLatLng!.latitude},${_currentLatLng!.longitude}';
    String pickup = '${widget.pickupLat!},${widget.pickupLong!}';

    // Current → Pickup
    var leg1 = await _fetchLeg(origin, pickup, apiKey);
    if (leg1 != null) {
      allPoints.addAll(leg1['points']);
      toPickupDistance = leg1['distance'];
      toPickupDuration = leg1['duration'];
      totalDist += leg1['distValue'];
      totalTime += (leg1['timeValue'] as num).toInt();
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
        totalTime += (leg1!['timeValue'] as num).toInt();
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
        LatLngBounds bounds = _calculateBounds(allPoints);
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
    // Same as before
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

                    // ✅ Local dialog state update
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
                              // socket: widget.socket,
                              // pickupLat: widget.pickupLat,
                              // pickupLong: widget.pickupLong,
                              // dropLat: widget.dropLat,
                              // droplong: widget.droplong,
                              // deliveryData: widget.deliveryData!,
                              // txtid: widget.txtid,
                              socket: widget.socket,
                              deliveryData:  widget.deliveryData!,
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

  @override
  Widget build(BuildContext context) {
    final customer = widget.deliveryData.customer!;
    final senderName = '${customer.firstName ?? ''} ${customer.lastName ?? ''}'.trim();
    final dropLocations = widget.dropNames;
    return Scaffold(
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

          // Distance Card
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
          //               Text("To Pickup: $toPickupDistance • $toPickupDuration",
          //                   style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
          //             ...dropDistances.asMap().entries.map((e) => Text(
          //                 "Drop ${e.key + 1}: ${e.value} • ${dropDurations[e.key]}")),
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
                    Text("Pickup: ${widget.deliveryData.pickup?.name ?? 'Unknown'}"),
                    ...dropLocations.asMap().entries.map((e) => Padding(
                      padding: EdgeInsets.only(top: 4.h),
                      child: Text("Drop ${e.key + 1}: ${e.value}"),
                    )),

                    SizedBox(height: 16.h),

                    ElevatedButton.icon(
                      onPressed: _openCustomerLiveTracking,
                      icon: const Icon(Icons.navigation, color: Colors.white),
                      label: const Text("Start Navigation"),
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
                                    deliveryData!
                                        .data!
                                        .deliveryBoy ??
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
                                borderRadius: BorderRadius.circular(
                                  40.r,
                                ),
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

                        // actionButton(
                        //   "assets/SvgImage/calld.svg",
                        //   phone,
                        // ),
                      ],
                    ),

                    SizedBox(height: 12.h),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isLoading ? null : () => _showOTPDialog(),
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006970)),
                            child: isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text("Pickup", style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child:


                          ElevatedButton(
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
                                      return SingleChildScrollView(
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                            bottom: MediaQuery.of(
                                              context,
                                            ).viewInsets.bottom,
                                            left: 16.w,
                                            right: 16.w,
                                            top: 10.h,
                                          ),
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
                                                    color:
                                                    Colors.white,
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
                                                      decoration:
                                                      BoxDecoration(
                                                        color: Colors
                                                            .grey[300],
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                          10.r,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 15.h),
                                                  Text(
                                                    "Cancel Delivery",
                                                    style:
                                                    GoogleFonts.inter(
                                                      fontSize: 18.sp,
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
                                                      fontSize: 14.sp,
                                                      color: Colors
                                                          .black54,
                                                    ),
                                                  ),
                                                  SizedBox(height: 20.h),

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
                                                                  ? Icons
                                                                  .radio_button_checked
                                                                  : Icons
                                                                  .radio_button_off,
                                                              color:
                                                              localCancelTab ==
                                                                  i
                                                                  ? const Color(
                                                                0xFF006970,
                                                              )
                                                                  : Colors
                                                                  .grey,
                                                              size: 20.sp,
                                                            ),
                                                            SizedBox(
                                                              width: 12.w,
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

                                                  SizedBox(height: 10.h),

                                                  // TextField for "Other Reason"
                                                  if (localCancelTab == 4)
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
                                                          borderSide:
                                                          const BorderSide(
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

                                                  SizedBox(height: 15.h),

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
                                                              () => isSubmit =
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
                                                            Navigator.pushAndRemoveUntil(
                                                              context,
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
                                                        } catch (e, st) {
                                                          log(
                                                            e.toString(),
                                                          );
                                                          log(
                                                            st.toString(),
                                                          );
                                                        } finally {
                                                          setState(
                                                                () =>
                                                            isSubmit =
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
                                                            color: Colors
                                                                .white,
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelBottomSheet() {
    // Same as your previous cancel logic
  }
}