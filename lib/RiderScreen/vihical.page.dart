
import 'package:delivery_rider_app/RiderScreen/vihicalDetails.page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/network/api.state.dart';
import '../config/utils/pretty.dio.dart';
import '../data/model/VihicleSelectModel.dart';
import '../data/model/driverProfileModel.dart';
import 'addVihiclePage.dart';

final driverProfileProvider = FutureProvider<DriverProfileModel>((ref) async {
  final dio = await callDio();
  final service = APIStateNetwork(dio);
  final response = await service.getDriverProfile();
  return response;
});

class VihicalPage extends ConsumerStatefulWidget {
  const VihicalPage({super.key});

  @override
  ConsumerState<VihicalPage> createState() => _VihicalPageState();
}

class _VihicalPageState extends ConsumerState<VihicalPage> {
 /* String? activeVehicleId; // Currently active vehicle

  @override
  void initState() {
    super.initState();
    _loadActiveVehicle();
  }

  void _loadActiveVehicle() async {
    final profile = await ref.read(driverProfileProvider.future);
    VehicleDetail? activeVehicle;

    try {
      activeVehicle = profile.data?.vehicleDetails?.firstWhere(
            (v) => v.isActive == true,
      );
    } catch (_) {
      activeVehicle = null;
    }

    if (mounted) {
      setState(() {
        activeVehicleId = activeVehicle?.id;
      });
    }
  }
*/

  String? activeVehicleId;

  @override
  void initState() {
    super.initState();
    // Har baar screen open hone par fresh data load karo
    ref.refresh(driverProfileProvider);
    _loadActiveVehicle();
  }

  void _loadActiveVehicle() async {
    final profile = await ref.read(driverProfileProvider.future);
    VehicleDetail? activeVehicle;

    try {
      activeVehicle = profile.data?.vehicleDetails?.firstWhere(
            (v) => v.isActive == true,
      );
    } catch (_) {
      activeVehicle = null;
    }

    if (mounted) {
      setState(() {
        activeVehicleId = activeVehicle?.id;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(driverProfileProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: 16.w),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text("My Vehicles", style: GoogleFonts.inter(fontSize: 20.sp, fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Color(0xFF006970)),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AddVihiclePage()))
                  .then((_) => ref.invalidate(driverProfileProvider));
            },
          ),
          SizedBox(width: 10.w),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text("Failed to load vehicles", style: TextStyle(color: Colors.red))),
        data: (profile) {
          final vehicles = profile.data?.vehicleDetails ?? [];

          if (vehicles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Icon(Icons.directions_car_outlined, size: 80, color: Colors.grey.shade400),
                  SizedBox(height: 16.h),
                  Text("No vehicles added yet", style: GoogleFonts.inter(fontSize: 18.sp, color: Colors.grey)),
                  SizedBox(height: 10.h),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddVihiclePage())),
                    icon: Icon(Icons.add,color: Colors.white,),
                    label: Text("Add Vehicle",style: TextStyle(color: Colors.white),),
                    style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF006970)),
                  ),

                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(20.w),
            itemCount: vehicles.length,
            itemBuilder: (context, index) {
              final vehicle = vehicles[index];
              final vehicleName = vehicle.vehicle?.name ?? "Vehicle";
              final isActive = activeVehicleId == vehicle.id;
              final isApproved = vehicle.status == "approved";

              return Card(
                elevation: 4,
                margin: EdgeInsets.only(bottom: 16.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16.r),
                  onTap: () async {
                    // अगर vehicle approved नहीं है
                    if (!isApproved) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.error, color: Colors.white),
                              SizedBox(width: 12.w),
                              Text("This vehicle is not approved yet!", style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                            ],
                          ),
                          backgroundColor: Colors.orange.shade700,
                          behavior: SnackBarBehavior.floating,
                          margin: EdgeInsets.all(16.w),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                      Navigator.push(
                        context,
                        CupertinoPageRoute(builder: (_) => VihicalDetailsPage(vehicle: vehicle)),
                      );

                      return;
                    }

                    setState(() => activeVehicleId = vehicle.id);

                    try {
                      final dio = await callDio();
                      final service = APIStateNetwork(dio);
                      final response = await service.updateVehicleStatus(
                        VihicleSelectModel(vehicleId: vehicle.id ?? ""),
                      );

                      if (response.error == false) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.white, size: 24),
                                SizedBox(width: 12.w),
                                Text(
                                  response.message ?? "Vehicle activated!",
                                  style: GoogleFonts.inter(fontSize: 15.sp, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            backgroundColor: Colors.green.shade600,
                            behavior: SnackBarBehavior.floating,
                            margin: EdgeInsets.all(16.w),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            duration: Duration(seconds: 3),
                          ),
                        );

                        setState(() {
                          activeVehicleId = vehicle.id;
                        });
                        ref.invalidate(driverProfileProvider);
                      } else {
                        setState(() => activeVehicleId = null);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(response.message ?? "Failed"), backgroundColor: Colors.red),
                        );
                      }
                    } catch (e) {
                      setState(() => activeVehicleId = null);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Network error"), backgroundColor: Colors.red),
                      );
                    }

                    Navigator.push(
                      context,
                      CupertinoPageRoute(builder: (_) => VihicalDetailsPage(vehicle: vehicle)),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.all(18.w),
                    child: Row(
                      children: [
                        // Vehicle Icon
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: SvgPicture.asset(
                            _getVehicleSvg(vehicleName),
                            width: 38.w,
                            height: 38.w,
                          ),
                        ),
                        SizedBox(width: 16.w),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "$vehicleName • ${vehicle.model ?? 'N/A'}",
                                style: GoogleFonts.inter(fontSize: 17.sp, fontWeight: FontWeight.w600),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                "Plate: ${vehicle.numberPlate ?? 'N/A'}",
                                style: GoogleFonts.inter(fontSize: 15.sp, color: Colors.grey.shade700),
                              ),
                              if (!isApproved)
                                Padding(
                                  padding: EdgeInsets.only(top: 8.h),
                                  child: Chip(
                                    label: Text("Pending Approval", style: TextStyle(color: Colors.orange.shade800, fontSize: 12.sp)),
                                    backgroundColor: Colors.orange.shade100,
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Right Side Indicator
                        if (isActive)
                          Icon(Icons.check_circle_rounded, color: Colors.green, size: 32.sp)
                        else if (!isApproved)
                          Icon(Icons.error_rounded, color: Colors.red.shade600, size: 28.sp)
                        else
                          Icon(Icons.radio_button_unchecked, color: Colors.grey.shade400, size: 28.sp),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _getVehicleSvg(String name) {
    final n = name.toLowerCase();
    if (n.contains('car')) return "assets/SvgImage/c1.svg";
    if (n.contains('bike') || n.contains('scooter') || n.contains('motorcycle')) return "assets/SvgImage/c2.svg";
    if (n.contains('truck') || n.contains('van')) return "assets/SvgImage/c3.svg";
    return "assets/SvgImage/c2.svg";
  }
}