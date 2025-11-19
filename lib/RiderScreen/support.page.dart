import 'dart:developer';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:delivery_rider_app/RiderScreen/ticketDetails.page.dart';
import 'package:delivery_rider_app/config/network/api.state.dart';
import 'package:delivery_rider_app/config/utils/pretty.dio.dart';
import 'package:delivery_rider_app/data/controller/getTicketListController.dart';
import 'package:delivery_rider_app/data/model/createTicketBodyModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

class SupportPage extends ConsumerStatefulWidget {
  final IO.Socket socket;
  const SupportPage(this.socket, {super.key});

  @override
  ConsumerState<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends ConsumerState<SupportPage> {
  final subjectController = TextEditingController();
  final descController = TextEditingController();
  bool isCreate = false;

  @override
  Widget build(BuildContext context) {
    final getTicketListProvider = ref.watch(getTicketListController);
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),

      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFFFFFFFF),
        leading: Padding(
          padding: EdgeInsets.only(left: 20.w),
          child: IconButton(
            style: IconButton.styleFrom(shape: CircleBorder()),
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios, size: 20.sp),
          ),
        ),
        title: Padding(
          padding: EdgeInsets.only(left: 15.w),
          child: Text(
            "Support/Faq",
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              fontWeight: FontWeight.w400,
              color: Color(0xFF091425),
            ),
          ),
        ),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //SizedBox(height: 10.h),
          Divider(color: Color(0xFFCBCBCB), thickness: 1),
          SizedBox(height: 28.h),
          Padding(
            padding: EdgeInsets.only(left: 20.w, right: 20.w),
            child: TextFormField(
              controller: subjectController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(
                  left: 15.w,
                  right: 15.w,
                  top: 10.h,
                  bottom: 10.h,
                ),
                filled: true,
                fillColor: Color(0xFFF0F5F5),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide(color: Colors.grey, width: 1.w),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide(color: Color(0xFF006970), width: 1.w),
                ),
                hint: Text(
                  "Enter Subject",
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFFAFAFAF),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 20.h),
            child: TextFormField(
              controller: descController,
              maxLines: 4,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(
                  left: 15.w,
                  right: 15.w,
                  top: 10.h,
                  bottom: 10.h,
                ),
                filled: true,
                fillColor: Color(0xFFF0F5F5),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide(color: Colors.grey, width: 1.w),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide(color: Color(0xFF006970), width: 1.w),
                ),
                hint: Text(
                  "Enter Description",
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFFAFAFAF),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 20.h),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006970),
                minimumSize: Size(double.infinity, 50.h),
                padding: EdgeInsets.symmetric(vertical: 16.h),
              ),
              onPressed: isCreate
                  ? null
                  : () async {
                      setState(() {
                        isCreate = true;
                      });
                      final body = CreateTicketBodyModel(
                        subject: subjectController.text,
                        description: descController.text,
                      );
                      try {
                        final service = APIStateNetwork(callDio());
                        final response = await service.createTicket(body);
                        if (response.code == 0) {
                          Fluttertoast.showToast(msg: response.message);
                          ref.invalidate(getTicketListController);

                          // ✅ Clear fields after success (optional)
                          subjectController.clear();
                          descController.clear();
                        } else {
                          setState(() {
                            isCreate = false;
                          });
                          Fluttertoast.showToast(msg: response.message);
                        }
                      } catch (e, st) {
                        setState(() {
                          isCreate = false;
                        });
                        log("${e.toString()} /n ${st.toString()}");
                        Fluttertoast.showToast(msg: "Create Error : $e");
                      } finally {
                        setState(() {
                          isCreate = false;
                        });
                      }
                    },
              child: isCreate
                  ? Center(
                      child: SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 1,
                        ),
                      ),
                    )
                  : Text(
                      "Create Ticket",
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          SizedBox(height: 20.h),
          Expanded(
            child: getTicketListProvider.when(
              data: (snap) {
                String _formatDate(dynamic timestamp) {
                  try {
                    if (timestamp == null) return "-";
                    int timeValue = timestamp is int
                        ? timestamp
                        : int.tryParse(timestamp.toString()) ?? 0;

                    if (timeValue > 9999999999999) {
                      timeValue = (timeValue / 1000).round();
                    }

                    DateTime date = DateTime.fromMillisecondsSinceEpoch(
                      timeValue,
                    );
                    return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
                  } catch (e) {
                    return "-";
                  }
                }

                if (snap.data.list.isEmpty) {
                  return Center(child: Text("No message available"));
                }
                return ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: snap.data.list.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        log(snap.data.list[index].id);
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => TicketDetailsPage(
                              widget.socket,
                              id: snap.data.list[index].id,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: 15.h,
                          left: 20.w,
                          right: 20.w,
                        ),
                        child: Container(
                          padding: EdgeInsets.only(
                            left: 10.w,
                            right: 10.w,
                            top: 10.h,
                            bottom: 10.h,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.r),
                            color: const Color(0xFFF0F5F5),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.headphones_outlined,
                                color: Color(0xFF006970),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      snap.data.list[index].subject,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      snap.data.list[index].description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Spacer(),
                              Text(
                                _formatDate(snap.data.list[index].date),
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  color: Colors.grey[700],
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
              error: (error, stackTrace) {
                log(stackTrace.toString());
                return Center(child: Text(error.toString()));
              },
              loading: () => Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }
}
