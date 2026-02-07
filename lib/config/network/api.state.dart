/*
import 'package:delivery_rider_app/data/model/getCityResModel.dart';
import 'package:delivery_rider_app/data/model/loginBodyModel.dart';
import 'package:delivery_rider_app/data/model/otpModelDATA.dart';
import 'package:delivery_rider_app/data/model/registerBodyModel.dart';
import 'package:delivery_rider_app/data/model/registerResModel.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../data/model/AddBodyVihileModel.dart';
import '../../data/model/AddVihicleResponseModel.dart';
import '../../data/model/DriverResponseModel.dart';
import '../../data/model/LoginResponseModel.dart';
import '../../data/model/OtpResponseLoginModel.dart';
import '../../data/model/OtpResponseResisterModel.dart';
import '../../data/model/VihicleResponseModel.dart';
import '../../data/model/driverProfileModel.dart';
import '../../data/model/saveDriverBodyModel.dart';
part 'api.state.g.dart';

@RestApi(baseUrl: "https://backend.weloads.live/api")

// @RestApi(baseUrl: "https://backend.weloads.live/api")

abstract class APIStateNetwork {
  factory APIStateNetwork(Dio dio, {String baseUrl}) = _APIStateNetwork;

  @GET("/v1/driver/getVehicleType")
  Future<VihicleResponseModel> getVehicleType();



  @POST("/v1/driver/login")
  Future<LoginResponseModel> login(@Body() LoginBodyModel body);


  @GET("/v1/driver/getCityList")
  Future<GetCityResModel> fetchCity();

  @POST("/v1/driver/register")
  Future<RegisterResModel> register(@Body() RegisterBodyModel body);




  @POST("/v1/driver/registerVerify")
  Future<OtpResponseResisterModel> verifyUser(@Body() OtpBodyModel body);


  @POST("/v1/driver/verifyUser")
  Future<OtpResponseLoginModel> verifylogin(@Body() OtpBodyModel body);



  @GET("/v1/driver/getDriverProfile")
  Future<DriverProfileModel> getDriverProfile();


  @POST("/v1/driver/saveDriverDocuments")
  Future<DriverResponseModel> saveDriverDocuments(@Body() SaveDriverBodyModel body);

  @POST("/v1/driver/addNewVehicle")
  Future<AddVihivleResponseModel> addNewVehicle (@Body() AddVihicleBodyModel body);
*/

/*

  import 'package:delivery_rider_app/data/model/getCityResModel.dart';
  import 'package:delivery_rider_app/data/model/loginBodyModel.dart';
  import 'package:delivery_rider_app/data/model/otpModelDATA.dart';
  import 'package:delivery_rider_app/data/model/registerBodyModel.dart';
  import 'package:delivery_rider_app/data/model/registerResModel.dart';
  import 'package:dio/dio.dart';
  import 'package:retrofit/retrofit.dart';
  import '../../data/model/AddBodyVihileModel.dart';
  import '../../data/model/AddVihicleResponseModel.dart';
  import '../../data/model/DriverResponseModel.dart';
  import '../../data/model/LoginResponseModel.dart';
  import '../../data/model/OtpResponseLoginModel.dart';
  import '../../data/model/OtpResponseResisterModel.dart';
  import '../../data/model/VihicleResponseModel.dart';
  import '../../data/model/driverProfileModel.dart';
  import '../../data/model/saveDriverBodyModel.dart';
  import '../../data/model/DeliveryResponseModel.dart'; // Assuming this model exists or needs to be created
  part 'api.state.g.dart';

  @RestApi(baseUrl: "https://backend.weloads.live/api")

// @RestApi(baseUrl: "https://backend.weloads.live/api")

  abstract class APIStateNetwork {
  factory APIStateNetwork(Dio dio, {String baseUrl}) = _APIStateNetwork;
  @GET("/v1/driver/getDeliveryById")
  Future<DeliveryResponseModel> getDeliveryById(@Query("deliveryId") String deliveryId);

  @GET("/v1/driver/getVehicleType")
  Future<VihicleResponseModel> getVehicleType();

  @POST("/v1/driver/login")
  Future<LoginResponseModel> login(@Body() LoginBodyModel body);

  @GET("/v1/driver/getCityList")
  Future<GetCityResModel> fetchCity();

  @POST("/v1/driver/register")
  Future<RegisterResModel> register(@Body() RegisterBodyModel body);

  @POST("/v1/driver/registerVerify")
  Future<OtpResponseResisterModel> verifyUser(@Body() OtpBodyModel body);

  @POST("/v1/driver/verifyUser")
  Future<OtpResponseLoginModel> verifylogin(@Body() OtpBodyModel body);

  @GET("/v1/driver/getDriverProfile")
  Future<DriverProfileModel> getDriverProfile();

  @POST("/v1/driver/saveDriverDocuments")
  Future<DriverResponseModel> saveDriverDocuments(@Body() SaveDriverBodyModel body);

  @POST("/v1/driver/addNewVehicle")
  Future<AddVihivleResponseModel> addNewVehicle (@Body() AddVihicleBodyModel body);





}
*/

import 'dart:io';
import 'package:delivery_rider_app/data/model/createTicketBodyModel.dart';
import 'package:delivery_rider_app/data/model/createTicketResModel.dart';
import 'package:delivery_rider_app/data/model/deliveryOnGoingBodyModel.dart';
import 'package:delivery_rider_app/data/model/deliveryOnGoingResModel.dart';
import 'package:delivery_rider_app/data/model/deliveryPickedReachedBodyModel.dart';
import 'package:delivery_rider_app/data/model/deliveryPickedReachedResModel.dart';
import 'package:delivery_rider_app/data/model/driverUpdateProfileImageResModel.dart';
import 'package:delivery_rider_app/data/model/getCityResModel.dart';
import 'package:delivery_rider_app/data/model/getTicketDetailsBodyModel.dart';
import 'package:delivery_rider_app/data/model/getTicketDetailsResModel.dart';
import 'package:delivery_rider_app/data/model/getTicketResModel.dart';
import 'package:delivery_rider_app/data/model/loginBodyModel.dart';
import 'package:delivery_rider_app/data/model/otpModelDATA.dart';
import 'package:delivery_rider_app/data/model/registerBodyModel.dart';
import 'package:delivery_rider_app/data/model/registerResModel.dart';
import 'package:delivery_rider_app/data/model/ticketReplyBodyModel.dart';
import 'package:delivery_rider_app/data/model/ticketReplyResModel.dart';
import 'package:delivery_rider_app/data/model/totalEarningResModel.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../data/model/AddBodyVihileModel.dart';
import '../../data/model/AddVihicleResponseModel.dart';
import '../../data/model/ArrivedResponseModel.dart';
import '../../data/model/CommisionModel.dart';
import '../../data/model/CreateOrderModel.dart';
import '../../data/model/CreateOrderResponseModel.dart';
import '../../data/model/DeliveryHistoryDataModel.dart';
import '../../data/model/DeliveryHistoryResponseModel.dart';
import '../../data/model/DeliveryOnGoingModel.dart';
import '../../data/model/DriverArivedModel.dart';
import '../../data/model/DriverCancelDeliveryBodyModel.dart';
import '../../data/model/DriverCancelResponseModel.dart';
import '../../data/model/DriverCompleteResponseModel.dart';
import '../../data/model/DriverResponseModel.dart';
import '../../data/model/GetTransactionListModel.dart';
import '../../data/model/ImageBodyModel.dart';
import '../../data/model/LoginResponseModel.dart';
import '../../data/model/OtpResponseLoginModel.dart';
import '../../data/model/OtpResponseResisterModel.dart';
import '../../data/model/PickedModel.dart';
import '../../data/model/QrTransactionHistoryModel.dart';
import '../../data/model/RatingResponseModel.dart';
import '../../data/model/RejectDeliveryBodyModel.dart';
import '../../data/model/ReviewRatingRequest.dart';
import '../../data/model/SelectVihicleResponseModel.dart';
import '../../data/model/UpdateProfileBodyModel.dart';
import '../../data/model/UploadImageResponseModel.dart';
import '../../data/model/VihicleResponseModel.dart';
import '../../data/model/VihicleSelectModel.dart';
import '../../data/model/WithdrawBodyModel.dart';
import '../../data/model/WithdrawRequestResponseModel.dart';
import '../../data/model/completeBodyModel.dart';
import '../../data/model/driverProfileModel.dart';
import '../../data/model/rejectedResponseModel.dart';
import '../../data/model/saveDriverBodyModel.dart';
import '../../data/model/DeliveryResponseModel.dart';
import '../../data/model/updateUserResProfileModel.dart';

part 'api.state.g.dart';

// @RestApi(baseUrl: "https://backend.weloads.live/api")

//@RestApi(baseUrl: "http://192.168.1.82:4567/api") // local url julkar
@RestApi(baseUrl: "https://backend.weloads.live/api")
abstract class APIStateNetwork {
  factory APIStateNetwork(Dio dio, {String baseUrl}) = _APIStateNetwork;

  @POST("/v1/driver/updateVehicleStatus")
  Future<SelectVicileResponse> updateVehicleStatus(
    @Body() VihicleSelectModel body,
  );

  @POST("/v1/driver/withdrawRequest")
  Future<WithdrawRequestResponseModel> withdrawRequest(
    @Body() WithdrawBodyModel body,
  );

  @POST("/v1/driver/createOrder")
  Future<CreateOrderResponseModel> createOrder(@Body() CreateOrderModel body);

  @GET("/v1/driver/getTxList")
  Future<TransactionListResponseModel> getTxList();

  @POST("/v1/driver/getWalletTransactions")
  Future<QrTransactionHistoryModel> getWalletTransactions();

  @POST("/v1/driver/getCommissions")
  Future<CommissionModel> getCommissions();

  @POST("/v1/driver/driverArrived")
  Future<ArrivedResponseModel> driverArrived(@Body() DriverArivedModel body);

  // ✅ Delivery-related
  @GET("/v1/driver/getDeliveryById")
  Future<DeliveryResponseModel> getDeliveryById(
    @Query("deliveryId") String deliveryId,
  );

  @POST("/v1/driver/getReviewRatingList")
  Future<RatingResponseModel> getReviewRatingList(
    @Body() ReviewRatingRatingModel body,
  );

  @POST("/v1/driver/getDeliveryHistory")
  Future<DeliveryHistoryResponseModel> getDeliveryHistory(
    @Body() DeliveryHistoryRequestModel body,
  );

  @POST("/v1/driver/deliveryPickupReached")
  Future<HttpResponse<dynamic>> deliveryPickupReached(
    @Body() PickedBodyModel body,
  );

  @POST("/v1/driver/deliveryOnGoingReached")
  Future<HttpResponse<dynamic>> deliveryOnGoingReached(
    @Body() DeliveryOnGoingModel body,
  );

  // ✅ Vehicle-related
  @GET("/v1/driver/getVehicleType")
  Future<VihicleResponseModel> getVehicleType();

  @POST("/v1/driver/addNewVehicle")
  Future<AddVihivleResponseModel> addNewVehicle(
    @Body() AddVihicleBodyModel body,
  );

  @POST("/v1/driver/updateVehicle")
  Future<AddVihivleResponseModel> updateNewVehicle(
    @Body() UpdateVihicleBodyModel body,
  );

  // ✅ Auth-related
  @POST("/v1/driver/login")
  Future<LoginResponseModel> login(@Body() LoginBodyModel body);

  @POST("/v1/driver/register")
  Future<RegisterResModel> register(@Body() RegisterBodyModel body);

  @POST("/v1/driver/registerVerify")
  Future<OtpResponseResisterModel> verifyUser(@Body() OtpBodyModel body);

  @POST("/v1/driver/verifyUser")
  Future<OtpResponseLoginModel> verifylogin(@Body() OtpBodyModel body);

  // ✅ Profile-related
  @GET("/v1/driver/getDriverProfile")
  Future<DriverProfileModel> getDriverProfile();

  @POST("/v1/driver/saveDriverDocuments")
  Future<DriverResponseModel> saveDriverDocuments(
    @Body() SaveDriverBodyModel body,
  );

  @POST("/v1/driver/saveDriverDocuments")
  Future<DriverResponseModel> saveDriverBackDocuments(
    @Body() SaveDriverBackBodyModel body,
  );

  @PUT("/v1/driver/updateDriverProfile")
  Future<HttpResponse<dynamic>> updateDriverProfile(
    @Body() ImageBodyModel body,
  );

  // ✅ City List
  @GET("/v1/driver/getCityList")
  Future<GetCityResModel> fetchCity();

  @POST("/v1/driver/deliveryPickupReached")
  Future<DeliveryPickedReachedResModel> pickedOrReachedDelivery(
    @Body() DeliveryPickedReachedBodyModel body,
  );

  @POST("/v1/driver/deliveryOnGoingReached")
  Future<DeliveryOnGoingResModel> deliveryOnGoing(
    @Body() DeliveryOnGoingBodyModel body,
  );

  @POST("/v1/driver/deliveryCancelledByDriver")
  Future<DriverCancelDeliveryResModel> driverCancelDelivery(
    @Body() DriverCancelDeliveryBodyModel body,
  );

  @POST("/v1/driver/deliveryCompleted")
  Future<DeliverCompleteResModel> deliveryCompelte(
    @Body() DeliverCompleteBodyModel body,
  );

  @POST("/v1/driver/rejectDelivery")
  Future<RejectedDeliveryResponseModel> rejectDelivery(
    @Body() RejectDeliveryBodyModel body,
  );

  // @POST("/v1/driver/updateProfileImage")
  // Future<DriverUpdateProfileImageResModel> driverUpdateProfileImage(
  //   @Body() DriverUpdateProfileImageBodyModel body,
  // );

  /// ✅ Upload driver profile image (Multipart)
  @POST("/v1/driver/updateProfileImage")
  @MultiPart()
  Future<DriverUpdateProfileImageResModel> driverUpdateProfileImage(
    @Part(name: "image") MultipartFile image,
  );

  @POST("/v1/ticket/createTicket")
  Future<CreateTicketResModel> createTicket(@Body() CreateTicketBodyModel body);

  @POST("/v1/ticket/getTicketList")
  Future<GetTicketListResModel> getTicketList();

  @POST("/v1/ticket/getTicketById")
  Future<GetTicketDetailsResModel> ticketDetails(
    @Body() TicketDetailsBodyModel body,
  );

  @POST("/v1/ticket/ticketReply")
  Future<TicketReplyResModel> ticketReply(@Body() TicketReplyBodyModel body);

  @MultiPart()
  @POST("/v1/uploadImage")
  Future<UploadImageReModel> uploadImage(@Part(name: "file") File file);

  @PUT("/v1/driver/updateDriverProfile")
  Future<UpdateUserProfileResModel> updateCutomerProfile(
    @Body() UpdateUserProfileBodyModel body,
  );

  @GET("/v1/driver/totalEraning")
  Future<TotalEarningResModel> totlaEarning(@Query("type") String type);

  @GET("/v1/driver/earningDashboard")
  Future<TotalEarningDashbordResModel> totlaEarningDashbord(
    @Query("type") String type,
  );
}
