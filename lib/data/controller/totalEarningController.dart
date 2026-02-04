import 'package:delivery_rider_app/config/network/api.state.dart';
import 'package:delivery_rider_app/config/utils/pretty.dio.dart';
import 'package:delivery_rider_app/data/model/totalEarningResModel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final earningTypeProvider = StateProvider<String>((ref) => "day");
final totalEarningProvider = FutureProvider.autoDispose<TotalEarningResModel>((
  ref,
) async {
  final type = ref.watch(earningTypeProvider);
  final service = APIStateNetwork(callDio());
  return await service.totlaEarning(type);
});

final earningDashbordProvider = StateProvider<String>((ref) => "day");
final totalEarningDashbordProvider =
    FutureProvider.autoDispose<TotalEarningDashbordResModel>((ref) async {
      final type = ref.watch(earningDashbordProvider);
      final service = APIStateNetwork(callDio());
      return await service.totlaEarningDashbord(type);
    });
