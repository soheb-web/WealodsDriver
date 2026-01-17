/*

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:delivery_rider_app/RiderScreen/identityCard.page.dart';
import 'package:delivery_rider_app/config/network/api.state.dart';
import 'package:delivery_rider_app/config/utils/pretty.dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../data/model/ImageBodyModel.dart';

class DocumentPage extends StatefulWidget {
  const DocumentPage({super.key});

  @override
  State<DocumentPage> createState() => _DocumentPageState();
}

var box = Hive.box("userdata");

class _DocumentPageState extends State<DocumentPage> {
  File? _image;
  final picker = ImagePicker();

  Future pickImageFromGallery() async {
    var status = await Permission.camera.request();
    if (status.isGranted) {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
        box.put('driver_photo_path', pickedFile.path);
      }
    } else {
      log("Gallery permission denied");
      Fluttertoast.showToast(msg: "Gallery permission denied");
    }
  }

  Future pickImageFromCamera() async {
    var status = await Permission.camera.request();
    if (status.isGranted) {
      final pickedFile = await picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
        box.put('driver_photo_path', pickedFile.path);
      }
    } else {
      log("Camera permission denied");
      Fluttertoast.showToast(msg: "Camera permission denied");
    }
  }

  Future showImage() async {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          actions: [
            CupertinoActionSheetAction(
              onPressed: () async {
                Navigator.pop(context);
                await pickImageFromGallery();
                if (_image != null) {
                  // await uploadImage(_image!);
                  uploadImageComplete(_image!);
                }
              },
              child: const Text("Gallery"),
            ),
            CupertinoActionSheetAction(
              onPressed: () async {
                Navigator.pop(context);
                await pickImageFromCamera();
                if (_image != null) {
                  uploadImageComplete(_image!);
                  // await uploadImage(_image!);
                }
              },
              child: const Text("Camera"),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
  }


  Future<String?> uploadImage(File image) async {
    try {
      if (!await image.exists()) throw Exception('Image file does not exist at path: ${image.path}');

      var request = http.MultipartRequest('POST', Uri.parse('https://backend.weloads.live/api/v1/uploadImage'));
      request.files.add(await http.MultipartFile.fromPath('file', image.path, filename: 'profile.jpg'));

      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);
      final responseData = jsonDecode(responseBody.body) as Map<String, dynamic>;

      if (response.statusCode == 200 &&
          responseData['error'] == false &&
          responseData['data'] != null &&
          responseData['data']['imageUrl'] != null) {
        return responseData['data']['imageUrl'] as String;
      } else {
        throw Exception('Invalid response format: $responseData');
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to upload image: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 12.sp,
      );
      return null;
    }
  }

  uploadImageComplete(File image)async{
    final backImageUrl = await uploadImage(image!);
    if (backImageUrl == null || backImageUrl.isEmpty) throw Exception("Failed to upload back image");

    final body = ImageBodyModel(
      image: backImageUrl
    );

    final dio = await callDio();
    final service = APIStateNetwork(dio);
    final response = await service.updateDriverProfile(body);
  }

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
            style: IconButton.styleFrom(shape: const CircleBorder()),
            onPressed: () {
              Navigator.pop(context);
            },
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
          Divider(color: const Color(0xFFCBCBCB), thickness: 1),
          SizedBox(height: 28.h),
          InkWell(
            onTap: () async {
              await showImage();
            },
            child: driverUploadPhoto(_image, "Driver's Photo"),
          ),
          SizedBox(height: 24.h),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const IdentityCardPage(),
                ),
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
  Widget VerifyWidget(String image, String name) {
    return Container(
      margin: EdgeInsets.only(left: 24.w, right: 24.w),
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.r),
        color: const Color(0xFFF0F5F5),
      ),
      child: Row(
        children: [
          Image.asset(image, width: 40.w, height: 40.h, fit: BoxFit.cover),
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
*/

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
  /* File? _image;

  final ImagePicker _picker = ImagePicker();


  void showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  pickImage( ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

// Pick image from Camera or Gallery
  Future<void> pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {

          _image = File(pickedFile.path);
          uploadImageComplete(_image!);
      });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No image selected')));
    }
  }



  // Common handler after picking image
  void _handleImagePicked(File image) {
    setState(() {
      _image = image;
    });
    box.put('driver_photo_path', image.path); // Save path locally
    uploadImageComplete(image); // Upload immediately
  }


  // Upload image to server and update profile
  Future<void> uploadImageComplete(File image) async {
    try {
      final imageUrl = await uploadImage(image);
      if (imageUrl == null || imageUrl.isEmpty) {
        _showToast("Failed to upload image. Please try again.");
        return;
      }

      final body = ImageBodyModel(image: imageUrl);
      final dio = await callDio();
      final service = APIStateNetwork(dio);

      final response = await service.updateDriverProfile(body);

      // Optional: Handle success/failure from API
      _showToast("Profile photo updated successfully!");
    } catch (e) {
      log("Upload error: $e");
      _showToast("Upload failed: $e");
    }
  }

  // Upload image to https://backend.weloads.live/api/v1/uploadImage
  Future<String?> uploadImage(File image) async {
    try {
      if (!await image.exists()) {
        throw Exception('Image file does not exist');
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://backend.weloads.live/api/v1/uploadImage'),
      );
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          image.path,
          filename: 'profile.jpg',
        ),
      );

      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);
      final data = jsonDecode(responseBody.body) as Map<String, dynamic>;

      if (response.statusCode == 200 &&
          data['error'] == false &&
          data['data']?['imageUrl'] != null) {
        return data['data']['imageUrl'] as String;
      } else {
        throw Exception('Upload failed: ${data['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      log("Image upload error: $e");
      return null;
    }
  }

  void _showToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.SNACKBAR,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
      fontSize: 14.sp,
    );
  }
*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar:
      AppBar(
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
      body:
      Column(
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
