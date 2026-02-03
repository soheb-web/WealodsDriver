

import 'package:delivery_rider_app/RiderScreen/login.page.dart';
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
  const OtpPage(this.data, this.token, {super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  String otpValue = "";
  bool isLoading = false;

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

              /// Back Button
              InkWell(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 35.w,
                  height: 35.h,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Icon(Icons.arrow_back,
                      color: Colors.black, size: 20.sp),
                ),
              ),

              SizedBox(height: 30.h),

              /// Title
              Text(
                "OTP Verification",
                style: GoogleFonts.inter(
                  fontSize: 25.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),

              SizedBox(height: 7.h),

              /// Subtitle (UPDATED)
              Text(
                "Please enter the 4-digit code sent to you.",
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFFD7D7D7),
                ),
              ),

              SizedBox(height: 40.h),

              /// OTP Input Field (4 DIGIT)
              OtpPinField(
                cursorColor: Colors.white,
                maxLength: 4, // ✅ UPDATED
                fieldWidth: 50.w,
                fieldHeight: 45.h,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                otpPinFieldDecoration:
                OtpPinFieldDecoration.defaultPinBoxDecoration,
                otpPinFieldStyle: OtpPinFieldStyle(
                  textStyle: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  activeFieldBackgroundColor:
                  const Color.fromARGB(12, 255, 255, 255),
                  defaultFieldBorderColor:
                  const Color.fromARGB(153, 255, 255, 255),
                  activeFieldBorderColor: Colors.white,
                ),
                onChange: (text) => otpValue = text,
                onSubmit: (text) => otpValue = text,
              ),

              SizedBox(height: 50.h),

              /// Verify Button
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                  ),
                  onPressed: isLoading
                      ? null
                      : () {
                    widget.data
                        ? _verifyRegisterOtp()
                        : _verifyLoginOtp();
                  },
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : Text(
                    "Verify",
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF091425),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ✅ 4-DIGIT OTP VALIDATION
  bool _validateOtp() {
    if (otpValue.isEmpty || otpValue.length != 4) {
      Fluttertoast.showToast(msg: "Please enter a valid 4-digit OTP");
      return false;
    }
    return true;
  }

  /// ✅ OTP Verification for Registration
  Future<void> _verifyRegisterOtp() async {
    if (!_validateOtp()) return;

    setState(() => isLoading = true);
    final body = OtpBodyModel(token: widget.token, otp: otpValue);

    try {
      final dio = await callDio();
      final service = APIStateNetwork(dio);
      final response = await service.verifyUser(body);

      if (response.code == 0) {
        Fluttertoast.showToast(msg: response.message ?? "OTP Verified");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
              (_) => false,
        );
      } else {
        Fluttertoast.showToast(msg: response.message ?? "OTP verification failed");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Something went wrong");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  /// ✅ OTP Verification for Login
  Future<void> _verifyLoginOtp() async {
    if (!_validateOtp()) return;

    setState(() => isLoading = true);
    final body = OtpBodyModel(token: widget.token, otp: otpValue);

    try {
      final dio = await callDio();
      final service = APIStateNetwork(dio);
      final response = await service.verifylogin(body);

      if (response.code == 0) {
        Fluttertoast.showToast(msg: response.message ?? "OTP Verified");

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
        Fluttertoast.showToast(msg: response.message ?? "OTP verification failed");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Something went wrong");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }
}
