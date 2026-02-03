import 'dart:developer';
import 'dart:io' show Platform;
import 'package:delivery_rider_app/RiderScreen/onbordingPolicy.page.dart';
import 'package:delivery_rider_app/RiderScreen/otp.page.dart';
import 'package:delivery_rider_app/RiderScreen/termsCondition.page.dart';
import 'package:delivery_rider_app/config/network/api.state.dart';
import 'package:delivery_rider_app/config/utils/pretty.dio.dart';
import 'package:delivery_rider_app/data/controller/getCityController.dart';
import 'package:delivery_rider_app/data/model/registerBodyModel.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/model/getCityResModel.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  Datum? selectedCityObj;
  final registerformKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneNumberController = TextEditingController();
  // final passwordController = TextEditingController();
  final codeController = TextEditingController();

  bool isCheckt = false;
  bool isLoading = false;

  static const Color _fillColor = Color(0x0AFFFFFF);
  static const Color _borderColor = Color(0x99FFFFFF);
  static const TextStyle _textStyle = TextStyle(color: Colors.white);

  InputDecoration _getInputDecoration(String hint, {bool showCounter = false}) {
    return InputDecoration(
      filled: true,
      fillColor: _fillColor,
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _borderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _borderColor, width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      hintText: hint,
      hintStyle: GoogleFonts.inter(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: Colors.white,
      ),
      counterText: showCounter ? null : "",
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
    int? maxLength,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      cursorColor: Colors.white,
      style: _textStyle,
      obscureText: obscureText,
      maxLength: maxLength,
      decoration: _getInputDecoration(hint, showCounter: maxLength != null),
      validator: validator,
    );
  }

  Future<String> _getDeviceToken() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      String? token = await messaging.getToken();
      return token ?? "unknown_device";
    } catch (e) {
      log("Error getting device token: $e");
      return "unknown_device";
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    // passwordController.dispose();
    codeController.dispose();
    super.dispose();
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

  Future<void> register(String cityId, String deviceId) async {
    final deviceToken = await fcmGetToken();

    if (firstNameController.text.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter First Name');
      return;
    }
    if (lastNameController.text.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter Last Name');
      return;
    }
    if (emailController.text.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter Email');
      return;
    }
    if (phoneNumberController.text.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter Phone Number');
      return;
    }
    // if (passwordController.text.isEmpty) {
    //   Fluttertoast.showToast(msg: 'Please enter Password');
    //   return;
    // }
    if (!isCheckt) {
      Fluttertoast.showToast(msg: 'Please agree to the Terms & Conditions');
      return;
    }

    setState(() => isLoading = true);

    final body = RegisterBodyModel(
      firstName: firstNameController.text,
      lastName: lastNameController.text,
      email: emailController.text,
      phone: phoneNumberController.text,
      cityId: cityId,
      deviceId: deviceToken,
      refByCode: codeController.text,
      // password: passwordController.text,
    );

    try {
      final dio = await callDio();
      final service = APIStateNetwork(dio);
      final response = await service.register(body);

      if (response.code == 0) {
        Fluttertoast.showToast(
          msg: response.message ?? "Registration successful",
        );
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            CupertinoPageRoute(
              builder: (context) => OtpPage(
                true,
                response.data['token'],
                mobile: phoneNumberController.text.trim(),
                firstName: firstNameController.text.trim(),
                lastNameController: lastNameController.text.trim(),
                emailController: emailController.text.trim(),
                cityId: cityId,
                codeController: codeController.text.trim(),
              ),
            ),
            (route) => false,
          );
        }
      } else {
        Fluttertoast.showToast(msg: response.message ?? "Registration failed");
      }
    } catch (e, st) {
      log("Register error: $e\n$st");
      Fluttertoast.showToast(msg: "Something went wrong");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<String> _getDeviceId() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? 'unknown_device';
      } else {
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id ?? 'unknown_device';
      }
    } catch (e) {
      log('Error getting device ID: $e');
      return 'unknown_device';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ref
        .watch(getCityControlelr)
        .when(
          data: (cityList) {
            final filteredCities = (cityList.data ?? [])
                .where((city) => city.city != null && city.city!.isNotEmpty)
                .toList();

            final uniqueCities = <Datum>{...filteredCities}.toList();

            return Scaffold(
              backgroundColor: const Color(0xFF092325),
              body: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 40.h),
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
                      SizedBox(height: 20.h),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Let’s get Started",
                                style: GoogleFonts.inter(
                                  fontSize: 25.sp,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                "Please input your information",
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFFD7D7D7),
                                ),
                              ),
                              SizedBox(height: 30.h),

                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextFormField(
                                      controller: firstNameController,
                                      hint: "First Name",
                                    ),
                                  ),
                                  SizedBox(width: 24.w),
                                  Expanded(
                                    child: _buildTextFormField(
                                      controller: lastNameController,
                                      hint: "Last Name",
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 25.h),
                              _buildTextFormField(
                                controller: emailController,
                                hint: "Email Address",
                              ),
                              SizedBox(height: 24.h),
                              _buildTextFormField(
                                controller: phoneNumberController,
                                hint: "Phone Number",
                                maxLength: 10,
                              ),
                              SizedBox(height: 24.h),
                              // _buildTextFormField(
                              //   controller: passwordController,
                              //   hint: "Password",
                              //   obscureText: true,
                              // ),
                              // SizedBox(height: 24.h),

                              /// City Dropdown
                              DropdownButtonFormField<Datum>(
                                value: selectedCityObj,
                                dropdownColor: Colors.black,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: _fillColor,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 20.w,
                                    vertical: 15.h,
                                  ),
                                  enabledBorder: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                    borderSide: BorderSide(
                                      color: _borderColor,
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                    borderSide: BorderSide(
                                      color: _borderColor,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                hint: Text(
                                  "City",
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 15.sp,
                                  ),
                                ),
                                items: uniqueCities
                                    .map(
                                      (city) => DropdownMenuItem<Datum>(
                                        value: city,
                                        child: Text(
                                          city.city!,
                                          style: GoogleFonts.inter(
                                            fontSize: 15.sp,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  setState(() => selectedCityObj = value);
                                },
                              ),

                              SizedBox(height: 24.h),
                              _buildTextFormField(
                                controller: codeController,
                                hint: "Referral Code (Optional)",
                              ),
                              SizedBox(height: 26.h),

                              Row(
                                children: [
                                  Checkbox(
                                    side: const BorderSide(color: Colors.white),
                                    value: isCheckt,
                                    onChanged: (value) =>
                                        setState(() => isCheckt = value!),
                                  ),

                                  Expanded(
                                    child: Text.rich(
                                      TextSpan(
                                        text: "I agree to the ",
                                        style: GoogleFonts.inter(
                                          fontSize: 12.sp,
                                          color: Colors.white,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: "Terms of Service",
                                            style: const TextStyle(
                                              decoration:
                                                  TextDecoration.underline,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.red,
                                              decorationColor: Colors.red,
                                            ),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () {
                                                Navigator.push(
                                                  context,
                                                  CupertinoPageRoute(
                                                    builder: (_) =>
                                                        const TermsConditionPage(),
                                                  ),
                                                );
                                              },
                                          ),
                                          const TextSpan(text: " and "),
                                          TextSpan(
                                            text: "Privacy Policy",
                                            style: const TextStyle(
                                              decoration:
                                                  TextDecoration.underline,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.red,
                                              decorationColor: Colors.red,
                                            ),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () {
                                                Navigator.push(
                                                  context,
                                                  CupertinoPageRoute(
                                                    builder: (_) =>
                                                        const OnbordingPolicyPage(),
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

                              SizedBox(height: 30.h),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: Size(320.w, 48.h),
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.r),
                                    ),
                                  ),
                                  onPressed: isLoading
                                      ? null
                                      : () async {
                                          if (selectedCityObj == null ||
                                              selectedCityObj!.id == null) {
                                            Fluttertoast.showToast(
                                              msg: "Please select a valid city",
                                            );
                                            return;
                                          }
                                          final deviceId = await _getDeviceId();
                                          register(
                                            selectedCityObj!.id.toString(),
                                            deviceId,
                                          );
                                        },
                                  child: isLoading
                                      ? const CircularProgressIndicator(
                                          color: Colors.black,
                                        )
                                      : Text(
                                          "Continue",
                                          style: GoogleFonts.inter(
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFF091425),
                                          ),
                                        ),
                                ),
                              ),
                              SizedBox(height: 10.h),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          error: (error, stackTrace) {
            log(stackTrace.toString());
            return Scaffold(
              backgroundColor: const Color(0xFF092325),
              body: Center(
                child: Text(
                  error.toString(),
                  style: GoogleFonts.inter(color: Colors.white),
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
        );
  }
}
