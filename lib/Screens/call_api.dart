import 'dart:convert';

import 'package:deliveryboy/Helper/Session.dart';
import 'package:deliveryboy/Helper/String.dart';
import 'package:dio/dio.dart';

class CallApiClass{

  final Dio dio = Dio();

  Future<Map<String, dynamic>> getBidderEnableApi(String customerNum) async {

    final Dio dio = Dio();

    String? mobile = await getPrefrence(MOBILE);

    print("mobile $mobile");

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIzNzcwMjgiLCJpc3MiOiJodHRwczovL2Nsb3VkcGhvbmUudGF0YXRlbGVzZXJ2aWNlcy5jb20vdG9rZW4vZ2VuZXJhdGUiLCJpYXQiOjE3MDIwMjMyOTIsImV4cCI6MjAwMjAyMzI5MiwibmJmIjoxNzAyMDIzMjkyLCJqdGkiOiJxNzBNUDdsVVdUaXJCMVV5In0.PH9cA25FAnrKALku4TsdD7iJa32qxb3vFt31GsN7oLA',
    };


    var data = json.encode({
      "agent_number": mobile,
      "destination_number": customerNum
    });

    var response = await dio.request(
      "https://api-smartflo.tatateleservices.com/v1/click_to_call",
      options: Options(
        method: 'POST',
        headers: headers,
      ),
      data: data,
    );

    if (response.statusCode == 200) {
      print(json.encode(response.data));
    }
    else {
      print(response.statusMessage);
    }

    return response.data;
  }

}