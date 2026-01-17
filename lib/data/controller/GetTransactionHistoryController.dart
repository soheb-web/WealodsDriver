
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/network/api.state.dart';
import '../model/GetTransactionListModel.dart';



import 'package:delivery_rider_app/config/utils/pretty.dio.dart';

final getTransactionController = FutureProvider.autoDispose<TransactionListResponseModel>((
    ref,
    ) async {
  final service = APIStateNetwork(callDio());
  return await service.getTxList();
});
