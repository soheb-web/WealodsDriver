import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:delivery_rider_app/RiderScreen/complete.page.dart';
import 'package:delivery_rider_app/config/network/api.state.dart';
import 'package:delivery_rider_app/config/utils/pretty.dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' hide MultipartFile;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../data/model/completeBodyModel.dart';

class ProcessDropOffPage extends StatefulWidget {
  final String txtid;
  const ProcessDropOffPage({super.key, required this.txtid});

  @override
  State<ProcessDropOffPage> createState() => _ProcessDropOffPageState();
}

class _ProcessDropOffPageState extends State<ProcessDropOffPage> {
  File? image;
  final picker = ImagePicker();
  bool isUploading = false;

  Future pickImageFromGallery() async {
    var status = await Permission.camera.request();
    if (status.isDenied) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gallery permission is Denied")));
      return;
    } else {
      final PickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (PickedFile != null) {
        setState(() {
          image = File(PickedFile.path);
        });
      }
    }
  }

  Future pickImageFromCamera() async {
    var status = await Permission.camera.request();
    if (status.isDenied) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Camere permission is Denied")));
      return;
    } else {
      final PickedFile = await picker.pickImage(source: ImageSource.camera);
      if (PickedFile != null) {
        setState(() {
          image = File(PickedFile.path);
        });
      }
    }
  }

  Future showImage() async {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              pickImageFromGallery();
            },
            child: Text("Gallery"),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              pickImageFromCamera();
            },
            child: Text("Camera"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFFFF),
        leading: Container(
          padding: EdgeInsets.zero,
          margin: EdgeInsets.only(left: 15.w),
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios, color: Color(0xFF111111)),
          ),
        ),
        title: Text(
          "Drop off process",
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.w400,
            color: Color(0xFF111111),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40.h),
          Center(
            child: DottedBorder(
              options: RoundedRectDottedBorderOptions(
                radius: Radius.circular(8.r),
                color: Color(0xFFA8DADC),
                strokeWidth: 2,
                dashPattern: [6, 3],
              ),
              child: InkWell(
                onTap: () {
                  showImage();
                },
                child: Container(
                  width: 300,
                  height: 200.h,
                  decoration: BoxDecoration(
                    color: Color(0xFFF0F5F5),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: Image.file(image!, fit: BoxFit.contain),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 35.w,
                              height: 35.h,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFA8DADC),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.camera_alt_outlined,
                                  color: Color(0xFF004448),
                                  size: 20.sp,
                                ),
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              "Take proof of delivery photo",
                              style: GoogleFonts.inter(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF545454),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),

          SizedBox(height: 30.h),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(306.w, 45.h),
                backgroundColor: Color(0xFF006970),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.r),
                  side: BorderSide.none,
                ),
              ),
              onPressed: image == null || isUploading
                  ? null
                  : () async {
                      // => deliveryComplete(widget.txtid, image!),
                      setState(() {
                        isUploading = true;
                      });
                      try {
                        final body = DeliverCompleteBodyModel(
                          txId: widget.txtid,
                          image: image!.path.toString(),
                        );
                        final service = APIStateNetwork(callDio());
                        final response = await service.deliveryCompelte(body);
                        if (response.code == 0) {
                          Fluttertoast.showToast(msg: response.message ?? "");

                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => CompletePage(
                                previousAmount: response.data!.previousAmount!,
                                extraWaitingMinutes:
                                    response.data!.extraWaitingMinutes!,
                                extraWaitingCharge:
                                    response.data!.extraWaitingCharge!,
                                freeWaitingTime:
                                    response.data!.freeWaitingTime!,
                              ),
                            ),
                          );

                          setState(() {
                            isUploading = false;
                          });
                        } else {
                          Fluttertoast.showToast(msg: response.message ?? "");
                          setState(() {
                            isUploading = false;
                          });
                        }
                      } catch (e, st) {
                        setState(() {
                          isUploading = false;
                        });
                        log(e.toString());
                        log(st.toString());
                      }
                    },
              child: isUploading
                  ? Center(
                      child: SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 1.w,
                        ),
                      ),
                    )
                  : Text(
                      "Complete",
                      style: GoogleFonts.inter(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
