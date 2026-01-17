/*
// To parse this JSON data, do
//
//     final deliverCompleteResModel = deliverCompleteResModelFromJson(jsonString);

import 'dart:convert';

DeliverCompleteResModel deliverCompleteResModelFromJson(String str) => DeliverCompleteResModel.fromJson(json.decode(str));

String deliverCompleteResModelToJson(DeliverCompleteResModel data) => json.encode(data.toJson());

class DeliverCompleteResModel {
  String message;
  int code;
  bool error;
  Data data;

  DeliverCompleteResModel({
    required this.message,
    required this.code,
    required this.error,
    required this.data,
  });

  factory DeliverCompleteResModel.fromJson(Map<String, dynamic> json) => DeliverCompleteResModel(
    message: json["message"],
    code: json["code"],
    error: json["error"],
    data: Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "code": code,
    "error": error,
    "data": data.toJson(),
  };
}

class Data {
  Dropoff pickup;
  Dropoff dropoff;
  PackageDetails packageDetails;
  String id;
  String customer;
  String deliveryBoy;
  dynamic pendingDriver;
  String vehicleTypeId;
  bool isCopanCode;
  int copanAmount;
  int coinAmount;
  int taxAmount;
  int userPayAmount;
  double distance;
  String mobNo;
  String picUpType;
  String name;
  String status;
  dynamic cancellationReason;
  String paymentMethod;
  String image;
  bool isDisable;
  bool isDeleted;
  String txId;
  int date;
  int month;
  int year;
  int createdAt;
  int updatedAt;

  Data({
    required this.pickup,
    required this.dropoff,
    required this.packageDetails,
    required this.id,
    required this.customer,
    required this.deliveryBoy,
    required this.pendingDriver,
    required this.vehicleTypeId,
    required this.isCopanCode,
    required this.copanAmount,
    required this.coinAmount,
    required this.taxAmount,
    required this.userPayAmount,
    required this.distance,
    required this.mobNo,
    required this.picUpType,
    required this.name,
    required this.status,
    required this.cancellationReason,
    required this.paymentMethod,
    required this.image,
    required this.isDisable,
    required this.isDeleted,
    required this.txId,
    required this.date,
    required this.month,
    required this.year,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    pickup: Dropoff.fromJson(json["pickup"]),
    dropoff: Dropoff.fromJson(json["dropoff"]),
    packageDetails: PackageDetails.fromJson(json["packageDetails"]),
    id: json["_id"],
    customer: json["customer"],
    deliveryBoy: json["deliveryBoy"],
    pendingDriver: json["pendingDriver"],
    vehicleTypeId: json["vehicleTypeId"],
    isCopanCode: json["isCopanCode"],
    copanAmount: json["copanAmount"],
    coinAmount: json["coinAmount"],
    taxAmount: json["taxAmount"],
    userPayAmount: json["userPayAmount"],
    distance: json["distance"]?.toDouble(),
    mobNo: json["mobNo"],
    picUpType: json["picUpType"],
    name: json["name"],
    status: json["status"],
    cancellationReason: json["cancellationReason"],
    paymentMethod: json["paymentMethod"],
    image: json["image"],
    isDisable: json["isDisable"],
    isDeleted: json["isDeleted"],
    txId: json["txId"],
    date: json["date"],
    month: json["month"],
    year: json["year"],
    createdAt: json["createdAt"],
    updatedAt: json["updatedAt"],
  );

  Map<String, dynamic> toJson() => {
    "pickup": pickup.toJson(),
    "dropoff": dropoff.toJson(),
    "packageDetails": packageDetails.toJson(),
    "_id": id,
    "customer": customer,
    "deliveryBoy": deliveryBoy,
    "pendingDriver": pendingDriver,
    "vehicleTypeId": vehicleTypeId,
    "isCopanCode": isCopanCode,
    "copanAmount": copanAmount,
    "coinAmount": coinAmount,
    "taxAmount": taxAmount,
    "userPayAmount": userPayAmount,
    "distance": distance,
    "mobNo": mobNo,
    "picUpType": picUpType,
    "name": name,
    "status": status,
    "cancellationReason": cancellationReason,
    "paymentMethod": paymentMethod,
    "image": image,
    "isDisable": isDisable,
    "isDeleted": isDeleted,
    "txId": txId,
    "date": date,
    "month": month,
    "year": year,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
  };
}

class Dropoff {
  String name;
  double lat;
  double long;

  Dropoff({
    required this.name,
    required this.lat,
    required this.long,
  });

  factory Dropoff.fromJson(Map<String, dynamic> json) => Dropoff(
    name: json["name"],
    lat: json["lat"]?.toDouble(),
    long: json["long"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "lat": lat,
    "long": long,
  };
}

class PackageDetails {
  bool fragile;

  PackageDetails({
    required this.fragile,
  });

  factory PackageDetails.fromJson(Map<String, dynamic> json) => PackageDetails(
    fragile: json["fragile"],
  );

  Map<String, dynamic> toJson() => {
    "fragile": fragile,
  };
}*//*



import 'dart:convert';

DeliverCompleteResModel deliverCompleteResModelFromJson(String str) =>
    DeliverCompleteResModel.fromJson(json.decode(str));

String deliverCompleteResModelToJson(DeliverCompleteResModel data) =>
    json.encode(data.toJson());

class DeliverCompleteResModel {
  String message;
  int code;
  bool error;
  Data data;

  DeliverCompleteResModel({
    required this.message,
    required this.code,
    required this.error,
    required this.data,
  });

  factory DeliverCompleteResModel.fromJson(Map<String, dynamic> json) =>
      DeliverCompleteResModel(
        message: json["message"] ?? "",
        code: json["code"] ?? 1,
        error: json["error"] ?? true,
        data: Data.fromJson(json["data"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "code": code,
    "error": error,
    "data": data.toJson(),
  };
}

class Data {
  Dropoff pickup;
  List<Dropoff> dropoff; // ← YEH CHANGE HAI: List<Dropoff>
  PackageDetails packageDetails;
  String id;
  String customer;
  String deliveryBoy;
  dynamic pendingDriver;
  String vehicleTypeId;
  bool isCopanCode;
  int copanAmount;
  int coinAmount;
  int taxAmount;
  int userPayAmount;
  double distance;
  String mobNo;
  String picUpType;
  String name;
  String status;
  dynamic cancellationReason;
  String paymentMethod;
  String image;
  bool isDisable;
  bool isDeleted;
  String txId;
  int date;
  int month;
  int year;
  int createdAt;
  int updatedAt;
  String? otp; // Extra field jo response mein aa raha hai

  Data({
    required this.pickup,
    required this.dropoff,
    required this.packageDetails,
    required this.id,
    required this.customer,
    required this.deliveryBoy,
    this.pendingDriver,
    required this.vehicleTypeId,
    required this.isCopanCode,
    required this.copanAmount,
    required this.coinAmount,
    required this.taxAmount,
    required this.userPayAmount,
    required this.distance,
    required this.mobNo,
    required this.picUpType,
    required this.name,
    required this.status,
    this.cancellationReason,
    required this.paymentMethod,
    required this.image,
    required this.isDisable,
    required this.isDeleted,
    required this.txId,
    required this.date,
    required this.month,
    required this.year,
    required this.createdAt,
    required this.updatedAt,
    this.otp,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    var dropoffList = <Dropoff>[];

    // Handle both single object and list
    if (json["dropoff"] is List) {
      dropoffList = List<Dropoff>.from(
        (json["dropoff"] as List).map((x) => Dropoff.fromJson(x)),
      );
    } else if (json["dropoff"] != null) {
      // If single object (old format)
      dropoffList.add(Dropoff.fromJson(json["dropoff"]));
    }

    return Data(
      pickup: Dropoff.fromJson(json["pickup"] ?? {}),
      dropoff: dropoffList,
      packageDetails: PackageDetails.fromJson(json["packageDetails"] ?? {}),
      id: json["_id"] ?? "",
      customer: json["customer"] ?? "",
      deliveryBoy: json["deliveryBoy"] ?? "",
      pendingDriver: json["pendingDriver"],
      vehicleTypeId: json["vehicleTypeId"] ?? "",
      isCopanCode: json["isCopanCode"] ?? false,
      copanAmount: json["copanAmount"] ?? 0,
      coinAmount: json["coinAmount"] ?? 0,
      taxAmount: json["taxAmount"] ?? 0,
      userPayAmount: json["userPayAmount"] ?? 0,
      distance: (json["distance"] ?? 0.0).toDouble(),
      mobNo: json["mobNo"] ?? "",
      picUpType: json["picUpType"] ?? "",
      name: json["name"] ?? "",
      status: json["status"] ?? "",
      cancellationReason: json["cancellationReason"],
      paymentMethod: json["paymentMethod"] ?? "",
      image: json["image"] ?? "",
      isDisable: json["isDisable"] ?? false,
      isDeleted: json["isDeleted"] ?? false,
      txId: json["txId"] ?? "",
      date: json["date"] ?? 0,
      month: json["month"] ?? 0,
      year: json["year"] ?? 0,
      createdAt: json["createdAt"] ?? 0,
      updatedAt: json["updatedAt"] ?? 0,
      otp: json["otp"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    "pickup": pickup.toJson(),
    "dropoff": List<dynamic>.from(dropoff.map((x) => x.toJson())),
    "packageDetails": packageDetails.toJson(),
    "_id": id,
    "customer": customer,
    "deliveryBoy": deliveryBoy,
    "pendingDriver": pendingDriver,
    "vehicleTypeId": vehicleTypeId,
    "isCopanCode": isCopanCode,
    "copanAmount": copanAmount,
    "coinAmount": coinAmount,
    "taxAmount": taxAmount,
    "userPayAmount": userPayAmount,
    "distance": distance,
    "mobNo": mobNo,
    "picUpType": picUpType,
    "name": name,
    "status": status,
    "cancellationReason": cancellationReason,
    "paymentMethod": paymentMethod,
    "image": image,
    "otp": otp,
    "isDisable": isDisable,
    "isDeleted": isDeleted,
    "txId": txId,
    "date": date,
    "month": month,
    "year": year,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
  };
}

class Dropoff {
  String name;
  double lat;
  double long;
  String? id; // Extra _id field jo list mein aa raha hai

  Dropoff({
    required this.name,
    required this.lat,
    required this.long,
    this.id,
  });

  factory Dropoff.fromJson(Map<String, dynamic> json) => Dropoff(
    name: json["name"] ?? "Unknown Location",
    lat: (json["lat"] ?? 0.0).toDouble(),
    long: (json["long"] ?? 0.0).toDouble(),
    id: json["_id"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "lat": lat,
    "long": long,
    "_id": id,
  };
}

class PackageDetails {
  bool fragile;

  PackageDetails({required this.fragile});

  factory PackageDetails.fromJson(Map<String, dynamic> json) => PackageDetails(
    fragile: json["fragile"] ?? false,
  );

  Map<String, dynamic> toJson() => {
    "fragile": fragile,
  };
}*/




// To parse this JSON data, do
//
//     final deliverCompleteResModel = deliverCompleteResModelFromJson(jsonString);

import 'dart:convert';

DeliverCompleteResModel deliverCompleteResModelFromJson(String str) => DeliverCompleteResModel.fromJson(json.decode(str));

String deliverCompleteResModelToJson(DeliverCompleteResModel data) => json.encode(data.toJson());

class DeliverCompleteResModel {
  String? message;
  int? code;
  bool? error;
  Data? data;

  DeliverCompleteResModel({
    this.message,
    this.code,
    this.error,
    this.data,
  });

  factory DeliverCompleteResModel.fromJson(Map<String, dynamic> json) => DeliverCompleteResModel(
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
  Delivery? delivery;
  int? previousAmount;
  int? extraWaitingMinutes;
  int? extraWaitingCharge;
  int? freeWaitingTime;
  int? totalWaitingTime;
  int? totalAmount;

  Data({
    this.delivery,
    this.previousAmount,
    this.extraWaitingMinutes,
    this.extraWaitingCharge,
    this.freeWaitingTime,
    this.totalAmount,
    this.totalWaitingTime,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    delivery: json["delivery"] == null ? null : Delivery.fromJson(json["delivery"]),
    previousAmount: json["previousAmount"],
    extraWaitingMinutes: json["extraWaitingMinutes"],
    extraWaitingCharge: json["extraWaitingCharge"],
    freeWaitingTime: json["freeWaitingTime"],
    totalAmount: json["totalAmount"],
    totalWaitingTime: json["totalWaitingTime"],
  );

  Map<String, dynamic> toJson() => {
    "delivery": delivery?.toJson(),
    "previousAmount": previousAmount,
    "extraWaitingMinutes": extraWaitingMinutes,
    "extraWaitingCharge": extraWaitingCharge,
    "freeWaitingTime": freeWaitingTime,
    "totalAmount": totalAmount,
    "totalWaitingTime": totalWaitingTime,
  };
}

class Delivery {
  Pickup? pickup;
  PackageDetails? packageDetails;
  String? id;
  String? customer;
  String? deliveryBoy;
  dynamic pendingDriver;
  String? vehicleTypeId;
  List<dynamic>? rejectedDeliveryBoy;
  bool? isCopanCode;
  int? copanAmount;
  int? coinAmount;
  int? taxAmount;
  int? userPayAmount;
  int? distance;
  String? mobNo;
  String? picUpType;
  String? name;
  List<Pickup>? dropoff;
  String? status;
  dynamic cancellationReason;
  String? paymentMethod;
  String? image;
  String? otp;
  int? arrivedAt;
  int? pickedAt;
  int? freeWaitingTime;
  int? totalWaitingTime;
  int? extraWaitingMinutes;
  int? extraWaitingCharge;
  int? previousAmount;
  bool? isDisable;
  bool? isDeleted;
  String? txId;
  int? date;
  int? month;
  int? year;
  int? createdAt;
  int? updatedAt;

  Delivery({
    this.pickup,
    this.packageDetails,
    this.id,
    this.customer,
    this.deliveryBoy,
    this.pendingDriver,
    this.vehicleTypeId,
    this.rejectedDeliveryBoy,
    this.isCopanCode,
    this.copanAmount,
    this.coinAmount,
    this.taxAmount,
    this.userPayAmount,
    this.distance,
    this.mobNo,
    this.picUpType,
    this.name,
    this.dropoff,
    this.status,
    this.cancellationReason,
    this.paymentMethod,
    this.image,
    this.otp,
    this.arrivedAt,
    this.pickedAt,
    this.freeWaitingTime,
    this.totalWaitingTime,
    this.extraWaitingMinutes,
    this.extraWaitingCharge,
    this.previousAmount,
    this.isDisable,
    this.isDeleted,
    this.txId,
    this.date,
    this.month,
    this.year,
    this.createdAt,
    this.updatedAt,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) => Delivery(
    pickup: json["pickup"] == null ? null : Pickup.fromJson(json["pickup"]),
    packageDetails: json["packageDetails"] == null ? null : PackageDetails.fromJson(json["packageDetails"]),
    id: json["_id"],
    customer: json["customer"],
    deliveryBoy: json["deliveryBoy"],
    pendingDriver: json["pendingDriver"],
    vehicleTypeId: json["vehicleTypeId"],
    rejectedDeliveryBoy: json["rejectedDeliveryBoy"] == null ? [] : List<dynamic>.from(json["rejectedDeliveryBoy"]!.map((x) => x)),
    isCopanCode: json["isCopanCode"],
    copanAmount: json["copanAmount"],
    coinAmount: json["coinAmount"],
    taxAmount: json["taxAmount"],
    userPayAmount: json["userPayAmount"],
    distance: json["distance"],
    mobNo: json["mobNo"],
    picUpType: json["picUpType"],
    name: json["name"],
    dropoff: json["dropoff"] == null ? [] : List<Pickup>.from(json["dropoff"]!.map((x) => Pickup.fromJson(x))),
    status: json["status"],
    cancellationReason: json["cancellationReason"],
    paymentMethod: json["paymentMethod"],
    image: json["image"],
    otp: json["otp"],
    arrivedAt: json["arrivedAt"],
    pickedAt: json["pickedAt"],
    freeWaitingTime: json["freeWaitingTime"],
    totalWaitingTime: json["totalWaitingTime"],
    extraWaitingMinutes: json["extraWaitingMinutes"],
    extraWaitingCharge: json["extraWaitingCharge"],
    previousAmount: json["previousAmount"],
    isDisable: json["isDisable"],
    isDeleted: json["isDeleted"],
    txId: json["txId"],
    date: json["date"],
    month: json["month"],
    year: json["year"],
    createdAt: json["createdAt"],
    updatedAt: json["updatedAt"],
  );

  Map<String, dynamic> toJson() => {
    "pickup": pickup?.toJson(),
    "packageDetails": packageDetails?.toJson(),
    "_id": id,
    "customer": customer,
    "deliveryBoy": deliveryBoy,
    "pendingDriver": pendingDriver,
    "vehicleTypeId": vehicleTypeId,
    "rejectedDeliveryBoy": rejectedDeliveryBoy == null ? [] : List<dynamic>.from(rejectedDeliveryBoy!.map((x) => x)),
    "isCopanCode": isCopanCode,
    "copanAmount": copanAmount,
    "coinAmount": coinAmount,
    "taxAmount": taxAmount,
    "userPayAmount": userPayAmount,
    "distance": distance,
    "mobNo": mobNo,
    "picUpType": picUpType,
    "name": name,
    "dropoff": dropoff == null ? [] : List<dynamic>.from(dropoff!.map((x) => x.toJson())),
    "status": status,
    "cancellationReason": cancellationReason,
    "paymentMethod": paymentMethod,
    "image": image,
    "otp": otp,
    "arrivedAt": arrivedAt,
    "pickedAt": pickedAt,
    "freeWaitingTime": freeWaitingTime,
    "totalWaitingTime": totalWaitingTime,
    "extraWaitingMinutes": extraWaitingMinutes,
    "extraWaitingCharge": extraWaitingCharge,
    "previousAmount": previousAmount,
    "isDisable": isDisable,
    "isDeleted": isDeleted,
    "txId": txId,
    "date": date,
    "month": month,
    "year": year,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
  };
}

class Pickup {
  String? name;
  double? lat;
  double? long;
  String? id;

  Pickup({
    this.name,
    this.lat,
    this.long,
    this.id,
  });

  factory Pickup.fromJson(Map<String, dynamic> json) => Pickup(
    name: json["name"],
    lat: json["lat"]?.toDouble(),
    long: json["long"]?.toDouble(),
    id: json["_id"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "lat": lat,
    "long": long,
    "_id": id,
  };
}

class PackageDetails {
  bool? fragile;

  PackageDetails({
    this.fragile,
  });

  factory PackageDetails.fromJson(Map<String, dynamic> json) => PackageDetails(
    fragile: json["fragile"],
  );

  Map<String, dynamic> toJson() => {
    "fragile": fragile,
  };
}
