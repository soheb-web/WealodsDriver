import 'dart:developer';
import 'dart:async';
import 'package:delivery_rider_app/RiderScreen/booking.page.dart';
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
import 'PaymenetScreen.dart';
import 'identityCard.page.dart';
import 'notificationService.dart';

class HomePage extends StatefulWidget {
  final int? selectIndex;
  final bool forceSocketRefresh;

  const HomePage(
    this.selectIndex, {
    super.key,
    this.forceSocketRefresh = false,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  int selectIndex = 0;
  String firstName = '';
  String lastName = '';
  String statusFront = '';
  String statusBack = '';
  double balance = 0;
  String? driverId;
  IO.Socket? socket;
  bool isSocketConnected = false;
  bool _isConnecting = false;
  Timer? _locationTimer;
  List<Map<String, dynamic>> availableRequests = [];
  double? latitude;
  double? longitude;
  bool _isPopupShowing = false;
  final List<DeliveryRequest> _activeRequests = [];
  final ValueNotifier<int> _rebuildTrigger = ValueNotifier(0);
  Timer? _dialogCleanupTimer;
  List vehicleList = [];
  final ValueNotifier<bool> _connectionNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    selectIndex = widget.selectIndex ?? 0;
    WidgetsBinding.instance.addObserver(this);
    getDriverProfile();
  }

  @override
  void dispose() {
    _connectionNotifier.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _locationTimer?.cancel();
    _dialogCleanupTimer?.cancel();
    _disconnectSocket();
    _rebuildTrigger.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      if (mounted &&
          isSocketConnected &&
          driverId != null &&
          driverId!.isNotEmpty) {
        Future.delayed(
          const Duration(milliseconds: 800),
          _ensureSocketConnected,
        );
      }
    }
    if (state == AppLifecycleState.paused) {
      _locationTimer?.cancel();
    }
  }

  void _connectSocket() {
    if (_isConnecting) return;

    print(
      "connectSocket called | driverId = $driverId | forceRefresh = ${widget.forceSocketRefresh}",
    );

    setState(() {
      _isConnecting = true;
      isSocketConnected = false;
    });

    const socketUrl = 'https://backend.weloads.live';
    // const socketUrl = 'http://192.168.1.43:4567';

    _disconnectSocket();

    socket = IO.io(socketUrl, <String, dynamic>{
      'transports': ['websocket', 'polling'],
      'autoConnect': false,
      'forceNew': true,
    });

    socket!.io.options!['reconnection'] = true;
    socket!.io.options!['reconnectionAttempts'] = 10;
    socket!.io.options!['reconnectionDelay'] = 1000;
    socket!.io.options!['reconnectionDelayMax'] = 5000;
    socket!.io.options!['timeout'] = 20000;

    socket!.connect();

    socket!.onConnect((_) {
      print("Socket successfully connected → ONLINE now");
      if (mounted) {
        setState(() {
          isSocketConnected = true;
          _isConnecting = false;
        });
        _connectionNotifier.value = true;
      }
      _registerAndSendLocation();
    });

    socket!.onDisconnect((_) {
      print("Socket disconnected");
      if (mounted) {
        setState(() {
          isSocketConnected = false;
          _isConnecting = false;
        });
        _connectionNotifier.value = false;
      }
      _locationTimer?.cancel();
    });

    socket!.onConnectError((err) {
      print("Socket connection FAILED: $err");
      if (mounted) {
        setState(() {
          isSocketConnected = false;
          _isConnecting = false;
        });
        _connectionNotifier.value = false;
        Fluttertoast.showToast(msg: "Connection failed: ${err.toString()}");
      }
    });

    socket!.io.on('reconnect', (_) {
      print("Socket reconnected");
      if (mounted) {
        setState(() {
          isSocketConnected = true;
          _isConnecting = false;
        });
        _connectionNotifier.value = true;
      }
      _registerAndSendLocation();
    });

    socket!.on('error', (err) => print("Socket general error: $err"));
    socket!.on('connect_timeout', (_) => print("Socket connect timeout"));
    socket!.on('connect_failed', (err) => print("Socket connect failed: $err"));

    socket!.on('booking:request', _acceptRequest);
    socket!.on('delivery:new_request', _handleNewRequest);
    socket!.on('delivery:you_assigned', _handleAssigned);
  }

  void _disconnectSocket() {
    socket?.disconnect();
    socket?.clearListeners();
    socket?.dispose();
    socket = null;
    _locationTimer?.cancel();
    if (mounted) {
      setState(() {
        isSocketConnected = false;
        _isConnecting = false;
      });
      _connectionNotifier.value = false;
    }
  }

  void _ensureSocketConnected() {
    if (driverId == null || driverId!.isEmpty) return;
    if (socket == null || !socket!.connected) {
      _connectSocket();
    } else {
      _registerAndSendLocation();
    }
  }

  Future<void> getDriverProfile() async {
    try {
      final dio = await callDio();
      final service = APIStateNetwork(dio);
      final response = await service.getDriverProfile();

      if (response.error == false && response.data != null && mounted) {
        setState(() {
          firstName = response.data!.firstName ?? '';
          lastName = response.data!.lastName ?? '';
          statusFront =
              response.data!.driverDocuments?.identityFront?.status ?? '';
          statusBack =
              response.data!.driverDocuments?.identityBack?.status ?? '';
          balance = response.data!.wallet?.balance?.toDouble() ?? 0;
          driverId = response.data!.id ?? '';
          vehicleList = response.data!.vehicleDetails ?? [];
        });

        // Force refresh → optimistic UI + real connect
        if (widget.forceSocketRefresh &&
            driverId != null &&
            driverId!.isNotEmpty) {
          print("forceSocketRefresh = true → auto connecting socket");

          // Step 1: Immediately show ONLINE in UI
          if (mounted) {
            setState(() {
              isSocketConnected = true;
              _isConnecting = false;
            });
            _connectionNotifier.value = true;
          }

          // Step 2: Real connection attempt
          Future.delayed(const Duration(milliseconds: 400), () {
            if (mounted) {
              // _disconnectSocket();
              _connectSocket();
            }
          });
        }
      }
    } catch (e) {
      log("Profile fetch error: $e");
    }
  }

  void _registerAndSendLocation() async {
    if (socket == null || !socket!.connected || driverId == null) return;

    socket!.emit('register', {'userId': driverId, 'role': 'driver'});

    final pos = await _getCurrentLocation();
    if (pos != null && mounted) {
      setState(() {
        latitude = pos.latitude;
        longitude = pos.longitude;
      });

      socket!.emit('user:location_update', {
        'userId': driverId,
        'lat': pos.latitude,
        'lon': pos.longitude,
      });

      socket!.emit('booking:request', {
        'driverId': driverId,
        'lat': pos.latitude,
        'lon': pos.longitude,
        'keyWord': '',
      });
    }

    _startLocationTimer();
  }

  void _startLocationTimer() {
    _locationTimer?.cancel();
    _locationTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      if (socket == null || !socket!.connected) return;
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
      if (!await Geolocator.isLocationServiceEnabled()) return null;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) return null;
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      return null;
    }
  }

  // ──────────────────────────────────────────────
  // MULTIPLE REQUEST DIALOG LOGIC (unchanged)
  // ──────────────────────────────────────────────

  void _handleNewRequest(dynamic payload) {
    final data = Map<String, dynamic>.from(payload as Map);
    final pickup = data['pickup'] as Map<String, dynamic>? ?? {};
    final dropoffList = data['dropoff'] as List<dynamic>? ?? [];
    final expiresAt = data['expiresAt'] as int? ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    final remaining = ((expiresAt - now) / 1000).ceil();
    if (remaining <= 0) return;

    final dropoffNames = dropoffList
        .take(3)
        .map((d) => (d as Map)['name']?.toString() ?? 'Unknown')
        .toList();

    final request = DeliveryRequest(
      deliveryId: data['deliveryId']?.toString() ?? DateTime.now().toString(),
      category: 'Delivery',
      pickupName: pickup['name']?.toString() ?? 'Unknown Pickup',
      dropOffLocations: dropoffNames,
      countdown: remaining,
    );

    _activeRequests.insert(0, request);
    availableRequests.insert(0, data);
    NotificationService.instance.triggerDeliveryAlert(request);

    if (mounted) setState(() {});
    _showOrUpdateMultiDialog();
  }

  void _showOrUpdateMultiDialog() {
    if (!mounted || _isPopupShowing) return;
    _isPopupShowing = true;
    _startDialogCleanupTimer();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _buildMultiRequestDialog(),
    ).then((_) => _cleanupDialog());
  }

  void _startDialogCleanupTimer() {
    _dialogCleanupTimer?.cancel();
    _dialogCleanupTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_activeRequests.isEmpty && _isPopupShowing && mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  Widget _buildMultiRequestDialog() {
    return ValueListenableBuilder<int>(
      valueListenable: _rebuildTrigger,
      builder: (context, _, __) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            title: Row(
              children: [
                Icon(Icons.delivery_dining, color: Colors.orange, size: 28.sp),
                SizedBox(width: 12.w),
                Text(
                  "New Requests (${_activeRequests.length})",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              height: MediaQuery.of(context).size.height * 0.65,
              child: _activeRequests.isEmpty
                  ? const Center(child: Text("No active requests"))
                  : ListView.builder(
                      itemCount: _activeRequests.length,
                      itemBuilder: (context, i) =>
                          _buildRequestCard(_activeRequests[i]),
                    ),
            ),
            actions: [
              TextButton(
                onPressed: _rejectAllRequests,
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text("Reject All"),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRequestCard(DeliveryRequest req) {
    final countdown = ValueNotifier<int>(req.countdown);
    late Timer countdownTimer;
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (countdown.value <= 1) {
        countdownTimer.cancel();
        _removeRequest(req.deliveryId, autoExpired: true);
      } else {
        countdown.value--;
      }
    });

    Timer(const Duration(seconds: 10), () {
      if (_activeRequests.any((r) => r.deliveryId == req.deliveryId)) {
        countdownTimer.cancel();
        _removeRequest(req.deliveryId, autoExpired: true);
      }
    });

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      color: Colors.grey[50],
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.blue, size: 18.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    "Pickup: ${req.pickupName}",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            ...req.dropOffLocations.map(
              (name) => Padding(
                padding: EdgeInsets.only(left: 26.w, top: 4.h),
                child: Row(
                  children: [
                    Icon(
                      Icons.subdirectory_arrow_right,
                      color: Colors.green,
                      size: 16.sp,
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(name, style: TextStyle(fontSize: 13.sp)),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ValueListenableBuilder<int>(
                  valueListenable: countdown,
                  builder: (_, sec, __) {
                    return Text(
                      "$sec sec",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: sec <= 3 ? Colors.red : Colors.orange,
                      ),
                    );
                  },
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        countdownTimer.cancel();
                        _removeRequest(req.deliveryId, rejected: true);
                      },
                      child: Text(
                        "Reject",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: () {
                        countdownTimer.cancel();
                        _acceptAndRemove(req.deliveryId);
                      },
                      child: Text(
                        "Accept",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _removeRequest(
    String id, {
    bool autoExpired = false,
    bool rejected = false,
  }) {
    if (!mounted) return;

    NotificationService.instance.stopBuzzer();

    _activeRequests.removeWhere((r) => r.deliveryId == id);

    if (autoExpired || rejected) {
      _skipDelivery(id);
      if (autoExpired) Fluttertoast.showToast(msg: "Request expired!");
    }

    setState(() {});
    _rebuildTrigger.value++;

    if (_activeRequests.isEmpty && _isPopupShowing) {
      Navigator.of(context).pop();
      _cleanupDialog();
    }
  }

  void _acceptAndRemove(String id) {
    _acceptDelivery(id);
    _removeRequest(id);
    NotificationService.instance.stopBuzzer();
    Fluttertoast.showToast(msg: "Delivery Accepted!");
  }

  void _rejectAllRequests() {
    for (var r in List.from(_activeRequests)) {
      _skipDelivery(r.deliveryId);
    }
    NotificationService.instance.stopBuzzer();
    _activeRequests.clear();
    setState(() {});
    Navigator.of(context).pop();
    _cleanupDialog();
    Fluttertoast.showToast(msg: "All requests rejected");
  }

  void _cleanupDialog() {
    _isPopupShowing = false;
    _dialogCleanupTimer?.cancel();
    NotificationService.instance.stopBuzzer();
  }

  void _acceptDelivery(String id) {
    socket?.emitWithAck('delivery:accept', {'deliveryId': id}, ack: (_) {});
  }

  void _skipDelivery(String id) {
    socket?.emitWithAck('delivery:skip', {'deliveryId': id}, ack: (_) {});
  }

  Future<void> _handleAssigned(dynamic payload) async {
    if (!mounted) return;
    try {
      if (payload is! Map<String, dynamic>) return;
      final deliveryId = payload['deliveryId']?.toString();
      if (deliveryId == null) return;

      final dio = await callDio();
      final service = APIStateNetwork(dio);
      final response = await service.getDeliveryById(deliveryId);

      if (!mounted) return;

      if (response.error == false && response.data != null) {
        if (socket == null || !socket!.connected) {
          _ensureSocketConnected();
          await Future.delayed(const Duration(milliseconds: 500));
        }

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RequestDetailsPage(
              socket: socket,
              deliveryData: response.data!,
              txtID: response.data!.txId.toString(),
              data: true,
            ),
          ),
        );

        if (!mounted) return;

        await getDriverProfile();
        _ensureSocketConnected();

        final pos = await _getCurrentLocation();
        if (pos != null && socket != null && socket!.connected) {
          socket!.emit('booking:request', {
            'driverId': driverId,
            'lat': pos.latitude,
            'lon': pos.longitude,
            'keyWord': '',
          });
        }
      }
    } catch (e) {
      if (mounted) Fluttertoast.showToast(msg: "Something went wrong");
    }
  }

  Future<void> _acceptRequest(dynamic payload) async {
    try {
      final data = Map<String, dynamic>.from(payload);
      final deliveries = List<Map<String, dynamic>>.from(
        data['deliveries'] ?? [],
      );
      if (deliveries.isNotEmpty && mounted) {
        setState(() => availableRequests = deliveries);
      }
    } catch (e) {}
  }

  Future<void> _refreshHomeCompletely() async {
    if (!mounted) return;

    availableRequests.clear();
    _activeRequests.clear();
    setState(() {});

    // _disconnectSocket();

    await getDriverProfile();

    if (isSocketConnected) {
      _connectSocket();
    }
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
                          Text(
                            "Welcome Back",
                            style: TextStyle(fontSize: 14.sp),
                          ),
                          Text(
                            "$firstName $lastName",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.notifications),
                      ),
                      InkWell(
                        onTap: () => setState(() => selectIndex = 3),
                        child: Container(
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
                  SizedBox(height: 10.h),

                  // Connection status card with notifier
                  ValueListenableBuilder<bool>(
                    valueListenable: _connectionNotifier,
                    builder: (context, connected, child) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 12.h,
                        ),
                        decoration: BoxDecoration(
                          color: _isConnecting
                              ? Colors.orange.withOpacity(0.15)
                              : (connected
                                    ? Colors.green.withOpacity(0.15)
                                    : Colors.red.withOpacity(0.15)),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: _isConnecting
                                ? Colors.orange
                                : (connected ? Colors.green : Colors.red),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                if (_isConnecting)
                                  Padding(
                                    padding: EdgeInsets.only(right: 8.w),
                                    child: SizedBox(
                                      width: 16.w,
                                      height: 16.h,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                      ),
                                    ),
                                  )
                                else
                                  Icon(
                                    connected
                                        ? Icons.circle
                                        : Icons.circle_outlined,
                                    color: connected
                                        ? Colors.green
                                        : Colors.red,
                                    size: 16.sp,
                                  ),
                                SizedBox(width: 8.w),
                                Text(
                                  _isConnecting
                                      ? "CONNECTING..."
                                      : (connected ? "ONLINE" : "OFFLINE"),
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: _isConnecting
                                        ? Colors.orange[800]
                                        : (connected
                                              ? Colors.green
                                              : Colors.red),
                                  ),
                                ),
                              ],
                            ),

                            if (_isConnecting)
                              const SizedBox(
                                width: 50,
                                child: Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                    ),
                                  ),
                                ),
                              )
                            else
                              Switch(
                                value: connected,
                                activeColor: Colors.green,
                                inactiveThumbColor: Colors.red,
                                inactiveTrackColor: Colors.red.withOpacity(0.5),
                                onChanged:
                                    (driverId == null || driverId!.isEmpty)
                                    ? null
                                    : (bool value) async {
                                        if (value) {
                                          await getDriverProfile();
                                          _connectSocket();
                                        } else {
                                          // _disconnectSocket();
                                          availableRequests.clear();
                                          _activeRequests.clear();
                                          setState(() {});
                                          _connectionNotifier.value = false;
                                        }
                                      },
                              ),
                          ],
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 16.h),

                  if (statusFront == "pending" && statusBack == "pending")
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => IdentityCardPage()),
                      ).then((_) => getDriverProfile()),
                      child: _buildVerificationCard(
                        "Identity Verification",
                        "Add your driving license...",
                      ),
                    ),

                  if (vehicleList.isEmpty)
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => VihicalPage()),
                      ).then((_) => getDriverProfile()),
                      child: _buildVerificationCard(
                        "Add Vehicle",
                        "Upload insurance and registration...",
                      ),
                    ),

                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _refreshHomeCompletely,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 15.h),
                            Text(
                              "Would you like to specify direction for deliveries?",
                              style: GoogleFonts.inter(fontSize: 13.sp),
                            ),
                            SizedBox(height: 4.h),
                            _buildSearchField(),
                            SizedBox(height: 16.h),
                            Row(
                              children: [
                                Text(
                                  "Available Requests",
                                  style: GoogleFonts.inter(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  "View all",
                                  style: GoogleFonts.inter(
                                    fontSize: 13.sp,
                                    color: Color(0xFF006970),
                                  ),
                                ),
                              ],
                            ),
                            availableRequests.isEmpty
                                ? ValueListenableBuilder<bool>(
                                    valueListenable: _connectionNotifier,
                                    builder: (context, connected, child) {
                                      return _buildEmptyState(
                                        connected: connected,
                                      );
                                    },
                                  )
                                : _buildRequestList(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : selectIndex == 1
          ? const WithdrawMoneyPage()
          : selectIndex == 2
          ? BookingPage(socket)
          : ProfilePage(socket),

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
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            subtitle,
            style: GoogleFonts.inter(fontSize: 12.sp, color: Color(0xFF111111)),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      onChanged: (value) async {
        final keyword = value.trim();
        if (socket != null && socket!.connected) {
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
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.r),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.r),
          borderSide: BorderSide.none,
        ),
        hintText: "Where to?",
        hintStyle: GoogleFonts.inter(fontSize: 14.sp, color: Color(0xFFAFAFAF)),
        prefixIcon: Icon(
          Icons.circle_outlined,
          color: Color(0xFF28B877),
          size: 18.sp,
        ),
      ),
    );
  }

  Widget _buildEmptyState({required bool connected}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delivery_dining, size: 64.sp, color: Colors.grey),
          SizedBox(height: 16.h),
          Text("Waiting for new delivery requests..."),
          SizedBox(height: 8.h),
          Text(
            "Driver: ${connected ? 'Connected' : 'Disconnected'}",
            style: TextStyle(
              color: connected ? Colors.green : Colors.red,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }

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
        List<String> dropoffNames = [];
        final dropoffData = req['dropoff'];
        if (dropoffData != null) {
          if (dropoffData is List) {
            dropoffNames = dropoffData
                .take(3)
                .map((d) => (d as Map)['name']?.toString() ?? 'Unknown')
                .toList();
          } else if (dropoffData is Map) {
            dropoffNames = [(dropoffData['name']?.toString() ?? 'Unknown')];
          }
        }
        final dropoffText = dropoffNames.isEmpty
            ? "No dropoff"
            : dropoffNames.join(" → ");

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
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
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                    Text(
                      "₹$price",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  "Dropoff: $dropoffText",
                  style: TextStyle(fontSize: 13.sp),
                ),
                SizedBox(height: 6.h),
                Text(
                  "Distance: $distance km",
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
                ),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () => _deliveryAcceptDelivery(
                        req['_id'] ?? req['deliveryId'],
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006970),
                      ),
                      child: const Text(
                        "Accept",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    OutlinedButton(
                      onPressed: () =>
                          _rejectDelivery(req['_id'] ?? req['deliveryId']),
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
      final body = RejectDeliveryBodyModel(
        deliveryId: deliveryId,
        lat: latitude.toString(),
        lon: longitude.toString(),
      );
      final service = APIStateNetwork(await callDio());
      await service.rejectDelivery(body);
      _refreshHomeCompletely();
    } catch (e) {}
  }

  void _deliveryAcceptDelivery(String deliveryId) {
    if (socket != null && socket!.connected) {
      socket!.emitWithAck('delivery:accept_request', {
        'deliveryId': deliveryId,
      }, ack: (_) {});
      Fluttertoast.showToast(msg: "Delivery Accepted!");
    }
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.r),
          topRight: Radius.circular(10.r),
        ),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: Offset(0, -2),
            blurRadius: 30,
            color: Colors.black12,
          ),
        ],
      ),
      child: BottomNavigationBar(
        onTap: (value) {
          setState(() => selectIndex = value);
          if (value == 0 && isSocketConnected) {
            Future.delayed(
              const Duration(milliseconds: 300),
              _ensureSocketConnected,
            );
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
  final String pickupName;
  final List<String> dropOffLocations;
  final int countdown;

  DeliveryRequest({
    required this.deliveryId,
    required this.category,
    required this.pickupName,
    required this.dropOffLocations,
    required this.countdown,
  });
}
