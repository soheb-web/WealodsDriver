// To parse this JSON data, do
//
//     final selectVicileResponse = selectVicileResponseFromJson(jsonString);

import 'dart:convert';

SelectVicileResponse selectVicileResponseFromJson(String str) => SelectVicileResponse.fromJson(json.decode(str));

String selectVicileResponseToJson(SelectVicileResponse data) => json.encode(data.toJson());

class SelectVicileResponse {
  String? message;
  int? code;
  bool? error;
  dynamic data;

  SelectVicileResponse({
    this.message,
    this.code,
    this.error,
    this.data,
  });

  factory SelectVicileResponse.fromJson(Map<String, dynamic> json) => SelectVicileResponse(
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
