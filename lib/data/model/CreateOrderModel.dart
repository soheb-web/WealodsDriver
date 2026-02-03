// To parse this JSON data, do
//
//     final createOrderModel = createOrderModelFromJson(jsonString);

import 'dart:convert';

CreateOrderModel createOrderModelFromJson(String str) => CreateOrderModel.fromJson(json.decode(str));

String createOrderModelToJson(CreateOrderModel data) => json.encode(data.toJson());

class CreateOrderModel {
  int? amount;
  String? currency;

  CreateOrderModel({
    this.amount,
    this.currency,
  });

  factory CreateOrderModel.fromJson(Map<String, dynamic> json) => CreateOrderModel(
    amount: json["amount"],
    currency: json["currency"],
  );

  Map<String, dynamic> toJson() => {
    "amount": amount,
    "currency": currency,
  };
}
