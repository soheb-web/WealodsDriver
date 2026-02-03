import 'dart:developer';
import 'package:delivery_rider_app/RiderScreen/start.page.dart';
import 'package:delivery_rider_app/config/utils/navigatorKey.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'RiderScreen/LocationEnablePage.dart';
import 'RiderScreen/firbaseoption.dart';
import 'RiderScreen/notificationService.dart';
import 'RiderScreen/notificationservice1.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService1().init();
  await NotificationService.instance.init();

  // Initialize Hive
  try {
    await Hive.initFlutter();
    if (!Hive.isBoxOpen('userdata')) {
      await Hive.openBox('userdata');
    }
  } catch (e) {
    log("Hive initialization failed: $e");
  }
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  Future<void> getToken() async {
    // Permission request करें (iOS/Android पर जरूरी)
    NotificationSettings settings = await FirebaseMessaging.instance
        .requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: true, // iOS के लिए provisional permission
          carPlay: true,
        );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
      return;
    }

    // FCM Token निकालें
    String? token = await FirebaseMessaging.instance.getToken();
    // setState(() {
    //   _fcmToken = token;
    // });
    print('FCM Token: $token'); // Console में print होगा
  }

  @override
  Widget build(BuildContext context) {
    getToken();
    var box = Hive.box("userdata");
    var PrintToken = box.get("token");
    //log(PrintToken);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF092325),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            title: 'Weloads Partner',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            ),
            home: FutureBuilder<String?>(
              future: _getToken(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError) {
                  return Scaffold(
                    body: Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                } else {
                  final token = snapshot.data;
                  if (token == null) {
                    return SplashScreen();
                  } else {
                    // ✅ Token exists → go to LocationEnablePage before HomePage
                    return const LocationEnablePage();
                  }
                }
              },
            ),
          );
        },
      ),
    );
  }

  Future<String?> _getToken() async {
    await Future.delayed(const Duration(seconds: 1));
    final box = Hive.box('userdata');
    return box.get('token') as String?;
  }
}
