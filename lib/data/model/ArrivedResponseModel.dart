// To parse this JSON data, do
//
//     final arrivedResponseModel = arrivedResponseModelFromJson(jsonString);

import 'dart:convert';

ArrivedResponseModel arrivedResponseModelFromJson(String str) => ArrivedResponseModel.fromJson(json.decode(str));

String arrivedResponseModelToJson(ArrivedResponseModel data) => json.encode(data.toJson());

class ArrivedResponseModel {
  String? message;
  int? code;
  bool? error;
  Data? data;

  ArrivedResponseModel({
    this.message,
    this.code,
    this.error,
    this.data,
  });

  factory ArrivedResponseModel.fromJson(Map<String, dynamic> json) => ArrivedResponseModel(
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
  dynamic time;

  Data({
    this.delivery,
    this.time,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    delivery: json["delivery"] == null ? null : Delivery.fromJson(json["delivery"]),
    time: json["time"],
  );

  Map<String, dynamic> toJson() => {
    "delivery": delivery?.toJson(),
    "time": time,
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
  dynamic image;
  String? otp;
  int? arrivedAt;
  dynamic pickedAt;
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
