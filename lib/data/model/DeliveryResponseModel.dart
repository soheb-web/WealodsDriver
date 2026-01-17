// To parse this JSON data, do
//
//     final deliveryResponseModel = deliveryResponseModelFromJson(jsonString);

import 'dart:convert';

DeliveryResponseModel deliveryResponseModelFromJson(String str) => DeliveryResponseModel.fromJson(json.decode(str));

String deliveryResponseModelToJson(DeliveryResponseModel data) => json.encode(data.toJson());

class DeliveryResponseModel {
  String? message;
  int? code;
  bool? error;
  Data? data;

  DeliveryResponseModel({
    this.message,
    this.code,
    this.error,
    this.data,
  });

  factory DeliveryResponseModel.fromJson(Map<String, dynamic> json) => DeliveryResponseModel(
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
  Dropoff? pickup;
  List<Dropoff>? dropoff;  // ← CHANGE: List<Dropoff>
  PackageDetails? packageDetails;
  String? id;
  Customer? customer;
  String? deliveryBoy;
  int? userPayAmount;
  String? status;
  String? paymentMethod;
  int? freeWaitingTime;
  int? totalWaitingTime;
  int? extraWaitingMinutes;
  int? extraWaitingCharge;
  String? txId;
  int? createdAt;

  Data({
    this.pickup,
    this.dropoff,
    this.packageDetails,
    this.id,
    this.customer,
    this.deliveryBoy,
    this.userPayAmount,
    this.status,
    this.paymentMethod,
    this.freeWaitingTime,
    this.totalWaitingTime,
    this.extraWaitingMinutes,
    this.extraWaitingCharge,
    this.txId,
    this.createdAt,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    pickup: json["pickup"] == null ? null : Dropoff.fromJson(json["pickup"]),
    dropoff: json["dropoff"] == null
        ? null
        : List<Dropoff>.from(json["dropoff"].map((x) => Dropoff.fromJson(x))),
    packageDetails: json["packageDetails"] == null ? null : PackageDetails.fromJson(json["packageDetails"]),
    id: json["_id"],
    customer: json["customer"] == null ? null : Customer.fromJson(json["customer"]),
    deliveryBoy: json["deliveryBoy"],
    userPayAmount: json["userPayAmount"],
    status: json["status"],
    paymentMethod: json["paymentMethod"],
    freeWaitingTime: json["freeWaitingTime"],
    totalWaitingTime: json["totalWaitingTime"],
    extraWaitingMinutes: json["extraWaitingMinutes"],
    extraWaitingCharge: json["extraWaitingCharge"],
    txId: json["txId"],
    createdAt: json["createdAt"],
  );

  Map<String, dynamic> toJson() => {
    "pickup": pickup?.toJson(),
    "dropoff": dropoff == null ? null : List<dynamic>.from(dropoff!.map((x) => x.toJson())),
    "packageDetails": packageDetails?.toJson(),
    "_id": id,
    "customer": customer?.toJson(),
    "deliveryBoy": deliveryBoy,
    "userPayAmount": userPayAmount,
    "status": status,
    "paymentMethod": paymentMethod,
    "freeWaitingTime": freeWaitingTime,
    "totalWaitingTime": totalWaitingTime,
    "extraWaitingMinutes": extraWaitingMinutes,
    "extraWaitingCharge": extraWaitingCharge,
    "txId": txId,
    "createdAt": createdAt,
  };
}

class Customer {
  CurrentLocation? currentLocation;
  String? status;
  int? completedOrderCount;
  String? id;
  String? userType;
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  String? password;
  String? driverStatus;
  int? averageRating;
  dynamic image;
  bool? isDisable;
  bool? isDeleted;
  int? date;
  int? month;
  int? year;
  int? createdAt;
  int? updatedAt;
  String? deviceId;
  dynamic socketId;
  DateTime? lastLocationUpdate;
  List<dynamic>? vehicleDetails;
  List<dynamic>? rating;

  Customer({
    this.currentLocation,
    this.status,
    this.completedOrderCount,
    this.id,
    this.userType,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.password,
    this.driverStatus,
    this.averageRating,
    this.image,
    this.isDisable,
    this.isDeleted,
    this.date,
    this.month,
    this.year,
    this.createdAt,
    this.updatedAt,
    this.deviceId,
    this.socketId,
    this.lastLocationUpdate,
    this.vehicleDetails,
    this.rating,
  });

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
    currentLocation: json["currentLocation"] == null ? null : CurrentLocation.fromJson(json["currentLocation"]),
    status: json["status"],
    completedOrderCount: json["completedOrderCount"],
    id: json["_id"],
    userType: json["userType"],
    firstName: json["firstName"],
    lastName: json["lastName"],
    email: json["email"],
    phone: json["phone"],
    password: json["password"],
    driverStatus: json["driverStatus"],
    averageRating: json["averageRating"],
    image: json["image"],
    isDisable: json["isDisable"],
    isDeleted: json["isDeleted"],
    date: json["date"],
    month: json["month"],
    year: json["year"],
    createdAt: json["createdAt"],
    updatedAt: json["updatedAt"],
    deviceId: json["deviceId"],
    socketId: json["socketId"],
    lastLocationUpdate: json["lastLocationUpdate"] == null ? null : DateTime.parse(json["lastLocationUpdate"]),
    vehicleDetails: json["vehicleDetails"] == null ? [] : List<dynamic>.from(json["vehicleDetails"]!.map((x) => x)),
    rating: json["rating"] == null ? [] : List<dynamic>.from(json["rating"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "currentLocation": currentLocation?.toJson(),
    "status": status,
    "completedOrderCount": completedOrderCount,
    "_id": id,
    "userType": userType,
    "firstName": firstName,
    "lastName": lastName,
    "email": email,
    "phone": phone,
    "password": password,
    "driverStatus": driverStatus,
    "averageRating": averageRating,
    "image": image,
    "isDisable": isDisable,
    "isDeleted": isDeleted,
    "date": date,
    "month": month,
    "year": year,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
    "deviceId": deviceId,
    "socketId": socketId,
    "lastLocationUpdate": lastLocationUpdate?.toIso8601String(),
    "vehicleDetails": vehicleDetails == null ? [] : List<dynamic>.from(vehicleDetails!.map((x) => x)),
    "rating": rating == null ? [] : List<dynamic>.from(rating!.map((x) => x)),
  };
}

class CurrentLocation {
  String? type;
  List<double>? coordinates;

  CurrentLocation({
    this.type,
    this.coordinates,
  });

  factory CurrentLocation.fromJson(Map<String, dynamic> json) => CurrentLocation(
    type: json["type"],
    coordinates: json["coordinates"] == null ? [] : List<double>.from(json["coordinates"]!.map((x) => x?.toDouble())),
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "coordinates": coordinates == null ? [] : List<dynamic>.from(coordinates!.map((x) => x)),
  };
}

class Dropoff {
  String? name;
  double? lat;
  double? long;

  Dropoff({
    this.name,
    this.lat,
    this.long,
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
