/*
// To parse this JSON data, do
//
//     final QrTransactionHistoryModel = QrTransactionHistoryModelFromJson(jsonString);

import 'dart:convert';

QrTransactionHistoryModel QrTransactionHistoryModelFromJson(String str) => QrTransactionHistoryModel.fromJson(json.decode(str));

String QrTransactionHistoryModelToJson(QrTransactionHistoryModel data) => json.encode(data.toJson());

class QrTransactionHistoryModel {
  String? message;
  int? code;
  bool? error;
  Data? data;

  QrTransactionHistoryModel({
    this.message,
    this.code,
    this.error,
    this.data,
  });

  factory QrTransactionHistoryModel.fromJson(Map<String, dynamic> json) => QrTransactionHistoryModel(
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
  List<Datum>? data;
  Pagination? pagination;

  Data({
    this.data,
    this.pagination,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
    pagination: json["pagination"] == null ? null : Pagination.fromJson(json["pagination"]),
  );

  Map<String, dynamic> toJson() => {
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    "pagination": pagination?.toJson(),
  };
}

class Datum {
  String? id;
  Receiver? sender;
  Receiver? receiver;
  String? txType;
  String? status;
  int? amount;
  bool? isDisable;
  bool? isDeleted;
  int? date;
  int? month;
  int? year;
  int? createdAt;
  int? updatedAt;
  int? v;

  Datum({
    this.id,
    this.sender,
    this.receiver,
    this.txType,
    this.status,
    this.amount,
    this.isDisable,
    this.isDeleted,
    this.date,
    this.month,
    this.year,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["_id"],
    sender: json["sender"] == null ? null : Receiver.fromJson(json["sender"]),
    receiver: json["receiver"] == null ? null : Receiver.fromJson(json["receiver"]),
    txType: json["txType"],
    status: json["status"],
    amount: json["amount"],
    isDisable: json["isDisable"],
    isDeleted: json["isDeleted"],
    date: json["date"],
    month: json["month"],
    year: json["year"],
    createdAt: json["createdAt"],
    updatedAt: json["updatedAt"],
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "sender": sender?.toJson(),
    "receiver": receiver?.toJson(),
    "txType": txType,
    "status": status,
    "amount": amount,
    "isDisable": isDisable,
    "isDeleted": isDeleted,
    "date": date,
    "month": month,
    "year": year,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
    "__v": v,
  };
}

class Receiver {
  Id? id;
  Email? email;

  Receiver({
    this.id,
    this.email,
  });

  factory Receiver.fromJson(Map<String, dynamic> json) => Receiver(
    id: idValues.map[json["_id"]]!,
    email: emailValues.map[json["email"]]!,
  );

  Map<String, dynamic> toJson() => {
    "_id": idValues.reverse[id],
    "email": emailValues.reverse[email],
  };
}

enum Email {
  SAJIV_GMAIL_COM,
  SKP_GMAIL_COM
}

final emailValues = EnumValues({
  "sajiv@gmail.com": Email.SAJIV_GMAIL_COM,
  "skp@gmail.com": Email.SKP_GMAIL_COM
});

enum Id {
  THE_68_E5_F744_D1777_FDD770_CC78_D,
  THE_6918_AF8_E82_F491_A26_F3_A7_C57
}

final idValues = EnumValues({
  "68e5f744d1777fdd770cc78d": Id.THE_68_E5_F744_D1777_FDD770_CC78_D,
  "6918af8e82f491a26f3a7c57": Id.THE_6918_AF8_E82_F491_A26_F3_A7_C57
});

class Pagination {
  int? page;
  int? limit;
  int? total;
  int? totalPages;

  Pagination({
    this.page,
    this.limit,
    this.total,
    this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    page: json["page"],
    limit: json["limit"],
    total: json["total"],
    totalPages: json["totalPages"],
  );

  Map<String, dynamic> toJson() => {
    "page": page,
    "limit": limit,
    "total": total,
    "totalPages": totalPages,
  };
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
*/



// To parse this JSON data, do
//
//     final qrTransactionHistoryModel = qrTransactionHistoryModelFromJson(jsonString);

import 'dart:convert';

QrTransactionHistoryModel qrTransactionHistoryModelFromJson(String str) => QrTransactionHistoryModel.fromJson(json.decode(str));

String qrTransactionHistoryModelToJson(QrTransactionHistoryModel data) => json.encode(data.toJson());

class QrTransactionHistoryModel {
  String? message;
  int? code;
  bool? error;
  Data? data;

  QrTransactionHistoryModel({
    this.message,
    this.code,
    this.error,
    this.data,
  });

  factory QrTransactionHistoryModel.fromJson(Map<String, dynamic> json) => QrTransactionHistoryModel(
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
  List<Datum>? data;
  Pagination? pagination;

  Data({
    this.data,
    this.pagination,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
    pagination: json["pagination"] == null ? null : Pagination.fromJson(json["pagination"]),
  );

  Map<String, dynamic> toJson() => {
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    "pagination": pagination?.toJson(),
  };
}

class Datum {
  String? id;
  Sender? sender;
  dynamic receiver;
  String? txType;
  String? status;
  int? amount;
  String? reason;
  bool? isDisable;
  bool? isDeleted;
  int? date;
  int? month;
  int? year;
  int? createdAt;
  int? updatedAt;
  int? v;

  Datum({
    this.id,
    this.sender,
    this.receiver,
    this.txType,
    this.status,
    this.amount,
    this.reason,
    this.isDisable,
    this.isDeleted,
    this.date,
    this.month,
    this.year,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["_id"],
    sender: json["sender"] == null ? null : Sender.fromJson(json["sender"]),
    receiver: json["receiver"],
    txType: json["txType"],
    status: json["status"],
    amount: json["amount"],
    reason: json["reason"],
    isDisable: json["isDisable"],
    isDeleted: json["isDeleted"],
    date: json["date"],
    month: json["month"],
    year: json["year"],
    createdAt: json["createdAt"],
    updatedAt: json["updatedAt"],
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "sender": sender?.toJson(),
    "receiver": receiver,
    "txType": txType,
    "status": status,
    "amount": amount,
    "reason": reason,
    "isDisable": isDisable,
    "isDeleted": isDeleted,
    "date": date,
    "month": month,
    "year": year,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
    "__v": v,
  };
}

class Sender {
  String? id;
  String? userType;
  String? lastName;
  String? email;

  Sender({
    this.id,
    this.userType,
    this.lastName,
    this.email,
  });

  factory Sender.fromJson(Map<String, dynamic> json) => Sender(
    id: json["_id"],
    userType: json["userType"],
    lastName: json["lastName"],
    email: json["email"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "userType": userType,
    "lastName": lastName,
    "email": email,
  };
}

class Pagination {
  int? page;
  int? limit;
  int? total;
  int? totalPages;

  Pagination({
    this.page,
    this.limit,
    this.total,
    this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    page: json["page"],
    limit: json["limit"],
    total: json["total"],
    totalPages: json["totalPages"],
  );

  Map<String, dynamic> toJson() => {
    "page": page,
    "limit": limit,
    "total": total,
    "totalPages": totalPages,
  };
}
