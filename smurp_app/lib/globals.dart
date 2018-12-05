library my_prj.globals;
import 'dart:io';
import 'dart:convert';

bool isLoggedIn;
String username;
int user_id;
String lastfm_name;
String joindate;
String session_key;

final double regularPadding = 8.0;
final double halfPadding = 4.0;
final double doublePadding = 16.0;

final HttpClient client = new HttpClient();

//"username": "TheActualDevil",
//    "lastfm_name": "DeadMetal1m1",
//    "join_date": "November 13, 2018",
//    "user_id": 323
//todo add session information