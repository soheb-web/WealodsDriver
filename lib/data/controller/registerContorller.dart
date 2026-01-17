import 'dart:developer';
import 'package:delivery_rider_app/RiderScreen/home.page.dart';
import 'package:delivery_rider_app/config/network/api.state.dart';
import 'package:delivery_rider_app/config/utils/pretty.dio.dart';
import 'package:delivery_rider_app/data/model/registerBodyModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';

mixin RegisterContorller<T extends StatefulWidget> on State<T> {
  final registerformKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final passwordController = TextEditingController();
  final codeController = TextEditingController();
  bool isCheckt = false;
  bool isLoading = false;

  void register(String cityId, String deviceId) async {
    if (!isCheckt) {
      Fluttertoast.showToast(msg: "Please agree to Terms & Conditions");
      setState(() {
        isLoading = false;
      });
      return;
    }
    if (!registerformKey.currentState!.validate()) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    final body = RegisterBodyModel(
      firstName: firstNameController.text,
      lastName: lastNameController.text,
      email: emailController.text,
      phone: phoneNumberController.text,
      cityId: cityId,
      deviceId: deviceId,
      refByCode: codeController.text,
      // password: passwordController.text,
    );
    try {
      final service = APIStateNetwork(callDio());
      final response = await service.register(body);
      if (response.error == false) {
        Fluttertoast.showToast(msg: response.message);
        Navigator.pushAndRemoveUntil(
          context,
          CupertinoPageRoute(builder: (context) => HomePage(0)),
              (route) => false,
        );

        setState(() {
          isLoading = false;
        });
      } else {
        Fluttertoast.showToast(msg: response.message);

        setState(() {
          isLoading = false;
        });
      }
    } catch (e, st) {
      setState(() {
        isLoading = false;
      });
      log("${e.toString()} / ${st.toString()}");
    }
  }

}