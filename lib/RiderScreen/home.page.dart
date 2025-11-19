/*



import 'dart:developer';
import 'dart:async';
import 'package:delivery_rider_app/RiderScreen/booking.page.dart';
import 'package:delivery_rider_app/RiderScreen/earning.page.dart';
import 'package:delivery_rider_app/RiderScreen/profile.page.dart';
import 'package:delivery_rider_app/RiderScreen/requestDetails.page.dart';
import 'package:delivery_rider_app/RiderScreen/vihical.page.dart';
import 'package:delivery_rider_app/data/model/RejectDeliveryBodyModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:geolocator/geolocator.dart';
import '../config/network/api.state.dart';
import '../config/utils/pretty.dio.dart';
import 'identityCard.page.dart';
import 'notificationService.dart';

class HomePage extends StatefulWidget {
  int? selectIndex;
  final bool
  forceSocketRefresh; // New flag to force socket refresh on navigation
  HomePage(this.selectIndex, {super.key, this.forceSocketRefresh = false});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with WidgetsBindingObserver, RouteAware {
  bool isVisible = true;
  int selectIndex = 0;
  String firstName = '';
  String lastName = '';
  String status = '';
  double balance = 0;
  String? driverId;
  bool isStatus = false;
  IO.Socket? socket; // Changed to nullable for safe handling
  bool isSocketConnected = false;
  Timer? _locationTimer;
  List<Map<String, dynamic>> availableRequests = [];
  double? lattitude;
  double? longutude;
  bool isDriverOnline = true; // default ON


  @override
  void initState() {

    super.initState();
    selectIndex = widget.selectIndex!;
    WidgetsBinding.instance.addObserver(this);
    getDriverProfile(); // Fetch profile when screen loads

    if (widget.forceSocketRefresh) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _forceRefreshSocket();
        }
      });
    }

    if (isDriverOnline && driverId != null) {
      _ensureSocketConnected();
    }

  }
  void _connectSocket() {
    // const socketUrl = 'https://weloads.com';

    const socketUrl = 'https://weloads.com';

    _disconnectSocket();
    socket = IO.io(socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    socket!.io.options!['reconnection'] = true;
    socket!.io.options!['reconnectionAttempts'] = 10;
    socket!.io.options!['reconnectionDelay'] = 1000;
    socket!.io.options!['reconnectionDelayMax'] = 5000;
    socket!.io.options!['randomizationFactor'] = 0.5;
    socket!.io.options!['timeout'] = 20000;
    socket!.connect();
    socket!.onConnect((_) {
      print('SOCKET CONNECTED: ${socket!.id}');
      if (mounted) setState(() => isSocketConnected = true);
      _registerAndSendLocation();
    });
    socket!.onDisconnect((_) {
      print('SOCKET DISCONNECTED');
      if (mounted) setState(() => isSocketConnected = false);
      _locationTimer?.cancel();
    });
    socket!.io.on('reconnect_attempt', (attempt) {
      print('RECONNECTING... Attempt #$attempt');
      if (mounted) setState(() {});
    });
    socket!.io.on('reconnect', (attempt) {
      print('RECONNECTED after $attempt attempts!');
      if (mounted) setState(() => isSocketConnected = true);
      _registerAndSendLocation(); // CRITICAL: Re-register after reconnect
    });
    socket!.io.on('reconnect_failed', (_) {
      print('RECONNECT FAILED PERMANENTLY');
      Fluttertoast.showToast(msg: "No internet. Retrying...");
    });
    socket!.onConnectError((err) {
      print('CONNECT ERROR: $err');
      if (mounted) setState(() => isSocketConnected = false);
    });
    socket!.onError((err) => print('SOCKET ERROR: $err'));
    socket!.on('booking:request', _acceptRequest);
    socket!.on('delivery:new_request', _handleNewRequest);
    socket!.on('delivery:you_assigned', _handleAssigned);
    socket!.onAny((event, data) => print('EVENT → $event: $data'));
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final modalRoute = ModalRoute.of(context);
    if (modalRoute is PageRoute) {
      modalRoute.addScopedWillPopCallback(() async => false,);
    }
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print('AppLifecycleState: $state');
    if (state == AppLifecycleState.resumed) {
      print('APP RESUMED → Forcing socket reconnect...');
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted && isDriverOnline) {
          _ensureSocketConnected();
        }
      });
    }
    if (state == AppLifecycleState.paused) {
      print('APP PAUSED → Stopping location timer');
      _locationTimer?.cancel();
    }
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _locationTimer?.cancel();
    _disconnectSocket(); // Safe disconnect on dispose
    super.dispose();
  }
  void _disconnectSocket() {




    if (socket != null) {
      if (socket!.connected) {
        socket!.disconnect();
      }
      socket!.clearListeners(); // Remove all listeners to prevent duplicates
      socket!.dispose();
      socket = null;
    }
    _locationTimer?.cancel();
    if (mounted) {
      setState(() => isSocketConnected = false);
    }
    print('🔌 Old socket disconnected and cleaned');
  }
  void _forceRefreshSocket() async {
    print('🔄 Force refreshing socket...');
    _disconnectSocket(); // Clean old connection
    await getDriverProfile(); // Re-fetch profile to ensure driverId is fresh
    _ensureSocketConnected(); // Connect new socket
    setState(() {}); // Trigger UI update for availableRequests
  }
  void _ensureSocketConnected() {
    if (driverId == null || driverId!.isEmpty) return;

    if (socket?.connected == true) {
      _registerAndSendLocation(); // Reuse existing connection
    } else {
      _connectSocket(); // Fresh connection with auto-reconnect
    }
  }


  Future<void> getDriverProfile() async {
    try {
      final dio = await callDio();
      final service = APIStateNetwork(dio);
      final response = await service.getDriverProfile();

      if (response.error == false && response.data != null) {
        if (mounted) {
          setState(() {
            firstName = response.data!.firstName ?? '';
            lastName = response.data!.lastName ?? '';
            status = response.data!.status ?? '';
            balance = response.data!.wallet?.balance?.toDouble() ?? 0;
            driverId = response.data!.id ?? '';
          });
        }

        if (driverId != null && driverId!.isNotEmpty) {
          _ensureSocketConnected(); // Use ensure to force fresh on profile load
        }
      } else {
        Fluttertoast.showToast(
          msg: response.message ?? "Failed to fetch profile",
        );
      }
    } catch (e, st) {
      log("Get Driver Profile Error: $e\n$st");
      Fluttertoast.showToast(
        msg: "Something went wrong while fetching profile",
      );
    }
  }
  void _registerAndSendLocation() async {
    if (driverId == null || !socket!.connected) return;
    socket!.emit('register', {'userId': driverId, 'role': 'driver'});
    print('REGISTERED: $driverId');
    final pos = await _getCurrentLocation();
    if (pos != null) {
      lattitude = pos.latitude;
      longutude = pos.longitude;
      socket!.emit('booking:request', {
        'driverId': driverId,
        'lat': pos.latitude,
        'lon': pos.longitude,
      });
      socket!.emit('user:location_update', {
        'userId': driverId,
        'lat': pos.latitude,
        'lon': pos.longitude,
      });
    }
    _startLocationTimer();
  }
  void _startLocationTimer() {
    _locationTimer?.cancel();
    _locationTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (!socket!.connected || driverId == null) {
        timer.cancel();
        return;
      }
      final pos = await _getCurrentLocation();
      if (pos != null) {
        socket!.emit('user:location_update', {
          'userId': driverId,
          'lat': pos.latitude,
          'lon': pos.longitude,
        });
      }
    });
  }
  Future<Position?> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Fluttertoast.showToast(msg: "Please enable location services");
        return null;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Fluttertoast.showToast(msg: "Location permission denied");
          return null;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        Fluttertoast.showToast(msg: "Location permission permanently denied");
        return null;
      }
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      log("Error getting location: $e");
      return null;
    }
  }







  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // void _handleNewRequest(dynamic payload) async {
  //   print("New Delivery Request: $payload");
  //   final requestData = Map<String, dynamic>.from(payload as Map);
  //   final dropoff = requestData['dropoff'] as Map<String, dynamic>? ?? {};
  //   final expiresAt = requestData['expiresAt'] as int? ?? 0;
  //   final nowMs =DateTime.now().millisecondsSinceEpoch;
  //   final countdownMs = expiresAt - nowMs;
  //   final countdown = (countdownMs > 0 ? (countdownMs / 1000).round() : 0);
  //   if (countdown <= 0) return;
  //   final requestWithTimer = DeliveryRequest(
  //     deliveryId: requestData['deliveryId'] as String? ?? '',
  //     category: 'Delivery',
  //     recipient: dropoff['name'] ?? 'Unknown',
  //     dropOffLocation: dropoff['name'] ?? 'Unknown Location',
  //     countdown: countdown,
  //   );
  //   await NotificationService.instance.triggerDeliveryAlert(requestWithTimer);
  //   _showRequestPopup(requestWithTimer);
  // }




  void _handleNewRequest(dynamic payload) {
    print("New Delivery Request: $payload");

    final requestData = Map<String, dynamic>.from(payload as Map);
    final dropoff = requestData['dropoff'] as Map<String, dynamic>? ?? {};
    final expiresAt = requestData['expiresAt'] as int? ?? 0;
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final countdownMs = expiresAt - nowMs;
    final countdown = (countdownMs > 0 ? (countdownMs / 1000).round() : 0);
    if (countdown <= 0) return;

    final requestWithTimer = DeliveryRequest(
      deliveryId: requestData['deliveryId'] as String? ?? '',
      category: 'Delivery',
      recipient: dropoff['name'] ?? 'Unknown',
      dropOffLocation: dropoff['name'] ?? 'Unknown Location',
      countdown: countdown,
    );

    // 1. Notification + Sound + Vibrate (non-blocking)
    NotificationService.instance.triggerDeliveryAlert(requestWithTimer);

    // 2. Dialog (UI thread पर safe)
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showRequestPopup(requestWithTimer);
        }
      });
    }
  }


  Future<void> _handleAssigned(dynamic payload) async {
    print("Delivery Assigned: ${payload['deliveryId']}");
    final deliveryId = payload['deliveryId'] as String;
    try {
      final dio = await callDio();
      final service = APIStateNetwork(dio);
      final response = await service.getDeliveryById(deliveryId);
      if (response.error == false && response.data != null) {
        if (socket == null || !socket!.connected) {
          _ensureSocketConnected();
          await Future.delayed(const Duration(seconds: 1));
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RequestDetailsPage(
              socket: socket, // Now safe: either connected or null
              deliveryData: response.data!,
              txtID: response.data!.txId.toString(),
            ),
          ),
        ).then((_) {
          print('Back from details | Refreshing profile');
          getDriverProfile();
        });
      } else {
        Fluttertoast.showToast(
          msg: response.message ?? "Failed to fetch delivery details",
        );
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error fetching delivery details");
    }
  }
  Future<void> _acceptRequest(dynamic payload) async {
    log("📩 Booking Request Received: $payload");

    try {
      final data = Map<String, dynamic>.from(payload);
      final deliveries = List<Map<String, dynamic>>.from(
        data['deliveries'] ?? [],
      );
      if (deliveries.isEmpty) {
        log("⚠ No deliveries found in payload");
        return;
      }
      if (mounted) {
        setState(() {
          availableRequests = deliveries;
        });
      }
    } catch (e, st) {
      log("❌ Error parsing booking:request → $e\n$st");
    }
  }
  void _acceptDelivery(String deliveryId) {
    if (socket != null && socket!.connected) {
      socket!.emitWithAck(
        'delivery:accept',
        {'deliveryId': deliveryId},
        ack: (ackData) {
          print('Accept ack: $ackData');
        },
      );
      Fluttertoast.showToast(msg: "Delivery Accepted!");
    } else {
    }
  }
  void _deliveryAcceptDelivery(String deliveryId) {
    if (socket != null && socket!.connected) {
      socket!.emitWithAck(
        'delivery:accept_request',
        {'deliveryId': deliveryId},
        ack: (ackData) {
          print('Accept ack: $ackData');
        },
      );
      Fluttertoast.showToast(msg: "Delivery Accepted!");
    } else {
    }
  }
  void _skipDelivery(String deliveryId) {
    if (socket != null && socket!.connected) {
      socket!.emitWithAck(
        'delivery:skip',
        {'deliveryId': deliveryId},
        ack: (ackData) {
          print('Skip ack: $ackData');
        },
      );
      Fluttertoast.showToast(msg: "Delivery Rejected!");
    } else {
    }
  }
  // void _showRequestPopup(DeliveryRequest req) {
  //   int currentCountdown = req.countdown; // Local copy
  //   Timer? countdownTimer;
  //   Timer? autoCloseTimer; // New timer for auto-close after 10 seconds
  //   bool timerStarted = false; // Flag to start timer only once
  //
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext dialogContext) {
  //       return StatefulBuilder(
  //         builder: (BuildContext context, StateSetter setDialogState) {
  //           if (!timerStarted) {
  //             timerStarted = true;
  //             countdownTimer = Timer.periodic(const Duration(seconds: 1), (
  //                 timer,
  //                 ) {
  //               if (dialogContext.mounted) {
  //                 setDialogState(() {
  //                   currentCountdown--;
  //                 });
  //                 if (currentCountdown <= 0) {
  //                   timer.cancel();
  //                   autoCloseTimer
  //                       ?.cancel();
  //                   if (dialogContext.mounted) {
  //                     Navigator.of(dialogContext).pop();
  //                   }
  //                   _skipDelivery(req.deliveryId);
  //                   Fluttertoast.showToast(
  //                     msg: "Time expired! Delivery auto-rejected.",
  //                   );
  //                 }
  //               }
  //             });
  //
  //             // Start auto-close timer for exactly 10 seconds (independent of countdown)
  //             autoCloseTimer = Timer(const Duration(seconds: 10), () {
  //               countdownTimer?.cancel();
  //               if (dialogContext.mounted) {
  //                 Navigator.of(dialogContext).pop();
  //               }
  //               // Optional: Auto-reject on fixed 10s timeout
  //               _skipDelivery(req.deliveryId);
  //               Fluttertoast.showToast(
  //                 msg: "Popup timed out after 10 seconds!",
  //               );
  //             });
  //           }
  //
  //           return AlertDialog(
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(16.r),
  //             ),
  //             title: Text(req.category),
  //             content: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(req.category),
  //                 SizedBox(height: 8.h),
  //                 // Add pickup row
  //                 Row(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Icon(Icons.location_on, size: 16.sp, color: Colors.blue),
  //                     SizedBox(width: 5.w),
  //                     // Expanded(child: Text("Pickup: ${req.pickupName ?? 'Unknown Pickup'}")),
  //                   ],
  //                 ),
  //                 SizedBox(height: 8.h),
  //                 Text("Recipient: ${req.recipient}"),
  //                 SizedBox(height: 8.h),
  //                 Row(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Icon(Icons.location_on, size: 16.sp, color: Colors.green),
  //                     SizedBox(width: 5.w),
  //                     Expanded(child: Text(req.dropOffLocation)),
  //                   ],
  //                 ),
  //                 SizedBox(height: 8.h),
  //                 Text(
  //                   "Time left: ${currentCountdown}s",
  //                   style: TextStyle(
  //                     color: currentCountdown <= 3 ? Colors.red : Colors.green,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             actions: [
  //
  //               ElevatedButton(
  //                 onPressed: () {
  //                   NotificationService.instance.stopBuzzer(); // ← सिंगलटन इंस्टेंस
  //                   // NotificationService().stopBuzzer(); // Stop sound
  //                   countdownTimer?.cancel();
  //                   autoCloseTimer?.cancel();
  //                   Navigator.of(dialogContext).pop();
  //                   _acceptDelivery(req.deliveryId);
  //
  //                 },
  //                 child: const Text("Accept"),
  //               ),
  //
  //               TextButton(
  //                 onPressed: () {
  //                   NotificationService.instance.stopBuzzer(); // ← सिंगलटन इंस्टेंस
  //                   // NotificationService().stopBuzzer(); // Stop sound
  //                   countdownTimer?.cancel();
  //                   autoCloseTimer?.cancel();
  //                   Navigator.of(dialogContext).pop();
  //                   _skipDelivery(req.deliveryId);
  //
  //                 },
  //                 child: const Text("Reject"),
  //               ),
  //             ],
  //           );
  //         },
  //       );
  //     },
  //   ).then((_) {
  //     countdownTimer?.cancel();
  //     autoCloseTimer?.cancel(); // Ensure cleanup on dialog close
  //   });
  // }

  void _showRequestPopup(DeliveryRequest req) {
    int currentCountdown = req.countdown;
    Timer? countdownTimer;
    Timer? autoCloseTimer;

    // Start timers IMMEDIATELY
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      currentCountdown--;
      if (currentCountdown <= 0) {
        timer.cancel();
        autoCloseTimer?.cancel();
        if (mounted) {
          Navigator.pop(context);
          _skipDelivery(req.deliveryId);
          Fluttertoast.showToast(msg: "Time expired! Auto-rejected.");
        }
      }
    });

    autoCloseTimer = Timer(const Duration(seconds: 10), () {
      countdownTimer?.cancel();
      if (mounted) {
        Navigator.pop(context);
        _skipDelivery(req.deliveryId);
        Fluttertoast.showToast(msg: "Popup timed out after 10s!");
      }
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: Text(req.category),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Recipient: ${req.recipient}"),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16.sp, color: Colors.green),
                  SizedBox(width: 5.w),
                  Expanded(child: Text(req.dropOffLocation)),
                ],
              ),
              SizedBox(height: 8.h),
              // Real-time countdown
              StreamBuilder<int>(
                stream: Stream.periodic(const Duration(seconds: 1), (i) => req.countdown - i).take(req.countdown + 1),
                initialData: req.countdown,
                builder: (context, snapshot) {
                  final timeLeft = snapshot.data ?? 0;
                  return Text(
                    "Time left: ${timeLeft}s",
                    style: TextStyle(color: timeLeft <= 3 ? Colors.red : Colors.green),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                countdownTimer?.cancel();
                autoCloseTimer?.cancel();
                Navigator.pop(dialogContext);
                _skipDelivery(req.deliveryId);
                NotificationService.instance.stopBuzzer();
              },
              child: Text("Reject"),
            ),
            ElevatedButton(
              onPressed: () {
                countdownTimer?.cancel();
                autoCloseTimer?.cancel();
                Navigator.pop(dialogContext);
                _acceptDelivery(req.deliveryId);
                NotificationService.instance.stopBuzzer();
              },
              child: Text("Accept"),
            ),
          ],
        );
      },
    ).then((_) {
      countdownTimer?.cancel();
      autoCloseTimer?.cancel();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: selectIndex == 0
          ? Padding(
        padding: EdgeInsets.only(left: 24.w, right: 24.w, top: 55.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Welcome Back"),
                    Text("$firstName $lastName"),
                  ],
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.notifications),
                ),
                InkWell(
                  onTap: () {
                    selectIndex = 3; // Fixed: Profile is index 3
                    setState(() {});
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: 5.w),
                    width: 35.w,
                    height: 35.h,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFA8DADC),
                    ),
                    child: Center(
                      child: Text(
                        firstName.isNotEmpty
                            ? "${firstName[0]}${lastName[0]}"
                            : "AS",
                      ),
                    ),
                  ),
                ),
              ],
            ),
SizedBox(height: 10.h,),


            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: isDriverOnline ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isDriverOnline ? Colors.green : Colors.red,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                // mainAxisSize: MainAxisSize.min,
                children: [

                  Row(
                    children:[
                      Icon(
                      isDriverOnline ? Icons.circle : Icons.circle_outlined,
                      color: isDriverOnline ? Colors.green : Colors.red,
                      size: 16.sp,
                    ),
                      SizedBox(width: 6.w),
                      Text(
                        isDriverOnline ? "ONLINE" : "OFFLINE",
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: isDriverOnline ? Colors.green : Colors.red,
                        ),
                      ),
                 ] ),

                  // SizedBox(width: 6.w),
                  Switch(
                    value: isDriverOnline,
                    activeColor: Colors.green,
                    inactiveThumbColor: Colors.red,
                    inactiveTrackColor: Colors.red.withOpacity(0.3),
                    onChanged: (value) async {
                      setState(() {
                        isDriverOnline = value;
                      });

                      if (value) {
                        // Turn ON → Connect Socket
                        Fluttertoast.showToast(msg: "Going Online...");
                        await getDriverProfile(); // fresh driverId
                        _ensureSocketConnected();
                      } else {
                        // Turn OFF → Disconnect Socket
                        Fluttertoast.showToast(msg: "You are now Offline");
                        _disconnectSocket();
                        _locationTimer?.cancel();
                        availableRequests.clear(); // Clear pending requests
                        setState(() {});
                      }
                    },
                  ),

                ],
              ),
            ),

            SizedBox(height: 16.h),

            if (status == "pending")
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => IdentityCardPage(),
                    ),
                  ).then((_) {
                    getDriverProfile();
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(10.sp),
                  height: 91.h,
                  width: double.infinity,
                  decoration: BoxDecoration(color: Color(0xffFDF1F1)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Identity Verification",
                                  style: GoogleFonts.inter(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF111111),
                                  ),
                                ),
                                SizedBox(height: 5.h),
                                Text(
                                  "Add your driving license, or any other means of driving identification used in your country",
                                  style: GoogleFonts.inter(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF111111),
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
              ),

            SizedBox(height: 10.h),

            if (status == "pending")
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VihicalPage(),
                    ),
                  ).then((_) {
                    getDriverProfile();
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(10.sp),
                  height: 91.h,
                  width: double.infinity,
                  decoration: BoxDecoration(color: Color(0xffFDF1F1)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Add Vehicle",
                                  style: GoogleFonts.inter(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF111111),
                                  ),
                                ),
                                SizedBox(height: 5.h),
                                Text(
                                  "Upload insurance and registration documents of the vehicle you intend to use.",
                                  style: GoogleFonts.inter(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF111111),
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
              ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.r),
                        color: const Color(0xFFD1E5E6),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Available balance"),
                          SizedBox(height: 3.h),
                          Row(
                            children: [
                              Text(isVisible ? "₹ $balance" : ""),
                              IconButton(
                                onPressed: () => setState(
                                      () => isVisible = !isVisible,
                                ),
                                icon: Icon(
                                  isVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Divider(color: Color(0xFFE5E5E5)),

                    SizedBox(height: 15.h),
                    Text(
                      "Would you like to specify direction for deliveries?",
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF111111),
                      ),
                    ),
                    SizedBox(height: 4.h),

                    TextField(
                      onChanged: (value) async {
                        // Trim whitespace
                        final keyword = value.trim();

                        // Get current location (only if socket is connected)
                        if (socket != null && socket!.connected && driverId != null) {
                          final position = await _getCurrentLocation();
                          if (position != null) {
                            socket!.emit('booking:request', {
                              'driverId': driverId,
                              'lat': position.latitude,
                              'lon': position.longitude,
                              'keyWord': keyword, // यही आपका search keyword
                            });

                            print('Emitted booking:request → keyword: "$keyword" | lat: ${position.latitude}, lon: ${position.longitude}');
                          }
                        }
                      },
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(
                          left: 15.w,
                          right: 15.w,
                          top: 10.h,
                          bottom: 10.h,
                        ),
                        filled: true,
                        fillColor: Color(0xFFF0F5F5),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.r),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.r),
                          borderSide: BorderSide.none,
                        ),
                        hint: Text(
                          "Where to?",
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFFAFAFAF),
                          ),
                        ),
                        prefixIcon: Icon(
                          Icons.circle_outlined,
                          color: Color(0xFF28B877),
                          size: 18.sp,
                        ),
                      ),
                    ),

                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Text(
                          "Available Requests",
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF111111),
                          ),
                        ),
                        Spacer(),
                        Text(
                          "View all",
                          style: GoogleFonts.inter(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF006970),
                          ),
                        ),
                      ],
                    ),

                    // Expanded(
                    //   child: Center(
                    //     child: Column(
                    //       mainAxisAlignment: MainAxisAlignment.center,
                    //       children: [
                    //         Icon(
                    //           Icons.delivery_dining,
                    //           size: 64.sp,
                    //           color: Colors.grey,
                    //         ),
                    //         SizedBox(height: 16.h),
                    //         Text("Waiting for new delivery requests..."),
                    //         SizedBox(height: 8.h),
                    //         Text(  // Uncommented for debugging
                    //           "Socket: ${isSocketConnected ? 'Connected' : 'Disconnected'}",
                    //           style: TextStyle(
                    //             color: isSocketConnected ? Colors.green : Colors.red,
                    //             fontSize: 12.sp,
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),

                    availableRequests.isEmpty
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.delivery_dining,
                            size: 64.sp,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            "Waiting for new delivery requests...",
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            "Socket: ${isSocketConnected ? 'Connected' : 'Disconnected'}",
                            style: TextStyle(
                              color: isSocketConnected
                                  ? Colors.green
                                  : Colors.red,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    )
                        : ListView.builder(
                      padding: EdgeInsets.only(top: 10.h),
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: availableRequests.length,
                      itemBuilder: (context, index) {
                        final req = availableRequests[index];
                        final pickup =
                            req['pickup']?['name'] ??
                                'Unknown Pickup';
                        final dropoff =
                            req['dropoff']?['name'] ??
                                'Unknown Dropoff';
                        final price =
                            req['userPayAmount']?.toString() ?? '0';
                        final distance =
                            req['distance']?.toString() ?? 'N/A';

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              20.r,
                            ),
                          ),
                          color: Color(0xFFF0F5F5),
                          margin: EdgeInsets.only(bottom: 10.h),
                          child: Padding(
                            padding: EdgeInsets.all(12.sp),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Pickup: $pickup",
                                        style: TextStyle(
                                          fontWeight:
                                          FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "₹$price",
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5.h),
                                Text("Dropoff: $dropoff"),
                                SizedBox(height: 5.h),
                                Text("Distance: $distance km"),
                                SizedBox(height: 8.h),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () =>
                                          _deliveryAcceptDelivery(
                                            req['_id'],
                                          ),
                                      style:
                                      ElevatedButton.styleFrom(
                                        backgroundColor: Color(
                                          0xFF006970,
                                        ),
                                        padding:
                                        EdgeInsets.symmetric(
                                          horizontal: 20.w,
                                          vertical: 8.h,
                                        ),
                                      ),
                                      child: const Text(
                                        "Accept",
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    OutlinedButton(
                                      onPressed: () async {
                                        try {
                                          final body =
                                          RejectDeliveryBodyModel(
                                            deliveryId:
                                            req['_id'],
                                            lat: lattitude
                                                .toString(),
                                            lon: longutude
                                                .toString(),
                                          );

                                          final service =
                                          APIStateNetwork(
                                            callDio(),
                                          );
                                          final response =
                                          await service
                                              .rejectDelivery(
                                            body,
                                          );

                                          // ✅ Always show the actual message from API
                                          Fluttertoast.showToast(
                                            msg:
                                            response.message ??
                                                "No message received",
                                          );

                                          // (Optional) — you can handle success/failure visually if needed
                                          if (response.code == 0) {
                                            print(
                                              "✅ Delivery rejected successfully",
                                            );
                                          } else {
                                            print(
                                              "⚠ Failed to reject delivery: ${response.message}",
                                            );
                                          }
                                        } catch (e) {
                                          Fluttertoast.showToast(
                                            msg: "Error: $e",
                                          );
                                          print(
                                            "❌ Reject request error: $e",
                                          );
                                        }
                                      },
                                      style: OutlinedButton.styleFrom(
                                        // side: const BorderSide(
                                        //   color: Colors.red,
                                        // ),
                                        side: BorderSide.none,
                                        backgroundColor: Color(
                                          0xFFD1E5E6,
                                        ),
                                      ),

                                      child: const Text("Reject"),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),


                  ],
                ),
              ),
            ),
          ],
        ),
      )
          : selectIndex == 1
          ? EarningPage()
          : selectIndex == 2
          ? BookingPage(socket) // Now safe: either connected or null)
          : ProfilePage(socket!),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.r),
          topRight: Radius.circular(10.r),
        ),
        color: const Color(0xFFFFFFFF),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 30,
            spreadRadius: 0,
            color: const Color.fromARGB(17, 0, 0, 0),
          ),
        ],
      ),
      child: BottomNavigationBar(
        onTap: (value) {
          setState(() => selectIndex = value);
          if (value == 0 && isDriverOnline) {
            print('Home tab pressed → Ensuring socket');
            Future.delayed(const Duration(milliseconds: 300), () {
              _ensureSocketConnected();
            });
          }
          // if (value == 0) {
          //   print('🏠 Nav to Home - ensuring fresh socket...');
          //   _ensureSocketConnected(); // Force fresh socket on home enter
          // }
        },
        backgroundColor: const Color(0xFFFFFFFF),
        currentIndex: selectIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF006970),
        unselectedItemColor: const Color(0xFFC0C5C2),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 10.sp,
          fontWeight: FontWeight.w400,
          color: const Color(0xFFC0C5C2),
        ),
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF006970),
        ),
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/SvgImage/iconhome.svg",
              color: const Color(0xFFC0C5C2),
            ),
            activeIcon: SvgPicture.asset(
              "assets/SvgImage/iconhome.svg",
              color: const Color(0xFF006970),
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/SvgImage/iconearning.svg",
              color: const Color(0xFFC0C5C2),
            ),
            activeIcon: SvgPicture.asset(
              "assets/SvgImage/iconearning.svg",
              color: const Color(0xFF006970),
            ),
            label: "Earning",
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/SvgImage/iconbooking.svg",
              color: const Color(0xFFC0C5C2),
            ),
            activeIcon: SvgPicture.asset(
              "assets/SvgImage/iconbooking.svg",
              color: const Color(0xFF006970),
            ),
            label: "Booking",
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/SvgImage/iconProfile.svg",
              color: const Color(0xFFC0C5C2),
            ),
            activeIcon: SvgPicture.asset(
              "assets/SvgImage/iconProfile.svg",
              color: const Color(0xFF006970),
            ),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}

class DeliveryRequest {
  final String deliveryId;
  final String category;
  final String recipient;
  final String dropOffLocation;
  final int countdown;

  DeliveryRequest({
    required this.deliveryId,
    required this.category,
    required this.recipient,
    required this.dropOffLocation,
    required this.countdown,
  });
}*/

/*

import 'dart:developer';
import 'dart:async';
import 'package:delivery_rider_app/RiderScreen/booking.page.dart';
import 'package:delivery_rider_app/RiderScreen/earning.page.dart';
import 'package:delivery_rider_app/RiderScreen/profile.page.dart';
import 'package:delivery_rider_app/RiderScreen/requestDetails.page.dart';
import 'package:delivery_rider_app/RiderScreen/vihical.page.dart';
import 'package:delivery_rider_app/data/model/RejectDeliveryBodyModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:geolocator/geolocator.dart';
import '../config/network/api.state.dart';
import '../config/utils/pretty.dio.dart';
import 'identityCard.page.dart';
import 'notificationService.dart';

class HomePage extends StatefulWidget {
  int? selectIndex;
  final bool forceSocketRefresh;
  HomePage(this.selectIndex, {super.key, this.forceSocketRefresh = false});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with WidgetsBindingObserver, RouteAware {
  bool isVisible = true;
  int selectIndex = 0;
  String firstName = '';
  String lastName = '';
  String status = '';
  double balance = 0;
  String? driverId;
  bool isStatus = false;
  IO.Socket? socket;
  bool isSocketConnected = false;
  Timer? _locationTimer;
  List<Map<String, dynamic>> availableRequests = [];
  double? lattitude;
  double? longutude;
  bool isDriverOnline = true;

  @override
  void initState() {
    super.initState();
    selectIndex = widget.selectIndex!;
    WidgetsBinding.instance.addObserver(this);
    getDriverProfile();

    if (widget.forceSocketRefresh) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _forceRefreshSocket();
      });
    }

    if (isDriverOnline && driverId != null) {
      _ensureSocketConnected();
    }
  }

  void _connectSocket() {
    const socketUrl = 'https://weloads.com';
    _disconnectSocket();
    socket = IO.io(socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    socket!.io.options!['reconnection'] = true;
    socket!.io.options!['reconnectionAttempts'] = 10;
    socket!.io.options!['reconnectionDelay'] = 1000;
    socket!.io.options!['reconnectionDelayMax'] = 5000;
    socket!.io.options!['randomizationFactor'] = 0.5;
    socket!.io.options!['timeout'] = 20000;
    socket!.connect();

    socket!.onConnect((_) {
      print('SOCKET CONNECTED: ${socket!.id}');
      if (mounted) setState(() => isSocketConnected = true);
      _registerAndSendLocation();
    });

    socket!.onDisconnect((_) {
      print('SOCKET DISCONNECTED');
      if (mounted) setState(() => isSocketConnected = false);
      _locationTimer?.cancel();
    });

    socket!.io.on('reconnect_attempt', (attempt) {
      print('RECONNECTING... Attempt #$attempt');
    });

    socket!.io.on('reconnect', (attempt) {
      print('RECONNECTED after $attempt attempts!');
      if (mounted) setState(() => isSocketConnected = true);
      _registerAndSendLocation();
    });

    socket!.io.on('reconnect_failed', (_) {
      print('RECONNECT FAILED PERMANENTLY');
      Fluttertoast.showToast(msg: "No internet. Retrying...");
    });

    socket!.onConnectError((err) => print('CONNECT ERROR: $err'));
    socket!.onError((err) => print('SOCKET ERROR: $err'));

    socket!.on('booking:request', _acceptRequest);
    socket!.on('delivery:new_request', _handleNewRequest);
    socket!.on('delivery:you_assigned', _handleAssigned);
    socket!.onAny((event, data) => print('EVENT → $event: $data'));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final modalRoute = ModalRoute.of(context);
    if (modalRoute is PageRoute) {
      modalRoute.addScopedWillPopCallback(() async => false);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted && isDriverOnline) _ensureSocketConnected();
      });
    }
    if (state == AppLifecycleState.paused) {
      _locationTimer?.cancel();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _locationTimer?.cancel();
    _disconnectSocket();
    super.dispose();
  }

  void _disconnectSocket() {
    if (socket != null) {
      if (socket!.connected) socket!.disconnect();
      socket!.clearListeners();
      socket!.dispose();
      socket = null;
    }
    _locationTimer?.cancel();
    if (mounted) setState(() => isSocketConnected = false);
    print('Old socket disconnected and cleaned');
  }

  void _forceRefreshSocket() async {
    print('Force refreshing socket...');
    _disconnectSocket();
    await getDriverProfile();
    _ensureSocketConnected();
    setState(() {});
  }

  void _ensureSocketConnected() {
    if (driverId == null || driverId!.isEmpty) return;
    if (socket?.connected == true) {
      _registerAndSendLocation();
    } else {
      _connectSocket();
    }
  }

  Future<void> getDriverProfile() async {
    try {
      final dio = await callDio();
      final service = APIStateNetwork(dio);
      final response = await service.getDriverProfile();

      if (response.error == false && response.data != null) {
        if (mounted) {
          setState(() {
            firstName = response.data!.firstName ?? '';
            lastName = response.data!.lastName ?? '';
            status = response.data!.status ?? '';
            balance = response.data!.wallet?.balance?.toDouble() ?? 0;
            driverId = response.data!.id ?? '';
          });
        }
        if (driverId != null && driverId!.isNotEmpty) {
          _ensureSocketConnected();
        }
      } else {
        Fluttertoast.showToast(msg: response.message ?? "Failed to fetch profile");
      }
    } catch (e, st) {
      log("Get Driver Profile Error: $e\n$st");
      Fluttertoast.showToast(msg: "Something went wrong while fetching profile");
    }
  }

  void _registerAndSendLocation() async {
    if (driverId == null || !socket!.connected) return;
    socket!.emit('register', {'userId': driverId, 'role': 'driver'});
    print('REGISTERED: $driverId');
    final pos = await _getCurrentLocation();
    if (pos != null) {
      lattitude = pos.latitude;
      longutude = pos.longitude;
      socket!.emit('booking:request', {
        'driverId': driverId,
        'lat': pos.latitude,
        'lon': pos.longitude,
      });
      socket!.emit('user:location_update', {
        'userId': driverId,
        'lat': pos.latitude,
        'lon': pos.longitude,
      });
    }
    _startLocationTimer();
  }

  void _startLocationTimer() {
    _locationTimer?.cancel();
    _locationTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (!socket!.connected || driverId == null) {
        timer.cancel();
        return;
      }
      final pos = await _getCurrentLocation();
      if (pos != null) {
        socket!.emit('user:location_update', {
          'userId': driverId,
          'lat': pos.latitude,
          'lon': pos.longitude,
        });
      }
    });
  }

  Future<Position?> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Fluttertoast.showToast(msg: "Please enable location services");
        return null;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Fluttertoast.showToast(msg: "Location permission denied");
          return null;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        Fluttertoast.showToast(msg: "Location permission permanently denied");
        return null;
      }
      return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    } catch (e) {
      log("Error getting location: $e");
      return null;
    }
  }

  // ========================================
  // NEW REQUEST HANDLER (WITH AUTO DIALOG)
  // ========================================
  void _handleNewRequest(dynamic payload) {
    print("New Delivery Request: $payload");

    final requestData = Map<String, dynamic>.from(payload as Map);
    final dropoff = requestData['dropoff'] as Map<String, dynamic>? ?? {};
    final pickup = requestData['pickup'] as Map<String, dynamic>? ?? {};
    final expiresAt = requestData['expiresAt'] as int? ?? 0;
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final countdownMs = expiresAt - nowMs;
    final countdown = (countdownMs > 0 ? (countdownMs / 1000).round() : 0);
    if (countdown <= 0) return;

    final requestWithTimer = DeliveryRequest(
      deliveryId: requestData['deliveryId'] as String? ?? '',
      category: 'Delivery',
      recipient: dropoff['name'] ?? 'Unknown',
      dropOffLocation: dropoff['name'] ?? 'Unknown Location',
      pickupName: pickup['name'],
      countdown: countdown,
    );

    // 1. Sound + Vibrate + Notification
    NotificationService.instance.triggerDeliveryAlert(requestWithTimer);

    // 2. Auto Show Dialog (No await, No delay)
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showRequestPopup(requestWithTimer);
        }
      });
    }
  }

  Future<void> _handleAssigned(dynamic payload) async {
    print("Delivery Assigned: ${payload['deliveryId']}");
    final deliveryId = payload['deliveryId'] as String;
    try {
      final dio = await callDio();
      final service = APIStateNetwork(dio);
      final response = await service.getDeliveryById(deliveryId);
      if (response.error == false && response.data != null) {
        if (socket == null || !socket!.connected) {
          _ensureSocketConnected();
          await Future.delayed(const Duration(seconds: 1));
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RequestDetailsPage(
              socket: socket,
              deliveryData: response.data!,
              txtID: response.data!.txId.toString(),
            ),
          ),
        ).then((_) => getDriverProfile());
      } else {
        Fluttertoast.showToast(msg: response.message ?? "Failed to fetch delivery details");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error fetching delivery details");
    }
  }

  Future<void> _acceptRequest(dynamic payload) async {
    log("Booking Request Received: $payload");
    try {
      final data = Map<String, dynamic>.from(payload);
      final deliveries = List<Map<String, dynamic>>.from(data['deliveries'] ?? []);
      if (deliveries.isEmpty) return;
      if (mounted) {
        setState(() => availableRequests = deliveries);
      }
    } catch (e, st) {
      log("Error parsing booking:request → $e\n$st");
    }
  }

  void _acceptDelivery(String deliveryId) {
    if (socket != null && socket!.connected) {
      socket!.emitWithAck('delivery:accept', {'deliveryId': deliveryId}, ack: (ackData) {
        print('Accept ack: $ackData');
      });
      Fluttertoast.showToast(msg: "Delivery Accepted!");
    }
  }

  void _deliveryAcceptDelivery(String deliveryId) {
    if (socket != null && socket!.connected) {
      socket!.emitWithAck('delivery:accept_request', {'deliveryId': deliveryId}, ack: (ackData) {
        print('Accept ack: $ackData');
      });
      Fluttertoast.showToast(msg: "Delivery Accepted!");
    }
  }

  void _skipDelivery(String deliveryId) {
    if (socket != null && socket!.connected) {
      socket!.emitWithAck('delivery:skip', {'deliveryId': deliveryId}, ack: (ackData) {
        print('Skip ack: $ackData');
      });
      Fluttertoast.showToast(msg: "Delivery Rejected!");
    }
  }

  // ========================================
  // AUTO DIALOG WITH REAL-TIME COUNTDOWN
  // ========================================
  void _showRequestPopup(DeliveryRequest req) {
    final ValueNotifier<int> countdownNotifier = ValueNotifier(req.countdown);
    Timer? countdownTimer;
    Timer? autoCloseTimer;

    // Start countdown immediately
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdownNotifier.value <= 0) {
        timer.cancel();
        autoCloseTimer?.cancel();
        if (mounted) {
          Navigator.pop(context);
          _skipDelivery(req.deliveryId);
          Fluttertoast.showToast(msg: "Time expired! Auto-rejected.");
        }
        return;
      }
      countdownNotifier.value--;
    });

    // Auto-close after 10 seconds
    autoCloseTimer = Timer(const Duration(seconds: 10), () {
      countdownTimer?.cancel();
      if (mounted) {
        Navigator.pop(context);
        _skipDelivery(req.deliveryId);
        Fluttertoast.showToast(msg: "Popup timed out after 10s!");
      }
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: Text(req.category, style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (req.pickupName != null)
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16.sp, color: Colors.blue),
                    SizedBox(width: 5.w),
                    Expanded(child: Text("Pickup: ${req.pickupName}")),
                  ],
                ),
              if (req.pickupName != null) SizedBox(height: 8.h),
              Text("Recipient: ${req.recipient}"),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16.sp, color: Colors.green),
                  SizedBox(width: 5.w),
                  Expanded(child: Text(req.dropOffLocation)),
                ],
              ),
              SizedBox(height: 12.h),
              ValueListenableBuilder<int>(
                valueListenable: countdownNotifier,
                builder: (context, value, child) {
                  return Text(
                    "Time left: ${value}s",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: value <= 3 ? Colors.red : Colors.green,
                    ),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () {
                countdownTimer?.cancel();
                autoCloseTimer?.cancel();
                Navigator.pop(dialogContext);
                _skipDelivery(req.deliveryId);
                NotificationService.instance.stopBuzzer();
              },
              child: const Text("Reject"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                countdownTimer?.cancel();
                autoCloseTimer?.cancel();
                Navigator.pop(dialogContext);
                _acceptDelivery(req.deliveryId);
                NotificationService.instance.stopBuzzer();
              },
              child: const Text("Accept", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    ).then((_) {
      countdownTimer?.cancel();
      autoCloseTimer?.cancel();
      countdownNotifier.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: selectIndex == 0
          ? Padding(
        padding: EdgeInsets.only(left: 24.w, right: 24.w, top: 55.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Welcome Back", style: TextStyle(fontSize: 14.sp)),
                    Text("$firstName $lastName", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                  ],
                ),
                const Spacer(),
                IconButton(onPressed: () {}, icon: Icon(Icons.notifications)),
                InkWell(
                  onTap: () => setState(() => selectIndex = 3),
                  child: Container(
                    margin: EdgeInsets.only(left: 5.w),
                    width: 35.w,
                    height: 35.h,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFA8DADC)),
                    child: Center(child: Text(firstName.isNotEmpty ? "${firstName[0]}${lastName[0]}" : "AS")),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),

            // Online/Offline Switch
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: isDriverOnline ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: isDriverOnline ? Colors.green : Colors.red, width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(isDriverOnline ? Icons.circle : Icons.circle_outlined, color: isDriverOnline ? Colors.green : Colors.red, size: 16.sp),
                      SizedBox(width: 6.w),
                      Text(isDriverOnline ? "ONLINE" : "OFFLINE", style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: isDriverOnline ? Colors.green : Colors.red)),
                    ],
                  ),
                  Switch(
                    value: isDriverOnline,
                    activeColor: Colors.green,
                    inactiveThumbColor: Colors.red,
                    inactiveTrackColor: Colors.red.withOpacity(0.3),
                    onChanged: (value) async {
                      setState(() => isDriverOnline = value);
                      if (value) {
                        Fluttertoast.showToast(msg: "Going Online...");
                        await getDriverProfile();
                        _ensureSocketConnected();
                      } else {
                        Fluttertoast.showToast(msg: "You are now Offline");
                        _disconnectSocket();
                        _locationTimer?.cancel();
                        availableRequests.clear();
                        setState(() {});
                      }
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Identity & Vehicle Cards
            if (status == "pending") ...[
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => IdentityCardPage())).then((_) => getDriverProfile()),
                child: _buildVerificationCard("Identity Verification", "Add your driving license..."),
              ),
              SizedBox(height: 10.h),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VihicalPage())).then((_) => getDriverProfile()),
                child: _buildVerificationCard("Add Vehicle", "Upload insurance and registration..."),
              ),
            ],

            // Balance + Search + Requests
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBalanceCard(),
                    Divider(color: Color(0xFFE5E5E5)),
                    SizedBox(height: 15.h),
                    Text("Would you like to specify direction for deliveries?", style: GoogleFonts.inter(fontSize: 13.sp, color: Color(0xFF111111))),
                    SizedBox(height: 4.h),
                    _buildSearchField(),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Text("Available Requests", style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w500)),
                        Spacer(),
                        Text("View all", style: GoogleFonts.inter(fontSize: 13.sp, color: Color(0xFF006970))),
                      ],
                    ),
                    availableRequests.isEmpty
                        ? _buildEmptyState()
                        : _buildRequestList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      )
          : selectIndex == 1
          ? EarningPage()
          : selectIndex == 2
          ? BookingPage(socket)
          : ProfilePage(socket!),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildVerificationCard(String title, String subtitle) {
    return Container(
      padding: EdgeInsets.all(10.sp),
      height: 91.h,
      width: double.infinity,
      decoration: BoxDecoration(color: Color(0xffFDF1F1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w600)),
          SizedBox(height: 5.h),
          Text(subtitle, style: GoogleFonts.inter(fontSize: 12.sp, color: Color(0xFF111111))),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.r), color: const Color(0xFFD1E5E6)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Available balance"),
          SizedBox(height: 3.h),
          Row(
            children: [
              Text(isVisible ? "₹ $balance" : "₹ ••••", style: TextStyle(fontWeight: FontWeight.bold)),
              IconButton(onPressed: () => setState(() => isVisible = !isVisible), icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      onChanged: (value) async {
        final keyword = value.trim();
        if (socket != null && socket!.connected && driverId != null) {
          final position = await _getCurrentLocation();
          if (position != null) {
            socket!.emit('booking:request', {
              'driverId': driverId,
              'lat': position.latitude,
              'lon': position.longitude,
              'keyWord': keyword,
            });
          }
        }
      },
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
        filled: true,
        fillColor: Color(0xFFF0F5F5),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5.r), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5.r), borderSide: BorderSide.none),
        hintText: "Where to?",
        hintStyle: GoogleFonts.inter(fontSize: 14.sp, color: Color(0xFFAFAFAF)),
        prefixIcon: Icon(Icons.circle_outlined, color: Color(0xFF28B877), size: 18.sp),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delivery_dining, size: 64.sp, color: Colors.grey),
          SizedBox(height: 16.h),
          Text("Waiting for new delivery requests..."),
          SizedBox(height: 8.h),
          Text("Socket: ${isSocketConnected ? 'Connected' : 'Disconnected'}", style: TextStyle(color: isSocketConnected ? Colors.green : Colors.red, fontSize: 12.sp)),
        ],
      ),
    );
  }

  Widget _buildRequestList() {
    return ListView.builder(
      padding: EdgeInsets.only(top: 10.h),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: availableRequests.length,
      itemBuilder: (context, index) {
        final req = availableRequests[index];
        final pickup = req['pickup']?['name'] ?? 'Unknown Pickup';
        final dropoff = req['dropoff']?['name'] ?? 'Unknown Dropoff';
        final price = req['userPayAmount']?.toString() ?? '0';
        final distance = req['distance']?.toString() ?? 'N/A';

        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          color: Color(0xFFF0F5F5),
          margin: EdgeInsets.only(bottom: 10.h),
          child: Padding(
            padding: EdgeInsets.all(12.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Pickup: $pickup", style: TextStyle(fontWeight: FontWeight.w600)), Text("₹$price", style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600))]),
                SizedBox(height: 5.h),
                Text("Dropoff: $dropoff"),
                SizedBox(height: 5.h),
                Text("Distance: $distance km"),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(onPressed: () => _deliveryAcceptDelivery(req['_id']), style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF006970)), child: const Text("Accept", style: TextStyle(color: Colors.white))),
                    SizedBox(width: 10.w),
                    OutlinedButton(onPressed: () => _rejectDelivery(req['_id']), style: OutlinedButton.styleFrom(backgroundColor: Color(0xFFD1E5E6)), child: const Text("Reject")),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _rejectDelivery(String deliveryId) async {
    try {
      final body = RejectDeliveryBodyModel(deliveryId: deliveryId, lat: lattitude.toString(), lon: longutude.toString());
      final service = APIStateNetwork(callDio());
      final response = await service.rejectDelivery(body);
      Fluttertoast.showToast(msg: response.message ?? "Rejected");
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(10.r), topRight: Radius.circular(10.r)),
        color: Colors.white,
        boxShadow: [BoxShadow(offset: Offset(0, -2), blurRadius: 30, color: Colors.black12)],
      ),
      child: BottomNavigationBar(
        onTap: (value) {
          setState(() => selectIndex = value);
          if (value == 0 && isDriverOnline) {
            Future.delayed(const Duration(milliseconds: 300), _ensureSocketConnected);
          }
        },
        currentIndex: selectIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFF006970),
        unselectedItemColor: Color(0xFFC0C5C2),
        items: [
          _navItem("assets/SvgImage/iconhome.svg", "Home"),
          _navItem("assets/SvgImage/iconearning.svg", "Earning"),
          _navItem("assets/SvgImage/iconbooking.svg", "Booking"),
          _navItem("assets/SvgImage/iconProfile.svg", "Profile"),
        ],
      ),
    );
  }

  BottomNavigationBarItem _navItem(String asset, String label) {
    return BottomNavigationBarItem(
      icon: SvgPicture.asset(asset, color: Color(0xFFC0C5C2)),
      activeIcon: SvgPicture.asset(asset, color: Color(0xFF006970)),
      label: label,
    );
  }
}

class DeliveryRequest {
  final String deliveryId;
  final String category;
  final String recipient;
  final String dropOffLocation;
  final String? pickupName;
  final int countdown;

  DeliveryRequest({
    required this.deliveryId,
    required this.category,
    required this.recipient,
    required this.dropOffLocation,
    this.pickupName,
    required this.countdown,
  });
}*/

/*

import 'dart:developer';
import 'dart:async';
import 'package:delivery_rider_app/RiderScreen/booking.page.dart';
import 'package:delivery_rider_app/RiderScreen/earning.page.dart';
import 'package:delivery_rider_app/RiderScreen/profile.page.dart';
import 'package:delivery_rider_app/RiderScreen/requestDetails.page.dart';
import 'package:delivery_rider_app/RiderScreen/vihical.page.dart';
import 'package:delivery_rider_app/data/model/RejectDeliveryBodyModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:geolocator/geolocator.dart';
import '../config/network/api.state.dart';
import '../config/utils/pretty.dio.dart';
import 'identityCard.page.dart';
import 'notificationService.dart';

class HomePage extends StatefulWidget {
  int? selectIndex;
  final bool forceSocketRefresh;
  HomePage(this.selectIndex, {super.key, this.forceSocketRefresh = false});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with WidgetsBindingObserver, RouteAware {
  bool isVisible = true;
  int selectIndex = 0;
  String firstName = '';
  String lastName = '';
  String status = '';
  double balance = 0;
  String? driverId;
  bool isStatus = false;
  IO.Socket? socket;
  bool isSocketConnected = false;
  Timer? _locationTimer;
  List<Map<String, dynamic>> availableRequests = [];
  double? lattitude;
  double? longutude;
  bool isDriverOnline = true;

  // Popup control
  bool _isPopupShowing = false;

  @override
  void initState() {
    super.initState();
    selectIndex = widget.selectIndex!;
    WidgetsBinding.instance.addObserver(this);
    getDriverProfile();

    if (widget.forceSocketRefresh) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _forceRefreshSocket();
      });
    }

    if (isDriverOnline && driverId != null) {
      _ensureSocketConnected();
    }
  }

  void _connectSocket() {
    // const socketUrl = 'https://weloads.com';
    const socketUrl = 'http://192.168.1.43:4567';
    _disconnectSocket();
    socket = IO.io(socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    socket!.io.options!['reconnection'] = true;
    socket!.io.options!['reconnectionAttempts'] = 10;
    socket!.io.options!['reconnectionDelay'] = 1000;
    socket!.io.options!['reconnectionDelayMax'] = 5000;
    socket!.io.options!['randomizationFactor'] = 0.5;
    socket!.io.options!['timeout'] = 20000;
    socket!.connect();

    socket!.onConnect((_) {
      print('SOCKET CONNECTED: ${socket!.id}');
      if (mounted) setState(() => isSocketConnected = true);
      _registerAndSendLocation();
    });

    socket!.onDisconnect((_) {
      print('SOCKET DISCONNECTED');
      if (mounted) setState(() => isSocketConnected = false);
      _locationTimer?.cancel();
    });

    socket!.io.on('reconnect_attempt', (attempt) {
      print('RECONNECTING... Attempt #$attempt');
    });

    socket!.io.on('reconnect', (attempt) {
      print('RECONNECTED after $attempt attempts!');
      if (mounted) setState(() => isSocketConnected = true);
      _registerAndSendLocation();
    });

    socket!.io.on('reconnect_failed', (_) {
      print('RECONNECT FAILED PERMANENTLY');
      Fluttertoast.showToast(msg: "No internet. Retrying...");
    });

    socket!.onConnectError((err) => print('CONNECT ERROR: $err'));
    socket!.onError((err) => print('SOCKET ERROR: $err'));

    socket!.on('booking:request', _acceptRequest);
    socket!.on('delivery:new_request', _handleNewRequest);
    socket!.on('delivery:you_assigned', _handleAssigned);
    socket!.onAny((event, data) => print('EVENT → $event: $data'));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final modalRoute = ModalRoute.of(context);
    if (modalRoute is PageRoute) {
      modalRoute.addScopedWillPopCallback(() async => false);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted && isDriverOnline) _ensureSocketConnected();
      });
    }
    if (state == AppLifecycleState.paused) {
      _locationTimer?.cancel();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _locationTimer?.cancel();
    _disconnectSocket();
    super.dispose();
  }

  void _disconnectSocket() {
    if (socket != null) {
      if (socket!.connected) socket!.disconnect();
      socket!.clearListeners();
      socket!.dispose();
      socket = null;
    }
    _locationTimer?.cancel();
    if (mounted) setState(() => isSocketConnected = false);
    print('Old socket disconnected and cleaned');
  }

  void _forceRefreshSocket() async {
    print('Force refreshing socket...');
    _disconnectSocket();
    await getDriverProfile();
    _ensureSocketConnected();
    setState(() {});
  }

  void _ensureSocketConnected() {
    if (driverId == null || driverId!.isEmpty) return;
    if (socket?.connected == true) {
      _registerAndSendLocation();
    } else {
      _connectSocket();
    }
  }

  Future<void> getDriverProfile() async {
    try {
      final dio = await callDio();
      final service = APIStateNetwork(dio);
      final response = await service.getDriverProfile();

      if (response.error == false && response.data != null) {
        if (mounted) {
          setState(() {
            firstName = response.data!.firstName ?? '';
            lastName = response.data!.lastName ?? '';
            status = response.data!.status ?? '';
            balance = response.data!.wallet?.balance?.toDouble() ?? 0;
            driverId = response.data!.id ?? '';
          });
        }
        if (driverId != null && driverId!.isNotEmpty) {
          _ensureSocketConnected();
        }
      } else {
        Fluttertoast.showToast(msg: response.message ?? "Failed to fetch profile");
      }
    } catch (e, st) {
      log("Get Driver Profile Error: $e\n$st");
      Fluttertoast.showToast(msg: "Something went wrong while fetching profile");
    }
  }

  void _registerAndSendLocation() async {
    if (driverId == null || !socket!.connected) return;
    socket!.emit('register', {'userId': driverId, 'role': 'driver'});
    print('REGISTERED: $driverId');
    final pos = await _getCurrentLocation();
    if (pos != null) {
      lattitude = pos.latitude;
      longutude = pos.longitude;
      socket!.emit('booking:request', {
        'driverId': driverId,
        'lat': pos.latitude,
        'lon': pos.longitude,
      });
      socket!.emit('user:location_update', {
        'userId': driverId,
        'lat': pos.latitude,
        'lon': pos.longitude,
      });
    }
    _startLocationTimer();
  }

  void _startLocationTimer() {
    _locationTimer?.cancel();
    _locationTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (!socket!.connected || driverId == null) {
        timer.cancel();
        return;
      }
      final pos = await _getCurrentLocation();
      if (pos != null) {
        socket!.emit('user:location_update', {
          'userId': driverId,
          'lat': pos.latitude,
          'lon': pos.longitude,
        });
      }
    });
  }

  Future<Position?> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Fluttertoast.showToast(msg: "Please enable location services");
        return null;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Fluttertoast.showToast(msg: "Location permission denied");
          return null;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        Fluttertoast.showToast(msg: "Location permission permanently denied");
        return null;
      }
      return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    } catch (e) {
      log("Error getting location: $e");
      return null;
    }
  }

  // ========================================
  // NEW REQUEST HANDLER (AUTO POPUP + LIST UPDATE)
  // ========================================
  void _handleNewRequest(dynamic payload) {
    print("New Delivery Request: $payload");

    final requestData = Map<String, dynamic>.from(payload as Map);
    final dropoff = requestData['dropoff'] as Map<String, dynamic>? ?? {};
    final pickup = requestData['pickup'] as Map<String, dynamic>? ?? {};
    final expiresAt = requestData['expiresAt'] as int? ?? 0;
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final countdownMs = expiresAt - nowMs;
    final countdown = (countdownMs > 0 ? (countdownMs / 1000).round() : 0);
    if (countdown <= 0) return;

    final requestWithTimer = DeliveryRequest(
      deliveryId: requestData['deliveryId'] as String? ?? '',
      category: 'Delivery',
      recipient: dropoff['name'] ?? 'Unknown',
      dropOffLocation: dropoff['name'] ?? 'Unknown Location',
      pickupName: pickup['name'],
      countdown: countdown,
    );

    // 1. Sound + Vibrate + Notification
    NotificationService.instance.triggerDeliveryAlert(requestWithTimer);

    // 2. Add to list (top pe)
    if (mounted) {
      setState(() {
        availableRequests.insert(0, requestData);
      });
    }

    // 3. Show popup IMMEDIATELY (if not already showing)
    if (mounted && ModalRoute.of(context)?.isCurrent == true && !_isPopupShowing) {
      Future.microtask(() {
        if (mounted) {
          _showRequestPopup(requestWithTimer);
        }
      });
    }
  }

  Future<void> _handleAssigned(dynamic payload) async {
    print("Delivery Assigned: ${payload['deliveryId']}");
    final deliveryId = payload['deliveryId'] as String;
    try {
      final dio = await callDio();
      final service = APIStateNetwork(dio);
      final response = await service.getDeliveryById(deliveryId);
      if (response.error == false && response.data != null) {
        if (socket == null || !socket!.connected) {
          _ensureSocketConnected();
          await Future.delayed(const Duration(seconds: 1));
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RequestDetailsPage(
              socket: socket,
              deliveryData: response.data!,
              txtID: response.data!.txId.toString(),
            ),
          ),
        ).then((_) => getDriverProfile());
      } else {
        Fluttertoast.showToast(msg: response.message ?? "Failed to fetch delivery details");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error fetching delivery details");
    }
  }

  Future<void> _acceptRequest(dynamic payload) async {
    log("Booking Request Received: $payload");
    try {
      final data = Map<String, dynamic>.from(payload);
      final deliveries = List<Map<String, dynamic>>.from(data['deliveries'] ?? []);
      if (deliveries.isEmpty) return;
      if (mounted) {
        setState(() => availableRequests = deliveries);
      }
    } catch (e, st) {
      log("Error parsing booking:request → $e\n$st");
    }
  }

  void _acceptDelivery(String deliveryId) {
    if (socket != null && socket!.connected) {
      socket!.emitWithAck('delivery:accept', {'deliveryId': deliveryId}, ack: (ackData) {
        print('Accept ack: $ackData');
      });
      Fluttertoast.showToast(msg: "Delivery Accepted!");
    }
  }

  void _deliveryAcceptDelivery(String deliveryId) {
    if (socket != null && socket!.connected) {
      socket!.emitWithAck('delivery:accept_request', {'deliveryId': deliveryId}, ack: (ackData) {
        print('Accept ack: $ackData');
      });
      Fluttertoast.showToast(msg: "Delivery Accepted!");
    }
  }

  void _skipDelivery(String deliveryId) {
    if (socket != null && socket!.connected) {
      socket!.emitWithAck('delivery:skip', {'deliveryId': deliveryId}, ack: (ackData) {
        print('Skip ack: $ackData');
      });
      Fluttertoast.showToast(msg: "Delivery Rejected!");
    }
  }

  // ========================================
  // AUTO DIALOG WITH COUNTDOWN
  // ========================================
  void _showRequestPopup(DeliveryRequest req) {
    if (_isPopupShowing) {
      Navigator.pop(context); // Close previous
    }
    _isPopupShowing = true;

    final ValueNotifier<int> countdownNotifier = ValueNotifier(req.countdown);
    Timer? countdownTimer;
    Timer? autoCloseTimer;

    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdownNotifier.value <= 0) {
        timer.cancel();
        autoCloseTimer?.cancel();
        if (mounted) {
          Navigator.pop(context);
          _skipDelivery(req.deliveryId);
          Fluttertoast.showToast(msg: "Time expired! Auto-rejected.");
        }
        return;
      }
      countdownNotifier.value--;
    });

    autoCloseTimer = Timer(const Duration(seconds: 10), () {
      countdownTimer?.cancel();
      if (mounted) {
        Navigator.pop(context);
        _skipDelivery(req.deliveryId);
        Fluttertoast.showToast(msg: "Popup timed out after 10s!");
      }
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: Text(req.category, style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (req.pickupName != null)
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16.sp, color: Colors.blue),
                    SizedBox(width: 5.w),
                    Expanded(child: Text("Pickup: ${req.pickupName}")),
                  ],
                ),
              if (req.pickupName != null) SizedBox(height: 8.h),
              Text("Recipient: ${req.recipient}"),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16.sp, color: Colors.green),
                  SizedBox(width: 5.w),
                  Expanded(child: Text(req.dropOffLocation)),
                ],
              ),
              SizedBox(height: 12.h),
              ValueListenableBuilder<int>(
                valueListenable: countdownNotifier,
                builder: (context, value, child) {
                  return Text(
                    "Time left: ${value}s",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: value <= 3 ? Colors.red : Colors.green,
                    ),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () {
                countdownTimer?.cancel();
                autoCloseTimer?.cancel();
                Navigator.pop(dialogContext);
                _skipDelivery(req.deliveryId);
                NotificationService.instance.stopBuzzer();
                _isPopupShowing = false;
              },
              child: const Text("Reject"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                countdownTimer?.cancel();
                autoCloseTimer?.cancel();
                Navigator.pop(dialogContext);
                _acceptDelivery(req.deliveryId);
                NotificationService.instance.stopBuzzer();
                _isPopupShowing = false;
              },
              child: const Text("Accept", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    ).then((_) {
      countdownTimer?.cancel();
      autoCloseTimer?.cancel();
      countdownNotifier.dispose();
      _isPopupShowing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: selectIndex == 0
          ? Padding(
        padding: EdgeInsets.only(left: 24.w, right: 24.w, top: 55.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Welcome Back", style: TextStyle(fontSize: 14.sp)),
                    Text("$firstName $lastName", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                  ],
                ),
                const Spacer(),
                IconButton(onPressed: () {}, icon: Icon(Icons.notifications)),
                InkWell(
                  onTap: () => setState(() => selectIndex = 3),
                  child: Container(
                    margin: EdgeInsets.only(left: 5.w),
                    width: 35.w,
                    height: 35.h,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFA8DADC)),
                    child: Center(child: Text(firstName.isNotEmpty ? "${firstName[0]}${lastName[0]}" : "AS")),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),

            // Online/Offline Switch
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: isDriverOnline ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: isDriverOnline ? Colors.green : Colors.red, width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(isDriverOnline ? Icons.circle : Icons.circle_outlined, color: isDriverOnline ? Colors.green : Colors.red, size: 16.sp),
                      SizedBox(width: 6.w),
                      Text(isDriverOnline ? "ONLINE" : "OFFLINE", style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: isDriverOnline ? Colors.green : Colors.red)),
                    ],
                  ),
                  Switch(
                    value: isDriverOnline,
                    activeColor: Colors.green,
                    inactiveThumbColor: Colors.red,
                    inactiveTrackColor: Colors.red.withOpacity(0.3),
                    onChanged: (value) async {
                      setState(() => isDriverOnline = value);
                      if (value) {
                        Fluttertoast.showToast(msg: "Going Online...");
                        await getDriverProfile();
                        _ensureSocketConnected();
                      } else {
                        Fluttertoast.showToast(msg: "You are now Offline");
                        _disconnectSocket();
                        _locationTimer?.cancel();
                        availableRequests.clear();
                        setState(() {});
                      }
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Identity & Vehicle Cards
            if (status == "pending") ...[
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => IdentityCardPage())).then((_) => getDriverProfile()),
                child: _buildVerificationCard("Identity Verification", "Add your driving license..."),
              ),
              SizedBox(height: 10.h),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VihicalPage())).then((_) => getDriverProfile()),
                child: _buildVerificationCard("Add Vehicle", "Upload insurance and registration..."),
              ),
            ],

            // Balance + Search + Requests
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBalanceCard(),
                    Divider(color: Color(0xFFE5E5E5)),
                    SizedBox(height: 15.h),
                    Text("Would you like to specify direction for deliveries?", style: GoogleFonts.inter(fontSize: 13.sp, color: Color(0xFF111111))),
                    SizedBox(height: 4.h),
                    _buildSearchField(),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Text("Available Requests", style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w500)),
                        Spacer(),
                        Text("View all", style: GoogleFonts.inter(fontSize: 13.sp, color: Color(0xFF006970))),
                      ],
                    ),
                    availableRequests.isEmpty
                        ? _buildEmptyState()
                        : _buildRequestList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      )
          : selectIndex == 1
          ? EarningPage()
          : selectIndex == 2
          ? BookingPage(socket)
          : ProfilePage(socket!),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // ... [Baaki sab methods same rahenge: _buildVerificationCard, _buildBalanceCard, etc.]

  Widget _buildVerificationCard(String title, String subtitle) {
    return Container(
      padding: EdgeInsets.all(10.sp),
      height: 91.h,
      width: double.infinity,
      decoration: BoxDecoration(color: Color(0xffFDF1F1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w600)),
          SizedBox(height: 5.h),
          Text(subtitle, style: GoogleFonts.inter(fontSize: 12.sp, color: Color(0xFF111111))),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.r), color: const Color(0xFFD1E5E6)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Available balance"),
          SizedBox(height: 3.h),
          Row(
            children: [
              Text(isVisible ? "₹ $balance" : "₹ ••••", style: TextStyle(fontWeight: FontWeight.bold)),
              IconButton(onPressed: () => setState(() => isVisible = !isVisible), icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off)),
            ],
          ),
        ],
      ),
    );
  }




  Widget _buildSearchField() {
    return TextField(
      onChanged: (value) async {
        final keyword = value.trim();
        if (socket != null && socket!.connected && driverId != null) {
          final position = await _getCurrentLocation();
          if (position != null) {
            socket!.emit('booking:request', {
              'driverId': driverId,
              'lat': position.latitude,
              'lon': position.longitude,
              'keyWord': keyword,
            });
          }
        }
      },
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
        filled: true,
        fillColor: Color(0xFFF0F5F5),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5.r), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5.r), borderSide: BorderSide.none),
        hintText: "Where to?",
        hintStyle: GoogleFonts.inter(fontSize: 14.sp, color: Color(0xFFAFAFAF)),
        prefixIcon: Icon(Icons.circle_outlined, color: Color(0xFF28B877), size: 18.sp),
      ),
    );
  }
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delivery_dining, size: 64.sp, color: Colors.grey),
          SizedBox(height: 16.h),
          Text("Waiting for new delivery requests..."),
          SizedBox(height: 8.h),
          Text("Socket: ${isSocketConnected ? 'Connected' : 'Disconnected'}", style: TextStyle(color: isSocketConnected ? Colors.green : Colors.red, fontSize: 12.sp)),
        ],
      ),
    );
  }

  Widget _buildRequestList() {
    return ListView.builder(
      padding: EdgeInsets.only(top: 10.h),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: availableRequests.length,
      itemBuilder: (context, index) {
        final req = availableRequests[index];
        final pickup = req['pickup']?['name'] ?? 'Unknown Pickup';
        // final dropoff = req['dropoff']?['name'] ?? 'Unknown Dropoff';
        final price = req['userPayAmount']?.toString() ?? '0';
        final distance = req['distance']?.toString() ?? 'N/A';

        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          color: Color(0xFFF0F5F5),
          margin: EdgeInsets.only(bottom: 10.h),
          child: Padding(
            padding: EdgeInsets.all(12.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Expanded(child: Text("Pickup: $pickup", style: TextStyle(fontWeight: FontWeight.w600))), Text("₹$price", style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600))]),
                SizedBox(height: 5.h),
                // Text("Dropoff: $dropoff"),
                SizedBox(height: 5.h),
                Text("Distance: $distance km"),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(onPressed: () => _deliveryAcceptDelivery(req['_id']), style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF006970)), child: const Text("Accept", style: TextStyle(color: Colors.white))),
                    SizedBox(width: 10.w),
                    OutlinedButton(onPressed: () => _rejectDelivery(req['_id']), style: OutlinedButton.styleFrom(backgroundColor: Color(0xFFD1E5E6)), child: const Text("Reject")),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _rejectDelivery(String deliveryId) async {
    try {
      final body = RejectDeliveryBodyModel(deliveryId: deliveryId, lat: lattitude.toString(), lon: longutude.toString());
      final service = APIStateNetwork(callDio());
      final response = await service.rejectDelivery(body);
      Fluttertoast.showToast(msg: response.message ?? "Rejected");
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(10.r), topRight: Radius.circular(10.r)),
        color: Colors.white,
        boxShadow: [BoxShadow(offset: Offset(0, -2), blurRadius: 30, color: Colors.black12)],
      ),
      child: BottomNavigationBar(
        onTap: (value) {
          setState(() => selectIndex = value);
          if (value == 0 && isDriverOnline) {
            Future.delayed(const Duration(milliseconds: 300), _ensureSocketConnected);
          }
        },
        currentIndex: selectIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFF006970),
        unselectedItemColor: Color(0xFFC0C5C2),
        items: [
          _navItem("assets/SvgImage/iconhome.svg", "Home"),
          _navItem("assets/SvgImage/iconearning.svg", "Earning"),
          _navItem("assets/SvgImage/iconbooking.svg", "Booking"),
          _navItem("assets/SvgImage/iconProfile.svg", "Profile"),
        ],
      ),
    );
  }

  BottomNavigationBarItem _navItem(String asset, String label) {
    return BottomNavigationBarItem(
      icon: SvgPicture.asset(asset, color: Color(0xFFC0C5C2)),
      activeIcon: SvgPicture.asset(asset, color: Color(0xFF006970)),
      label: label,
    );
  }
}

class DeliveryRequest {
  final String deliveryId;
  final String category;
  final String recipient;
  final String dropOffLocation;
  final String? pickupName;
  final int countdown;

  DeliveryRequest({
    required this.deliveryId,
    required this.category,
    required this.recipient,
    required this.dropOffLocation,
    this.pickupName,
    required this.countdown,
  });
}*/


import 'dart:developer';
import 'dart:async';
import 'package:delivery_rider_app/RiderScreen/booking.page.dart';
import 'package:delivery_rider_app/RiderScreen/earning.page.dart';
import 'package:delivery_rider_app/RiderScreen/profile.page.dart';
import 'package:delivery_rider_app/RiderScreen/requestDetails.page.dart';
import 'package:delivery_rider_app/RiderScreen/vihical.page.dart';
import 'package:delivery_rider_app/data/model/RejectDeliveryBodyModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:geolocator/geolocator.dart';
import '../config/network/api.state.dart';
import '../config/utils/pretty.dio.dart';
import 'identityCard.page.dart';
import 'notificationService.dart';

class HomePage extends StatefulWidget {
  int? selectIndex;
  final bool forceSocketRefresh;
  HomePage(this.selectIndex, {super.key, this.forceSocketRefresh = false});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with WidgetsBindingObserver, RouteAware {
  bool isVisible = true;
  int selectIndex = 0;
  String firstName = '';
  String lastName = '';
  String status = '';
  double balance = 0;
  String? driverId;
  bool isStatus = false;
  IO.Socket? socket;
  bool isSocketConnected = false;
  Timer? _locationTimer;
  List<Map<String, dynamic>> availableRequests = [];
  double? lattitude;
  double? longutude;
  bool isDriverOnline = true;
  bool _isPopupShowing = false;

  @override
  void initState() {
    super.initState();
    selectIndex = widget.selectIndex!;
    WidgetsBinding.instance.addObserver(this);
    getDriverProfile();

    if (widget.forceSocketRefresh) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _forceRefreshSocket();
      });
    }

    if (isDriverOnline && driverId != null) {
      _ensureSocketConnected();
    }
  }

  void _connectSocket() {
    const socketUrl = 'http://192.168.1.43:4567';
    // const socketUrl = 'https://weloads.com';
    _disconnectSocket();
    socket = IO.io(socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    socket!.io.options!['reconnection'] = true;
    socket!.io.options!['reconnectionAttempts'] = 10;
    socket!.io.options!['reconnectionDelay'] = 1000;
    socket!.io.options!['reconnectionDelayMax'] = 5000;
    socket!.io.options!['randomizationFactor'] = 0.5;
    socket!.io.options!['timeout'] = 20000;
    socket!.connect();
    socket!.onConnect((_) {
      print('SOCKET CONNECTED: ${socket!.id}');
      if (mounted) setState(() => isSocketConnected = true);
      _registerAndSendLocation();
    });

    socket!.onDisconnect((_) {
      print('SOCKET DISCONNECTED');
      if (mounted) setState(() => isSocketConnected = false);
      _locationTimer?.cancel();
    });

    socket!.io.on('reconnect_attempt', (attempt) {
      print('RECONNECTING... Attempt #$attempt');
    });

    socket!.io.on('reconnect', (attempt) {
      print('RECONNECTED after $attempt attempts!');
      if (mounted) setState(() => isSocketConnected = true);
      _registerAndSendLocation();
    });

    socket!.io.on('reconnect_failed', (_) {
      print('RECONNECT FAILED PERMANENTLY');
      Fluttertoast.showToast(msg: "No internet. Retrying...");
    });

    socket!.onConnectError((err) => print('CONNECT ERROR: $err'));
    socket!.onError((err) => print('SOCKET ERROR: $err'));

    socket!.on('booking:request', _acceptRequest);
    socket!.on('delivery:new_request', _handleNewRequest);
    socket!.on('delivery:you_assigned', _handleAssigned);
    socket!.onAny((event, data) => print('EVENT → $event: $data'));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final modalRoute = ModalRoute.of(context);
    if (modalRoute is PageRoute) {
      modalRoute.addScopedWillPopCallback(() async => false);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted && isDriverOnline) _ensureSocketConnected();
      });
    }
    if (state == AppLifecycleState.paused) {
      _locationTimer?.cancel();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _locationTimer?.cancel();
    _disconnectSocket();
    super.dispose();
  }

  void _disconnectSocket() {
    if (socket != null) {
      if (socket!.connected) socket!.disconnect();
      socket!.clearListeners();
      socket!.dispose();
      socket = null;
    }
    _locationTimer?.cancel();
    if (mounted) setState(() => isSocketConnected = false);
    print('Old socket disconnected and cleaned');
  }

  void _forceRefreshSocket() async {
    print('Force refreshing socket...');
    _disconnectSocket();
    await getDriverProfile();
    _ensureSocketConnected();
    setState(() {});
  }

  void _ensureSocketConnected() {
    if (driverId == null || driverId!.isEmpty) return;
    if (socket?.connected == true) {
      _registerAndSendLocation();
    } else {
      _connectSocket();
    }
  }

  Future<void> getDriverProfile() async {
    try {
      final dio = await callDio();
      final service = APIStateNetwork(dio);
      final response = await service.getDriverProfile();

      if (response.error == false && response.data != null) {
        if (mounted) {
          setState(() {
            firstName = response.data!.firstName ?? '';
            lastName = response.data!.lastName ?? '';
            status = response.data!.status ?? '';
            balance = response.data!.wallet?.balance?.toDouble() ?? 0;
            driverId = response.data!.id ?? '';
          });
        }
        if (driverId != null && driverId!.isNotEmpty) {
          _ensureSocketConnected();
        }
      } else {
        Fluttertoast.showToast(msg: response.message ?? "Failed to fetch profile");
      }
    } catch (e, st) {
      log("Get Driver Profile Error: $e\n$st");
      Fluttertoast.showToast(msg: "Something went wrong while fetching profile");
    }
  }

  void _registerAndSendLocation() async {
    if (driverId == null || !socket!.connected) return;
    socket!.emit('register', {'userId': driverId, 'role': 'driver'});
    print('REGISTERED: $driverId');
    final pos = await _getCurrentLocation();
    if (pos != null) {
      lattitude = pos.latitude;
      longutude = pos.longitude;
      socket!.emit('booking:request', {
        'driverId': driverId,
        'lat': pos.latitude,
        'lon': pos.longitude,
      });
      socket!.emit('user:location_update', {
        'userId': driverId,
        'lat': pos.latitude,
        'lon': pos.longitude,
      });
    }
    _startLocationTimer();
  }

  void _startLocationTimer() {
    _locationTimer?.cancel();
    _locationTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (!socket!.connected || driverId == null) {
        timer.cancel();
        return;
      }
      final pos = await _getCurrentLocation();
      if (pos != null) {
        socket!.emit('user:location_update', {
          'userId': driverId,
          'lat': pos.latitude,
          'lon': pos.longitude,
        });
      }
    });
  }

  Future<Position?> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Fluttertoast.showToast(msg: "Please enable location services");
        return null;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Fluttertoast.showToast(msg: "Location permission denied");
          return null;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        Fluttertoast.showToast(msg: "Location permission permanently denied");
        return null;
      }
      return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    } catch (e) {
      log("Error getting location: $e");
      return null;
    }
  }

  // ========================================
  // NEW REQUEST HANDLER (1 to 3 DROPOFFS)
  // ========================================
  void _handleNewRequest(dynamic payload) {
    print("New Delivery Request: $payload");

    final requestData = Map<String, dynamic>.from(payload as Map);
    final pickup = requestData['pickup'] as Map<String, dynamic>? ?? {};
    final dropoffList = requestData['dropoff'] as List<dynamic>? ?? [];
    final expiresAt = requestData['expiresAt'] as int? ?? 0;
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final countdownMs = expiresAt - nowMs;
    final countdown = (countdownMs > 0 ? (countdownMs / 1000).round() : 0);
    if (countdown <= 0) return;

    // Extract dropoff names (max 3)
    final dropoffNames = dropoffList
        .take(3)
        .map((d) => (d as Map<String, dynamic>)['name']?.toString() ?? 'Unknown')
        .toList();

    final requestWithTimer = DeliveryRequest(
      deliveryId: requestData['deliveryId'] as String? ?? '',
      category: 'Delivery',
      pickupName: pickup['name']?.toString() ?? 'Unknown Pickup',
      dropOffLocations: dropoffNames,
      countdown: countdown,
    );

    // Sound + Vibrate + Notification
    NotificationService.instance.triggerDeliveryAlert(requestWithTimer);

    // Add to list (top pe)
    if (mounted) {
      setState(() {
        availableRequests.insert(0, requestData);
      });
    }

    // Show popup IMMEDIATELY (if not already showing)
    if (mounted && ModalRoute.of(context)?.isCurrent == true && !_isPopupShowing) {
      Future.microtask(() {
        if (mounted) {
          _showRequestPopup(requestWithTimer);
        }
      });
    }
  }

  // Future<void> _handleAssigned(dynamic payload) async {
  //   print("Delivery Assigned body : ${payload}");
  //   print("Delivery Assigned: ${payload['deliveryId']}");
  //   final deliveryId = payload['deliveryId'] as String;
  //   try {
  //     final dio = await callDio();
  //     final service = APIStateNetwork(dio);
  //     final response = await service.getDeliveryById(deliveryId);
  //     if (response.error == false && response.data != null) {
  //       if (socket == null || !socket!.connected) {
  //         _ensureSocketConnected();
  //         await Future.delayed(const Duration(seconds: 1));
  //       }
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => RequestDetailsPage(
  //             socket: socket,
  //             deliveryData: response.data!,
  //             txtID: response.data!.txId.toString(),
  //           ),
  //         ),
  //       ).then((_) => getDriverProfile());
  //     } else {
  //       Fluttertoast.showToast(msg: response.message ?? "Failed to fetch delivery details");
  //     }
  //   } catch (e) {
  //     Fluttertoast.showToast(msg: "Error fetching delivery details");
  //   }
  // }

  Future<void> _handleAssigned(dynamic payload) async {
    if (!mounted) {
      print("Screen not mounted, skipping navigation");
      return;
    }

    print("Delivery Assigned body : $payload");

    try {
      if (payload is! Map<String, dynamic>) {
        Fluttertoast.showToast(msg: "Invalid data received");
        return;
      }

      final deliveryId = payload['deliveryId']?.toString();
      if (deliveryId == null) {
        Fluttertoast.showToast(msg: "Delivery ID missing");
        return;
      }

      // API call kar rahe ho? Theek hai, but safe karo
      final dio = await callDio();
      final service = APIStateNetwork(dio);

      final response = await service.getDeliveryById(deliveryId);

      // Ek baar aur check karo mounted hai ya nahi (API ke baad)
      if (!mounted) {
        print("Screen disposed after API call");
        return;
      }

      if (response.error == false && response.data != null) {
        // Socket connected rakho
        if (socket == null || !socket!.connected) {
          _ensureSocketConnected();
          await Future.delayed(const Duration(milliseconds: 500));
        }

        // Ab safely navigate karo
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RequestDetailsPage(
              socket: socket,
              deliveryData: response.data!,
              txtID: response.data!.txId.toString(),
            ),
          ),
        );

        // Sirf tab call karo jab screen wapas aaye
        if (mounted) {
          getDriverProfile();
        }

      } else {
        Fluttertoast.showToast(msg: response.message ?? "Delivery not found");
      }
    } catch (e, s) {
      print("Handle Assigned Error: $e\n$s");
      if (mounted) {
        Fluttertoast.showToast(msg: "Something went wrong");
      }
    }
  }


  Future<void> _acceptRequest(dynamic payload) async {
    log("Booking Request Received: $payload");
    try {
      final data = Map<String, dynamic>.from(payload);
      final deliveries = List<Map<String, dynamic>>.from(data['deliveries'] ?? []);
      if (deliveries.isEmpty) return;
      if (mounted) {
        setState(() => availableRequests = deliveries);
      }
    } catch (e, st) {
      log("Error parsing booking:request → $e\n$st");
    }
  }

  void _acceptDelivery(String deliveryId) {
    if (socket != null && socket!.connected) {
      socket!.emitWithAck('delivery:accept', {'deliveryId': deliveryId}, ack: (ackData) {
        print('Accept ack: $ackData');
      });
      Fluttertoast.showToast(msg: "Delivery Accepted!");
    }
  }

  void _deliveryAcceptDelivery(String deliveryId) {
    if (socket != null && socket!.connected) {
      socket!.emitWithAck('delivery:accept_request', {'deliveryId': deliveryId}, ack: (ackData) {
        print('Accept ack: $ackData');
      });
      Fluttertoast.showToast(msg: "Delivery Accepted!");
    }
  }

  void _skipDelivery(String deliveryId) {
    if (socket != null && socket!.connected) {
      socket!.emitWithAck('delivery:skip', {'deliveryId': deliveryId}, ack: (ackData) {
        print('Skip ack: $ackData');
      });
      Fluttertoast.showToast(msg: "Delivery Rejected!");
    }
  }

  // ========================================
  // POPUP WITH MULTIPLE DROPOFFS
  // ========================================
  void _showRequestPopup(DeliveryRequest req) {
    if (_isPopupShowing) {
      Navigator.pop(context);
    }
    _isPopupShowing = true;

    final ValueNotifier<int> countdownNotifier = ValueNotifier(req.countdown);
    Timer? countdownTimer;
    Timer? autoCloseTimer;

    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdownNotifier.value <= 0) {
        timer.cancel();
        autoCloseTimer?.cancel();
        if (mounted) {
          Navigator.pop(context);
          _skipDelivery(req.deliveryId);
          Fluttertoast.showToast(msg: "Time expired! Auto-rejected.");
        }
        return;
      }
      countdownNotifier.value--;
    });

    autoCloseTimer = Timer(const Duration(seconds: 10), () {
      countdownTimer?.cancel();
      if (mounted) {
        Navigator.pop(context);
        _skipDelivery(req.deliveryId);
        Fluttertoast.showToast(msg: "Popup timed out after 10s!");
      }
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: Text(req.category, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pickup
              Row(
                children: [
                  Icon(Icons.location_on, size: 16.sp, color: Colors.blue),
                  SizedBox(width: 5.w),
                  Expanded(child: Text("Pickup: ${req.pickupName}")),
                ],
              ),
              SizedBox(height: 8.h),

              // Dropoffs
              Text("Dropoffs (${req.dropOffLocations.length}):", style: TextStyle(fontWeight: FontWeight.w600)),
              SizedBox(height: 4.h),
              ...req.dropOffLocations.map((drop) => Padding(
                padding: EdgeInsets.only(left: 20.w, bottom: 4.h),
                child: Row(
                  children: [
                    Icon(Icons.subdirectory_arrow_right, size: 14.sp, color: Colors.green),
                    SizedBox(width: 4.w),
                    Expanded(child: Text(drop, style: TextStyle(fontSize: 13.sp))),
                  ],
                ),
              )).toList(),

              SizedBox(height: 12.h),

              // Countdown
              ValueListenableBuilder<int>(
                valueListenable: countdownNotifier,
                builder: (context, value, child) {
                  return Text(
                    "Time left: ${value}s",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: value <= 3 ? Colors.red : Colors.green,
                    ),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () {
                countdownTimer?.cancel();
                autoCloseTimer?.cancel();
                Navigator.pop(dialogContext);
                _skipDelivery(req.deliveryId);
                NotificationService.instance.stopBuzzer();
                _isPopupShowing = false;
              },
              child: const Text("Reject"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                countdownTimer?.cancel();
                autoCloseTimer?.cancel();
                Navigator.pop(dialogContext);
                _acceptDelivery(req.deliveryId);
                NotificationService.instance.stopBuzzer();
                _isPopupShowing = false;
              },
              child: const Text("Accept", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    ).then((_) {
      countdownTimer?.cancel();
      autoCloseTimer?.cancel();
      countdownNotifier.dispose();
      _isPopupShowing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: selectIndex == 0
          ? Padding(
        padding: EdgeInsets.only(left: 24.w, right: 24.w, top: 55.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Welcome Back", style: TextStyle(fontSize: 14.sp)),
                    Text("$firstName $lastName", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                  ],
                ),
                const Spacer(),
                IconButton(onPressed: () {}, icon: Icon(Icons.notifications)),
                InkWell(
                  onTap: () => setState(() => selectIndex = 3),
                  child: Container(
                    margin: EdgeInsets.only(left: 5.w),
                    width: 35.w,
                    height: 35.h,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFA8DADC)),
                    child: Center(child: Text(firstName.isNotEmpty ? "${firstName[0]}${lastName[0]}" : "AS")),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),

            // Online/Offline Switch
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: isDriverOnline ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: isDriverOnline ? Colors.green : Colors.red, width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(isDriverOnline ? Icons.circle : Icons.circle_outlined, color: isDriverOnline ? Colors.green : Colors.red, size: 16.sp),
                      SizedBox(width: 6.w),
                      Text(isDriverOnline ? "ONLINE" : "OFFLINE", style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: isDriverOnline ? Colors.green : Colors.red)),
                    ],
                  ),
                  Switch(
                    value: isDriverOnline,
                    activeColor: Colors.green,
                    inactiveThumbColor: Colors.red,
                    inactiveTrackColor: Colors.red.withOpacity(0.3),
                    onChanged: (value) async {
                      setState(() => isDriverOnline = value);
                      if (value) {
                        Fluttertoast.showToast(msg: "Going Online...");
                        await getDriverProfile();
                        _ensureSocketConnected();
                      } else {
                        Fluttertoast.showToast(msg: "You are now Offline");
                        _disconnectSocket();
                        _locationTimer?.cancel();
                        availableRequests.clear();
                        setState(() {});
                      }
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Identity & Vehicle Cards
            if (status == "pending") ...[
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => IdentityCardPage())).then((_) => getDriverProfile()),
                child: _buildVerificationCard("Identity Verification", "Add your driving license..."),
              ),
              SizedBox(height: 10.h),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VihicalPage())).then((_) => getDriverProfile()),
                child: _buildVerificationCard("Add Vehicle", "Upload insurance and registration..."),
              ),
            ],

            // Balance + Search + Requests
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBalanceCard(),
                    Divider(color: Color(0xFFE5E5E5)),
                    SizedBox(height: 15.h),
                    Text("Would you like to specify direction for deliveries?", style: GoogleFonts.inter(fontSize: 13.sp, color: Color(0xFF111111))),
                    SizedBox(height: 4.h),
                    _buildSearchField(),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Text("Available Requests", style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w500)),
                        Spacer(),
                        Text("View all", style: GoogleFonts.inter(fontSize: 13.sp, color: Color(0xFF006970))),
                      ],
                    ),
                    availableRequests.isEmpty
                        ? _buildEmptyState()
                        : _buildRequestList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      )
          : selectIndex == 1
          ? EarningPage()
          : selectIndex == 2
          ? BookingPage(socket)
          : ProfilePage(socket!),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildVerificationCard(String title, String subtitle) {
    return Container(
      padding: EdgeInsets.all(10.sp),
      height: 91.h,
      width: double.infinity,
      decoration: BoxDecoration(color: Color(0xffFDF1F1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w600)),
          SizedBox(height: 5.h),
          Text(subtitle, style: GoogleFonts.inter(fontSize: 12.sp, color: Color(0xFF111111))),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.r), color: const Color(0xFFD1E5E6)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Available balance"),
          SizedBox(height: 3.h),
          Row(
            children: [
              Text(isVisible ? "₹ $balance" : "₹ ••••", style: TextStyle(fontWeight: FontWeight.bold)),
              IconButton(onPressed: () => setState(() => isVisible = !isVisible), icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      onChanged: (value) async {
        final keyword = value.trim();
        if (socket != null && socket!.connected ) {
          final position = await _getCurrentLocation();
          if (position != null) {
            socket!.emit('booking:request', {
              'driverId': driverId,
              'lat': position.latitude,
              'lon': position.longitude,
              'keyWord': keyword,
            });
          }
        }
      },
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
        filled: true,
        fillColor: Color(0xFFF0F5F5),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5.r), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5.r), borderSide: BorderSide.none),
        hintText: "Where to?",
        hintStyle: GoogleFonts.inter(fontSize: 14.sp, color: Color(0xFFAFAFAF)),
        prefixIcon: Icon(Icons.circle_outlined, color: Color(0xFF28B877), size: 18.sp),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delivery_dining, size: 64.sp, color: Colors.grey),
          SizedBox(height: 16.h),
          Text("Waiting for new delivery requests..."),
          SizedBox(height: 8.h),
          Text("Socket: ${isSocketConnected ? 'Connected' : 'Disconnected'}", style: TextStyle(color: isSocketConnected ? Colors.green : Colors.red, fontSize: 12.sp)),
        ],
      ),
    );
  }

  // Widget _buildRequestList() {
  //   return ListView.builder(
  //     padding: EdgeInsets.only(top: 10.h),
  //     shrinkWrap: true,
  //     physics: const NeverScrollableScrollPhysics(),
  //     itemCount: availableRequests.length,
  //     itemBuilder: (context, index) {
  //       final req = availableRequests[index];
  //       final pickup = req['pickup']?['name'] ?? 'Unknown Pickup';
  //       final dropoffList = (req['dropoff'] as List<dynamic>?) ?? [];
  //       final price = req['userPayAmount']?.toString() ?? '0';
  //       final distance = req['distance']?.toString() ?? 'N/A';
  //
  //       final dropoffNames = dropoffList
  //           .take(3)
  //           .map((d) => (d as Map)['name']?.toString() ?? 'Unknown')
  //           .join(" → ");
  //
  //       return Card(
  //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
  //         color: const Color(0xFFF0F5F5),
  //         margin: EdgeInsets.only(bottom: 10.h),
  //         child: Padding(
  //           padding: EdgeInsets.all(12.sp),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   Expanded(
  //                     child: Text(
  //                       "Pickup: $pickup",
  //                       style: const TextStyle(fontWeight: FontWeight.w600),
  //                     ),
  //                   ),
  //                   Text("₹$price", style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
  //                 ],
  //               ),
  //               SizedBox(height: 5.h),
  //
  //               Text(
  //                 "Dropoffs: $dropoffNames",
  //                 style: TextStyle(fontSize: 13.sp, color: Colors.black87),
  //               ),
  //               SizedBox(height: 5.h),
  //
  //               Text("Distance: $distance km"),
  //               SizedBox(height: 8.h),
  //
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.end,
  //                 children: [
  //                   ElevatedButton(
  //                     onPressed: () => _deliveryAcceptDelivery(req['_id']),
  //                     style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006970)),
  //                     child: const Text("Accept", style: TextStyle(color: Colors.white)),
  //                   ),
  //                   SizedBox(width: 10.w),
  //                   OutlinedButton(
  //                     onPressed: () => _rejectDelivery(req['_id']),
  //                     style: OutlinedButton.styleFrom(backgroundColor: const Color(0xFFD1E5E6)),
  //                     child: const Text("Reject"),
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }


  Widget _buildRequestList() {
    return ListView.builder(
      padding: EdgeInsets.only(top: 10.h),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: availableRequests.length,
      itemBuilder: (context, index) {
        final req = availableRequests[index];

        final pickup = req['pickup']?['name']?.toString() ?? 'Unknown Pickup';
        final price = req['userPayAmount']?.toString() ?? '0';
        final distance = req['distance']?.toString() ?? 'N/A';

        // SAFE DROPOFF HANDLING (Single Map ya List dono ko handle karega)
        List<String> dropoffNames = [];

        final dropoffData = req['dropoff'];
        if (dropoffData != null) {
          if (dropoffData is List) {
            // Multiple dropoffs
            dropoffNames = dropoffData
                .take(3)
                .map((d) => (d as Map<String, dynamic>)['name']?.toString() ?? 'Unknown Drop')
                .toList();
          } else if (dropoffData is Map<String, dynamic>) {
            // Single dropoff (server ne List nahi, direct object bheja)
            final name = dropoffData['name']?.toString() ?? 'Unknown Drop';
            dropoffNames = [name];
          }
        }

        final dropoffText = dropoffNames.isEmpty
            ? "No dropoff"
            : dropoffNames.length == 1
            ? dropoffNames.first
            : dropoffNames.join(" → ");

        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          color: const Color(0xFFF0F5F5),
          margin: EdgeInsets.only(bottom: 10.h),
          child: Padding(
            padding: EdgeInsets.all(12.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "Pickup: $pickup",
                        style:  TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
                      ),
                    ),
                    Text("₹$price", style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600, fontSize: 16.sp)),
                  ],
                ),
                SizedBox(height: 8.h),

                Text(
                  "Dropoff: $dropoffText",
                  style: TextStyle(fontSize: 13.sp, color: Colors.black87),
                ),
                SizedBox(height: 6.h),
                Text("Distance: $distance km", style: TextStyle(fontSize: 12.sp, color: Colors.grey[700])),
                SizedBox(height: 12.h),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () => _deliveryAcceptDelivery(req['_id'] ?? req['deliveryId']),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006970)),
                      child: const Text("Accept", style: TextStyle(color: Colors.white)),
                    ),
                    SizedBox(width: 10.w),
                    OutlinedButton(
                      onPressed: () => _rejectDelivery(req['_id'] ?? req['deliveryId']),
                      child: const Text("Reject"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  Future<void> _rejectDelivery(String deliveryId) async {
    try {
      final body = RejectDeliveryBodyModel(deliveryId: deliveryId, lat: lattitude.toString(), lon: longutude.toString());
      final service = APIStateNetwork(callDio());
      final response = await service.rejectDelivery(body);
      Fluttertoast.showToast(msg: response.message ?? "Rejected");
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(10.r), topRight: Radius.circular(10.r)),
        color: Colors.white,
        boxShadow: [BoxShadow(offset: Offset(0, -2), blurRadius: 30, color: Colors.black12)],
      ),
      child: BottomNavigationBar(
        onTap: (value) {
          setState(() => selectIndex = value);
          if (value == 0 && isDriverOnline) {
            Future.delayed(const Duration(milliseconds: 300), _ensureSocketConnected);
          }
        },
        currentIndex: selectIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFF006970),
        unselectedItemColor: Color(0xFFC0C5C2),
        items: [
          _navItem("assets/SvgImage/iconhome.svg", "Home"),
          _navItem("assets/SvgImage/iconearning.svg", "Earning"),
          _navItem("assets/SvgImage/iconbooking.svg", "Booking"),
          _navItem("assets/SvgImage/iconProfile.svg", "Profile"),
        ],
      ),
    );
  }
  BottomNavigationBarItem _navItem(String asset, String label) {
    return BottomNavigationBarItem(
      icon: SvgPicture.asset(asset, color: Color(0xFFC0C5C2)),
      activeIcon: SvgPicture.asset(asset, color: Color(0xFF006970)),
      label: label,
    );
  }
}

// ========================================
// UPDATED DELIVERY REQUEST MODEL
// ========================================
class DeliveryRequest {
  final String deliveryId;
  final String category;
  final String pickupName;
  final List<String> dropOffLocations; // 1 to 3
  final int countdown;

  DeliveryRequest({
    required this.deliveryId,
    required this.category,
    required this.pickupName,
    required this.dropOffLocations,
    required this.countdown,
  });
}



