// To parse this JSON data, do
//
//     final totalEarningResModel = totalEarningResModelFromJson(jsonString);

import 'dart:convert';

TotalEarningResModel totalEarningResModelFromJson(String str) =>
    TotalEarningResModel.fromJson(json.decode(str));

String totalEarningResModelToJson(TotalEarningResModel data) =>
    json.encode(data.toJson());

class TotalEarningResModel {
  String? message;
  int? code;
  bool? error;
  int? data;

  TotalEarningResModel({this.message, this.code, this.error, this.data});

  factory TotalEarningResModel.fromJson(Map<String, dynamic> json) =>
      TotalEarningResModel(
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

// To parse this JSON data, do
//
//     final totalEarningDashbordResModel = totalEarningDashbordResModelFromJson(jsonString);

TotalEarningDashbordResModel totalEarningDashbordResModelFromJson(String str) =>
    TotalEarningDashbordResModel.fromJson(json.decode(str));

String totalEarningDashbordResModelToJson(TotalEarningDashbordResModel data) =>
    json.encode(data.toJson());

class TotalEarningDashbordResModel {
  String? message;
  int? code;
  bool? error;
  Data? data;

  TotalEarningDashbordResModel({
    this.message,
    this.code,
    this.error,
    this.data,
  });

  factory TotalEarningDashbordResModel.fromJson(Map<String, dynamic> json) =>
      TotalEarningDashbordResModel(
        message: json["message"],
        code: json["code"],
        error: json["error"],
        data: json["data"] is Map<String, dynamic>
            ? Data.fromJson(json["data"])
            : null, // ✅ crash safe
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "code": code,
    "error": error,
    "data": data?.toJson(),
  };
}

class Data {
  int? totalEarning;
  int? totalDeliveries;
  String? totalTime;
  List<Graph>? graph;

  Data({this.totalEarning, this.totalDeliveries, this.totalTime, this.graph});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    totalEarning: json["totalEarning"] ?? 0,
    totalDeliveries: json["totalDeliveries"] ?? 0,
    totalTime: json["totalTime"] ?? "0h 0m",

    /// ✅ graph crash-proof parsing
    graph: json["graph"] is List
        ? List<Graph>.from(json["graph"].map((x) => Graph.fromJson(x)))
        : [],
  );

  Map<String, dynamic> toJson() => {
    "totalEarning": totalEarning,
    "totalDeliveries": totalDeliveries,
    "totalTime": totalTime,
    "graph": graph == null
        ? []
        : List<dynamic>.from(graph!.map((x) => x.toJson())),
  };
}

class Graph {
  String? label;
  int? earning;

  Graph({this.label, this.earning});

  factory Graph.fromJson(Map<String, dynamic> json) => Graph(
    label: json["label"], // ✅ backend key match
    earning: json["earning"] ?? 0, // ✅ null safe
  );

  Map<String, dynamic> toJson() => {"label": label, "earning": earning};
}
