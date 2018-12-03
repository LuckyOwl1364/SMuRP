import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smurp_app/models/user.dart';
import 'globals.dart' as globals;


class ProfilePage extends StatefulWidget {
  @override
  ProfileState createState()=> new ProfileState();

}

class ProfileState extends State<ProfilePage> {
  var userList;
  String userData = "Endpoint Data Username";
  String profileData = "Testing Profile. . . Did it work? ";
  List profileList;
  double regularPadding = 8.0;
  double halfPadding = 4.0;
  double doublePadding = 16.0;

  @override
  void initState() {
    super.initState();
    this.getUserData();
    this.getProfileData();
  }

  @override
  Widget build(BuildContext context){
    return new Scaffold(
      appBar: new AppBar(title: Text('Profile Page')),
      body: new Column(
        children: <Widget>[
          new Padding(
            padding:  new EdgeInsets.only(top: doublePadding),
            child: new Text(
                userList['username'] == null ? 'username unavailable' : userList['username'],
                textAlign: TextAlign.start,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30.0)
            ),//end of text
          ),//end of padding
          new Padding(
            padding: new EdgeInsets.all(halfPadding),
            child: new Text(
                userList['email'] == null ? 'email value unavailable' : userList['email'],
                textAlign: TextAlign.start
            ),//end of text
          ),//end of padding
          new Padding(
            padding: new EdgeInsets.all(halfPadding),
            child: new Text(
                (userList['join_date'] == null || userList['join_date'].length < 10) ? 'Join date unavailable ' :
                'Joined on '+userList['join_date'].substring(0, 10),
                textAlign: TextAlign.start
            ),//end of text
          ),//end of padding
          new Expanded(
            child: new ListView.builder(
              itemCount: profileList == null ? 0 : profileList.length,
              itemBuilder: (BuildContext context, int index){
                return new Card(
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(
                          child: Padding(
                              padding: new EdgeInsets.all(doublePadding),
                              child : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children : [
                                    Text(
                                      profileList[index]['username'] == null ? 'empty username ' + (profileList[index]['rating'] == 1 ? ' liked ' : ' recently listened to ')
                                          : profileList[index]['username'] + (profileList[index]['rating'] == 1 ? ' liked ' : ' recently listened to '),
                                      textAlign: TextAlign.start,
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                        profileList[index]['song_title'] == null ? 'song title null ' :
                                        profileList[index]['song_title'] + ' by ' + (profileList[index]['artist'] == null ? 'artist unknown' : profileList[index]['artist'] ),
                                        textAlign: TextAlign.start),

                                  ]//end of column children
                              )//end of column
                          )),
                    ],//end widget
                  ),//end row
                );//end card
              },//end itembuilder
            )//ed of listbuilder

          )//end of expanded
        ],//end of widget children
      )//end of column
    );
  }

  //asynchronous call to hit the test endpoint
  // it's asynchronous because it might take a while
  // and we don't want the app to crash in the time
  // it takes to gather the data
  Future<String> getProfileData() async {
    http.Response response = await http.get(
        "http://ec2-52-91-42-119.compute-1.amazonaws.com:5000/getfeed?user_id="+globals.user_id.toString()+"&user_only=true",
        headers: {"Accept": "application/json"});

    setState(() {
      profileList = json.decode(response.body);
      profileData = 'Successfully grabbed profile data!';

      print(profileData);
    });
  }

  //asynchronous call to hit the test endpoint
  // it's asynchronous because it might take a while
  // and we don't want the app to crash in the time
  // it takes to gather the data
  Future<String> getUserData() async {
    http.Response response = await http.get(
        "http://ec2-52-91-42-119.compute-1.amazonaws.com:5000/get_user?user_id="+globals.user_id.toString(),
        headers: {"Accept": "application/json"});

    setState(() {
      userList = json.decode(response.body);
      userData = userList['username'] == null ? 'null username' : userList['username'];

      print(userData);
    });
  }

}