// To parse this JSON data, do
//
//     final VihicleSelectModel = VihicleSelectModelFromJson(jsonString);

import 'dart:convert';

VihicleSelectModel VihicleSelectModelFromJson(String str) => VihicleSelectModel.fromJson(json.decode(str));

String VihicleSelectModelToJson(VihicleSelectModel data) => json.encode(data.toJson());

class VihicleSelectModel {
  String vehicleId;

  VihicleSelectModel({
    required this.vehicleId,
  });

  factory VihicleSelectModel.fromJson(Map<String, dynamic> json) => VihicleSelectModel(
    vehicleId: json["vehicleId"],
  );

  Map<String, dynamic> toJson() => {
    "vehicleId": vehicleId,
  };
}
