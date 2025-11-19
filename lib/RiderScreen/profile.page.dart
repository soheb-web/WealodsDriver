import 'dart:developer';
import 'package:delivery_rider_app/RiderScreen/document.page.dart';
import 'package:delivery_rider_app/RiderScreen/login.page.dart';
import 'package:delivery_rider_app/RiderScreen/support.page.dart';
import 'package:delivery_rider_app/RiderScreen/updateProfile.dart';
import 'package:delivery_rider_app/RiderScreen/vihical.page.dart';
import 'package:delivery_rider_app/data/controller/getProfileController.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:share_plus/share_plus.dart';
import 'Rating/ratingListPage.dart';
import 'home.page.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ProfilePage extends ConsumerStatefulWidget {
  final IO.Socket socket;
  const ProfilePage(this.socket, {super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final profileData = ref.watch(profileController);
    var box = Hive.box("userdata");

    return Scaffold(
      backgroundColor: Colors.white,
      body: profileData.when(
        data: (profile) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 70.h),

              /*  Center(
                child: Container(
                  width: 72.w,
                  height: 72.h,
                  decoration: BoxDecoration(
                    // borderRadius: BorderRadius.circular(30.sp),
                    shape: BoxShape.circle,
                    color: const Color(0xFFA8DADC),
                  ),
                  // child: profile.data!.image != null
                  //     ? Image.network(
                  //         //"https://demofree.sirv.com/nope-not-here.jpg",
                  //         profile.data!.image!,
                  //         width: 72.w,
                  //         height: 72.h,
                  //         fit: BoxFit.cover,
                  //       )
                  //     : Center(
                  //         child: Text(
                  //           "${profile.data!.firstName![0].toUpperCase()}${profile.data!.lastName![0]}",
                  //           style: GoogleFonts.inter(
                  //             fontSize: 32.sp,
                  //             fontWeight: FontWeight.w500,
                  //             color: const Color(0xFF4F4F4F),
                  //           ),
                  //         ),
                  //       ),
                  child: profile.data!.image != null
                      ? ClipOval(
                          child: Image.network(
                            profile.data!.image!,
                            width: 72.w,
                            height: 72.h,
                            fit: BoxFit.cover,
                          ),
                        )
                      : (box.get('driver_photo_path') != null
                            ? ClipOval(
                                child: Image.file(
                                  File(box.get('driver_photo_path')),
                                  width: 72.w,
                                  height: 72.h,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Center(
                                child: Text(
                                  "${profile.data!.firstName![0].toUpperCase()}${profile.data!.lastName![0]}",
                                  style: GoogleFonts.inter(
                                    fontSize: 32.sp,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF4F4F4F),
                                  ),
                                ),
                              )),
                ),
              ),*/
              Center(
                child: Container(
                  width: 72.w,
                  height: 72.h,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFA8DADC),
                  ),
                  child: ClipOval(
                    child: profile.data!.image != null
                        ? Image.network(
                            profile.data!.image!,
                            width: 72.w,
                            height: 72.h,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Text(
                                  "${profile.data!.firstName![0].toUpperCase()}${profile.data!.lastName![0].toUpperCase()}",
                                  style: GoogleFonts.inter(
                                    fontSize: 28.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF4F4F4F),
                                  ),
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Text(
                              "${profile.data!.firstName![0].toUpperCase()}${profile.data!.lastName![0].toUpperCase()}",
                              style: GoogleFonts.inter(
                                fontSize: 28.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF4F4F4F),
                              ),
                            ),
                          ),
                  ),
                ),
              ),

              Center(
                child: Text(
                  "${profile.data!.firstName!.trim()} ${profile.data!.lastName!.trim()}",
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF111111),
                  ),
                ),
              ),

              // ✅ Driver Balance
              if (profile.data!.id!.isNotEmpty)
                Center(
                  child: Text(
                    // "Wallet: ₹${balance.toStringAsFixed(2)}",
                    "Wallet: ₹${profile.data!.wallet!.balance!.toStringAsFixed(2)}",
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: Colors.grey[700],
                    ),
                  ),
                ),

              SizedBox(height: 20.h),
              const Divider(
                color: Color(0xFFB0B0B0),
                thickness: 1,
                endIndent: 24,
                indent: 24,
              ),

              buildProfile(Icons.edit, "Edit Profile", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpdateUserProfilePage(),
                  ),
                );
              }),
              buildProfile(Icons.payment, "Payment", () {}),
              buildProfile(Icons.rate_review_outlined, "Rating", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RatingListPage()),
                );
              }),
              buildProfile(Icons.insert_drive_file_sharp, "Documents", () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => const DocumentPage(),
                  ),
                );
              }),
              buildProfile(Icons.directions_car, "Vehicle", () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (context) => const VihicalPage()),
                );
              }),
              buildProfile(Icons.history, "Delivery History", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage(2)),
                );
              }),
              buildProfile(Icons.contact_support, "Support/FAQ", () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => SupportPage(widget.socket),
                  ),
                );
              }),
              buildProfile(
                Icons.markunread_mailbox_rounded,
                "Invite Friends",
                () {
                  final referralCode =
                      profile.data?.referralCode?.toString() ?? "";
                  final shareUrl =
                      "Join me using my referral code: $referralCode";

                  if (referralCode.isNotEmpty) {
                    Share.share(shareUrl, subject: "Check out this course!");
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Referral code not available."),
                      ),
                    );
                  }
                },
              ),
              SizedBox(height: 50.h),

              // ✅ Logout with confirmation dialog
              InkWell(
                onTap: () {
                  _showLogoutDialog(context, box);
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(width: 24.w),
                    SvgPicture.asset("assets/SvgImage/signout.svg"),
                    SizedBox(width: 10.w),
                    Text(
                      "Sign out",
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color.fromARGB(186, 29, 53, 87),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        error: (error, stackTrace) {
          log(stackTrace.toString());
          return Center(child: Text(error.toString()));
        },
        loading: () => Center(child: CircularProgressIndicator()),
      ),
    );
  }

  /// ✅ Logout Confirmation Dialog
  void _showLogoutDialog(BuildContext context, Box box) {
    showDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to log out?"),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                Navigator.pop(context); // Close dialog only
              },
              child: const Text("No"),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.pop(context); // Close dialog
                box.clear();
                Fluttertoast.showToast(msg: "Logout Successful");
                Navigator.pushAndRemoveUntil(
                  context,
                  CupertinoPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  Widget buildProfile(IconData icon, String name, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(left: 24.w, top: 25.h),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFB0B0B0)),

            SizedBox(width: 10.w),

            Text(
              name,
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: const Color.fromARGB(186, 29, 53, 87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
