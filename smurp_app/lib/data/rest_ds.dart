// This file inspired by: https://medium.com/@kashifmin/flutter-login-app-using-rest-api-and-sqflite-b4815aed2149

import 'dart:async';

import 'package:smurp_app/utils/network_util.dart';
import 'package:smurp_app/models/user.dart';
import 'package:smurp_app/models/song.dart';

class RestDatasource {
  NetworkUtil _netUtil = new NetworkUtil();
  static final BASE_URL = "http://ec2-52-91-42-119.compute-1.amazonaws.com:5000";
  static final LOGIN_URL = BASE_URL + "/login";
  static final ONESONG_URL = BASE_URL + "/get_song";

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

  Future<Song> getOneSong() {
    return _netUtil.get(ONESONG_URL)
        .then((dynamic res) {
          print(res.toString());
          if(res["error"]) throw new Exception(res["error_msg"]);
          return new Song.map(res["song"]);
        });
  }

}