/*
// To parse this JSON data, do
//
//     final deliveryHistoryResponseModel = DeliveryHistoryResponseModelFromJson(jsonString);


import 'dart:convert';

DeliveryHistoryResponseModel DeliveryHistoryResponseModelFromJson(String str) => DeliveryHistoryResponseModel.fromJson(json.decode(str));

String DeliveryHistoryResponseModelToJson(DeliveryHistoryResponseModel data) => json.encode(data.toJson());

class DeliveryHistoryResponseModel {
  String message;
  int code;
  bool error;
  Data data;

  DeliveryHistoryResponseModel({
    required this.message,
    required this.code,
    required this.error,
    required this.data,
  });

  factory DeliveryHistoryResponseModel.fromJson(Map<String, dynamic> json) => DeliveryHistoryResponseModel(
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
  int totalCount;
  List<Delivery> deliveries;

  Data({
    required this.totalCount,
    required this.deliveries,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    totalCount: json["totalCount"],
    deliveries: List<Delivery>.from(json["deliveries"].map((x) => Delivery.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "totalCount": totalCount,
    "deliveries": List<dynamic>.from(deliveries.map((x) => x.toJson())),
  };
}

class Delivery {
  Pickup pickup;
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
  dynamic image;
  bool isDisable;
  bool isDeleted;
  String txId;
  int date;
  int month;
  int year;
  int createdAt;
  int updatedAt;

  Delivery({
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

  factory Delivery.fromJson(Map<String, dynamic> json) => Delivery(
    pickup: Pickup.fromJson(json["pickup"]),
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
}

class Pickup {
  String name;
  double lat;
  double long;

  Pickup({
    required this.name,
    required this.lat,
    required this.long,
  });

  factory Pickup.fromJson(Map<String, dynamic> json) => Pickup(
    name: json["name"],
    lat: json["lat"]?.toDouble(),
    long: json["long"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "lat": lat,
    "long": long,
  };
}*/
// To parse this JSON data, do
//
//     final deliveryHistoryResponseModel = deliveryHistoryResponseModelFromJson(jsonString);

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

  DeliveryHistoryResponseModel({
    this.message,
    this.code,
    this.error,
    this.data,
  });

  factory DeliveryHistoryResponseModel.fromJson(Map<String, dynamic> json) =>
      DeliveryHistoryResponseModel(
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

  Data({this.totalCount, this.deliveries});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    totalCount: json["totalCount"],
    deliveries: json["deliveries"] == null
        ? []
        : List<Delivery>.from(
            json["deliveries"]!.map((x) => Delivery.fromJson(x)),
          ),
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
  // Name? name;
  String? name;
  List<Pickup>? dropoff;
  // Status? status;
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
    packageDetails: json["packageDetails"] == null
        ? null
        : PackageDetails.fromJson(json["packageDetails"]),
    id: json["_id"],
    customer: customerValues.map[json["customer"]]!,
    deliveryBoy: deliveryBoyValues.map[json["deliveryBoy"]]!,
    pendingDriver: json["pendingDriver"],
    vehicleTypeId: vehicleTypeIdValues.map[json["vehicleTypeId"]]!,
    rejectedDeliveryBoy: json["rejectedDeliveryBoy"] == null
        ? []
        : List<dynamic>.from(json["rejectedDeliveryBoy"]!.map((x) => x)),
    isCopanCode: json["isCopanCode"],
    copanAmount: json["copanAmount"],
    coinAmount: json["coinAmount"],
    taxAmount: json["taxAmount"],
    userPayAmount: json["userPayAmount"],
    distance: json["distance"]?.toDouble(),
    mobNo: json["mobNo"],
    picUpType: json["picUpType"],
    // name: nameValues.map[json["name"]]!,
    name: json['name'],
    dropoff: json["dropoff"] == null
        ? []
        : List<Pickup>.from(json["dropoff"]!.map((x) => Pickup.fromJson(x))),
    // status: statusValues.map[json["status"]]!,
    status: json['status'],
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
    "rejectedDeliveryBoy": rejectedDeliveryBoy == null
        ? []
        : List<dynamic>.from(rejectedDeliveryBoy!.map((x) => x)),
    "isCopanCode": isCopanCode,
    "copanAmount": copanAmount,
    "coinAmount": coinAmount,
    "taxAmount": taxAmount,
    "userPayAmount": userPayAmount,
    "distance": distance,
    "mobNo": mobNo,
    "picUpType": picUpType,
    // "name": nameValues.reverse[name],
    "name": name,
    "dropoff": dropoff == null
        ? []
        : List<dynamic>.from(dropoff!.map((x) => x.toJson())),
    // "status": statusValues.reverse[status],
    "status": status,
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

enum Customer { THE_68_E5_F744_D1777_FDD770_CC78_D }

final customerValues = EnumValues({
  "68e5f744d1777fdd770cc78d": Customer.THE_68_E5_F744_D1777_FDD770_CC78_D,
});

enum DeliveryBoy { THE_68_F87_C3_B40938_D4_D2_F2_EB341 }

final deliveryBoyValues = EnumValues({
  "68f87c3b40938d4d2f2eb341": DeliveryBoy.THE_68_F87_C3_B40938_D4_D2_F2_EB341,
});

class Pickup {
  String? name;
  double? lat;
  double? long;
  String? id;

  Pickup({this.name, this.lat, this.long, this.id});

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

// enum Name { NMBKJ, SAJIV }

// final nameValues = EnumValues({"nmbkj": Name.NMBKJ, "sajiv": Name.SAJIV});

class PackageDetails {
  bool? fragile;

  PackageDetails({this.fragile});

  factory PackageDetails.fromJson(Map<String, dynamic> json) =>
      PackageDetails(fragile: json["fragile"]);

  Map<String, dynamic> toJson() => {"fragile": fragile};
}

enum PaymentMethod { CASH }

final paymentMethodValues = EnumValues({"cash": PaymentMethod.CASH});

// enum Status {
//   ASSIGNED,
//   CANCELLED_BY_DRIVER,
//   CANCELLED_BY_USER,
//   COMPLETED,
//   ONGOING,
// }

// final statusValues = EnumValues({
//   "assigned": Status.ASSIGNED,
//   "cancelled_by_driver": Status.CANCELLED_BY_DRIVER,
//   "cancelled_by_user": Status.CANCELLED_BY_USER,
//   "completed": Status.COMPLETED,
//   "ongoing": Status.ONGOING,
// });

enum VehicleTypeId {
  THE_68_CE8516_E9401176157710_F3,
  THE_68_CE8594_E9401176157710_FB,
}

final vehicleTypeIdValues = EnumValues({
  "68ce8516e9401176157710f3": VehicleTypeId.THE_68_CE8516_E9401176157710_F3,
  "68ce8594e9401176157710fb": VehicleTypeId.THE_68_CE8594_E9401176157710_FB,
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
