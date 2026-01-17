
import 'dart:convert';

DriverArivedModel DriverArivedModelFromJson(String str) => DriverArivedModel.fromJson(json.decode(str));

String DriverArivedModelToJson(DriverArivedModel data) => json.encode(data.toJson());

class DriverArivedModel {

  String txId;


  DriverArivedModel({

    required this.txId,

  });

  factory DriverArivedModel.fromJson(Map<String, dynamic> json) => DriverArivedModel(

    txId: json["txId"],

  );

  Map<String, dynamic> toJson() => {

    "txId": txId,

  };
}
