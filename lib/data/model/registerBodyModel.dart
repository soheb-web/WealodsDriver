// To parse this JSON data, do
//
//     final registerBodyModel = registerBodyModelFromJson(jsonString);

import 'dart:convert';

RegisterBodyModel registerBodyModelFromJson(String str) => RegisterBodyModel.fromJson(json.decode(str));

String registerBodyModelToJson(RegisterBodyModel data) => json.encode(data.toJson());

class RegisterBodyModel {
    String firstName;
    String lastName;
    String email;
    String phone;
    String cityId;
    String deviceId;
    String refByCode;
    // String password;

    RegisterBodyModel({
        required this.firstName,
        required this.lastName,
        required this.email,
        required this.phone,
        required this.cityId,
        required this.deviceId,
        required this.refByCode,
        // required this.password,
    });

    factory RegisterBodyModel.fromJson(Map<String, dynamic> json) => RegisterBodyModel(
        firstName: json["firstName"],
        lastName: json["lastName"],
        email: json["email"],
        phone: json["phone"],
        cityId: json["cityId"],
        deviceId: json["deviceId"],
        refByCode: json["refByCode"],
        // password: json["password"],
    );

    Map<String, dynamic> toJson() => {
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "phone": phone,
        "cityId": cityId,
        "deviceId": deviceId,
        "refByCode": refByCode,
        // "password": password,
    };
}


