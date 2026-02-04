// import 'dart:async';
// import 'dart:developer';

// import 'package:delivery_rider_app/RiderScreen/login.page.dart';
// import 'package:delivery_rider_app/data/model/loginBodyModel.dart';
// import 'package:delivery_rider_app/data/model/registerBodyModel.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:hive/hive.dart';
// import 'package:otp_pin_field/otp_pin_field.dart';
// import '../config/network/api.state.dart';
// import '../config/utils/pretty.dio.dart';
// import '../data/model/otpModelDATA.dart';
// import 'LocationEnablePage.dart';

// class OtpPage extends StatefulWidget {
//   final bool data;
//   final String token;
//   final String mobile;
//   final String? firstName;
//   final String? lastNameController;
//   final String? emailController;

//   final String? cityId;
//   final String? codeController;
//   const OtpPage(
//     this.data,
//     this.token, {
//     super.key,
//     required this.mobile,
//     this.firstName,
//     this.lastNameController,
//     this.emailController,

//     this.cityId,
//     this.codeController,
//   });

//   @override
//   State<OtpPage> createState() => _OtpPageState();
// }

// class _OtpPageState extends State<OtpPage> {
//   Key _otpKey = UniqueKey();

//   late String _currentToken; // 🔥 ALWAYS LATEST TOKEN
//   String otpValue = "";

//   bool isLoading = false;
//   int _secondsRemaining = 60;
//   bool _canResend = false;
//   Timer? _timer;

//   @override
//   void initState() {
//     super.initState();
//     _currentToken = widget.token; // initial token
//     _startTimer();
//   }

//   // 🔐 Mask mobile
//   String maskMobileNumber(String mobile) {
//     if (mobile.length < 4) return mobile;
//     return "${mobile.substring(0, 2)}XXXXXX${mobile.substring(mobile.length - 2)}";
//   }
//   void _startTimer() {
//     _secondsRemaining = 60;
//     _canResend = false;
//     _timer?.cancel();
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (_secondsRemaining == 0) {
//         setState(() => _canResend = true);
//         timer.cancel();
//       } else {
//         setState(() => _secondsRemaining--);
//       }
//     });
//   }
//   Future<String> fcmGetToken() async {
//     // Permission request करें (iOS/Android पर जरूरी)
//     NotificationSettings settings = await FirebaseMessaging.instance
//         .requestPermission(
//           alert: true,
//           badge: true,
//           sound: true,
//           provisional: true, // iOS के लिए provisional permission
//           carPlay: true,
//         );
//     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//       print('User granted permission');
//     } else if (settings.authorizationStatus ==
//         AuthorizationStatus.provisional) {
//       print('User granted provisional permission');
//     } else {
//       print('User declined or has not accepted permission');
//       return "no_permission";
//     }
//     // FCM Token निकालें
//     String? token = await FirebaseMessaging.instance.getToken();
//     print('FCM Token: $token');
//     return token ?? "unknown_device";
//   }

//   /// 🔁 LOGIN RESEND OTP
//   Future<void> _resendOtp() async {
//     final deviceToken = await fcmGetToken();

//     setState(() => isLoading = true);

//     try {
//       final dio = await callDio();
//       final service = APIStateNetwork(dio);

//       final response = await service.login(
//         LoginBodyModel(
//           loginType: widget.mobile,
//           deviceId: deviceToken,
//         ),
//       );

//       if (response.code == 0) {
//         final newToken = response.data?.token ?? "";
//         if (newToken.isNotEmpty) {
//           _currentToken = newToken; // 🔥 UPDATE TOKEN
//         }

//         Fluttertoast.showToast(msg: "OTP resent successfully");
//         _resetOtpField();
//         _startTimer();
//       } else {
//         Fluttertoast.showToast(msg: "Resend OTP failed");
//       }
//     } catch (e, st) {
//       debugPrint("Resend error: $e\n$st");
//       Fluttertoast.showToast(msg: "Something went wrong");
//     } finally {
//       if (mounted) setState(() => isLoading = false);
//     }
//   }

//   /// 🔁 REGISTER RESEND OTP
//   Future<void> _registorResendOTP() async {
//     final deviceToken = await fcmGetToken();
//     setState(() => isLoading = true);

//     try {
//       final dio = await callDio();
//       final service = APIStateNetwork(dio);

//       final response = await service.register(
//         RegisterBodyModel(
//           firstName: widget.firstName ?? "",
//           lastName: widget.lastNameController ?? "",
//           email: widget.emailController ?? "",
//           phone: widget.mobile,
//           cityId: widget.cityId ?? "",
//           deviceId: deviceToken,
//           refByCode: widget.codeController ?? "",
//         ),
//       );

//       if (response.code == 0) {
//         final newToken = response.data['token'];
//         if (newToken != null && newToken.toString().isNotEmpty) {
//           _currentToken = newToken.toString(); // 🔥 UPDATE TOKEN
//         }

//         Fluttertoast.showToast(msg: "OTP resent successfully");
//         _resetOtpField();
//         _startTimer();
//       } else {
//         Fluttertoast.showToast(msg: "Resend OTP failed");
//       }
//     } catch (e, st) {
//       log("Register resend error: $e\n$st");
//       Fluttertoast.showToast(msg: "Something went wrong");
//     } finally {
//       if (mounted) setState(() => isLoading = false);
//     }
//   }

//   void _resetOtpField() {
//     setState(() {
//       otpValue = "";
//       _otpKey = UniqueKey(); // 🔥 CLEAR OTP FIELD
//     });
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF092325),
//       body: SafeArea(
//         child: Padding(
//           padding: EdgeInsets.symmetric(horizontal: 24.w),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(height: 40.h),

//               /// Back Button
//               InkWell(
//                 onTap: () => Navigator.pop(context),
//                 child: Container(
//                   width: 35.w,
//                   height: 35.h,
//                   decoration: const BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: Colors.white,
//                   ),
//                   child: Icon(
//                     Icons.arrow_back,
//                     color: Colors.black,
//                     size: 20.sp,
//                   ),
//                 ),
//               ),

//               SizedBox(height: 30.h),

//               /// Title
//               Text(
//                 "OTP Verification",
//                 style: GoogleFonts.inter(
//                   fontSize: 25.sp,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.white,
//                 ),
//               ),

//               SizedBox(height: 7.h),

//               /// Subtitle (UPDATED)
//               Text(
//                 "Please enter the 4-digit code",
//                 style: GoogleFonts.inter(
//                   fontSize: 14.sp,
//                   fontWeight: FontWeight.w400,
//                   color: const Color(0xFFD7D7D7),
//                 ),
//               ),
//               Text(
//                 "sent to ${maskMobileNumber(widget.mobile)}",
//                 style: GoogleFonts.inter(
//                   fontSize: 14.sp,
//                   fontWeight: FontWeight.w400,
//                   color: const Color(0xFFD7D7D7),
//                 ),
//               ),

//               SizedBox(height: 40.h),

//               /// OTP Input Field (4 DIGIT)
//               OtpPinField(
//                 key: _otpKey,
//                 cursorColor: Colors.white,
//                 maxLength: 4, // ✅ UPDATED
//                 fieldWidth: 50.w,
//                 fieldHeight: 45.h,
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 otpPinFieldDecoration:
//                     OtpPinFieldDecoration.defaultPinBoxDecoration,
//                 otpPinFieldStyle: OtpPinFieldStyle(
//                   textStyle: GoogleFonts.inter(
//                     color: Colors.white,
//                     fontSize: 24.sp,
//                     fontWeight: FontWeight.w500,
//                   ),
//                   activeFieldBackgroundColor: const Color.fromARGB(
//                     12,
//                     255,
//                     255,
//                     255,
//                   ),
//                   defaultFieldBorderColor: const Color.fromARGB(
//                     153,
//                     255,
//                     255,
//                     255,
//                   ),
//                   activeFieldBorderColor: Colors.white,
//                 ),
//                 onChange: (text) => otpValue = text,
//                 onSubmit: (text) => otpValue = text,
//               ),
//               SizedBox(height: 20.h),

//               Align(
//                 alignment: Alignment.centerRight,
//                 child: TextButton(
//                   // onPressed: _canResend ? _resendOtp : null,
//                   onPressed: (_canResend)
//                       ? () {
//                           if (widget.data) {
//                             _registorResendOTP();
//                           } else {
//                             _resendOtp();
//                           }
//                         }
//                       : null,
//                   child: Text(
//                     _canResend
//                         ? "Resend Code"
//                         : "Resend in $_secondsRemaining sec",
//                     style: GoogleFonts.inter(
//                       fontSize: 14.sp,
//                       fontWeight: FontWeight.w400,
//                       color: _canResend
//                           ? Colors.white
//                           : const Color(0xFFD7D7D7),
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 40.h),

//               /// Verify Button
//               SizedBox(
//                 width: double.infinity,
//                 height: 50.h,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(5.r),
//                     ),
//                   ),
//                   onPressed: isLoading
//                       ? null
//                       : () {
//                           widget.data
//                               ? _verifyRegisterOtp()
//                               : _verifyLoginOtp();
//                         },
//                   child: isLoading
//                       ? const CircularProgressIndicator(color: Colors.black)
//                       : Text(
//                           "Verify",
//                           style: GoogleFonts.inter(
//                             fontSize: 15.sp,
//                             fontWeight: FontWeight.w500,
//                             color: const Color(0xFF091425),
//                           ),
//                         ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   /// ✅ 4-DIGIT OTP VALIDATION
//   bool _validateOtp() {
//     if (otpValue.isEmpty || otpValue.length != 4) {
//       Fluttertoast.showToast(msg: "Please enter a valid 4-digit OTP");
//       return false;
//     }
//     return true;
//   }

//   /// ✅ OTP Verification for Registration
//   Future<void> _verifyRegisterOtp() async {
//     if (!_validateOtp()) return;

//     setState(() => isLoading = true);
//     final body = OtpBodyModel(token: widget.token, otp: otpValue);

//     try {
//       final dio = await callDio();
//       final service = APIStateNetwork(dio);
//       final response = await service.verifyUser(body);

//       if (response.code == 0) {
//         Fluttertoast.showToast(msg: response.message ?? "OTP Verified");
//         Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(builder: (_) => const LoginPage()),
//           (_) => false,
//         );
//       } else {
//         Fluttertoast.showToast(
//           msg: response.message ?? "OTP verification failed",
//         );
//         setState(() {
//           otpValue = "";
//           _otpKey = UniqueKey();
//         });
//       }
//     } catch (e) {
//       Fluttertoast.showToast(msg: "Something went wrong");
//     } finally {
//       if (mounted) setState(() => isLoading = false);
//     }
//   }

//   /// ✅ OTP Verification for Login
//   Future<void> _verifyLoginOtp() async {
//     if (!_validateOtp()) return;

//     setState(() => isLoading = true);
//     final body = OtpBodyModel(token: widget.token, otp: otpValue);

//     try {
//       final dio = await callDio();
//       final service = APIStateNetwork(dio);
//       final response = await service.verifylogin(body);

//       if (response.code == 0) {
//         Fluttertoast.showToast(msg: response.message ?? "OTP Verified");

//         final token = response.data?.token ?? "";
//         if (token.isNotEmpty) {
//           final box = await Hive.openBox('userdata');
//           await box.put('token', token);
//         }

//         Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(builder: (_) => const LocationEnablePage()),
//           (_) => false,
//         );
//       } else {
//         Fluttertoast.showToast(
//           msg: response.message ?? "OTP verification failed",
//         );
//         setState(() {
//           otpValue = "";
//           _otpKey = UniqueKey(); // 🔥 FORCE REBUILD → OTP CLEARED
//         });
//       }
//     } catch (e) {
//       Fluttertoast.showToast(msg: "Something went wrong");
//     } finally {
//       if (mounted) setState(() => isLoading = false);
//     }
//   }
// }

import 'dart:async';
import 'dart:developer';
import 'package:delivery_rider_app/RiderScreen/login.page.dart';
import 'package:delivery_rider_app/data/model/loginBodyModel.dart';
import 'package:delivery_rider_app/data/model/registerBodyModel.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:otp_pin_field/otp_pin_field.dart';

import '../config/network/api.state.dart';
import '../config/utils/pretty.dio.dart';
import '../data/model/otpModelDATA.dart';
import 'LocationEnablePage.dart';

class OtpPage extends StatefulWidget {
  final bool data;
  final String token;
  final String mobile;
  final String? firstName;
  final String? lastNameController;
  final String? emailController;
  final String? cityId;
  final String? codeController;

  const OtpPage(
    this.data,
    this.token, {
    super.key,
    required this.mobile,
    this.firstName,
    this.lastNameController,
    this.emailController,
    this.cityId,
    this.codeController,
  });

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  Key _otpKey = UniqueKey();

  late String _currentToken; // 🔥 ALWAYS LATEST TOKEN
  String otpValue = "";

  bool isLoading = false;
  int _secondsRemaining = 60;
  bool _canResend = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _currentToken = widget.token; // initial token
    _startTimer();
  }

  // 🔐 Mask mobile
  String maskMobileNumber(String mobile) {
    if (mobile.length < 4) return mobile;
    return "${mobile.substring(0, 2)}XXXXXX${mobile.substring(mobile.length - 2)}";
  }

  void _startTimer() {
    _secondsRemaining = 60;
    _canResend = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        setState(() => _canResend = true);
        timer.cancel();
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  Future<String> fcmGetToken() async {
    NotificationSettings settings = await FirebaseMessaging.instance
        .requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: true,
        );
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      return "no_permission";
    }
    return await FirebaseMessaging.instance.getToken() ?? "unknown_device";
  }

  /// 🔁 LOGIN RESEND OTP
  Future<void> _loginResendOtp() async {
    final deviceToken = await fcmGetToken();
    setState(() => isLoading = true);
    try {
      final dio = await callDio();
      final service = APIStateNetwork(dio);
      final response = await service.login(
        LoginBodyModel(loginType: widget.mobile, deviceId: deviceToken),
      );
      if (response.code == 0) {
        final newToken = response.data?.token ?? "";
        if (newToken.isNotEmpty) {
          _currentToken = newToken; // 🔥 UPDATE TOKEN
        }
        Fluttertoast.showToast(msg: "OTP resent successfully");
        _resetOtpField();
        _startTimer();
      } else {
        Fluttertoast.showToast(msg: "Resend OTP failed");
      }
    } catch (e, st) {
      debugPrint("Resend error: $e\n$st");
      Fluttertoast.showToast(msg: "Something went wrong");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  /// 🔁 REGISTER RESEND OTP
  Future<void> _registorResendOTP() async {
    final deviceToken = await fcmGetToken();
    setState(() => isLoading = true);
    try {
      final dio = await callDio();
      final service = APIStateNetwork(dio);
      final response = await service.register(
        RegisterBodyModel(
          firstName: widget.firstName ?? "",
          lastName: widget.lastNameController ?? "",
          email: widget.emailController ?? "",
          phone: widget.mobile,
          cityId: widget.cityId ?? "",
          deviceId: deviceToken,
          refByCode: widget.codeController ?? "",
        ),
      );
      if (response.code == 0) {
        final newToken = response.data['token'];
        if (newToken != null && newToken.toString().isNotEmpty) {
          _currentToken = newToken.toString(); // 🔥 UPDATE TOKEN
        }

        Fluttertoast.showToast(msg: "OTP resent successfully");
        _resetOtpField();
        _startTimer();
      } else {
        Fluttertoast.showToast(msg: "Resend OTP failed");
      }
    } catch (e, st) {
      log("Register resend error: $e\n$st");
      Fluttertoast.showToast(msg: "Something went wrong");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _resetOtpField() {
    setState(() {
      otpValue = "";
      _otpKey = UniqueKey(); // 🔥 CLEAR OTP FIELD
    });
  }

  bool _validateOtp() {
    if (otpValue.length != 4) {
      Fluttertoast.showToast(msg: "Enter valid 4-digit OTP");
      return false;
    }
    return true;
  }

  /// ✅ REGISTER VERIFY
  Future<void> _verifyRegisterOtp() async {
    if (!_validateOtp()) return;
    setState(() => isLoading = true);
    try {
      final dio = await callDio();
      final service = APIStateNetwork(dio);
      final response = await service.verifyUser(
        OtpBodyModel(
          token: _currentToken, // 🔥 IMPORTANT
          otp: otpValue,
        ),
      );
      if (response.code == 0) {
        Fluttertoast.showToast(msg: "OTP Verified");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LocationEnablePage()),
          (_) => false,
        );
      } else {
        Fluttertoast.showToast(msg: response.message ?? "Invalid OTP");
        _resetOtpField();
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Something went wrong");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  /// ✅ LOGIN VERIFY
  Future<void> _verifyLoginOtp() async {
    if (!_validateOtp()) return;
    setState(() => isLoading = true);
    try {
      final dio = await callDio();
      final service = APIStateNetwork(dio);

      final response = await service.verifylogin(
        OtpBodyModel(
          token: _currentToken, // 🔥 IMPORTANT
          otp: otpValue,
        ),
      );
      if (response.code == 0) {
        Fluttertoast.showToast(msg: "OTP Verified");
        final token = response.data?.token ?? "";
        if (token.isNotEmpty) {
          final box = await Hive.openBox('userdata');
          await box.put('token', token);
        }
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LocationEnablePage()),
          (_) => false,
        );
      } else {
        Fluttertoast.showToast(msg: response.message ?? "Invalid OTP");
        _resetOtpField();
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Something went wrong");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              SizedBox(height: 30.h),
              Text(
                "OTP Verification",
                style: GoogleFonts.inter(
                  fontSize: 25.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 7.h),
              Text(
                "Please enter the 4-digit code",
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFFD7D7D7),
                ),
              ),
              Text(
                "sent to ${maskMobileNumber(widget.mobile)}",
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFFD7D7D7),
                ),
              ),

              SizedBox(height: 40.h),
              OtpPinField(
                key: _otpKey,
                maxLength: 4,
                fieldWidth: 50.w,
                fieldHeight: 45.h,
                cursorColor: Colors.white,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                otpPinFieldDecoration:
                    OtpPinFieldDecoration.defaultPinBoxDecoration,
                otpPinFieldStyle: OtpPinFieldStyle(
                  textStyle: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  activeFieldBackgroundColor: const Color.fromARGB(
                    12,
                    255,
                    255,
                    255,
                  ),
                  defaultFieldBorderColor: const Color.fromARGB(
                    153,
                    255,
                    255,
                    255,
                  ),
                  activeFieldBorderColor: Colors.white,
                ),
                onChange: (v) => otpValue = v,
                onSubmit: (v) => otpValue = v,
              ),
              SizedBox(height: 20.h),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _canResend
                      ? () => widget.data
                            ? _registorResendOTP()
                            : _loginResendOtp()
                      : null,
                  child: Text(
                    _canResend
                        ? "Resend Code"
                        : "Resend in $_secondsRemaining sec",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 30.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () => widget.data
                            ? _verifyRegisterOtp()
                            : _verifyLoginOtp(),
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text("Verify"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
