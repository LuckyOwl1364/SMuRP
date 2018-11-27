// This file inspired by: https://medium.com/@kashifmin/flutter-login-app-using-rest-api-and-sqflite-b4815aed2149

import 'dart:async';
import 'package:http/http.dart' as http;

import 'package:smurp_app/utils/network_util.dart';
import 'package:smurp_app/models/user.dart';
import 'package:smurp_app/models/song.dart';

class RestDatasource {
  NetworkUtil _netUtil = new NetworkUtil();
  static final BASE_URL = "http://ec2-52-91-42-119.compute-1.amazonaws.com:5000/";
  static final LOGIN_URL = BASE_URL + "loginuser";  // username = theactualdevil, password = good_password
  static final ONESONG_URL = BASE_URL + "get_song";
  static final LISTENEDSONGS_URL = BASE_URL + "getListened";
  static final LIKEDSONGS_URL = BASE_URL + "get_liked";
  static final DISLIKEDSONGS_URL = BASE_URL + "get_disliked";
  static final RECOMMEND_URL = BASE_URL + "recommend";

  Future<User> login(String username, String password) {
    return _netUtil.get(LOGIN_URL + "?username=$username&password=$password",).then((dynamic res) {
      print(res.toString());
      if(res["error"]) throw new Exception(res["error_msg"]);
      return new User.fromJson(res["user"]);
    });
  }

  Future<Song> getOneSong() {
    return _netUtil.get(ONESONG_URL)
        .then((dynamic res) {
          print(res.toString());
//          if(res["error"]) throw new Exception(res["error_msg"]);
          return Song.map(res);
        });
  }

  Future<List<Song>> getListenedSongs(int user_id) {
    return _netUtil.get(LISTENEDSONGS_URL + "?user_id=$user_id")
        .then((dynamic res) {
      print(res.toString());
//          if(res["error"]) throw new Exception(res["error_msg"]);
      List<Song> songList = new List<Song>();
      for (var item in res){
        songList.add(Song.map(item));
      }
      return songList;
    });
  }

  Future<List<Song>> getLikedSongs(int user_id) {
    print("~~~~ About to get_liked");
    return _netUtil.get(LISTENEDSONGS_URL + "?user_id=$user_id")
        .then((dynamic res) {
      print(res.toString());
//          if(res["error"]) throw new Exception(res["error_msg"]);
      List<Song> songList = new List<Song>();
      for (var item in res){
        songList.add(Song.map(item));
      }
      return songList;
    });
  }

  Future<List<Song>> getDislikedSongs(int user_id) {
    print("~~~~ About to get_disliked");
    return _netUtil.get(RECOMMEND_URL + "?user_id=$user_id")
        .then((dynamic res) {
      print(res.toString());
//          if(res["error"]) throw new Exception(res["error_msg"]);
      List<Song> songList = new List<Song>();
      for (var item in res){
        songList.add(Song.map(item));
      }
      return songList;
    });
  }

  Future<List<Song>> getRecommendations(int user_id) {
    return _netUtil.get(LISTENEDSONGS_URL + "?user_id=$user_id")
        .then((dynamic res) {
      print(res.toString());
//          if(res["error"]) throw new Exception(res["error_msg"]);
      List<Song> songList = new List<Song>();
      for (var item in res){
        songList.add(Song.map(item));
      }
      return songList;
    });
  }


  //async call to get data from endpoint
  Future<String> getData() async {
    http.Response response = await http.get(
        BASE_URL + "loginuser?username=theactualdevil&password=good_password",
        headers: {
          "Accept": "application/json"
        }
    );
//    Map userMap = json.decode(response.body);
//    var user = new User.fromJson(userMap);
    return response.body;
  }

}