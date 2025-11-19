import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gif/gif.dart';

import 'onbording.page.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late GifController controller;

  @override
  void initState() {
    super.initState();
    controller = GifController(vsync: this);
    Future.delayed(Duration(seconds: 8), () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => OnbordingPage()),
        (route) => false,
      );
      // // 3 सेकंड बाद home screen पर जाएं
      // Future.delayed(Duration(seconds: 3), () {
      //   Navigator.pushReplacementNamed(context, '/home');
      // });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // या अपनी पसंद का color
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Gif(
              image: AssetImage("assets/gif/splash.gif"),
              controller: controller,
              autostart: Autostart.loop,
              fit: BoxFit.contain,
              width: 300, // अपनी जरूरत के अनुसार size
              height: 300,
            ),
          ),

          // Text(
          //   "Splash",
          //   style: TextStyle(
          //     fontSize: 20.sp,
          //     fontWeight: FontWeight.bold,
          //     color:Colors.black ,
          //   ),
          // ),
        ],
      ),
    );
  }
}
