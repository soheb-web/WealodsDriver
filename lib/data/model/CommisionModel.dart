import 'dart:convert';

CommissionModel commissionModelFromJson(String str) =>
    CommissionModel.fromJson(json.decode(str));

String commissionModelToJson(CommissionModel data) =>
    json.encode(data.toJson());

class CommissionModel {
  String? message;
  int? code;
  bool? error;
  Data? data;

  CommissionModel({
    this.message,
    this.code,
    this.error,
    this.data,
  });

  factory CommissionModel.fromJson(Map<String, dynamic> json) => CommissionModel(
    message: json["message"] as String?,
    code: _parseInt(json["code"]),
    error: json["error"] as bool?,
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
  int? earning;
  int? commission;       // fixed spelling & lowercase
  int? totalCommission;  // fixed spelling & consistency

  Data({
    this.earning,
    this.commission,
    this.totalCommission,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    earning: _parseInt(json["earning"]),
    commission: _parseInt(json["Commissin"]),     // map old API key
    totalCommission: _parseInt(json["totalCommissin"]),
  );

  Map<String, dynamic> toJson() => {
    "earning": earning,
    "Commissin": commission,          // keep API compatibility if needed
    "totalCommissin": totalCommission,
  };
}

int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) {
    final cleaned = value.replaceAll(',', '').trim();
    return int.tryParse(cleaned);
  }
  return null;
}