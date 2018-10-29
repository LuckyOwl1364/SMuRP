// This file inspired by: https://medium.com/@kashifmin/flutter-login-app-using-rest-api-and-sqflite-b4815aed2149

import 'dart:async';

import 'package:smurp_app/utils/network_util.dart';
import 'package:smurp_app/models/user.dart';

class RestDatasource {
  NetworkUtil _netUtil = new NetworkUtil();
  static final BASE_URL = "http://YOUR_BACKEND_IP/login_app_backend";
  static final LOGIN_URL = BASE_URL + "/login.php";

  Future<User> login(String username, String password) {
    return _netUtil.post(LOGIN_URL, body: {
      "username": username,
      "password": password
    }).then((dynamic res) {
      print(res.toString());
      if(res["error"]) throw new Exception(res["error_msg"]);
      return new User.map(res["user"]);
    });
  }
}