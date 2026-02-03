/*


import 'dart:io';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'home.page.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  factory NotificationService() => instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  static const platform = MethodChannel('com.instantDriver/buzzer');

  // Track karo buzzer chal raha hai ya nahi
  static bool _isBuzzerActive = false;

  Future<void> init() async {
    const AndroidInitializationSettings android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _notificationsPlugin.initialize(const InitializationSettings(android: android));

    final channel = AndroidNotificationChannel(
      'delivery_requests_channel',
      'Delivery Requests',
      description: 'New delivery alerts',
      importance: Importance.max,
      playSound: false,
      enableVibration: true,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Jab bhi naya request aaye → buzzer restart hoga + countdown ke baad band
  Future<void> triggerDeliveryAlert(DeliveryRequest request) async {
    // 1. Vibration (short burst)
    // if (await Vibration.hasVibrator() ?? false) {
    //   await Vibration.vibrate(
    //     duration: 800,
    //     intensity: 255,  // ← intensity (not intensities)
    //   );
    // }
    if (await Vibration.hasVibrator() ?? false) {
      await Vibration.vibrate(duration: 1200);
    }
    // 2. Notification
    await _notificationsPlugin.show(
      999,
      'New Delivery Request!',
      'Pickup: ${request.pickupName} → ${request.dropOffLocations.join(" → ")}',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'delivery_requests_channel',
          'Delivery Requests',
          importance: Importance.max,
          priority: Priority.high,
          playSound: false,
          enableVibration: true,
          fullScreenIntent: true,
        ),
      ),
    );

    // 3. BUZZER LOGIC — HAR NAYE REQUEST PE FRESH START
    if (Platform.isAndroid) {
      try {
        // Pehle jo bhi chal raha hai → band kar do
        if (_isBuzzerActive) {
          await platform.invokeMethod('stopBuzzer');
        }

        // Thoda gap do → driver ko naya order ka feel aaye
        await Future.delayed(const Duration(milliseconds: 200));

        // Ab naya buzzer shuru karo
        await platform.invokeMethod('playBuzzer');
        _isBuzzerActive = true;

        // Countdown ke baad apne aap band kar do
        Future.delayed(Duration(seconds: request.countdown), () async {
          if (_isBuzzerActive) {
            await stopBuzzer();
          }
        });
      } catch (e) {
        print("Buzzer error: $e");
      }
    }
  }

  /// Accept / Reject / Expire / Reject All → Sab yahan se band hoga
  Future<void> stopBuzzer() async {
    if (!_isBuzzerActive) return;

    _isBuzzerActive = false;

    await Vibration.cancel();
    await _notificationsPlugin.cancel(999);

    if (Platform.isAndroid) {
      try {
        await platform.invokeMethod('stopBuzzer');
      } catch (e) {
        print("Stop buzzer error: $e");
      }
    }
  }
}*/


import 'dart:io';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'home.page.dart';
import 'dart:async'; // ← ये add करो

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  factory NotificationService() => instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();
  static const platform = MethodChannel('com.instantDriver/buzzer');

  static bool _isBuzzerActive = false;
  Timer? _buzzerTimer; // ← नया: cancelable timer

  Future<void> init() async {
    const AndroidInitializationSettings android =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    await _notificationsPlugin.initialize(
        const InitializationSettings(android: android));

    final channel = AndroidNotificationChannel(
      'delivery_requests_channel',
      'Delivery Requests',
      description: 'New delivery alerts',
      importance: Importance.max,
      playSound: false,
      enableVibration: true,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> triggerDeliveryAlert(DeliveryRequest request) async {
    // Vibration
    if (await Vibration.hasVibrator() ?? false) {
      await Vibration.vibrate(duration: 1200);
    }

    // Notification
    await _notificationsPlugin.show(
      999,
      'New Delivery Request!',
      'Pickup: ${request.pickupName} → ${request.dropOffLocations.join(" → ")}',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'delivery_requests_channel',
          'Delivery Requests',
          importance: Importance.max,
          priority: Priority.high,
          playSound: false,
          enableVibration: true,
          fullScreenIntent: true,
        ),
      ),
    );

    // Buzzer Logic
    if (Platform.isAndroid) {
      try {
        // पुराना buzzer और timer cancel करो
        await stopBuzzer();

        await Future.delayed(const Duration(milliseconds: 200));

        // नया buzzer शुरू करो
        await platform.invokeMethod('playBuzzer');
        _isBuzzerActive = true;

        // पुराना timer cancel करो
        _buzzerTimer?.cancel();

        // नया timer set करो जो countdown पूरा होने पर बंद कर दे
        _buzzerTimer = Timer(Duration(seconds: request.countdown), () {
          stopBuzzer();
        });
      } catch (e) {
        print("Buzzer error: $e");
      }
    }
  }

  /// ये हर जगह call करो: accept, reject, expire, reject all
  Future<void> stopBuzzer() async {
    if (!_isBuzzerActive) return;

    _isBuzzerActive = false;
    _buzzerTimer?.cancel(); // ← महत्वपूर्ण: timer cancel
    _buzzerTimer = null;

    await Vibration.cancel();
    await _notificationsPlugin.cancel(999);

    if (Platform.isAndroid) {
      try {
        await platform.invokeMethod('stopBuzzer');
      } catch (e) {
        print("Stop buzzer error: $e");
      }
    }
  }
}