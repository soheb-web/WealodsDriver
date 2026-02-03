
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/network/api.state.dart';
import '../model/CommisionModel.dart';
import '../model/GetTransactionListModel.dart';
import 'package:delivery_rider_app/config/utils/pretty.dio.dart';

import '../model/QrTransactionHistoryModel.dart';





final getTransactionController = FutureProvider.autoDispose<TransactionListResponseModel>((
    ref,
    ) async {
  final service = APIStateNetwork(callDio());
  return await service.getTxList();
});


final getCommissionController = FutureProvider.autoDispose<CommissionModel>((ref) async {
  final service = APIStateNetwork(callDio()); // your API client
  return await service.getCommissions();
});


// final getWalletTransactionsController = FutureProvider.autoDispose<QrTransactionHistoryModel>((
//     ref,
//     ) async {
//   final service = APIStateNetwork(callDio());
//   return await service.getWalletTransactions();
// });


final getWalletTransactionsController = FutureProvider.autoDispose<QrTransactionHistoryModel>((
    ref,
    ) async {
  final service = APIStateNetwork(callDio());
  return await service.getWalletTransactions();
});
