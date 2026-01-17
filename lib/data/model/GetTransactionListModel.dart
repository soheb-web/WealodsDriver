// To parse this JSON data, do
//
//     final transactionListResponseModel = transactionListResponseModelFromJson(jsonString);

import 'dart:convert';

TransactionListResponseModel transactionListResponseModelFromJson(String str) => TransactionListResponseModel.fromJson(json.decode(str));

String transactionListResponseModelToJson(TransactionListResponseModel data) => json.encode(data.toJson());

class TransactionListResponseModel {
  String? message;
  int? code;
  bool? error;
  List<Datum>? data;

  TransactionListResponseModel({
    this.message,
    this.code,
    this.error,
    this.data,
  });

  factory TransactionListResponseModel.fromJson(Map<String, dynamic> json) => TransactionListResponseModel(
    message: json["message"],
    code: json["code"],
    error: json["error"],
    data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "code": code,
    "error": error,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Datum {
  String? id;
  String? user;
  String? txType;
  String? status;
  int? amount;
  String? razorpayOrderId;
  bool? isDisable;
  bool? isDeleted;
  int? date;
  int? month;
  int? year;
  int? createdAt;
  int? updatedAt;
  int? v;

  Datum({
    this.id,
    this.user,
    this.txType,
    this.status,
    this.amount,
    this.razorpayOrderId,
    this.isDisable,
    this.isDeleted,
    this.date,
    this.month,
    this.year,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["_id"],
    user: json["user"],
    txType: json["txType"],
    status: json["status"],
    amount: json["amount"],
    razorpayOrderId: json["razorpayOrderId"],
    isDisable: json["isDisable"],
    isDeleted: json["isDeleted"],
    date: json["date"],
    month: json["month"],
    year: json["year"],
    createdAt: json["createdAt"],
    updatedAt: json["updatedAt"],
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "user": user,
    "txType": txType,
    "status": status,
    "amount": amount,
    "razorpayOrderId": razorpayOrderId,
    "isDisable": isDisable,
    "isDeleted": isDeleted,
    "date": date,
    "month": month,
    "year": year,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
    "__v": v,
  };
}
