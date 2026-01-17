// To parse this JSON data, do
//
//     final withdrawRequestResponseModel = withdrawRequestResponseModelFromJson(jsonString);

import 'dart:convert';

WithdrawRequestResponseModel withdrawRequestResponseModelFromJson(String str) => WithdrawRequestResponseModel.fromJson(json.decode(str));

String withdrawRequestResponseModelToJson(WithdrawRequestResponseModel data) => json.encode(data.toJson());

class WithdrawRequestResponseModel {
  String? message;
  int? code;
  bool? error;
  dynamic data;

  WithdrawRequestResponseModel({
    this.message,
    this.code,
    this.error,
    this.data,
  });

  factory WithdrawRequestResponseModel.fromJson(Map<String, dynamic> json) => WithdrawRequestResponseModel(
    message: json["message"],
    code: json["code"],
    error: json["error"],
    data: json["data"],
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "code": code,
    "error": error,
    "data": data,
  };
}
