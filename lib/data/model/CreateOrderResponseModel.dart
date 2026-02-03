// To parse this JSON data, do
//
//     final createOrderResponseModel = createOrderResponseModelFromJson(jsonString);

import 'dart:convert';

CreateOrderResponseModel createOrderResponseModelFromJson(String str) => CreateOrderResponseModel.fromJson(json.decode(str));

String createOrderResponseModelToJson(CreateOrderResponseModel data) => json.encode(data.toJson());

class CreateOrderResponseModel {
  String? message;
  int? code;
  bool? error;
  Data? data;

  CreateOrderResponseModel({
    this.message,
    this.code,
    this.error,
    this.data,
  });

  factory CreateOrderResponseModel.fromJson(Map<String, dynamic> json) => CreateOrderResponseModel(
    message: json["message"],
    code: json["code"],
    error: json["error"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "code": code,
    "error": error,
    "data": data?.toJson(),
  };
}

class Data {
  RazorpayOrder? razorpayOrder;
  Tx? tx;

  Data({
    this.razorpayOrder,
    this.tx,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    razorpayOrder: json["razorpayOrder"] == null ? null : RazorpayOrder.fromJson(json["razorpayOrder"]),
    tx: json["tx"] == null ? null : Tx.fromJson(json["tx"]),
  );

  Map<String, dynamic> toJson() => {
    "razorpayOrder": razorpayOrder?.toJson(),
    "tx": tx?.toJson(),
  };
}

class RazorpayOrder {
  int? amount;
  int? amountDue;
  int? amountPaid;
  int? attempts;
  int? createdAt;
  String? currency;
  String? entity;
  String? id;
  Notes? notes;
  dynamic offerId;
  String? receipt;
  String? status;

  RazorpayOrder({
    this.amount,
    this.amountDue,
    this.amountPaid,
    this.attempts,
    this.createdAt,
    this.currency,
    this.entity,
    this.id,
    this.notes,
    this.offerId,
    this.receipt,
    this.status,
  });

  factory RazorpayOrder.fromJson(Map<String, dynamic> json) => RazorpayOrder(
    amount: json["amount"],
    amountDue: json["amount_due"],
    amountPaid: json["amount_paid"],
    attempts: json["attempts"],
    createdAt: json["created_at"],
    currency: json["currency"],
    entity: json["entity"],
    id: json["id"],
    notes: json["notes"] == null ? null : Notes.fromJson(json["notes"]),
    offerId: json["offer_id"],
    receipt: json["receipt"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "amount": amount,
    "amount_due": amountDue,
    "amount_paid": amountPaid,
    "attempts": attempts,
    "created_at": createdAt,
    "currency": currency,
    "entity": entity,
    "id": id,
    "notes": notes?.toJson(),
    "offer_id": offerId,
    "receipt": receipt,
    "status": status,
  };
}

class Notes {
  String? userId;

  Notes({
    this.userId,
  });

  factory Notes.fromJson(Map<String, dynamic> json) => Notes(
    userId: json["userId"],
  );

  Map<String, dynamic> toJson() => {
    "userId": userId,
  };
}

class Tx {
  String? user;
  String? txType;
  int? amount;
  String? status;
  String? razorpayOrderId;

  Tx({
    this.user,
    this.txType,
    this.amount,
    this.status,
    this.razorpayOrderId,
  });

  factory Tx.fromJson(Map<String, dynamic> json) => Tx(
    user: json["user"],
    txType: json["txType"],
    amount: json["amount"],
    status: json["status"],
    razorpayOrderId: json["razorpayOrderId"],
  );

  Map<String, dynamic> toJson() => {
    "user": user,
    "txType": txType,
    "amount": amount,
    "status": status,
    "razorpayOrderId": razorpayOrderId,
  };
}
