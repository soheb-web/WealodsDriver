import 'package:delivery_rider_app/RiderScreen/forgatPassword.page.dart';
import 'package:delivery_rider_app/RiderScreen/register.page.dart';
import 'package:delivery_rider_app/data/model/loginBodyModel.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/network/api.state.dart';
import '../config/utils/pretty.dio.dart';
import 'otp.page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF092325),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 55.h),
              InkWell(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 35.w,
                  height: 35.h,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                    size: 20.sp,
                  ),
                ),
              ),
              SizedBox(height: 25.h),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: SvgPicture.asset("assets/SvgImage/login.svg"),
                      ),
                      SizedBox(height: 25.h),
                      Text(
                        "Welcome Back",
                        style: GoogleFonts.inter(
                          fontSize: 25.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 7.h),
                      Text(
                        "Please input your information",
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFFD7D7D7),
                        ),
                      ),
                      SizedBox(height: 40.h),

                      // _buildTextField(
                      //   controller: emailController,
                      //   hint: "Email Address",
                      //   obscure: false,
                      // ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30.r),
                          border: Border(
                            top: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 12,
                              spreadRadius: 1,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller:
                              emailController, // rename if possible -> phoneController
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w400,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter
                                .digitsOnly, // ✅ only numbers
                          ],
                          decoration: InputDecoration(
                            counterText: "", // hide maxLength counter
                            prefixIcon: Icon(
                              Icons.call,
                              color: Colors.black,
                              size: 20.sp,
                            ),
                            filled: true,
                            fillColor: Colors.transparent,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                            hintText: "Enter your phone number",
                            hintStyle: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 14.h,
                              horizontal: 20.w,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter phone number";
                            }
                            if (value.length != 10) {
                              return "Enter valid 10 digit phone number";
                            }
                            if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
                              return "Invalid phone number";
                            }
                            return null;
                          },
                        ),
                      ),

                      SizedBox(height: 25.h),

                      SizedBox(height: 30.h),

                      Container(
                        width: double.infinity,
                        height: 50.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(
                                0.08,
                              ), // ✅ same as TextField
                              blurRadius: 12,
                              spreadRadius: 1,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF006970),
                            elevation: 0, // ❗ shadow Container handle karega
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.r),
                            ),
                          ),
                          onPressed: isLoading ? null : login,
                          child: isLoading
                              ? SizedBox(
                                  width: 30.w,
                                  height: 30.h,
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  "GET OTP",
                                  style: GoogleFonts.inter(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),

                      SizedBox(height: 10.h),

                      // Expanded(child: SizedBox()),
                    ],
                  ),
                ),
              ),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterPage()),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don’t have an account?",
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 20),
                    Text(
                      "Sign up",
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF006970),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }

  Future<String> fcmGetToken() async {
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
      return "no_permission"; // Return a fallback string instead of void
    }

    // FCM Token निकालें
    String? token = await FirebaseMessaging.instance.getToken();
    // setState(() {
    //   _fcmToken = token;
    // });
    print('FCM Token: $token'); // Console में print होगा - moved before return
    return token ?? "unknown_device";
  }

  /// ✅ Reusable text field
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      cursorColor: Colors.white,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color.fromARGB(12, 255, 255, 255),
        contentPadding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 20.w),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color.fromARGB(153, 255, 255, 255),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color.fromARGB(153, 255, 255, 255),
          ),
        ),
        hintText: hint,
        hintStyle: GoogleFonts.inter(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
      ),
    );
  }

  /// ✅ API Call
  Future<void> login() async {
    final deviceToken = await fcmGetToken();

    if (emailController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Please enter your email");
      return;
    }

    // if (passwordController.text.isEmpty) {
    //   Fluttertoast.showToast(msg: "Please enter your password");
    //   return;
    // }

    setState(() => isLoading = true);

    final body = LoginBodyModel(
      loginType: emailController.text.trim(),
      // password: passwordController.text.trim(),
      deviceId: deviceToken,
    );

    try {
      final dio = await callDio();
      final service = APIStateNetwork(dio);
      final response = await service.login(body);

      if (response.code == 0) {
        final token = response.data?.token ?? '';
        if (token.isEmpty) {
          Fluttertoast.showToast(msg: "Something went wrong: Missing token");
          return;
        }

        Fluttertoast.showToast(msg: response.message ?? "Login successful");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                OtpPage(false, token, mobile: emailController.text.trim()),
          ),
        );
      } else {
        Fluttertoast.showToast(msg: response.message ?? "Login failed");
      }
    } catch (e, st) {
      debugPrint("Login Error: $e\n$st");
      Fluttertoast.showToast(msg: "Something went wrong. Please try again.");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }
}
