import 'dart:convert';

import 'package:dio/dio.dart';

class CallApiClass{

  final Dio dio = Dio();

  Future<Map<String, dynamic>> getBidderEnableApi(String customerNum) async {

    final Dio dio = Dio();

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIzMjQ1ODYiLCJpc3MiOiJodHRwczovL2Nsb3VkcGhvbmUudGF0YXRlbGVzZXJ2aWNlcy5jb20vdG9rZW4vZ2VuZXJhdGUiLCJpYXQiOjE2OTUxMTkyMjAsImV4cCI6MTk5NTExOTIyMCwibmJmIjoxNjk1MTE5MjIwLCJqdGkiOiJrUGlxRXZJSHUwc1FmRFRTIn0.kln5QFAlkbrAK_T0qo1_rZFbr7O6zB5xzzdcpk5ON2Y',
    };


    var data = json.encode({
      "agent_number": "8805475637",
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