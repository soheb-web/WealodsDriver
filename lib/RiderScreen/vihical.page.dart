import 'package:delivery_rider_app/RiderScreen/vihicalDetails.page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/network/api.state.dart';
import '../config/utils/pretty.dio.dart';
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
  int select = 0;

  @override
  Widget build(BuildContext context) {
    final driverProfileAsync = ref.watch(driverProfileProvider);

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
            icon: const Icon(Icons.arrow_back_ios, size: 20),
          ),
        ),
        title: Padding(
          padding: EdgeInsets.only(left: 15.w),
          child: Text(
            "Vehicles",
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF091425),
            ),
          ),
        ),
        actions: [
          Container(
            decoration: const BoxDecoration(),
            margin: EdgeInsets.only(right: 10.w),
            child: IconButton(
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFF0F5F5),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddVihiclePage(),
                  ),
                ).then((_) {
                  ref.invalidate(driverProfileProvider);
                });
              },
              icon: const Icon(Icons.add),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10.h),
          const Divider(color: Color(0xFFCBCBCB), thickness: 1),
          SizedBox(height: 28.h),
          Expanded(
            child: driverProfileAsync.when(
              data: (profile) {
                final vehicles = profile.data?.vehicleDetails ?? [];
                return ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: vehicles.length,
                  itemBuilder: (context, index) {
                    final vehicle = vehicles[index];
                    final vehicleName = vehicle.vehicle?.name ?? 'Vehicle';
                    // final isCar = vehicleName.toLowerCase().contains('car');
                    return Padding(
                      padding: EdgeInsets.only(bottom: 24.h),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            select = index;
                          });
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) =>
                                  VihicalDetailsPage(vehicle: vehicle),
                            ),
                          ).then((_) {
                            ref.invalidate(driverProfileProvider);
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.only(left: 24.w, right: 24.w),
                          padding: EdgeInsets.only(
                            left: 14.w,
                            right: 14.w,
                            top: 14.h,
                            bottom: 14.h,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.r),
                            color: const Color(0xFFF3F7F5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  // SvgPicture.asset(
                                  //   "assets/SvgImage/${isCar ? 'c1' : 'c2'}.svg",
                                  //   width: 18.w,
                                  //   height: 18.h,
                                  // ),
                                  vehicleName.toLowerCase().contains('car')
                                      ? SvgPicture.asset(
                                          "assets/SvgImage/c1.svg",
                                          width: 18.w,
                                          height: 18.h,
                                        )
                                      : vehicleName.toLowerCase().contains(
                                          'truck',
                                        )
                                      ? SvgPicture.asset(
                                          "assets/SvgImage/c3.svg",
                                          width: 18.w,
                                          height: 18.h,
                                        )
                                      : vehicleName.toLowerCase().contains(
                                          'cycle',
                                        )
                                      ? SvgPicture.asset(
                                          "assets/SvgImage/c3.svg",
                                          width: 18.w,
                                          height: 18.h,
                                        )
                                      : vehicleName.toLowerCase().contains(
                                          'bike',
                                        )
                                      ? SvgPicture.asset(
                                          "assets/SvgImage/c2.svg",
                                          width: 18.w,
                                          height: 18.h,
                                        )
                                      : SvgPicture.asset(
                                          "assets/SvgImage/c3.svg",
                                          width: 18.w,
                                          height: 18.h,
                                        ),
                                  const Spacer(),
                                  select == index
                                      ? const Icon(
                                          Icons.check_circle,
                                          color: Color(0xFF25BC15),
                                          size: 20,
                                        )
                                      : const Icon(
                                          Icons.circle_outlined,
                                          color: Color(0xFF898A8D),
                                          size: 20,
                                        ),
                                ],
                              ),
                              Text(
                                "$vehicleName • ${vehicle.model ?? ''}",
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF545454),
                                ),
                              ),
                              Text(
                                "Number Plate : ${vehicle.numberPlate ?? ''}",
                                style: GoogleFonts.inter(
                                  fontSize: 17.sp,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF545454),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text(
                  'Error loading vehicles: $error',
                  style: GoogleFonts.inter(fontSize: 14.sp, color: Colors.red),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
