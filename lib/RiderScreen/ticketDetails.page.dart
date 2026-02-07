import 'dart:developer';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:delivery_rider_app/config/network/api.state.dart';
import 'package:delivery_rider_app/config/utils/pretty.dio.dart';
import 'package:delivery_rider_app/data/model/ticketReplyBodyModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../data/controller/getTicketListController.dart';

class TicketDetailsPage extends ConsumerStatefulWidget {
  final IO.Socket? socket;
  final String id;
  const TicketDetailsPage(this.socket, {super.key, required this.id});

  @override
  ConsumerState<TicketDetailsPage> createState() => _TicketDetailsPageState();
}

class _TicketDetailsPageState extends ConsumerState<TicketDetailsPage> {
  final messageController = TextEditingController();
  final List<Map<String, dynamic>> _allReplies = [];
  final ScrollController _scrollController = ScrollController();
  late IO.Socket socket;
  String currentUserRole = 'driver';

  @override
  void initState() {
    super.initState();
    // STEP 1: Fresh data guarantee on every visit
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(ticketDetailsController(widget.id));
      ref.refresh(ticketDetailsController(widget.id));
    });
    socket = widget.socket!;
    // Socket setup
    if (socket.connected) {
      socket.emit("join_ticket", widget.id);
    } else {
      socket.onConnect((_) {
        socket.emit("join_ticket", widget.id);
      });
      socket.connect();
    }
    // REAL-TIME REPLY FROM SERVER
    socket.on("new_ticket_reply", (data) {
      log("Socket reply: $data");
      if (data is Map && data['ticketId'] == widget.id) {
        setState(() {
          _allReplies.add(data as Map<String, dynamic>);
        });
        _scrollToBottom();
      }
    });
  }

  @override
  void dispose() {
    socket.emit("leave_ticket", widget.id);
    socket.off("new_ticket_reply");
    messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;
    messageController.clear();

    final optimisticReply = {
      "message": text,
      "repliedByModel": "User",
      "role": "driver",
      "createdAt": DateTime.now().millisecondsSinceEpoch,
      "repliedBy": {"firstName": "You", "lastName": ""},
      "ticketId": widget.id,
    };

    // // Show message instantly
    // setState(() {
    //   _allReplies.add(optimisticReply);
    // });
    _scrollToBottom();

    try {
      final body = TicketReplyBodyModel(message: text, ticketId: widget.id);
      final service = APIStateNetwork(callDio());
      final response = await service.ticketReply(body);

      if (response.code == 0) {
        Fluttertoast.showToast(msg: "Message sent!");
        socket.emit("new_ticket_reply", optimisticReply);
      } else {
        setState(() {
          _allReplies.remove(optimisticReply); // rollback
        });
        Fluttertoast.showToast(msg: response.message);
      }
    } catch (e, st) {
      log("Send error: $e\n$st");
      setState(() {
        _allReplies.remove(optimisticReply);
      });
      Fluttertoast.showToast(msg: "Failed to send");
    }
  }

  @override
  Widget build(BuildContext context) {
    final ticketProvider = ref.watch(ticketDetailsController(widget.id));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: 20.w),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios, size: 20.sp),
          ),
        ),
        title: Text(
          "Support Details",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w400,
            fontSize: 15.sp,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(ticketDetailsController(widget.id));
          await ref.refresh(ticketDetailsController(widget.id));
        },
        child: ticketProvider.when(
          data: (snap) {
            // ONLY LOAD API DATA IF LIST IS EMPTY OR SERVER HAS MORE
            if (_allReplies.isEmpty ||
                (_allReplies.length <= (snap.data.replies?.length ?? 0))) {
              _allReplies.clear();
              if (snap.data.replies != null) {
                _allReplies.addAll(
                  snap.data.replies!.map((r) => r.toJson()).toList(),
                );
                _allReplies.sort(
                  (a, b) =>
                      (a['createdAt'] ?? 0).compareTo(b['createdAt'] ?? 0),
                );
              }
              _scrollToBottom();
            }

            return Padding(
              padding: EdgeInsets.only(left: 15.w, right: 15.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: Color(0xFFCBCBCB)),
                  SizedBox(height: 28.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F5F5),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      snap.data.ticket?.subject ?? "No Subject",
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: _allReplies.length,
                      itemBuilder: (context, index) {
                        final reply = _allReplies[index];
                        final isUser = reply['repliedByModel'] == "User";
                        // final name = isUser
                        //     ? "You"
                        //     : "${reply['repliedBy']?['firstName'] ?? 'Support'} ${reply['repliedBy']?['lastName'] ?? ''}".trim();

                        return _buildMessageBubble(
                          message: reply['message'] ?? '',
                          isSender: isUser,
                          // senderName: name,
                          timestamp: reply['createdAt'],
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 80.h),
                ],
              ),
            );
          },
          loading: () => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Color(0xFF008080)),
                SizedBox(height: 16.h),
                Text(
                  "Loading messages...",
                  style: GoogleFonts.inter(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          error: (err, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 60.sp),
                SizedBox(height: 16.h),
                Text("Failed to load ticket", style: GoogleFonts.inter()),
                SizedBox(height: 10.h),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(ticketDetailsController(widget.id));
                    ref.refresh(ticketDetailsController(widget.id));
                  },
                  child: Text("Retry"),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomSheet: MessageInput(
        controller: messageController,
        onSend: _handleSendMessage,
      ),
    );
  }

  Widget _buildMessageBubble({
    required String message,
    required bool isSender,
    // required String senderName,
    dynamic timestamp,
  }) {
    final time = _formatTimestamp(timestamp);

    return Padding(
      padding: EdgeInsets.only(top: 12.h),
      child: Column(
        crossAxisAlignment: isSender
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          // if (!isSender)
          //   Padding(
          //     padding: EdgeInsets.only(left: 12.w, bottom: 4.h),
          //     child: Text(senderName, style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.grey[600])),
          //   ),
          Align(
            alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              constraints: BoxConstraints(maxWidth: 0.75.sw),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: isSender
                    ? const Color(0xFF008080)
                    : const Color(0xFFF0F5F5),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.r),
                  topRight: Radius.circular(10.r),
                  bottomLeft: Radius.circular(isSender ? 10.r : 0),
                  bottomRight: Radius.circular(isSender ? 0 : 10.r),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      color: isSender ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    time,
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      color: isSender ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '';
    int millis = timestamp is String
        ? int.tryParse(timestamp) ?? DateTime.now().millisecondsSinceEpoch
        : timestamp;
    final date = DateTime.fromMillisecondsSinceEpoch(millis);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDate = DateTime(date.year, date.month, date.day);

    if (msgDate == today) {
      return DateFormat('h:mm a').format(date);
    } else if (msgDate == today.subtract(Duration(days: 1))) {
      return 'Yesterday ${DateFormat('h:mm a').format(date)}';
    } else {
      return DateFormat('dd MMM, h:mm a').format(date);
    }
  }
}

// class MessageInput extends StatelessWidget {
//   final TextEditingController controller;
//   final VoidCallback onSend;
//
//   const MessageInput({super.key, required this.controller, required this.onSend});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: Colors.white,
//       padding: EdgeInsets.only(
//         left: 10.w,
//         right: 10.w,
//         bottom: MediaQuery.of(context).viewInsets.bottom + 10.h,
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: TextField(
//               controller: controller,
//               decoration: InputDecoration(
//                 hintText: "Type a message...",
//                 filled: true,
//                 fillColor: const Color(0xFFF0F5F5),
//                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: BorderSide.none),
//                 contentPadding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
//               ),
//             ),
//           ),
//           SizedBox(width: 10.w),
//           GestureDetector(
//             onTap: onSend,
//             child: Container(
//               padding: EdgeInsets.all(14.w),
//               decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF008080)),
//               child: Icon(Icons.send, color: Colors.white, size: 24.sp),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const MessageInput({
    super.key,
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 10.w, bottom: 10.h),
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(
                    left: 15.w,
                    right: 15.w,
                    top: 10.h,
                    bottom: 10.h,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF0F5F5),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(color: Colors.grey, width: 1.w),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: const BorderSide(
                      color: Color(0xFF006970),
                      width: 1,
                    ),
                  ),
                  hintText: "Type a message ...",
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFAFAFAF),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 55.w,
              height: 54.h,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF008080),
              ),
              child: Center(
                child: Icon(Icons.send_sharp, color: Colors.white, size: 28.sp),
              ),
            ),
          ),
          SizedBox(width: 15.w),
        ],
      ),
    );
  }
}
