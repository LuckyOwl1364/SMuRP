import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smurp_app/models/user.dart';

void main() {
  runApp(new MaterialApp(
    home: new FollowingPage(),
  ));
}

class FollowingPage extends StatefulWidget {
  @override
  FollowingPageState createState() => new FollowingPageState();
}

class FollowingPageState extends State<FollowingPage> {

  String endPtData = "Test Data ";
  List data;

  //async call to get data from endpoint
  Future<String> getData() async{
    http.Response response = await http.get("http://ec2-52-91-42-119.compute-1.amazonaws.com:5000/database",
        headers: {
          "Accept" : "application/json"
        }
    );

    setState((){
      Map userMap = json.decode(response.body);
      var user = new User.fromJson(userMap);

      endPtData = 'DATA RECIEVED FROM ENDPOINT\n'
          'User name: ${user.username}\n'
          'LastFM name: ${user.lastfm_name}\n';

      //data.add('User name is ${user.username} \n LastFM name is ${user.lastfm_name}');
      print(endPtData);
      //data.add(user);
    });

    //data.add('Some Generic user name is abcUser321 \n generic LastFM name is abcU321');
    //data.add('Another Generic username is 432wxy \n another generic LastFM name is wxy432');

  }

  @override
  void initState() {
    super.initState();
    this.getData();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Listviews"),
      ),
      body: new ListView.builder(
        itemCount: 1,
        itemBuilder: (BuildContext context, int index) {
          return new Card(
            child: new Text(endPtData),
          );
        },
      ),
    );
  }

}