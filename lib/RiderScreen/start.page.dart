import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gif/gif.dart';
import 'package:google_fonts/google_fonts.dart';

import 'onbording.page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late GifController controller;

  @override
  void initState() {
    super.initState();
    controller = GifController(vsync: this);

    // 8 सेकंड बाद ऑनबोर्डिंग पर जाए
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const OnbordingPage()),
        (route) => false,
      );
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
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // आपका GIF (सेंटर में)
            SizedBox(
              width: 240.w,
              height: 240.h,
              child: Gif(
                image: const AssetImage("assets/gif/splash.gif"),
                controller: controller,
                autostart: Autostart.loop,
                fit: BoxFit.contain,
              ),
            ),

            SizedBox(height: 50.h),

            // Company Name - We Loads
            Text(
              "We Loads",
              style: GoogleFonts.poppins(
                fontSize: 48.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF006970), // आपका ब्रांड कलर
                letterSpacing: 2.0,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.2),
                    offset: const Offset(0, 4),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),

            SizedBox(height: 12.h),

            // Tagline (ऑप्शनल लेकिन बहुत प्रोफेशनल लगता है)
            Text(
              "Your Load, Our Responsibility",
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
                letterSpacing: 1.5,
              ),
            ),

            SizedBox(height: 80.h),

            // नीचे छोटा सा लोडिंग इंडिकेटर (शानदार लगता है)
            CircularProgressIndicator(
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF006970),
              ),
              strokeWidth: 4,
              backgroundColor: Colors.grey[200],
            ),

            SizedBox(height: 20.h),

            Text(
              "Loading your experience...",
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
