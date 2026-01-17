import 'dart:io';

import 'package:delivery_rider_app/config/network/api.state.dart';
import 'package:delivery_rider_app/config/utils/pretty.dio.dart';
import 'package:delivery_rider_app/data/model/getTicketDetailsBodyModel.dart';
import 'package:delivery_rider_app/data/model/getTicketDetailsResModel.dart';
import 'package:delivery_rider_app/data/model/getTicketResModel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/VihicleSelectModel.dart';

final getTicketListController =
    FutureProvider.autoDispose<GetTicketListResModel>((ref) async {
      final service = APIStateNetwork(callDio());
      return await service.getTicketList();
    });

final ticketDetailsController =
    FutureProvider.family<GetTicketDetailsResModel, String>((ref, id) async {
      final service = APIStateNetwork(callDio());
      final body = TicketDetailsBodyModel(id: id);
      return await service.ticketDetails(body);
    });

