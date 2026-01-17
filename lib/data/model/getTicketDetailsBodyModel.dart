// To parse this JSON data, do
//
//     final ticketDetailsBodyModel = ticketDetailsBodyModelFromJson(jsonString);

import 'dart:convert';

TicketDetailsBodyModel ticketDetailsBodyModelFromJson(String str) => TicketDetailsBodyModel.fromJson(json.decode(str));

String ticketDetailsBodyModelToJson(TicketDetailsBodyModel data) => json.encode(data.toJson());

class TicketDetailsBodyModel {
    String id;

    TicketDetailsBodyModel({
        required this.id,
    });

    factory TicketDetailsBodyModel.fromJson(Map<String, dynamic> json) => TicketDetailsBodyModel(
        id: json["id"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
    };
}





