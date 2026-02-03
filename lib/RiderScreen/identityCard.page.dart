import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../config/network/api.state.dart';
import '../config/utils/pretty.dio.dart';
import '../data/controller/getProfileController.dart';
import '../data/model/saveDriverBodyModel.dart';

class IdentityCardPage extends ConsumerStatefulWidget {
  const IdentityCardPage({super.key});

  @override
  ConsumerState<IdentityCardPage> createState() => _IdentityCardPageState();
}

class _IdentityCardPageState extends ConsumerState<IdentityCardPage> {
  File? _frontFile;
  File? _backFile;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(profileController);
    });
  }

  // Image Picker
  void _showPickerSheet(bool isFront) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(isFront, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(isFront, ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(bool isFront, ImageSource source) async {
    final XFile? picked = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );
    if (picked == null) return;

    setState(() {
      if (isFront) {
        _frontFile = File(picked.path);
      } else {
        _backFile = File(picked.path);
      }
    });
  }

  // Upload Image
  Future<String?> _uploadImage(File file) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://backend.weloads.live/api/v1/uploadImage'),
      );
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          filename: 'id.jpg',
        ),
      );

      final resp = await request.send();
      final body = await http.Response.fromStream(resp);
      final json = jsonDecode(body.body);

      if (resp.statusCode == 200 &&
          json['error'] == false &&
          json['data']?['imageUrl'] != null) {
        return json['data']['imageUrl'];
      }
      throw Exception(json['message'] ?? 'Upload failed');
    } catch (e) {
      Fluttertoast.showToast(msg: "$e", backgroundColor: Colors.red);
      return null;
    }
  }

  // Submit Front
  Future<void> _submitFront() async {
    if (_frontFile == null) return;
    setState(() => _isLoading = true);

    try {
      final url = await _uploadImage(_frontFile!);
      if (url == null) throw Exception("Upload failed");

      final body = SaveDriverBodyModel(identityFront: url);
      final service = APIStateNetwork(await callDio());
      await service.saveDriverDocuments(body);

      Fluttertoast.showToast(
        msg: "Front photo submitted!",
        backgroundColor: Colors.green,
      );
      ref.invalidate(profileController);
      setState(() => _frontFile = null);
    } catch (e) {
      Fluttertoast.showToast(msg: "$e", backgroundColor: Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Submit Back
  Future<void> _submitBack() async {
    if (_backFile == null) return;
    setState(() => _isLoading = true);

    try {
      final url = await _uploadImage(_backFile!);
      if (url == null) throw Exception("Upload failed");

      final body = SaveDriverBackBodyModel(identityBack: url);
      final service = APIStateNetwork(await callDio());
      await service.saveDriverBackDocuments(body);

      Fluttertoast.showToast(
        msg: "Back photo submitted!",
        backgroundColor: Colors.green,
      );
      ref.invalidate(profileController);
      setState(() => _backFile = null);
    } catch (e) {
      Fluttertoast.showToast(msg: "$e", backgroundColor: Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Status Badge
  Widget _statusBadge(String status) {
    final Map<String, dynamic> badge =
        {
          'pending': {'color': Colors.orange, 'text': 'Pending'},
          'rejected': {'color': Colors.red, 'text': 'Rejected'},
          'approved': {'color': Colors.green, 'text': 'Approved'},
          'complete': {'color': Colors.green, 'text': 'Approved'},
        }[status] ??
        {'color': Colors.grey, 'text': 'Unknown'};

    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: badge['color'],
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          badge['text'],
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Re-upload Overlay
  Widget _reuploadOverlay(String label, bool isFront) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.black.withOpacity(0.7),
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF006970),
          ),
          onPressed: () => _showPickerSheet(isFront),
          child: Text(
            "Re-upload $label",
            style: GoogleFonts.inter(color: Colors.white, fontSize: 14.sp),
          ),
        ),
      ),
    );
  }

  // Main Image Box (Front + Back दोनों के लिए)
  Widget _buildImageBox({
    required String label,
    required bool isFront,
    required String? imageUrl,
    required File? localFile,
    required String status,
  }) {
    final bool hasImage = imageUrl != null && imageUrl.isNotEmpty;
    final bool isRejected = status == "rejected";
    final bool isPending = status == "pending";
    final bool isApproved = status == "approved" || status == "complete";

    // 1. Selected local file
    if (localFile != null) {
      return _imageContainer(Image.file(localFile, fit: BoxFit.cover));
    }

    // 2. Image uploaded + status available
    if (hasImage && (isPending || isApproved || isRejected)) {
      return Stack(
        children: [
          _imageContainer(
            CachedNetworkImage(
              imageUrl: imageUrl!,
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  const Center(child: CircularProgressIndicator()),
              errorWidget: (_, __, ___) =>
                  const Icon(Icons.broken_image, size: 50, color: Colors.grey),
            ),
          ),
          _statusBadge(status),
          if (isRejected) _reuploadOverlay(label, isFront),
        ],
      );
    }

    // 3. No image yet OR rejected OR pending but no image → Show Upload CTA
    // ये सबसे महत्वपूर्ण कंडीशन है
    if (!hasImage || isRejected) {
      return GestureDetector(
        onTap: () => _showPickerSheet(isFront),
        child: _imageContainer(
          Container(
            color: Colors.grey[50],
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add_a_photo_outlined,
                    size: 70,
                    color: const Color(0xFF006970),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    "Upload $label",
                    style: GoogleFonts.inter(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF006970),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // 4. Fallback (should never reach here)
    return _imageContainer(
      Center(
        child: Text("Status: $status", style: TextStyle(color: Colors.grey)),
      ),
    );
  }

  Widget _imageContainer(Widget child) {
    return Container(
      width: 306.w,
      height: 200.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.sp),
        border: Border.all(color: Colors.black12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.sp),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileController);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: EdgeInsets.only(left: 20.w),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios, size: 20.sp),
          ),
        ),
        title: Text("Identity Card", style: GoogleFonts.inter(fontSize: 15.sp)),
      ),
      body: Stack(
        children: [
          profileAsync.when(
            data: (profile) {
              if (profile.error == true || profile.data == null) {
                return const Center(child: Text("Failed to load profile"));
              }

              final docs = profile.data!.driverDocuments;
              final frontUrl = docs?.identityFront?.image;
              final backUrl = docs?.identityBack?.image;
              final frontStatus = docs?.identityFront?.status ?? "";
              final backStatus = docs?.identityBack?.status ?? "";

              // Submit enable only when new image is selected
              final bool canSubmitFront = _frontFile != null;
              final bool canSubmitBack = _backFile != null;

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 28.h),
                    Text(
                      "Make sure the entire ID and all the details are VISIBLE",
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        color: const Color(0xFF4F4F4F),
                      ),
                    ),
                    SizedBox(height: 30.h),

                    // Front
                    Text(
                      "Front Photo",
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        color: const Color(0xFF4F4F4F),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Center(
                      child: _buildImageBox(
                        label: "Front Photo",
                        isFront: true,
                        imageUrl: frontUrl,
                        localFile: _frontFile,
                        status: frontStatus,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Center(
                      child: ElevatedButton(
                        onPressed: canSubmitFront ? _submitFront : null,
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(306.w, 45.h),
                          backgroundColor: const Color(0xFF006970),
                          disabledBackgroundColor: Colors.grey[400],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.r),
                          ),
                        ),
                        child: Text(
                          "Submit Front",
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 40.h),

                    // Back
                    Text(
                      "Back Photo",
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        color: const Color(0xFF4F4F4F),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Center(
                      child: _buildImageBox(
                        label: "Back Photo",
                        isFront: false,
                        imageUrl: backUrl,
                        localFile: _backFile,
                        status: backStatus,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Center(
                      child: ElevatedButton(
                        onPressed: canSubmitBack ? _submitBack : null,
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(306.w, 45.h),
                          backgroundColor: const Color(0xFF006970),
                          disabledBackgroundColor: Colors.grey[400],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.r),
                          ),
                        ),
                        child: Text(
                          "Submit Back",
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 60.h),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) =>
                const Center(child: Text("Error loading profile")),
          ),

          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF006970)),
              ),
            ),
        ],
      ),
    );
  }
}
