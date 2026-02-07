import 'dart:io';
import 'package:delivery_rider_app/RiderScreen/identityCard.page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

class DocumentPage extends StatefulWidget {
  const DocumentPage({super.key});

  @override
  State<DocumentPage> createState() => _DocumentPageState();
}

final box = Hive.box("userdata");

class _DocumentPageState extends State<DocumentPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFFFFFFF),
        leading: Padding(
          padding: EdgeInsets.only(left: 20.w),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios, size: 20.sp),
          ),
        ),
        title: Padding(
          padding: EdgeInsets.only(left: 15.w),
          child: Text(
            "Documents",
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF091425),
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10.h),
          const Divider(color: Color(0xFFCBCBCB), thickness: 1),
          SizedBox(height: 28.h),
          // InkWell(
          //   onTap: () => showImageSourceSheet(),
          //   // showImagePicker,
          //   child: driverUploadPhoto(_image, "Driver's Photo"),
          // ),
          SizedBox(height: 24.h),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                CupertinoPageRoute(builder: (_) => const IdentityCardPage()),
              );
            },
            child: VerifyWidget("assets/id-card.png", "Identity Card (front)"),
          ),
        ],
      ),
    );
  }

  Widget driverUploadPhoto(File? selectedImage, String name) {
    return Container(
      margin: EdgeInsets.only(left: 24.w, right: 24.w),
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.r),
        color: const Color(0xFFF0F5F5),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: selectedImage != null
                ? Image.file(
                    selectedImage,
                    width: 40.w,
                    height: 40.h,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    "assets/photo.jpg",
                    width: 40.w,
                    height: 40.h,
                    fit: BoxFit.cover,
                  ),
          ),
          SizedBox(width: 30.w),
          Text(
            name,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF4F4F4F),
            ),
          ),
          const Spacer(),
          const Icon(Icons.warning_amber_rounded, color: Colors.red),
        ],
      ),
    );
  }

  Widget VerifyWidget(String asset, String name) {
    return Container(
      margin: EdgeInsets.only(left: 24.w, right: 24.w),
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.r),
        color: const Color(0xFFF0F5F5),
      ),
      child: Row(
        children: [
          Image.asset(asset, width: 40.w, height: 40.h, fit: BoxFit.cover),
          SizedBox(width: 30.w),
          Text(
            name,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF4F4F4F),
            ),
          ),
          const Spacer(),
          const Icon(Icons.warning_amber_rounded, color: Colors.red),
        ],
      ),
    );
  }
}
