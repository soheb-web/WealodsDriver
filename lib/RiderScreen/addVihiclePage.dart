import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../config/network/api.state.dart';
import '../config/utils/pretty.dio.dart';
import '../data/model/AddBodyVihileModel.dart';
import '../data/model/VihicleResponseModel.dart';
import '../data/model/driverProfileModel.dart';

class AddVihiclePage extends StatefulWidget {
  final VehicleDetail? vehicleDetail;
  final Document? documentToReupload;

  const AddVihiclePage({
    super.key,
    this.vehicleDetail,
    this.documentToReupload,
  });

  @override
  State<AddVihiclePage> createState() => _AddVihiclePageState();
}

class _AddVihiclePageState extends State<AddVihiclePage> {
  List<Datum> vehicleList = [];
  Datum? selectedVehicle;
  final numberPlateController = TextEditingController();
  final modelController = TextEditingController();
  final capacityWeightController = TextEditingController();
  final capacityVolumeController = TextEditingController();
  bool isLoading = false;
  final _picker = ImagePicker();
  Map<String, File?> documentImages = {
    'POC': null,
    'License': null,
    'RC': null,
    'Insurance': null,
    'Permit': null,
    'Other': null,
  };
  Map<String, bool> uploadStatus = {
    'POC': false,
    'License': false,
    'RC': false,
    'Insurance': false,
    'Permit': false,
    'Other': false,
  };
  late final bool isEditMode;
  late final bool isReuploadMode;
  @override
  void initState() {
    super.initState();
    isEditMode = widget.vehicleDetail != null;
    isReuploadMode = widget.documentToReupload != null;

    // Pre-fill only text fields first
    if (isEditMode || isReuploadMode) {
      _prefillTextFields();
    }

    getVehicleType(); // This will set selectedVehicle safely
  }

  void _prefillTextFields() {
    final v = widget.vehicleDetail;
    if (v == null) return;

    numberPlateController.text = v.numberPlate ?? '';
    modelController.text = v.model ?? '';
    capacityWeightController.text = v.capacityWeight?.toString() ?? '';
    capacityVolumeController.text = v.capacityVolume?.toString() ?? '';

    // Mark existing docs as uploaded (for UI)
    for (var doc in (v.documents ?? [])) {
      final type = doc.type;
      if (type != null && uploadStatus.containsKey(type)) {
        uploadStatus[type] = true;
      }
    }
  }

  Future<void> getVehicleType() async {
    try {
      final dio = await callDio();
      final service = APIStateNetwork(dio);
      final response = await service.getVehicleType();

      setState(() {
        vehicleList = response.data ?? [];
        if (isEditMode || isReuploadMode) {
          _setSelectedVehicleSafely();
        }
      });
    } catch (e) {
      _showSnackBar("Failed to load vehicle types");
    }
  }

  void _setSelectedVehicleSafely() {
    final targetId = widget.vehicleDetail?.vehicle?.id;
    if (targetId == null || vehicleList.isEmpty) return;

    try {
      selectedVehicle = vehicleList.firstWhere(
        (e) => e.id.toString() == targetId,
      );
    } catch (_) {
      selectedVehicle = vehicleList.first;
    }
  }

  Future<String?> _upload(File file) async {
    try {
      if (!await file.exists()) throw Exception('File not found');

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://backend.weloads.live/api/v1/uploadImage'),
      );
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      final resp = await request.send();
      final body = await http.Response.fromStream(resp);
      final json = jsonDecode(body.body) as Map<String, dynamic>;

      if (resp.statusCode == 200 &&
          json['error'] == false &&
          json['data']?['imageUrl'] != null) {
        return json['data']['imageUrl'] as String;
      }
      throw Exception('Upload failed');
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Upload error: $e",
        backgroundColor: Colors.red,
      );
      return null;
    }
  }

  void _showPickerSheet(String docType) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _pickFromGallery(docType);
            },
            child: const Text('Gallery'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _pickFromCamera(docType);
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

  Future<void> _pickFromGallery(String docType) async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => documentImages[docType] = File(picked.path));
    }
  }

  Future<void> _pickFromCamera(String docType) async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      Fluttertoast.showToast(msg: "Camera permission denied");
      return;
    }
    final file = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (file != null) {
      setState(() => documentImages[docType] = File(file.path));
    }
  }
  // Widget buildTextField(String hint, TextEditingController controller) {
  //   return TextFormField(
  //     controller: controller,
  //     decoration: InputDecoration(
  //       hintText: hint,
  //       hintStyle: GoogleFonts.inter(fontSize: 14.sp, color: Colors.black),
  //       filled: true,
  //       fillColor: const Color.fromARGB(12, 255, 255, 255),
  //       contentPadding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 20.w),
  //       enabledBorder: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(10.r),
  //         borderSide: const BorderSide(color: Colors.black),
  //       ),
  //       focusedBorder: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(10.r),
  //         borderSide: const BorderSide(color: Colors.black),
  //       ),
  //     ),
  //   );
  // }

  Widget buildTextField(
    String hint,
    TextEditingController controller, {
    bool isNumberOnly = false, // ← नया optional parameter
    int? maxLength, // optional: max characters
    String? Function(String?)? validator, // optional: validation
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumberOnly ? TextInputType.number : TextInputType.text,
      inputFormatters: isNumberOnly
          ? [
              FilteringTextInputFormatter.digitsOnly, // सिर्फ 0-9
              if (maxLength != null)
                LengthLimitingTextInputFormatter(maxLength),
            ]
          : (maxLength != null
                ? [LengthLimitingTextInputFormatter(maxLength)]
                : []),
      maxLength: maxLength, // अगर चाहिए तो
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(fontSize: 14.sp, color: Colors.black),
        filled: true,
        fillColor: const Color.fromARGB(12, 255, 255, 255),
        contentPadding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 20.w),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: Colors.black),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: Colors.black, width: 2),
        ),
        counterText: "", // maxLength दिखाना बंद (अगर clean look चाहिए)
      ),
    );
  }

  int? _parseInt(String input) =>
      int.tryParse(input.replaceAll(RegExp(r'[^0-9]'), ''));
  double? _parseDouble(String input) =>
      double.tryParse(input.replaceAll(RegExp(r'[^0-9.]'), ''));
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: message.contains('Error') ? Colors.red : Colors.green,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> submitVehicle() async {
    if (selectedVehicle == null)
      return _showSnackBar('Please select a vehicle type');
    final numberPlate = numberPlateController.text.trim();
    final model = modelController.text.trim();
    final weightText = capacityWeightController.text.trim();
    final volumeText = capacityVolumeController.text.trim();

    if (numberPlate.isEmpty ||
        model.isEmpty ||
        weightText.isEmpty ||
        volumeText.isEmpty) {
      return _showSnackBar('Please fill all fields');
    }

    final capacityWeight = _parseInt(weightText);
    final capacityVolume = _parseDouble(volumeText);
    if (capacityWeight == null || capacityVolume == null) {
      return _showSnackBar('Invalid capacity values');
    }

    List<String> requiredDocs = ['POC', 'License', 'RC', 'Insurance', 'Other'];
    for (String doc in requiredDocs) {
      if (documentImages[doc] == null) {
        return _showSnackBar(
          'Please upload ${doc == 'Other' ? 'Vehicle Photo' : doc}',
        );
      }
    }

    setState(() => isLoading = true);
    try {
      final dio = await callDio();
      final service = APIStateNetwork(dio);

      List<VehicleDocument> documents = [];
      for (String docType in documentImages.keys) {
        if (documentImages[docType] != null) {
          final url = await _upload(documentImages[docType]!);
          if (url == null) throw Exception("Failed to upload $docType");
          documents.add(VehicleDocument(type: docType, fileUrl: url));
        }
      }

      final body = AddVihicleBodyModel(
        vehicle: selectedVehicle!.id.toString(),
        numberPlate: numberPlate,
        model: model,
        capacityWeight: capacityWeight,
        capacityVolume: capacityVolume,
        documents: documents,
      );

      final response = await service.addNewVehicle(body);
      _showSnackBar(response.message ?? "Success");
      Navigator.pop(context);
    } catch (e) {
      _showSnackBar("Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _reuploadSingleDocument() async {
    final rejectedDoc = widget.documentToReupload!;
    final docType = rejectedDoc.type!;
    if (documentImages[docType] == null) {
      return _showSnackBar("Please select a new image");
    }

    setState(() => isLoading = true);
    try {
      final dio = await callDio();
      final service = APIStateNetwork(dio);

      final newImageUrl = await _upload(documentImages[docType]!);
      if (newImageUrl == null) throw Exception("Upload failed");

      final currentDocs = widget.vehicleDetail!.documents ?? [];
      final updatedDocuments = currentDocs.map((doc) {
        if (doc.type == docType) {
          return VehicleDocument(type: docType, fileUrl: newImageUrl);
        }
        return VehicleDocument(type: doc.type!, fileUrl: doc.fileUrl!);
      }).toList();

      final body = UpdateVihicleBodyModel(
        vehicleId: widget.vehicleDetail!.id ?? "",
        numberPlate: widget.vehicleDetail!.numberPlate!,
        model: widget.vehicleDetail!.model!,
        capacityWeight: widget.vehicleDetail!.capacityWeight!,
        capacityVolume: widget.vehicleDetail!.capacityVolume!,
        documents: updatedDocuments,
      );

      final response = await service.updateNewVehicle(body);
      _showSnackBar(response.message ?? "Success");
      Navigator.pop(context);
    } catch (e) {
      _showSnackBar("Error: ${e.toString()}");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _submit() async {
    if (isReuploadMode) {
      await _reuploadSingleDocument();
    } else {
      await submitVehicle();
    }
  }

  Widget _buildDocumentUpload(String docType) {
    final isThisDoc = isReuploadMode
        ? widget.documentToReupload?.type == docType
        : true;
    final isRejected =
        isReuploadMode && widget.documentToReupload?.type == docType;

    return Column(
      children: [
        SizedBox(height: 10.h),
        Center(
          child: InkWell(
            borderRadius: BorderRadius.circular(20.r),
            onTap: isThisDoc ? () => _showPickerSheet(docType) : null,
            child: Container(
              height: 80.h,
              decoration: BoxDecoration(
                color: isRejected
                    ? Colors.red.shade50
                    : const Color(0xFFF0F5F5),
                borderRadius: BorderRadius.circular(20.r),
                border: isRejected
                    ? Border.all(color: Colors.red, width: 2)
                    : null,
              ),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Container(
                      width: 120.w,
                      height: 60.h,
                      color: Colors.grey[200],
                      child: documentImages[docType] != null
                          ? Image.file(
                              documentImages[docType]!,
                              fit: BoxFit.cover,
                            )
                          : uploadStatus[docType] == true
                          ? const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 40,
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image,
                                  size: 30.sp,
                                  color: Colors.grey,
                                ),
                                Text(
                                  "No Image",
                                  style: TextStyle(fontSize: 10.sp),
                                ),
                              ],
                            ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          docType == 'RC'
                              ? 'Registration Certificate'
                              : docType == 'Other'
                              ? 'Vehicle Photo'
                              : docType == 'POC'
                              ? "PUC"
                              : docType,
                          style: GoogleFonts.inter(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (isRejected)
                          Text(
                            "Rejected - Tap to re-upload",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12.sp,
                            ),
                          )
                        else if (uploadStatus[docType] == true)
                          Text(
                            "Uploaded",
                            style: TextStyle(color: Colors.green),
                          ),
                      ],
                    ),
                  ),
                  if (isThisDoc) Icon(Icons.camera_alt, color: Colors.teal),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Padding(
          padding: EdgeInsets.only(left: 20.w),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios, size: 20.sp),
          ),
        ),
        title: Text(
          isReuploadMode
              ? "Re-upload ${widget.documentToReupload?.type}"
              : isEditMode
              ? "Edit Vehicle"
              : "Add Vehicle",
          style: GoogleFonts.inter(
            fontSize: 15.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isReuploadMode) ...[
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.error_outline, size: 60.sp, color: Colors.red),
                      SizedBox(height: 16.h),
                      Text(
                        "Document Rejected",
                        style: GoogleFonts.inter(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.red,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        widget.documentToReupload!.type!,
                        style: GoogleFonts.inter(fontSize: 16.sp),
                      ),
                      if (widget.documentToReupload!.remarks != null) ...[
                        SizedBox(height: 12.h),
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            "Reason: ${widget.documentToReupload!.remarks}",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      ],
                      SizedBox(height: 30.h),
                      _buildDocumentUpload(widget.documentToReupload!.type!),
                    ],
                  ),
                ),
              ] else ...[
                vehicleList.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : Container(
                        decoration: const BoxDecoration(
                          color: Color(0xffF3F7F5),
                        ),
                        child: DropdownButtonFormField<Datum>(
                          value: selectedVehicle,
                          items: vehicleList
                              .map(
                                (v) => DropdownMenuItem(
                                  value: v,
                                  child: Text(v.name ?? "Unknown"),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => selectedVehicle = v),
                          decoration: InputDecoration(
                            hintText: "Select Vehicle Type",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.r),
                              borderSide: const BorderSide(color: Colors.black),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 15.h,
                              horizontal: 20.w,
                            ),
                          ),
                        ),
                      ),
                SizedBox(height: 20.h),
                Container(
                  decoration: const BoxDecoration(color: Color(0xffF3F7F5)),
                  child: buildTextField(
                    "Number Plate",
                    numberPlateController,

                    isNumberOnly: false, // ← Number keyboard + digits only
                    maxLength: 20,
                  ),
                ),
                SizedBox(height: 20.h),
                Container(
                  decoration: const BoxDecoration(color: Color(0xffF3F7F5)),
                  child: buildTextField(
                    "Vehicle Model",
                    modelController,
                    isNumberOnly: false, // ← Number keyboard + digits only
                    maxLength: 20,
                  ),
                ),
                SizedBox(height: 20.h),
                Container(
                  decoration: const BoxDecoration(color: Color(0xffF3F7F5)),
                  child:
                      // buildTextField(
                      //   "Max Load Capacity(Kg)",
                      //   capacityWeightController,
                      // ),
                      buildTextField(
                        "Max Load Capacity(Kg)",
                        capacityWeightController,
                        isNumberOnly: true, // ← Number keyboard + digits only
                        maxLength: 20, // optional: max 99999 kg तक
                      ),
                ),
                SizedBox(height: 20.h),
                Container(
                  decoration: const BoxDecoration(color: Color(0xffF3F7F5)),
                  child: buildTextField(
                    "Max Load Capacity(Kg)",
                    capacityVolumeController,
                    isNumberOnly: true, // ← Number keyboard + digits only
                    maxLength: 20, // optional: max 99999 kg तक
                  ),
                  // buildTextField(
                  //   "Capacity Volume",
                  //   capacityVolumeController,
                  // ),
                ),
                SizedBox(height: 30.h),
                ...[
                  'POC',
                  'License',
                  'RC',
                  'Insurance',
                  'Permit',
                  'Other',
                ].map(_buildDocumentUpload).toList(),
              ],

              SizedBox(height: 40.h),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48.h),
                  backgroundColor: const Color(0xff006970),
                ),
                onPressed: isLoading ? null : _submit,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        isReuploadMode ? "Re-upload Document" : "Submit",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
              ),

              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }
}
