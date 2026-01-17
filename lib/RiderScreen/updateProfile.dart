import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../config/network/api.state.dart';
import '../config/utils/pretty.dio.dart';
import '../data/controller/getProfileController.dart';
import '../data/model/UpdateProfileBodyModel.dart';

class UpdateUserProfilePage extends ConsumerStatefulWidget {
  const UpdateUserProfilePage({super.key});
  @override
  ConsumerState<UpdateUserProfilePage> createState() =>
      _UpdateUserProfilePageState();
}

class _UpdateUserProfilePageState extends ConsumerState<UpdateUserProfilePage> {
  // ---------- Controllers ----------
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  // ---------- Loading ----------
  bool _isLoading = false;

  // ---------- Images ----------
  File? _pickedImage; // newly selected by user
  String? _networkImageUrl; // URL that came from API
  final _picker = ImagePicker();

  // -----------------------------------------------------------------
  //  IMAGE PICKER
  // -----------------------------------------------------------------
  Future<void> _pickFromGallery() async {
    final status = await Permission.photos.request();
    if (!status.isGranted) {
      Fluttertoast.showToast(msg: "Gallery permission denied");
      return;
    }
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) setState(() => _pickedImage = File(file.path));
  }

  Future<void> _pickFromCamera() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      Fluttertoast.showToast(msg: "Camera permission denied");
      return;
    }
    final file = await _picker.pickImage(source: ImageSource.camera);
    if (file != null) setState(() => _pickedImage = File(file.path));
  }

  void _showPickerSheet() {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _pickFromGallery();
            },
            child: const Text('Gallery'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _pickFromCamera();
            },
            child: const Text('Camera'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  // -----------------------------------------------------------------
  //  BUILD
  // -----------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    // ---- Watch profile ----
    final profileAsync = ref.watch(profileController);

    // ---- Fill fields when data arrives ----
    profileAsync.whenData((profile) {
      if (profile.error == false && profile.data != null) {
        final data = profile.data!;

        // First / Last name (only once)
        if (_firstNameCtrl.text.isEmpty) {
          _firstNameCtrl.text = data.firstName ?? '';
        }
        if (_lastNameCtrl.text.isEmpty) {
          _lastNameCtrl.text = data.lastName ?? '';
        }

        if (emailController.text.isEmpty) {
          emailController.text = data.email ?? "";
        }

        if (phoneController.text.isEmpty) {
          phoneController.text = data.phone ?? "";
        }

        // Profile image URL (only once)
        if (data.image != null &&
            data.image!.isNotEmpty &&
            _networkImageUrl == null) {
          _networkImageUrl = data.image!;
          if (mounted) setState(() {});
        }
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 50.h),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF006970),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: const Offset(1, 1),
                      ),
                    ],
                  ),
                  child: Icon(Icons.arrow_back, size: 18, color: Colors.white),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                "Edit Your Profile",
                style: GoogleFonts.inter(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF111111),
                ),
              ),
              SizedBox(height: 35.h),

              // ---------- First Name ----------
              TextFormField(
                controller: _firstNameCtrl,
                keyboardType: TextInputType.name,
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF293540),
                ),
                decoration: InputDecoration(
                  labelText: "First Name",
                  labelStyle: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF006970),
                  ),
                  filled: true,
                  fillColor: Color(0xFFF0F5F5),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.r),
                    borderSide: BorderSide(
                      color: const Color(0xFF006970).withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.r),
                    borderSide: const BorderSide(
                      color: Color(0xFF006970),
                      width: 1.5,
                    ),
                  ),
                  hintText: "Enter First Name",
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF787B7B),
                  ),
                  suffixIcon: Icon(Icons.edit, color: Color(0xFF006970)),
                ),
                validator: (v) =>
                    (v?.isEmpty ?? true) ? "First Name is required" : null,
              ),
              SizedBox(height: 20.h),

              // ---------- Last Name ----------
              TextFormField(
                controller: _lastNameCtrl,
                keyboardType: TextInputType.name,
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF293540),
                ),
                decoration: InputDecoration(
                  labelText: "Last Name",
                  labelStyle: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF006970),
                  ),
                  filled: true,
                  fillColor: Color(0xFFF0F5F5),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.r),
                    borderSide: BorderSide(
                      color: const Color(0xFF006970).withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.r),
                    borderSide: const BorderSide(
                      color: Color(0xFF006970),
                      width: 1.5,
                    ),
                  ),
                  hintText: "Enter First Name",
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF787B7B),
                  ),
                  suffixIcon: Icon(Icons.edit, color: Color(0xFF006970)),
                ),
                validator: (v) =>
                    (v?.isEmpty ?? true) ? "Last Name is required" : null,
              ),
              SizedBox(height: 20.h),


              TextFormField(
                onTap: () {
                  Fluttertoast.showToast(
                    msg: "You cannot change your registered email",
                  );
                },
                controller: emailController,
                readOnly: true,
                keyboardType: TextInputType.name,
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF293540),
                ),
                decoration: InputDecoration(
                  labelText: "Email",
                  labelStyle: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF006970),
                  ),
                  filled: true,
                  fillColor: Color(0xFFF0F5F5),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.r),
                    borderSide: BorderSide(
                      color: const Color(0xFF006970).withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.r),
                    borderSide: BorderSide(
                      color: const Color(0xFF006970).withOpacity(0.3),
                    ),
                  ),
                  hintText: "Enter Email",
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF787B7B),
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              TextFormField(
                onTap: () {
                  Fluttertoast.showToast(
                    msg: "You cannot change your registered Phone Number",
                  );
                },
                controller: phoneController,
                readOnly: true,
                keyboardType: TextInputType.name,
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF293540),
                ),
                decoration: InputDecoration(
                  labelText: "Phone",
                  labelStyle: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF006970),
                  ),
                  filled: true,
                  fillColor: Color(0xFFF0F5F5),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.r),
                    borderSide: BorderSide(
                      color: const Color(0xFF006970).withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.r),
                    borderSide: BorderSide(
                      color: const Color(0xFF006970).withOpacity(0.3),
                    ),
                  ),
                  hintText: "Enter Phone",
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF787B7B),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              // ---------- IMAGE BOX ----------
              Center(
                child: InkWell(
                  onTap: _showPickerSheet,
                  child: Stack(
                    children: [

                      Container(
                        width: 300.w,
                        height: 200.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F5F5),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: _pickedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(20.r),
                                child: Image.file(
                                  _pickedImage!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              )
                            : _networkImageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(20.r),
                                child: CachedNetworkImage(
                                  imageUrl: _networkImageUrl!,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  errorWidget: (_, __, ___) => const Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.upload_sharp,
                                    color: const Color(0xFF008080),
                                    size: 30.sp,
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    "Upload Image",
                                    style: GoogleFonts.inter(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xFF4D4D4D),
                                    ),
                                  ),
                                ],
                              ),
                      ),


                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: const BoxDecoration(
                            color: Color(0xFF006970),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 18.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              // ---------- UPDATE BUTTON ----------
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(300.w, 50.h),
                    backgroundColor: const Color(0xFF006970),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                  ),
                  onPressed: _isLoading ? null : () => _updateProfile(),
                  child: _isLoading
                      ? SizedBox(
                          width: 30.w,
                          height: 30.h,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          "Update",
                          style: GoogleFonts.inter(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFFFFFFFF),
                          ),
                        ),
                ),
              ),
              SizedBox(height: 14.h),
            ],
          ),
        ),
      ),
    );
  }

  // -----------------------------------------------------------------
  //  UPDATE LOGIC
  // -----------------------------------------------------------------
  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);
    try {
      final service = APIStateNetwork(callDio());

      // 1. Upload new image (if any)
      String? finalImageUrl = _networkImageUrl; // keep old if no new
      if (_pickedImage != null) {
        final uploadRes = await service.uploadImage(_pickedImage!);
        if (uploadRes.error == false && uploadRes.data.imageUrl.isNotEmpty) {
          finalImageUrl = uploadRes.data.imageUrl;
        } else {
          throw Exception("Image upload failed");
        }
      }

      // 2. Build request body
      final body = UpdateUserProfileBodyModel(
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        image: finalImageUrl!,
      );

      // 3. Call update API
      final updateRes = await service.updateCutomerProfile(body);

      Fluttertoast.showToast(
        msg:
            updateRes.message ??
            (updateRes.code == 0 ? "Profile updated" : "Update failed"),
      );

      if (updateRes.code == 0) {
        // Optional: refresh profile data
        ref.invalidate(profileController);
        ref.refresh(profileController);
        Navigator.pop(context);
      }
    } catch (e, st) {
      log("Update error: $e\n$st");
      Fluttertoast.showToast(msg: "Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    super.dispose();
  }
}
