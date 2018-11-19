import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smurp_app/history.dart';
import 'package:smurp_app/models/user.dart';
import 'package:smurp_app/utils/endpointDemo.dart';
import 'package:smurp_app/feed.dart';
import 'package:smurp_app/profile.dart';
import 'package:smurp_app/recommended.dart';


//void main() {
//  runApp(new MaterialApp(
//    home: new FriendsPage(),
//  ));
//}

class FriendsPage extends StatefulWidget {
  @override
  FriendsPageState createState() => new FriendsPageState();
}

class FriendsPageState extends State<FriendsPage> {
  String endPtData = "Test Data ";
  List data;
  double regularPadding = 8.0;
  double halfPadding = 4.0;
  double doublePadding = 16.0;

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "Friends page",
      home: new DefaultTabController(
        length:2,
        child:  new Scaffold(
            appBar: new AppBar(
                title: new Text("Friends"),
                //creating tabs
                bottom: new TabBar(
                    tabs: <Widget>[
                      new Tab(text: "Users you Follow"),
                      new Tab(text: "Users who Follow You"),
                    ]//end of widget
                )//end of tab bar
            ),
            body: new TabBarView(
                children: <Widget>[
                  new FirstWidget(),
                  new SecondWidget(),
                ]
            )
        ),
      ),
    );
  } //build

  void unfollow() {
    setState(() {
      //hit the endpoint
      endPtData += " Unfollowed";
    });
  }

} //end of FriendsPageState

//this widget is what should be under the first tab
class FirstWidget extends StatelessWidget {
  @override
  Widget build(BuildContext ctxt) {
    return new Center(
      child: new Text("Hey look! nobody's here :P"),
    );
  }
}

//this widget is what should be under the second tab
class SecondWidget extends StatelessWidget {
  @override
  Widget build(BuildContext ctxt) {
    return new Center(
      child: new Text("Oof. There's still nobody here :P"),
    );
  }
}