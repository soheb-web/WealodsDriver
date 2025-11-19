/*
import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../config/network/api.state.dart';
import '../config/utils/pretty.dio.dart';
import '../data/model/AddBodyVihileModel.dart';
import '../data/model/VihicleResponseModel.dart'; // corrected import to match API
import 'package:permission_handler/permission_handler.dart';

class AddVihiclePage extends StatefulWidget {
  const AddVihiclePage({super.key});
  @override
  State<AddVihiclePage> createState() => _AddVihiclePageState();
}

class _AddVihiclePageState extends State<AddVihiclePage> {
  List<Datum>? vehicleList = <Datum>[];
  Datum? selectedVehicle;
  final numberPlateController = TextEditingController();
  final modelController = TextEditingController();
  final capacityWeightController = TextEditingController();
  final capacityVolumeController = TextEditingController();
  bool isLoading = false;
  // ---------- Images ----------
  File? _pickedImage;                     // newly selected by user
  String? _networkImageUrl;               // URL that came from API
  final _picker = ImagePicker();




  @override
  void initState() {
    super.initState();
    getVehicleType();
  }



  Future<void> getVehicleType() async {
    try {
      final dio = await callDio();
      final service = APIStateNetwork(dio);
      final response = await service.getVehicleType(); // Returns VihicleResponseModel

      setState(() {
        vehicleList = response.data ?? <Datum>[];
      });
    } catch (e) {
      print("Error fetching vehicle types: $e");
    }
  }



  // Future<void> submitVehicle() async {
  //
  //   if (selectedVehicle == null) {
  //     ScaffoldMessenger.of(context)
  //         .showSnackBar(const SnackBar(content: Text('Please select a vehicle type')));
  //     return;
  //   }
  //
  //   if (numberPlateController.text.isEmpty ||
  //       modelController.text.isEmpty ||
  //       capacityWeightController.text.isEmpty ||
  //       capacityVolumeController.text.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Please fill all fields'))
  //     );
  //     return;
  //   }
  //
  //   setState(() {
  //     isLoading = true;
  //   });
  //
  //   try {
  //     final dio = await callDio();
  //     final service = APIStateNetwork(dio);
  //
  //     final body =
  //
  //     AddVihicleBodyModel(
  //       vehicle: selectedVehicle!.id.toString(),
  //       numberPlate: numberPlateController.text,
  //       model: modelController.text,
  //       capacityWeight: 1,
  //       capacityVolume: 2,
  //     );
  //
  //     final response = await service.addNewVehicle(body);
  //
  //     ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text(response.message?? "Vehicle added successfully")));
  //
  //     // Clear inputs or navigate back
  //     Navigator.pop(context);
  //
  //   } catch (e) {
  //     ScaffoldMessenger.of(context)
  //         .showSnackBar(SnackBar(content: Text("Error: $e")));
  //   }
  //
  //   finally {
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }
  //
  // }
*/
/*
  Future<void> submitVehicle() async {
    if (selectedVehicle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a vehicle type')));
      return;
    }
    if (numberPlateController.text.isEmpty ||
        modelController.text.isEmpty ||
        capacityWeightController.text.isEmpty ||
        capacityVolumeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final dio = await callDio();
      final service = APIStateNetwork(dio);
      final String licence = await _upload(_pickedImage!) ?? '';
      if (licence.isEmpty) throw Exception("Upload failed");

      // Example document - baad mein real file upload se replace karna
      final documents = [
        VehicleDocument(
          type: "License",
          fileUrl:licence
        ),
        // Aur documents add kar sakte ho yahan
      ];

      final body = AddVihicleBodyModel(
        vehicle: selectedVehicle!.id.toString(), // ya selectedVehicle!.id (String)
        numberPlate: numberPlateController.text.trim(),
        model: modelController.text.trim(),
        capacityWeight: int.parse(capacityWeightController.text.trim()),
        capacityVolume: int.parse(capacityVolumeController.text.trim()),
        documents: documents,
      );

      final response = await service.addNewVehicle(body);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message ?? "Vehicle added successfully")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }*/ /*


  Future<void> submitVehicle() async {
    if (selectedVehicle == null) {
      _showSnackBar('Please select a vehicle type');
      return;
    }

    // Trim all inputs
    final numberPlate = numberPlateController.text.trim();
    final model = modelController.text.trim();
    final weightText = capacityWeightController.text.trim();
    final volumeText = capacityVolumeController.text.trim();

    if (numberPlate.isEmpty || model.isEmpty || weightText.isEmpty || volumeText.isEmpty) {
      _showSnackBar('Please fill all fields');
      return;
    }

    // Safe parsing for weight & volume
    final int? capacityWeight = _parseInt(weightText);
    final double? capacityVolume = _parseDouble(volumeText);

    if (capacityWeight == null) {
      _showSnackBar('Capacity Weight must be a valid whole number (e.g. 500)');
      return;
    }

    if (capacityVolume == null) {
      _showSnackBar('Capacity Volume must be a valid number (e.g. 10.5)');
      return;
    }

    if (_pickedImage == null) {
      _showSnackBar('Please upload vehicle license image');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final dio = await callDio();
      final service = APIStateNetwork(dio);
      final String licence = await _upload(_pickedImage!) ?? '';
      if (licence.isEmpty) throw Exception("Image upload failed");

      final documents = [
        VehicleDocument(type: "POC", fileUrl: licence),
        VehicleDocument(type: "License", fileUrl: licence),
        VehicleDocument(type: "RC", fileUrl: licence),
        VehicleDocument(type: "Insurance", fileUrl: licence),
        VehicleDocument(type: "Other", fileUrl: licence),
      ];

      final body = AddVihicleBodyModel(
        vehicle: selectedVehicle!.id.toString(),
        numberPlate: numberPlate,
        model: model,
        capacityWeight: capacityWeight,
        capacityVolume: capacityVolume, // Ab double bhi accept ho jayega agar API allow kare
        documents: documents,
      );

      final response = await service.addNewVehicle(body);

      _showSnackBar(response.message ?? "Vehicle added successfully");
      Navigator.pop(context);
    } catch (e) {
      _showSnackBar("Error: ${e.toString()}");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

// Helper methods
  int? _parseInt(String input) {
    final cleaned = input.replaceAll(RegExp(r'[^0-9]'), ''); // Sirf digits rakho
    if (cleaned.isEmpty) return null;
    return int.tryParse(cleaned);
  }

  double? _parseDouble(String input) {
    final cleaned = input.replaceAll(RegExp(r'[^0-9.]'), ''); // Digits + dot
    if (cleaned.isEmpty) return null;
    return double.tryParse(cleaned);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: message.contains('Error') ? Colors.red : Colors.green,
        duration: Duration(seconds: 4),
      ),
    );
  }
  Future<String?> _upload(File file) async {
    try {
      if (!await file.exists()) throw Exception('File not found');

      final request = http.MultipartRequest(
        'POST',
        // Uri.parse('https://weloads.com/api/v1/uploadImage'),
        Uri.parse('http://192.168.1.43:4567/api/v1/uploadImage'),
      );
      request.files.add(
        await http.MultipartFile.fromPath('file', file.path, ),
      );
      final resp = await request.send();
      final body = await http.Response.fromStream(resp);
      final json = jsonDecode(body.body) as Map<String, dynamic>;
      if (resp.statusCode == 200 && json['error'] == false && json['data']?['imageUrl'] != null) {
        return json['data']['imageUrl'] as String;
      }
      throw Exception('Upload failed');
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Upload error: $e",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return null;
    }
  }

  Future<void> _pickFromGallery() async {
    final XFile? picked = await _picker.pickImage(source:  ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;

    setState(() {

        _pickedImage = File(picked.path);

    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        leading: Padding(
          padding: EdgeInsets.only(left: 20.w),
          child: IconButton(
            style: IconButton.styleFrom(shape: const CircleBorder()),
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios, size: 20.sp),
          ),
        ),
        title: Padding(
          padding: EdgeInsets.only(left: 15.w),
          child: Text(
            "Add Vehicle",
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF091425),
            ),
          ),
        ),
      ),
      body:

      Padding(
        padding: EdgeInsets.all(16.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                "Select Vehicle Type",
                style: GoogleFonts.inter(fontSize: 14.sp, color: Colors.black),
              ),

              SizedBox(height: 10.h),


              vehicleList!.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  :

              Container(
                decoration: BoxDecoration(color: Color(0xffF3F7F5)),
                child: DropdownButtonFormField<Datum>(
                  value: selectedVehicle,
                  items:
                  vehicleList!.map((vehicle) {
                    return
                      DropdownMenuItem<Datum>(
                      value: vehicle,
                      child: Text(vehicle.name ?? "Unknown",
                        style: GoogleFonts.inter(fontSize: 14.sp, color: Colors.black),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedVehicle = value;
                    });
                  },
                  decoration: InputDecoration(
                    hint:
                    Text(
                      "Select Vehicle Type",
                      style: GoogleFonts.inter(fontSize: 14.sp, color: Colors.black),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                    contentPadding:
                    EdgeInsets.symmetric(vertical: 15.h, horizontal: 20.w),
                  ),
                ),
              ),


              SizedBox(height: 20.h),
          Container(
            decoration: BoxDecoration(color: Color(0xffF3F7F5)),
            child:
              buildTextField("Number Plate", numberPlateController),),
              SizedBox(height: 20.h),
          Container(
            decoration: BoxDecoration(color: Color(0xffF3F7F5)),
            child:
              buildTextField("Model", modelController),),
              SizedBox(height: 20.h),
          Container(
            decoration: BoxDecoration(color: Color(0xffF3F7F5)),
            child:
              buildTextField("Capacity Weight", capacityWeightController),),
              SizedBox(height: 20.h),

          Container(
            decoration: BoxDecoration(color: Color(0xffF3F7F5)),
            child:  buildTextField("Capacity Volume", capacityVolumeController),),

              
              SizedBox(height: 30.h),




              Center(
                child: InkWell(
                  borderRadius: BorderRadius.circular(20.r),
                  onTap: _showPickerSheet,
                  child: Container(
                    width: 300.w,
                    height: 80.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F5F5),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    child: Row(
                      children: [
                        // ---------- LEFT: Image / Placeholder ----------
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: Container(
                            width: 120.w,
                            height: 60.h,
                            color: Colors.grey[200],
                            child: _pickedImage != null
                                ? Image.file(
                              _pickedImage!,
                              fit: BoxFit.cover,
                            )
                                : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image, size: 30.sp, color: Colors.grey),
                                SizedBox(height: 4.h),
                                Text(
                                  "No Image",
                                  style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(width: 12.w),

                        // ---------- RIGHT: Text + Button ----------
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Vihicle Photo",
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF4D4D4D),
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                "Pick Image",
                                style: GoogleFonts.inter(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF008080),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Optional small arrow to indicate tap
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 18.sp,
                          color: Colors.grey[600],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 10.h,),

              Center(
                child: InkWell(
                  borderRadius: BorderRadius.circular(20.r),
                  onTap: _showPickerSheet,
                  child: Container(
                    width: 300.w,
                    height: 80.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F5F5),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    child: Row(
                      children: [
                        // ---------- LEFT: Image / Placeholder ----------
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: Container(
                            width: 120.w,
                            height: 60.h,
                            color: Colors.grey[200],
                            child: _pickedImage != null
                                ? Image.file(
                              _pickedImage!,
                              fit: BoxFit.cover,
                            )
                                : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image, size: 30.sp, color: Colors.grey),
                                SizedBox(height: 4.h),
                                Text(
                                  "No Image",
                                  style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(width: 12.w),

                        // ---------- RIGHT: Text + Button ----------
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Select Poc",
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF4D4D4D),
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                "Pick Image",
                                style: GoogleFonts.inter(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF008080),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Optional small arrow to indicate tap
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 18.sp,
                          color: Colors.grey[600],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

          SizedBox(height: 10.h,),
              Center(
                child: InkWell(
                  borderRadius: BorderRadius.circular(20.r),
                  onTap: _showPickerSheet,
                  child: Container(
                    width: 300.w,
                    height: 80.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F5F5),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    child: Row(
                      children: [
                        // ---------- LEFT: Image / Placeholder ----------
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: Container(
                            width: 120.w,
                            height: 60.h,
                            color: Colors.grey[200],
                            child: _pickedImage != null
                                ? Image.file(
                              _pickedImage!,
                              fit: BoxFit.cover,
                            )
                                : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image, size: 30.sp, color: Colors.grey),
                                SizedBox(height: 4.h),
                                Text(
                                  "No Image",
                                  style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(width: 12.w),

                        // ---------- RIGHT: Text + Button ----------
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "RC (Registration Certificate)",
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF4D4D4D),
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                "Pick Image",
                                style: GoogleFonts.inter(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF008080),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Optional small arrow to indicate tap
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 18.sp,
                          color: Colors.grey[600],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.h,),
              Center(
                child: InkWell(
                  borderRadius: BorderRadius.circular(20.r),
                  onTap: _showPickerSheet,
                  child: Container(
                    width: 300.w,
                    height: 80.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F5F5),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    child: Row(
                      children: [
                        // ---------- LEFT: Image / Placeholder ----------
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: Container(
                            width: 120.w,
                            height: 60.h,
                            color: Colors.grey[200],
                            child: _pickedImage != null
                                ? Image.file(
                              _pickedImage!,
                              fit: BoxFit.cover,
                            )
                                : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image, size: 30.sp, color: Colors.grey),
                                SizedBox(height: 4.h),
                                Text(
                                  "No Image",
                                  style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(width: 12.w),

                        // ---------- RIGHT: Text + Button ----------
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Licence",
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF4D4D4D),
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                "Pick Image",
                                style: GoogleFonts.inter(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF008080),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Optional small arrow to indicate tap
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 18.sp,
                          color: Colors.grey[600],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
SizedBox(height: 10.h,),

              Center(
                child: InkWell(
                  borderRadius: BorderRadius.circular(20.r),
                  onTap: _showPickerSheet,
                  child: Container(
                    width: 300.w,
                    height: 80.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F5F5),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    child: Row(
                      children: [
                        // ---------- LEFT: Image / Placeholder ----------
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: Container(
                            width: 120.w,
                            height: 60.h,
                            color: Colors.grey[200],
                            child: _pickedImage != null
                                ? Image.file(
                              _pickedImage!,
                              fit: BoxFit.cover,
                            )
                                : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image, size: 30.sp, color: Colors.grey),
                                SizedBox(height: 4.h),
                                Text(
                                  "No Image",
                                  style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(width: 12.w),

                        // ---------- RIGHT: Text + Button ----------
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Insurance",
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF4D4D4D),
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                "Pick Image",
                                style: GoogleFonts.inter(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF008080),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Optional small arrow to indicate tap
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 18.sp,
                          color: Colors.grey[600],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.h,),

              // 'POC', 'License', 'RC', 'Insurance', 'Permit', 'Other'


              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(420.w, 48.h),
                  backgroundColor: Color(0xff006970),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                ),
                onPressed: isLoading ? null : submitVehicle,
                child: isLoading
                    ? const CircularProgressIndicator(
                  color: Colors.black,
                )
                    : Text(
                  "Submit",
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),




            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String hint, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: Colors.black,
        ),
        filled: true,
        fillColor: const Color.fromARGB(12, 255, 255, 255),
        contentPadding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 20.w),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: Colors.black),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: Colors.black),
        ),
      ),
    );
  }





}*/

/*

import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

class AddVihiclePage extends StatefulWidget {
  const AddVihiclePage({super.key});

  @override
  State<AddVihiclePage> createState() => _AddVihiclePageState();
}

class _AddVihiclePageState extends State<AddVihiclePage> {
  List<Datum>? vehicleList = <Datum>[];
  Datum? selectedVehicle;
  final numberPlateController = TextEditingController();
  final modelController = TextEditingController();
  final capacityWeightController = TextEditingController();
  final capacityVolumeController = TextEditingController();
  bool isLoading = false;
  final _picker = ImagePicker();

  // Map to store images for each document type
  Map<String, File?> documentImages = {
    'POC': null,
    'License': null,
    'RC': null,
    'Insurance': null,
    'Permit': null,
    'Other': null,
  };
  // Map to track upload status
  Map<String, bool> uploadStatus = {
    'POC': false,
    'License': false,
    'RC': false,
    'Insurance': false,
    'Permit': false,
    'Other': false,
  };
  @override
  void initState() {
    super.initState();
    getVehicleType();
  }

  Future<void> getVehicleType() async {
    try {
      final dio = await callDio();
      final service = APIStateNetwork(dio);
      final response = await service.getVehicleType();

      setState(() {
        vehicleList = response.data ?? <Datum>[];
      });
    } catch (e) {
      print("Error fetching vehicle types: $e");
      _showSnackBar("Failed to load vehicle types");
    }
  }

  Future<void> submitVehicle() async {
    if (selectedVehicle == null) {
      _showSnackBar('Please select a vehicle type');
      return;
    }

    // Trim all inputs
    final numberPlate = numberPlateController.text.trim();
    final model = modelController.text.trim();
    final weightText = capacityWeightController.text.trim();
    final volumeText = capacityVolumeController.text.trim();

    if (numberPlate.isEmpty ||
        model.isEmpty ||
        weightText.isEmpty ||
        volumeText.isEmpty) {
      _showSnackBar('Please fill all fields');
      return;
    }

    // Validate weight and volume
    final int? capacityWeight = _parseInt(weightText);
    final double? capacityVolume = _parseDouble(volumeText);

    if (capacityWeight == null) {
      _showSnackBar('Capacity Weight must be a valid whole number (e.g. 500)');
      return;
    }

    if (capacityVolume == null) {
      _showSnackBar('Capacity Volume must be a valid number (e.g. 10.5)');
      return;
    }

    // Validate required documents
    List<String> requiredDocs = ['POC', 'License', 'RC', 'Insurance','Other'];
    for (String docType in requiredDocs) {
      if (documentImages[docType] == null) {
        docType=='Other'?
        _showSnackBar('Please upload Vihicle  image'):
        _showSnackBar('Please upload $docType image');
        return;
      }
    }

    setState(() {
      isLoading = true;
    });

    try {
      final dio = await callDio();
      final service = APIStateNetwork(dio);

      // Upload all images and collect URLs
      List<VehicleDocument> documents = [];
      for (String docType in documentImages.keys) {
        if (documentImages[docType] != null) {
          final String? imageUrl = await _upload(documentImages[docType]!);
          if (imageUrl == null) {
            throw Exception("Failed to upload $docType image");
          }
          documents.add(VehicleDocument(type: docType, fileUrl: imageUrl));
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

      _showSnackBar(response.message ?? "Vehicle added successfully");
      Navigator.pop(context);
    } catch (e) {
      _showSnackBar("Error: ${e.toString()}");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Helper methods
  int? _parseInt(String input) {
    final cleaned = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.isEmpty) return null;
    return int.tryParse(cleaned);
  }

  double? _parseDouble(String input) {
    final cleaned = input.replaceAll(RegExp(r'[^0-9.]'), '');
    if (cleaned.isEmpty) return null;
    return double.tryParse(cleaned);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: message.contains('Error') ? Colors.red : Colors.green,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<String?> _upload(File file) async {
    try {
      if (!await file.exists()) throw Exception('File not found');

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://weloads.com/api/v1/uploadImage'),
      );
      // final request = http.MultipartRequest(
      //   'POST',
      //   Uri.parse('http://192.168.1.43:4567/api/v1/uploadImage'),
      // );
      request.files.add(
        await http.MultipartFile.fromPath('file', file.path),
      );
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
        textColor: Colors.white,
      );
      return null;
    }
  }

  Future<void> _pickFromGallery(String docType) async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() {
        documentImages[docType] = File(picked.path);
      });
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
      setState(() {
        documentImages[docType] = File(file.path);
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        leading: Padding(
          padding: EdgeInsets.only(left: 20.w),
          child: IconButton(
            style: IconButton.styleFrom(shape: const CircleBorder()),
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios, size: 20.sp),
          ),
        ),
        title: Padding(
          padding: EdgeInsets.only(left: 15.w),
          child: Text(
            "Add Vehicle",
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF091425),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Select Vehicle Type",
                style: GoogleFonts.inter(fontSize: 14.sp, color: Colors.black),
              ),
              SizedBox(height: 10.h),
              vehicleList!.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : Container(
                decoration: const BoxDecoration(color: Color(0xffF3F7F5)),
                child: DropdownButtonFormField<Datum>(
                  value: selectedVehicle,
                  items: vehicleList!.map((vehicle) {
                    return DropdownMenuItem<Datum>(
                      value: vehicle,
                      child: Text(
                        vehicle.name ?? "Unknown",
                        style: GoogleFonts.inter(
                            fontSize: 14.sp, color: Colors.black),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedVehicle = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Select Vehicle Type",
                    hintStyle: GoogleFonts.inter(
                        fontSize: 14.sp, color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                        vertical: 15.h, horizontal: 20.w),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Container(
                decoration: const BoxDecoration(color: Color(0xffF3F7F5)),
                child: buildTextField("Number Plate", numberPlateController),
              ),
              SizedBox(height: 20.h),
              Container(
                decoration: const BoxDecoration(color: Color(0xffF3F7F5)),
                child: buildTextField("Model", modelController),
              ),
              SizedBox(height: 20.h),
              Container(
                decoration: const BoxDecoration(color: Color(0xffF3F7F5)),
                child: buildTextField("Capacity Weight", capacityWeightController),
              ),
              SizedBox(height: 20.h),
              Container(
                decoration: const BoxDecoration(color: Color(0xffF3F7F5)),
                child:
                buildTextField("Capacity Volume", capacityVolumeController),
              ),
              SizedBox(height: 30.h),
              // Document upload sections
              ...['POC', 'License', 'RC', 'Insurance', 'Permit', 'Other']
                  .map((docType) => Column(
                children: [
                  SizedBox(height: 10.h),
                  Center(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20.r),
                      onTap: () => _showPickerSheet(docType),
                      child: Container(
                        // width: 300.w,
                        height: 80.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F5F5),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 8.h),
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
                                    : Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.image,
                                        size: 30.sp,
                                        color: Colors.grey),
                                    SizedBox(height: 4.h),
                                    Text(
                                      "No Image",
                                      style: TextStyle(
                                          fontSize: 10.sp,
                                          color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  Text(
                                    docType == 'RC'
                                        ? 'Registration Certificate'
                                        : docType == 'Other'
                                        ? 'Vehicle Photo'
                                        : docType,
                                    style: GoogleFonts.inter(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF4D4D4D),
                                    ),
                                  ),
                                  SizedBox(height: 6.h),
                                  Text(
                                    "Pick Image",
                                    style: GoogleFonts.inter(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF008080),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 18.sp,
                              color: Colors.grey[600],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ))
                  .toList(),
              SizedBox(height: 20.h),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(420.w, 48.h),
                  backgroundColor: const Color(0xff006970),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                ),
                onPressed: isLoading ? null : submitVehicle,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                  "Submit",
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String hint, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: Colors.black,
        ),
        filled: true,
        fillColor: const Color.fromARGB(12, 255, 255, 255),
        contentPadding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 20.w),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: Colors.black),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: Colors.black),
        ),
      ),
    );
  }
}*/

/*




import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

  const AddVihiclePage({super.key, this.vehicleDetail, this.documentToReupload});

  @override
  State<AddVihiclePage> createState() => _AddVihiclePageState();
}

class _AddVihiclePageState extends State<AddVihiclePage> {
  List<Datum>? vehicleList = [];
  Datum? selectedVehicle;
  final numberPlateController = TextEditingController();
  final modelController = TextEditingController();
  final capacityWeightController = TextEditingController();
  final capacityVolumeController = TextEditingController();
  bool isLoading = false;
  final _picker = ImagePicker();

  Future<String?> _upload(File file) async {
    try {
      if (!await file.exists()) throw Exception('File not found');

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://weloads.com/api/v1/uploadImage'),
      );
      // final request = http.MultipartRequest(
      //   'POST',
      //   Uri.parse('http://192.168.1.43:4567/api/v1/uploadImage'),
      // );
      request.files.add(
        await http.MultipartFile.fromPath('file', file.path),
      );
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
        textColor: Colors.white,
      );
      return null;
    }
  }
  Map<String, File?> documentImages = {
    'POC': null, 'License': null, 'RC': null, 'Insurance': null, 'Permit': null, 'Other': null,
  };
  Map<String, bool> uploadStatus = {
    'POC': false, 'License': false, 'RC': false, 'Insurance': false, 'Permit': false, 'Other': false,
  };

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
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() {
        documentImages[docType] = File(picked.path);
      });
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
      setState(() {
        documentImages[docType] = File(file.path);
      });
    }
  }
  Widget buildTextField(String hint, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: Colors.black,
        ),
        filled: true,
        fillColor: const Color.fromARGB(12, 255, 255, 255),
        contentPadding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 20.w),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: Colors.black),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: Colors.black),
        ),
      ),
    );
  }
  late bool isEditMode;
  late bool isReuploadMode;
  // Helper methods
  int? _parseInt(String input) {
    final cleaned = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.isEmpty) return null;
    return int.tryParse(cleaned);
  }

  double? _parseDouble(String input) {
    final cleaned = input.replaceAll(RegExp(r'[^0-9.]'), '');
    if (cleaned.isEmpty) return null;
    return double.tryParse(cleaned);
  }


  Future<void> submitVehicle() async {
    if (selectedVehicle == null) {
      _showSnackBar('Please select a vehicle type');
      return;
    }

    // Trim all inputs
    final numberPlate = numberPlateController.text.trim();
    final model = modelController.text.trim();
    final weightText = capacityWeightController.text.trim();
    final volumeText = capacityVolumeController.text.trim();

    if (numberPlate.isEmpty ||
        model.isEmpty ||
        weightText.isEmpty ||
        volumeText.isEmpty) {
      _showSnackBar('Please fill all fields');
      return;
    }

    // Validate weight and volume
    final int? capacityWeight = _parseInt(weightText);
    final double? capacityVolume = _parseDouble(volumeText);

    if (capacityWeight == null) {
      _showSnackBar('Capacity Weight must be a valid whole number (e.g. 500)');
      return;
    }

    if (capacityVolume == null) {
      _showSnackBar('Capacity Volume must be a valid number (e.g. 10.5)');
      return;
    }

    // Validate required documents
    List<String> requiredDocs = ['POC', 'License', 'RC', 'Insurance','Other'];
    for (String docType in requiredDocs) {
      if (documentImages[docType] == null) {
        docType=='Other'?
        _showSnackBar('Please upload Vihicle  image'):
        _showSnackBar('Please upload $docType image');
        return;
      }
    }

    setState(() {
      isLoading = true;
    });

    try {
      final dio = await callDio();
      final service = APIStateNetwork(dio);

      // Upload all images and collect URLs
      List<VehicleDocument> documents = [];
      for (String docType in documentImages.keys) {
        if (documentImages[docType] != null) {
          final String? imageUrl = await _upload(documentImages[docType]!);
          if (imageUrl == null) {
            throw Exception("Failed to upload $docType image");
          }
          documents.add(VehicleDocument(type: docType, fileUrl: imageUrl));
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

      _showSnackBar(response.message ?? "Vehicle added successfully");
      Navigator.pop(context);
    } catch (e) {
      _showSnackBar("Error: ${e.toString()}");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    isEditMode = widget.vehicleDetail != null;
    isReuploadMode = widget.documentToReupload != null;

    if (isEditMode) _prefillData();
    getVehicleType();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: message.contains('Error') ? Colors.red : Colors.green,
        duration: const Duration(seconds: 4),
      ),
    );
  }
  void _prefillData() {
    final v = widget.vehicleDetail!;
    selectedVehicle = vehicleList?.firstWhere((e) => e.id.toString() == v.vehicle?.id, orElse: () => vehicleList!.first);
    numberPlateController.text = v.numberPlate ?? '';
    modelController.text = v.model ?? '';
    capacityWeightController.text = v.capacityWeight?.toString() ?? '';
    capacityVolumeController.text = v.capacityVolume?.toString() ?? '';

    for (var doc in (v.documents ?? [])) {
      if (doc.type != null) uploadStatus[doc.type!] = true;
    }
  }

  Future<void> getVehicleType() async {
    try {
      final dio = await callDio();
      final service = APIStateNetwork(dio);
      final response = await service.getVehicleType();
      setState(() {
        vehicleList = response.data ?? [];
        if (isEditMode && selectedVehicle == null) _prefillData();
      });
    } catch (e) {
      _showSnackBar("Failed to load vehicle types");
    }
  }

  Future<void> _submit() async {
    if (isReuploadMode) {
      await _reuploadSingleDocument();
    } else {
      await submitVehicle();
    }
  }

  // Future<void> _reuploadSingleDocument() async {
  //   final doc = widget.documentToReupload!;
  //   if (documentImages[doc.type] == null) {
  //     _showSnackBar("Please select a new image");
  //     return;
  //   }
  //
  //   setState(() => isLoading = true);
  //   final url = await _upload(documentImages[doc.type]!);
  //   if (url != null) {
  //     try {
  //       final dio = await callDio();
  //       final service = APIStateNetwork(dio);
  //       await service.updateVehicleDocument(
  //         vehicleId: widget.vehicleDetail!.id!,
  //         documentId: doc.id!,
  //         newFileUrl: url,
  //       );
  //       _showSnackBar("Document re-uploaded successfully!");
  //       Navigator.pop(context);
  //     } catch (e) {
  //       _showSnackBar("Failed to update: $e");
  //     }
  //   }
  //   setState(() => isLoading = false);
  // }
  Future<void> _reuploadSingleDocument() async {
    final rejectedDoc = widget.documentToReupload!;
    final docType = rejectedDoc.type!;

    if (documentImages[docType] == null) {
      _showSnackBar("Please select a new image");
      return;
    }

    setState(() => isLoading = true);

    try {
      final dio = await callDio();
      final service = APIStateNetwork(dio);

      // 1. Upload new image
      final newImageUrl = await _upload(documentImages[docType]!);
      if (newImageUrl == null) throw Exception("Upload failed");

      // 2. Get all current documents from vehicle
      final currentDocs = widget.vehicleDetail!.documents ?? [];

      // 3. Replace only the rejected document's URL
      final updatedDocuments = currentDocs.map((doc) {
        if (doc.type == docType) {
          return VehicleDocument(type: docType, fileUrl: newImageUrl);
        }
        return VehicleDocument(type: doc.type!, fileUrl: doc.fileUrl!);
      }).toList();

      // 4. Create body with ALL data (same as add new)
      final body = AddVihicleBodyModel(
        vehicle: widget.vehicleDetail!.vehicle!.id!,
        numberPlate: widget.vehicleDetail!.numberPlate!,
        model: widget.vehicleDetail!.model!,
        capacityWeight: widget.vehicleDetail!.capacityWeight!,
        capacityVolume: widget.vehicleDetail!.capacityVolume!,
        documents: updatedDocuments,
      );

      // 5. Call SAME addNewVehicle API
      final response = await service.addNewVehicle(body);

      _showSnackBar("Document re-uploaded successfully!");
      Navigator.pop(context);
    } catch (e) {
      _showSnackBar("Error: ${e.toString()}");
    } finally {
      setState(() => isLoading = false);
    }
  }
  // ... rest of your existing submitVehicle(), _upload(), _pickFromGallery(), etc. (same as before)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Padding(
          padding: EdgeInsets.only(left: 20.w),
          child: IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.arrow_back_ios, size: 20.sp)),
        ),
        title: Text(
          isReuploadMode
              ? "Re-upload ${widget.documentToReupload?.type}"
              : isEditMode
              ? "Edit Vehicle"
              : "Add Vehicle",
          style: GoogleFonts.inter(fontSize: 15.sp, fontWeight: FontWeight.w400),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isReuploadMode) ...[
                Center(child: Text("Re-upload rejected document", style: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w600))),
                SizedBox(height: 10.h),
                if (widget.documentToReupload?.remarks != null)
                  Text("Reason: ${widget.documentToReupload!.remarks}", style: TextStyle(color: Colors.red, fontSize: 14.sp)),
                SizedBox(height: 30.h),
                // _buildDocumentSection(widget.documentToReupload!.type!),
              ] else ...[
                // Your full form (dropdown, text fields, all documents)
                // ... keep your existing code here

                vehicleList!.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : Container(
                  decoration: const BoxDecoration(color: Color(0xffF3F7F5)),
                  child: DropdownButtonFormField<Datum>(
                    value: selectedVehicle,
                    items: vehicleList!.map((vehicle) {
                      return DropdownMenuItem<Datum>(
                        value: vehicle,
                        child: Text(
                          vehicle.name ?? "Unknown",
                          style: GoogleFonts.inter(
                              fontSize: 14.sp, color: Colors.black),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedVehicle = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Select Vehicle Type",
                      hintStyle: GoogleFonts.inter(
                          fontSize: 14.sp, color: Colors.black),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 15.h, horizontal: 20.w),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Container(
                  decoration: const BoxDecoration(color: Color(0xffF3F7F5)),
                  child: buildTextField("Number Plate", numberPlateController),
                ),
                SizedBox(height: 20.h),
                Container(
                  decoration: const BoxDecoration(color: Color(0xffF3F7F5)),
                  child: buildTextField("Model", modelController),
                ),
                SizedBox(height: 20.h),
                Container(
                  decoration: const BoxDecoration(color: Color(0xffF3F7F5)),
                  child: buildTextField("Capacity Weight", capacityWeightController),
                ),
                SizedBox(height: 20.h),
                Container(
                  decoration: const BoxDecoration(color: Color(0xffF3F7F5)),
                  child:
                  buildTextField("Capacity Volume", capacityVolumeController),
                ),
                SizedBox(height: 30.h),
                // Document upload sections
                ...['POC', 'License', 'RC', 'Insurance', 'Permit', 'Other']
                    .map((docType) => Column(
                  children: [
                    SizedBox(height: 10.h),
                    Center(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20.r),
                        onTap: () => _showPickerSheet(docType),
                        child: Container(
                          // width: 300.w,
                          height: 80.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F5F5),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 8.h),
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
                                      : Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.image,
                                          size: 30.sp,
                                          color: Colors.grey),
                                      SizedBox(height: 4.h),
                                      Text(
                                        "No Image",
                                        style: TextStyle(
                                            fontSize: 10.sp,
                                            color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      docType == 'RC'
                                          ? 'Registration Certificate'
                                          : docType == 'Other'
                                          ? 'Vehicle Photo'
                                          : docType,
                                      style: GoogleFonts.inter(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF4D4D4D),
                                      ),
                                    ),
                                    SizedBox(height: 6.h),
                                    Text(
                                      "Pick Image",
                                      style: GoogleFonts.inter(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF008080),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 18.sp,
                                color: Colors.grey[600],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ))
                    .toList(),

              ],

              SizedBox(height: 30.h),
              ElevatedButton(
                style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 48.h), backgroundColor: const Color(0xff006970)),
                onPressed: isLoading ? null : _submit,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(isReuploadMode ? "Re-upload Document" : "Submit", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
  //
  // Widget _buildDocumentSection(String docType) {
  //   // Your existing document upload UI
  //   // ... same as before
  // }
}
*/

import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
        Uri.parse('https://weloads.com/api/v1/uploadImage'),
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

  Widget buildTextField(String hint, TextEditingController controller) {
    return TextFormField(
      controller: controller,
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
          borderSide: const BorderSide(color: Colors.black),
        ),
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
    // ... your existing validation & submit logic (unchanged)
    // Keep exactly as you had
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
                // Full Form
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
                  child: buildTextField("Number Plate", numberPlateController),
                ),
                SizedBox(height: 20.h),
                Container(
                  decoration: const BoxDecoration(color: Color(0xffF3F7F5)),
                  child: buildTextField("Vehicle Model", modelController),
                ),
                SizedBox(height: 20.h),
                Container(
                  decoration: const BoxDecoration(color: Color(0xffF3F7F5)),
                  child: buildTextField(
                    "Max Load Capacity(Kg)",
                    capacityWeightController,
                  ),
                ),
                SizedBox(height: 20.h),
                Container(
                  decoration: const BoxDecoration(color: Color(0xffF3F7F5)),
                  child: buildTextField(
                    "Capacity Volume",
                    capacityVolumeController,
                  ),
                ),
                SizedBox(height: 30.h),
                ...[
                  'PUC',
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
