// transaction_list_response_model.dart

import 'dart:convert';

TransactionListResponseModel transactionListResponseModelFromJson(String str) =>
    TransactionListResponseModel.fromJson(json.decode(str));

String transactionListResponseModelToJson(TransactionListResponseModel data) =>
    json.encode(data.toJson());

class TransactionListResponseModel {
  final String? message;
  final bool? error;
  final List<Transaction>? transactions; // ← renamed & unified

  TransactionListResponseModel({
    this.message,
    this.error,
    this.transactions,
  });

  factory TransactionListResponseModel.fromJson(Map<String, dynamic> json) {
    // Choose ONE of the following patterns according to your real API response

    // Pattern A: popular in many APIs
    List<Transaction>? txs;
    if (json['data'] is List) {
      txs = List<Transaction>.from(
          (json['data'] as List).map((x) => Transaction.fromJson(x)));
    } else if (json['code'] is List) {
      txs = List<Transaction>.from(
          (json['code'] as List).map((x) => Transaction.fromJson(x)));
    }

    return TransactionListResponseModel(
      message: json['message'],
      error: json['error'],
      transactions: txs,
    );
  }

  Map<String, dynamic> toJson() => {
    "message": message,
    "error": error,
    "data": transactions?.map((x) => x.toJson()).toList(),
  };
}

class Transaction {
  final String? id;
  final String? sender;
  final String? receiver;        // ← changed to String (most likely ObjectId)
  final String? txType;          // ← keep as String
  final String? status;
  final int? amount;
  final bool? isDisable;
  final bool? isDeleted;
  final int? date;
  final int? month;
  final int? year;
  final int? createdAt;
  final int? updatedAt;
  final int? v;
  final String? user;            // ← most likely String
  final String? razorpayOrderId;

  Transaction({
    this.id,
    this.sender,
    this.receiver,
    this.txType,
    this.status,
    this.amount,
    this.isDisable,
    this.isDeleted,
    this.date,
    this.month,
    this.year,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.user,
    this.razorpayOrderId,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    id: json["_id"] as String?,
    sender: json["sender"] as String?,
    receiver: json["receiver"] as String?,
    txType: json["txType"] as String?,
    status: json["status"] as String?,
    amount: json["amount"] as int?,
    isDisable: json["isDisable"] as bool?,
    isDeleted: json["isDeleted"] as bool?,
    date: json["date"] as int?,
    month: json["month"] as int?,
    year: json["year"] as int?,
    createdAt: json["createdAt"] as int?,
    updatedAt: json["updatedAt"] as int?,
    v: json["__v"] as int?,
    user: json["user"] as String?,
    razorpayOrderId: json["razorpayOrderId"] as String?,
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "sender": sender,
    "receiver": receiver,
    "txType": txType,
    "status": status,
    "amount": amount,
    "isDisable": isDisable,
    "isDeleted": isDeleted,
    "date": date,
    "month": month,
    "year": year,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
    "__v": v,
    "user": user,
    "razorpayOrderId": razorpayOrderId,
  };
}