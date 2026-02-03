/*
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
import 'PaymenetScreen.dart';
import 'Rating/ratingListPage.dart';
import 'TransactionHistory.dart';
import 'home.page.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ProfilePage extends ConsumerStatefulWidget {
  final IO.Socket? socket;
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
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 70.h),
            
            
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
                buildProfile(Icons.payment, "Payment", () {
            
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => WithdrawMoneyPage()),
                  );
            
                }),
            
            
                buildProfile(Icons.payment, "Transaction History", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TransactionHistoryPage()),
                  );
                }),
            
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
                SizedBox(width: 30.w),
              ],
            ),
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
*/
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
import 'GetCommision.dart';
import 'History.dart';
import 'PaymenetScreen.dart';
import 'QrCode.dart';
import 'Rating/ratingListPage.dart';
import 'TransactionHistory.dart';
import 'home.page.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
class ProfilePage extends ConsumerStatefulWidget {
  final IO.Socket? socket;
  const ProfilePage(this.socket, {super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  Future<void> _refreshProfile() async {
    // Most reliable way with autoDispose FutureProvider
    ref.invalidate(profileController);
    // Alternative names people sometimes use:
    // ref.refresh(profileController);
    // ref.read(profileController.notifier).fetch();   ← only if using AsyncNotifier
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Auto refresh every time screen becomes visible
    _refreshProfile();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileController);
    final box = Hive.box("userdata");

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _refreshProfile,
        color: const Color(0xFF006970), // or your app's primary color
        child: profileAsync.when(
          skipLoadingOnRefresh: false, // ← shows spinner during pull-to-refresh
          skipLoadingOnReload: false,
          data: (profile) {
            final rider = profile.data; // adjust field name if different
            if (rider == null) {
              return const Center(child: Text("Profile data not available"));
            }

            final String firstName = rider.firstName?.trim() ?? '';
            final String lastName = rider.lastName?.trim() ?? '';
            final String? imageUrl = rider.image;
            final num balance = rider.wallet?.balance ?? 0.0;
            final String referralCode = rider.referralCode?.toString() ?? '';

            final String initials =
                (firstName.isNotEmpty ? firstName[0].toUpperCase() : '') +
                    (lastName.isNotEmpty ? lastName[0].toUpperCase() : '');

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 70.h),

                  // Avatar
                  Center(
                    child: Container(
                      width: 72.w,
                      height: 72.h,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFA8DADC),
                      ),
                      child: ClipOval(
                        child: (imageUrl != null && imageUrl.isNotEmpty)
                            ? Image.network(
                          imageUrl,
                          width: 72.w,
                          height: 72.h,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Text(
                                initials,
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
                            initials,
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

                  SizedBox(height: 12.h),

                  // Name
                  Center(
                    child: Text(
                      '$firstName $lastName'.trim(),
                      style: GoogleFonts.inter(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF111111),
                      ),
                    ),
                  ),

                  SizedBox(height: 8.h),

                  // Wallet balance
                  Center(
                    child: Text(
                      "Wallet: ₹${balance.toStringAsFixed(2)}",
                      style: GoogleFonts.inter(
                        fontSize: 15.sp,
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  SizedBox(height: 20.h),

                  const Divider(
                    color: Color(0xFFB0B0B0),
                    thickness: 1,
                    indent: 24,
                    endIndent: 24,
                  ),

                  // Menu items
                  _buildTile(Icons.edit, "Edit Profile", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const UpdateUserProfilePage()),
                    );
                  }),

                  _buildTile(Icons.payment, "Payment", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const WithdrawMoneyPage()),
                    );
                  }),

                  _buildTile(Icons.receipt_long, "Transaction History", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HistoryPage()),
                    );
                  }),
                  _buildTile(Icons.receipt_long, "Qr Code", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) =>  QRGeneratorScreen( userId: rider.id??"",)),
                    );
                  }),

  _buildTile(Icons.receipt_long, "Commision", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) =>  GetCommissionPage()),
                    );
                  }),

                  _buildTile(Icons.rate_review_outlined, "Rating", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RatingListPage()),
                    );
                  }),

                  _buildTile(Icons.insert_drive_file, "Documents", () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(builder: (_) => const DocumentPage()),
                    );
                  }),

                  _buildTile(Icons.directions_car, "Vehicle", () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(builder: (_) => const VihicalPage()),
                    );
                  }),

                  _buildTile(Icons.history, "Delivery History", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => HomePage(2, forceSocketRefresh: true)),
                    );
                  }),

                  _buildTile(Icons.contact_support, "Support/FAQ", () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => SupportPage(widget.socket),
                      ),
                    );
                  }),

                  _buildTile(Icons.person_add_alt_1, "Invite Friends", () {
                    if (referralCode.isNotEmpty) {
                      final message = "Join me using my referral code: $referralCode\n"
                          "Download the app here: [your-app-link]";
                      Share.share(message, subject: "Join me on the delivery app!");
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Referral code not available")),
                      );
                    }
                  }),

                  SizedBox(height: 40.h),

                  // Logout row
                  InkWell(
                    onTap: () => _showLogoutDialog(context, box),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            "assets/SvgImage/signout.svg",
                            height: 14.h,
                            width: 14.w,
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            "Sign out",
                            style: GoogleFonts.inter(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color.fromARGB(200, 29, 53, 87),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 60.h),
                ],
              ),
            );
          },

          error: (err, stack) {
            log("Profile error: $err\n$stack");
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    child: Text("Error loading profile: $err", textAlign: TextAlign.center),
                  ),
                  ElevatedButton(
                    onPressed: _refreshProfile,
                    child: const Text("Retry"),
                  ),
                ],
              ),
            );
          },

          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  Widget _buildTile(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(left: 24.w, top: 20.h),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFB0B0B0), size: 24),
            SizedBox(width: 12.w),
            Text(
              title,
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

  void _showLogoutDialog(BuildContext context, Box box) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text("Logout"),
            onPressed: () {
              Navigator.pop(context);
              box.clear();
              Fluttertoast.showToast(msg: "Logout Successful");
              Navigator.pushAndRemoveUntil(
                context,
                CupertinoPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}