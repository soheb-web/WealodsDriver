// To parse this JSON data, do
//
//     final LoginBodyModel = LoginBodyModelFromJson(jsonString);

import 'dart:convert';

LoginBodyModel LoginBodyModelFromJson(String str) => LoginBodyModel.fromJson(json.decode(str));

String LoginBodyModelToJson(LoginBodyModel data) => json.encode(data.toJson());

class LoginBodyModel {
  String loginType;
  // String password;
  String deviceId;


  LoginBodyModel({
    required this.loginType,
    // required this.password,
    required this.deviceId,

  });

  factory LoginBodyModel.fromJson(Map<String, dynamic> json) => LoginBodyModel(
    loginType: json["loginType"],
    // password: json["password"],
    deviceId: json["deviceId"],

  );

  Map<String, dynamic> toJson() => {
    "loginType": loginType,
    // "password": password,
    "deviceId": deviceId,

  };
}
