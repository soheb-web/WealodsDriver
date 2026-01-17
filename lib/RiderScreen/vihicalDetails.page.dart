//
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';
// import '../data/model/driverProfileModel.dart';
//
// class VihicalDetailsPage extends StatefulWidget {
//   final VehicleDetail vehicle;
//   const VihicalDetailsPage({super.key, required this.vehicle});
//
//   @override
//   State<VihicalDetailsPage> createState() => _VihicalDetailsPageState();
// }
//
// class _VihicalDetailsPageState extends State<VihicalDetailsPage> {
//   // Status helper - String based
//   ({Color color, IconData icon, String text}) getStatusInfo(String? status) {
//     final s = status?.toLowerCase();
//     switch (s) {
//     case 'approved':
//     return (color: const Color(0xFF25BC15), icon: Icons.check_circle, text: "Approved");
//     case 'rejected':
//     return (color: Colors.red, icon: Icons.cancel, text: "Rejected");
//     case 'pending':
//     default:
//     return (color: Colors.orange, icon: Icons.access_time, text: "Pending");
//     }
//   }
//
//   String formatDate(String? dateStr) {
//     if (dateStr == null || dateStr.isEmpty) return "Not verified";
//     try {
//       final date = DateTime.parse(dateStr);
//       return DateFormat('dd MMM yyyy, hh:mm a').format(date);
//     } catch (e) {
//       return "Invalid date";
//     }
//   }
//
//   void _showImagePreview(String? url) {
//     if (url == null || url.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("No image available")),
//       );
//       return;
//     }
//     showDialog(
//       context: context,
//       builder: (_) => Dialog(
//         backgroundColor: Colors.black,
//         child: Stack(
//           children: [
//             InteractiveViewer(
//               child: Center(
//                 child: Image.network(url, fit: BoxFit.contain),
//               ),
//             ),
//             Positioned(
//               top: 40,
//               right: 20,
//               child: IconButton(
//                 icon: const Icon(Icons.close, color: Colors.white, size: 30),
//                 onPressed: () => Navigator.pop(context),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final vehicle = widget.vehicle;
//     final vehicleName = vehicle.vehicle?.name ?? 'Unknown Vehicle';
//     final model = vehicle.model ?? 'N/A';
//     final numberPlate = vehicle.numberPlate ?? 'N/A';
//     final documents = vehicle.documents ?? [];
//     final vehicleStatus = getStatusInfo(vehicle.status);
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: Padding(
//           padding: EdgeInsets.only(left: 20.w),
//           child: IconButton(
//             onPressed: () => Navigator.pop(context),
//             icon: const Icon(Icons.arrow_back_ios, size: 20),
//           ),
//         ),
//         title: Text(
//           numberPlate,
//           style: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w500),
//         ),
//         actions: [
//           Padding(
//             padding: EdgeInsets.only(right: 10.w),
//             child: IconButton(
//               onPressed: () {
//                 // Edit vehicle
//               },
//               icon: const Icon(Icons.edit),
//               style: IconButton.styleFrom(backgroundColor: Color(0xFFF0F5F5)),
//             ),
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(24.w),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(height: 10.h),
//             const Divider(color: Color(0xFFCBCBCB)),
//             SizedBox(height: 28.h),
//
//             // Vehicle Info
//             _infoRow("Type", vehicleName),
//             SizedBox(height: 20.h),
//             _infoRow("Model", model),
//             SizedBox(height: 20.h),
//             _infoRow("Registration", numberPlate),
//             SizedBox(height: 20.h),
//
//             // Vehicle Status
//             Row(
//               children: [
//                 Text("Status: ", style: TextStyle(fontSize: 14.sp, color: Color(0xFF77869E))),
//                 Icon(vehicleStatus.icon, size: 18, color: vehicleStatus.color),
//                 SizedBox(width: 6.w),
//                 Text(
//                   vehicleStatus.text,
//                   style: TextStyle(
//                     fontSize: 14.sp,
//                     color: vehicleStatus.color,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 38.h),
//
//             // Documents Title
//             Text(
//               "Documents",
//               style: GoogleFonts.inter(
//                 fontSize: 16.sp,
//                 fontWeight: FontWeight.w600,
//                 color: const Color(0xFF111111),
//               ),
//             ),
//             SizedBox(height: 12.h),
//
//             // Documents List
//             if (documents.isEmpty)
//               Text(
//                 "No documents uploaded yet.",
//                 style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
//               )
//             else
//               ...documents.map((doc) => _documentCard(doc)).toList(),
//
//             SizedBox(height: 40.h),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _infoRow(String label, String value) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: GoogleFonts.inter(fontSize: 14.sp, color: const Color(0xFF77869E)),
//         ),
//         SizedBox(height: 4.h),
//         Text(
//           value,
//           style: GoogleFonts.inter(
//             fontSize: 15.sp,
//             fontWeight: FontWeight.w500,
//             color: const Color(0xFF111111),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _documentCard(Document doc) {
//     final statusInfo = getStatusInfo(doc.verificationStatus);
//     final docName = doc.type ?? "Document";
//
//     return Padding(
//       padding: EdgeInsets.only(bottom: 12.h),
//       child: InkWell(
//         onTap: () => _showImagePreview(doc.fileUrl),
//         borderRadius: BorderRadius.circular(10.r),
//         child: Container(
//           padding: EdgeInsets.all(16.w),
//           decoration: BoxDecoration(
//             color: const Color(0xFFF0F5F5),
//             borderRadius: BorderRadius.circular(10.r),
//             border: Border.all(color: Colors.grey.shade200, width: 0.5),
//           ),
//           child: Row(
//             children: [
//               SvgPicture.asset(
//                 "assets/SvgImage/do.svg",
//                 width: 42.w,
//                 height: 42.h,
//               ),
//               SizedBox(width: 16.w),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       docName,
//                       style: GoogleFonts.inter(
//                         fontSize: 15.sp,
//                         fontWeight: FontWeight.w600,
//                         color: const Color(0xFF333333),
//                       ),
//                     ),
//                     SizedBox(height: 6.h),
//                     Row(
//                       children: [
//                         Icon(statusInfo.icon, size: 16, color: statusInfo.color),
//                         SizedBox(width: 6.w),
//                         Text(
//                           statusInfo.text,
//                           style: GoogleFonts.inter(
//                             fontSize: 13.sp,
//                             color: statusInfo.color,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ],
//                     ),
//                     if (doc.verifiedAt != null) ...[
//                       SizedBox(height: 4.h),
//                       Text(
//                         "Verified: ${formatDate(doc.verifiedAt)}",
//                         style: TextStyle(fontSize: 11.sp, color: Colors.grey[700]),
//                       ),
//                     ],
//                     if (doc.remarks != null && doc.remarks!.isNotEmpty) ...[
//                       SizedBox(height: 4.h),
//                       Text(
//                         "Remark: ${doc.remarks}",
//                         style: TextStyle(
//                           fontSize: 11.sp,
//                           color: Colors.red,
//                           fontStyle: FontStyle.italic,
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//               Icon(Icons.chevron_right, color: Colors.grey.shade600),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../data/model/driverProfileModel.dart';
import 'addVihiclePage.dart'; // Import your AddVehiclePage

class VihicalDetailsPage extends StatefulWidget {
  final VehicleDetail vehicle;
  const VihicalDetailsPage({super.key, required this.vehicle});

  @override
  State<VihicalDetailsPage> createState() => _VihicalDetailsPageState();
}

class _VihicalDetailsPageState extends State<VihicalDetailsPage> {
  ({Color color, IconData icon, String text}) getStatusInfo(String? status) {
    final s = status?.toLowerCase();
    switch (s) {
      case 'approved':
        return (
          color: const Color(0xFF25BC15),
          icon: Icons.check_circle,
          text: "Approved",
        );
      case 'rejected':
        return (color: Colors.red, icon: Icons.cancel, text: "Rejected");
      case 'pending':
      default:
        return (color: Colors.orange, icon: Icons.access_time, text: "Pending");
    }
  }

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "Not verified";
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy, hh:mm a').format(date);
    } catch (e) {
      return "Invalid date";
    }
  }

  void _showImagePreview(String? url) {
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No image available")));
      return;
    }
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            InteractiveViewer(
              child: Center(
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.image_not_supported,
                      size: 40,
                      color: Colors.grey,
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vehicle = widget.vehicle;
    final vehicleName = vehicle.vehicle?.name ?? 'Unknown Vehicle';
    final model = vehicle.model ?? 'N/A';
    final numberPlate = vehicle.numberPlate ?? 'N/A';
    final documents = vehicle.documents ?? [];
    final vehicleStatus = getStatusInfo(vehicle.status);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: 20.w),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, size: 20),
          ),
        ),
        title: Text(
          // numberPlate,
          vehicleName,
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10.w),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.edit),
              style: IconButton.styleFrom(backgroundColor: Color(0xFFF0F5F5)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10.h),
            const Divider(color: Color(0xFFCBCBCB)),
            SizedBox(height: 28.h),

            _infoRow("Type", vehicleName),
            SizedBox(height: 20.h), 
            _infoRow("Model", model),
            SizedBox(height: 20.h),
            _infoRow("Registration", 'Number Plate: ${numberPlate}'),
            SizedBox(height: 20.h),

            // Row(
            //   children: [
            //     Text(
            //       "Status: ",
            //       style: TextStyle(
            //         fontSize: 15.sp,
            //         color: Color(0xFF77869E),
            //         fontWeight: FontWeight.bold,
            //       ),
            //     ),
            //     Icon(vehicleStatus.icon, size: 18, color: vehicleStatus.color),
            //     SizedBox(width: 6.w),
            //     Text(
            //       vehicleStatus.text,
            //       style: TextStyle(
            //         fontSize: 16.sp,
            //         color: vehicleStatus.color,
            //         fontWeight: FontWeight.bold,
            //       ),
            //     ),
            //   ],
            // ),
            //SizedBox(height: 38.h),
            Text(
              "Documents",
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF111111),
              ),
            ),
            SizedBox(height: 12.h),

            if (documents.isEmpty)
              Text(
                "No documents uploaded yet.",
                style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
              )
            else
              ...documents.map((doc) => _documentCard(doc)).toList(),

            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color: const Color(0xFF77869E),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 15.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF111111),
          ),
        ),
      ],
    );
  }

  Widget _documentCard(Document doc) {
    final statusInfo = getStatusInfo(doc.verificationStatus);
    final docName = doc.type ?? "Document";
    final isRejected = doc.verificationStatus?.toLowerCase() == 'rejected';

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        onTap: isRejected
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddVihiclePage(
                      vehicleDetail: widget.vehicle,
                      documentToReupload: doc,
                    ),
                  ),
                ).then((_) {
                  // Optional: Refresh data
                  setState(() {});
                });
              }
            : () => _showImagePreview(doc.fileUrl),
        borderRadius: BorderRadius.circular(10.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: isRejected ? Colors.red.shade50 : const Color(0xFFF0F5F5),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: isRejected ? Colors.red.shade400 : Colors.grey.shade200,
              width: isRejected ? 2 : 0.5,
            ),
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                "assets/SvgImage/do.svg",
                width: 42.w,
                height: 42.h,
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      docName == "Other" ? "Vihile Photo" : docName,
                      style: GoogleFonts.inter(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF333333),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Icon(
                          statusInfo.icon,
                          size: 16,
                          color: statusInfo.color,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          statusInfo.text,
                          style: GoogleFonts.inter(
                            fontSize: 13.sp,
                            color: statusInfo.color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    if (doc.verifiedAt != null) ...[
                      SizedBox(height: 4.h),
                      Text(
                        "Verified: ${formatDate(doc.verifiedAt)}",
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                    if (doc.remarks != null && doc.remarks!.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Text(
                        "Remark: ${doc.remarks}",
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.red,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    if (isRejected) ...[
                      SizedBox(height: 10.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          "TAP TO RE-UPLOAD",
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                isRejected ? Icons.refresh : Icons.chevron_right,
                color: isRejected ? Colors.red : Colors.grey.shade600,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
