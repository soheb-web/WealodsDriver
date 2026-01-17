// To parse this JSON data, do
//
//     final WithdrawBodyModel = WithdrawBodyModelFromJson(jsonString);

import 'dart:convert';

WithdrawBodyModel WithdrawBodyModelFromJson(String str) => WithdrawBodyModel.fromJson(json.decode(str));

String WithdrawBodyModelToJson(WithdrawBodyModel data) => json.encode(data.toJson());

class WithdrawBodyModel {
  int? amount;


  WithdrawBodyModel({
    this.amount,

  });

  factory WithdrawBodyModel.fromJson(Map<String, dynamic> json) => WithdrawBodyModel(
    amount: json["amount"],

  );

  Map<String, dynamic> toJson() => {
    "amount": amount,

  };
}
