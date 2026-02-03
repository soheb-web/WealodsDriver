// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/timezone.dart' as tz;
// import 'package:timezone/data/latest.dart' as tz;
//
// class NotificationService1 {
//   static final NotificationService1 _NotificationService1 = NotificationService1._internal();
//   factory NotificationService1() => _NotificationService1;
//   NotificationService1._internal();
//
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//   final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
//
//   // Initialize Firebase and local notifications
//   Future<void> init() async {
//     // Request permission for iOS
//     await _firebaseMessaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//
//     // Get FCM token
//     String? token = await _firebaseMessaging.getToken();
//     print('FCM Token: $token');
//
//     // Android initialization settings
//     const AndroidInitializationSettings initializationSettingsAndroid =
//     AndroidInitializationSettings('@mipmap/ic_launcher');
//
//     // iOS initialization settings
//     const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//     );
//
//     // Combine platform settings
//     const InitializationSettings initializationSettings = InitializationSettings(
//       android: initializationSettingsAndroid,
//       iOS: initializationSettingsIOS,
//     );
//
//     // Initialize timezone for scheduled notifications
//     tz.initializeTimeZones();
//
//     // Initialize local notifications
//     await _notificationsPlugin.initialize(initializationSettings);
//
//     // Handle foreground messages
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       // Print all incoming notification data in foreground
//       print('Foreground Notification Data: ${message.toMap()}');
//       _showNotification(message);
//     });
//
//     // Handle background messages
//     FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//   }
//
//   // Show notification from FCM message
//   Future<void> _showNotification(RemoteMessage message) async {
//     const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
//       'fcm_channel',
//       'FCM Notifications',
//       channelDescription: 'Channel for Firebase push notifications',
//       importance: Importance.max,
//       priority: Priority.high,
//       playSound: true,
//     );
//
//     const DarwinNotificationDetails iOSNotificationDetails = DarwinNotificationDetails();
//
//     const NotificationDetails notificationDetails = NotificationDetails(
//       android: androidNotificationDetails,
//       iOS: iOSNotificationDetails,
//     );
//
//     await _notificationsPlugin.show(
//       message.messageId.hashCode,
//       message.notification?.title ?? 'No Title',
//       message.notification?.body ?? 'No Body',
//
//       notificationDetails,
//       payload: message.data['payload'] ?? '',
//     );
//   }
// }
//
// // Background message handler
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   // Print all incoming notification data in background
//   print('Background Notification Data: ${message.toMap()}');
// }



// Assuming you have a way to navigate, e.g., via GetX, Navigator, or a global key.
// For example, import 'package:get/get.dart'; and use Get.toNamed('/pickup', arguments: deliveryId);
// Or use a callback passed to the service.
// Here, I'll assume a simple callback for navigation: void Function(String deliveryId)? onNavigateToPickup;

import 'dart:convert';
import 'package:timezone/data/latest.dart' as tz;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService1 {

  static final NotificationService1 _NotificationService1 = NotificationService1._internal();
  factory NotificationService1() => _NotificationService1;
  NotificationService1._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  // Callback for navigation (set this from your main app after init)
  void Function(String deliveryId)? _onNavigateToPickup;

  // Method to set the navigation callback
  void setNavigationCallback(void Function(String deliveryId) callback) {
    _onNavigateToPickup = callback;
  }

  // Initialize Firebase and local notifications
  Future<void> init() async {
    // Request permission for iOS
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get FCM token
    String? token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');

    // Android initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Combine platform settings
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Initialize timezone for scheduled notifications
    tz.initializeTimeZones();

    // Initialize local notifications with tap handler
    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap, // Add tap handler here
    );

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Print all incoming notification data in foreground
      print('Foreground Notification Data: ${message.toMap()}');
      _showNotification(message);
    });

    // Handle when app is opened from terminated state via notification
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        _handleNotificationTap(message);
      }
    });

    // Handle when app is in background and notification is tapped
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(message);
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  // Handle notification tap (common logic for all cases)
  void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    final deliveryId = data['deliveryId'];
    if (deliveryId != null && deliveryId.isNotEmpty) {
      _onNavigateToPickup?.call(deliveryId);
    }
  }

  // Local notification tap handler
  void _onNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final data = json.decode(response.payload!) as Map<String, dynamic>;
        final deliveryId = data['deliveryId'];
        if (deliveryId != null && deliveryId.isNotEmpty) {
          _onNavigateToPickup?.call(deliveryId);
        }
      } catch (e) {
        print('Error decoding payload: $e');
      }
    }
  }

  // Show notification from FCM message
  Future<void> _showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'fcm_channel',
      'FCM Notifications',
      channelDescription: 'Channel for Firebase push notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const DarwinNotificationDetails iOSNotificationDetails = DarwinNotificationDetails();

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iOSNotificationDetails,
    );

    // Serialize the entire data map to payload for tap handling
    final payload = json.encode(message.data);

    await _notificationsPlugin.show(
      message.messageId.hashCode,
      message.notification?.title ?? 'No Title',
      message.notification?.body ?? 'No Body',
      notificationDetails,
      payload: payload, // Pass serialized data
    );
  }

}

// Background message handler (updated to handle taps if needed, but taps in background use onMessageOpenedApp)
 Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Print all incoming notification data in background
  print('Background Notification Data: ${message.toMap()}');
  // Note: For background, show local notification if needed, but tap handling is via onMessageOpenedApp
}