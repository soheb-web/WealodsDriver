/*
// To parse this JSON data, do
//
//     final deliveryHistoryResponseModel = deliveryHistoryResponseModelFromJson(jsonString);

import 'dart:convert';

DeliveryHistoryResponseModel deliveryHistoryResponseModelFromJson(String str) => DeliveryHistoryResponseModel.fromJson(json.decode(str));

String deliveryHistoryResponseModelToJson(DeliveryHistoryResponseModel data) => json.encode(data.toJson());

class DeliveryHistoryResponseModel {
  String? message;
  int? code;
  bool? error;
  Data? data;

  DeliveryHistoryResponseModel({
    this.message,
    this.code,
    this.error,
    this.data,
  });

  factory DeliveryHistoryResponseModel.fromJson(Map<String, dynamic> json) => DeliveryHistoryResponseModel(
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
  int? totalCount;
  List<Delivery>? deliveries;

  Data({
    this.totalCount,
    this.deliveries,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    totalCount: json["totalCount"],
    deliveries: json["deliveries"] == null ? [] : List<Delivery>.from(json["deliveries"]!.map((x) => Delivery.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "totalCount": totalCount,
    "deliveries": deliveries == null ? [] : List<dynamic>.from(deliveries!.map((x) => x.toJson())),
  };
}

class Delivery {
  Pickup? pickup;
  PackageDetails? packageDetails;
  String? id;
  Customer? customer;
  DeliveryBoy? deliveryBoy;
  dynamic pendingDriver;
  VehicleTypeId? vehicleTypeId;
  List<dynamic>? rejectedDeliveryBoy;
  bool? isCopanCode;
  int? copanAmount;
  int? coinAmount;
  int? taxAmount;
  int? userPayAmount;
  double? distance;
  String? mobNo;
  String? picUpType;
  String? name;
  List<Pickup>? dropoff;
  String? status;
  String? cancellationReason;
  PaymentMethod? paymentMethod;
  String? image;
  String? otp;
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
    customer: customerValues.map[json["customer"]]!,
    deliveryBoy: deliveryBoyValues.map[json["deliveryBoy"]]!,
    pendingDriver: json["pendingDriver"],
    vehicleTypeId: vehicleTypeIdValues.map[json["vehicleTypeId"]]!,
    rejectedDeliveryBoy: json["rejectedDeliveryBoy"] == null ? [] : List<dynamic>.from(json["rejectedDeliveryBoy"]!.map((x) => x)),
    isCopanCode: json["isCopanCode"],
    copanAmount: json["copanAmount"],
    coinAmount: json["coinAmount"],
    taxAmount: json["taxAmount"],
    userPayAmount: json["userPayAmount"],
    distance: json["distance"]?.toDouble(),
    mobNo: json["mobNo"],
    picUpType: json["picUpType"],
    name: json["name"]!,
    dropoff: json["dropoff"] == null ? [] : List<Pickup>.from(json["dropoff"]!.map((x) => Pickup.fromJson(x))),
    status: json["status"]!,
    cancellationReason: json["cancellationReason"],
    paymentMethod: paymentMethodValues.map[json["paymentMethod"]]!,
    image: json["image"],
    otp: json["otp"],
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
    "customer": customerValues.reverse[customer],
    "deliveryBoy": deliveryBoyValues.reverse[deliveryBoy],
    "pendingDriver": pendingDriver,
    "vehicleTypeId": vehicleTypeIdValues.reverse[vehicleTypeId],
    "rejectedDeliveryBoy": rejectedDeliveryBoy == null ? [] : List<dynamic>.from(rejectedDeliveryBoy!.map((x) => x)),
    "isCopanCode": isCopanCode,
    "copanAmount": copanAmount,
    "coinAmount": coinAmount,
    "taxAmount": taxAmount,
    "userPayAmount": userPayAmount,
    "distance": distance,
    "mobNo": mobNo,
    "picUpType": picUpType,
    "name": nameValues.reverse[name],
    "dropoff": dropoff == null ? [] : List<dynamic>.from(dropoff!.map((x) => x.toJson())),
    "status": statusValues.reverse[status],
    "cancellationReason": cancellationReason,
    "paymentMethod": paymentMethodValues.reverse[paymentMethod],
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

enum Customer {
  THE_68_E5_F744_D1777_FDD770_CC78_D
}

final customerValues = EnumValues({
  "68e5f744d1777fdd770cc78d": Customer.THE_68_E5_F744_D1777_FDD770_CC78_D
});

enum DeliveryBoy {
  THE_68_F87_C3_B40938_D4_D2_F2_EB341
}

final deliveryBoyValues = EnumValues({
  "68f87c3b40938d4d2f2eb341": DeliveryBoy.THE_68_F87_C3_B40938_D4_D2_F2_EB341
});

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

enum Name {
  NMBKJ,
  SAJIV
}

final nameValues = EnumValues({
  "nmbkj": Name.NMBKJ,
  "sajiv": Name.SAJIV
});

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

enum PaymentMethod {
  CASH
}

final paymentMethodValues = EnumValues({
  "cash": PaymentMethod.CASH
});

enum Status {
  ASSIGNED,
  CANCELLED_BY_DRIVER,
  CANCELLED_BY_USER,
  COMPLETED,
  ONGOING
}

final statusValues = EnumValues({
  "assigned": Status.ASSIGNED,
  "cancelled_by_driver": Status.CANCELLED_BY_DRIVER,
  "cancelled_by_user": Status.CANCELLED_BY_USER,
  "completed": Status.COMPLETED,
  "ongoing": Status.ONGOING
});

enum VehicleTypeId {
  THE_68_CE84_D4_E9401176157710_EF,
  THE_68_CE8516_E9401176157710_F3,
  THE_68_CE853_BE9401176157710_F7,
  THE_68_CE8594_E9401176157710_FB
}

final vehicleTypeIdValues = EnumValues({
  "68ce84d4e9401176157710ef": VehicleTypeId.THE_68_CE84_D4_E9401176157710_EF,
  "68ce8516e9401176157710f3": VehicleTypeId.THE_68_CE8516_E9401176157710_F3,
  "68ce853be9401176157710f7": VehicleTypeId.THE_68_CE853_BE9401176157710_F7,
  "68ce8594e9401176157710fb": VehicleTypeId.THE_68_CE8594_E9401176157710_FB
});

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


// delivery_history_response_model.dart
import 'dart:convert';

DeliveryHistoryResponseModel deliveryHistoryResponseModelFromJson(String str) =>
    DeliveryHistoryResponseModel.fromJson(json.decode(str));

String deliveryHistoryResponseModelToJson(DeliveryHistoryResponseModel data) =>
    json.encode(data.toJson());

class DeliveryHistoryResponseModel {
  String? message;
  int? code;
  bool? error;
  Data? data;

  DeliveryHistoryResponseModel({this.message, this.code, this.error, this.data});

  factory DeliveryHistoryResponseModel.fromJson(Map<String, dynamic> json) =>
      DeliveryHistoryResponseModel(
        message: json["message"]?.toString(),
        code: json["code"] is int ? json["code"] : null,
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
  int? totalCount;
  List<Delivery>? deliveries;

  Data({this.totalCount, this.deliveries});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    totalCount: json["totalCount"] is int ? json["totalCount"] : null,
    deliveries: json["deliveries"] == null
        ? []
        : List<Delivery>.from(
        json["deliveries"].map((x) => Delivery.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "totalCount": totalCount,
    "deliveries": deliveries == null
        ? []
        : List<dynamic>.from(deliveries!.map((x) => x.toJson())),
  };
}

class Delivery {
  Pickup? pickup;
  PackageDetails? packageDetails;
  String? id;
  String? customer; // Enum ki jagah String rakha safe ke liye
  String? deliveryBoy;
  dynamic pendingDriver;
  String? vehicleTypeId;
  List<dynamic>? rejectedDeliveryBoy;
  bool? isCopanCode;
  int? copanAmount;
  int? coinAmount;
  int? taxAmount;
  int? userPayAmount;
  double? distance;
  String? mobNo;
  String? picUpType;
  String? name;
  List<Pickup>? dropoff;
  String? status;
  String? cancellationReason;
  String? paymentMethod;
  String? image;
  String? otp;
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
    this.isDisable,
    this.isDeleted,
    this.txId,
    this.date,
    this.month,
    this.year,
    this.createdAt,
    this.updatedAt,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      pickup: json["pickup"] == null ? null : Pickup.fromJson(json["pickup"]),
      packageDetails: json["packageDetails"] == null
          ? null
          : PackageDetails.fromJson(json["packageDetails"]),
      id: json["_id"]?.toString(),
      customer: json["customer"]?.toString(),
      deliveryBoy: json["deliveryBoy"]?.toString(),
      pendingDriver: json["pendingDriver"],
      vehicleTypeId: json["vehicleTypeId"]?.toString(),
      rejectedDeliveryBoy: json["rejectedDeliveryBoy"] == null
          ? []
          : List<dynamic>.from(json["rejectedDeliveryBoy"]),
      isCopanCode: json["isCopanCode"] is bool ? json["isCopanCode"] : null,
      copanAmount: json["copanAmount"] is int ? json["copanAmount"] : null,
      coinAmount: json["coinAmount"] is int ? json["coinAmount"] : null,
      taxAmount: json["taxAmount"] is int ? json["taxAmount"] : null,
      userPayAmount: json["userPayAmount"] is int ? json["userPayAmount"] : null,
      distance: json["distance"] is num ? json["distance"].toDouble() : null,
      mobNo: json["mobNo"]?.toString(),
      picUpType: json["picUpType"]?.toString(),
      name: json["name"]?.toString(),           // ← SAFE NOW (no !)
      dropoff: json["dropoff"] == null
          ? []
          : List<Pickup>.from(json["dropoff"].map((x) => Pickup.fromJson(x))),
      status: json["status"]?.toString(),       // ← SAFE NOW (no !)
      cancellationReason: json["cancellationReason"]?.toString(),
      paymentMethod: json["paymentMethod"]?.toString(),
      image: json["image"]?.toString(),
      otp: json["otp"]?.toString(),
      isDisable: json["isDisable"] is bool ? json["isDisable"] : null,
      isDeleted: json["isDeleted"] is bool ? json["isDeleted"] : null,
      txId: json["txId"]?.toString(),
      date: json["date"] is int ? json["date"] : null,
      month: json["month"] is int ? json["month"] : null,
      year: json["year"] is int ? json["year"] : null,
      createdAt: json["createdAt"] is int ? json["createdAt"] : null,
      updatedAt: json["updatedAt"] is int ? json["updatedAt"] : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "pickup": pickup?.toJson(),
    "packageDetails": packageDetails?.toJson(),
    "_id": id,
    "customer": customer,
    "deliveryBoy": deliveryBoy,
    "pendingDriver": pendingDriver,
    "vehicleTypeId": vehicleTypeId,
    "rejectedDeliveryBoy": rejectedDeliveryBoy ?? [],
    "isCopanCode": isCopanCode,
    "copanAmount": copanAmount,
    "coinAmount": coinAmount,
    "taxAmount": taxAmount,
    "userPayAmount": userPayAmount,
    "distance": distance,
    "mobNo": mobNo,
    "picUpType": picUpType,
    "name": name,
    "dropoff": dropoff == null ? [] : dropoff!.map((x) => x.toJson()).toList(),
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

class Pickup {
  String? name;
  double? lat;
  double? long;
  String? id;

  Pickup({this.name, this.lat, this.long, this.id});

  factory Pickup.fromJson(Map<String, dynamic> json) => Pickup(
    name: json["name"]?.toString(),
    lat: json["lat"] is num ? json["lat"].toDouble() : null,
    long: json["long"] is num ? json["long"].toDouble() : null,
    id: json["_id"]?.toString(),
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

  PackageDetails({this.fragile});

  factory PackageDetails.fromJson(Map<String, dynamic> json) => PackageDetails(
    fragile: json["fragile"] is bool ? json["fragile"] : null,
  );

  Map<String, dynamic> toJson() => {"fragile": fragile};
}