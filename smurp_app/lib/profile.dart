import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smurp_app/models/user.dart';

class ProfilePage extends StatefulWidget {
  @override
  ProfileState createState()=> new ProfileState();

}

class ProfileState extends State<ProfilePage> {

  String endPtData = "Endpoint Data Username";
  String profileData = "Testing Profile. . . Did it work? ";
  List profileList;
  double regularPadding = 8.0;
  double halfPadding = 4.0;
  double doublePadding = 16.0;

  @override
  void initState() {
    super.initState();
    this.getProfileData();
  }

  @override
  Widget build(BuildContext context){
    return new Scaffold(
        appBar: new AppBar(title: Text('Profile Page')),
        body: new ListView.builder(
          itemCount: profileList == null ? 0 : profileList.length,
            itemBuilder: (BuildContext context, int index){
              return new Card(
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Expanded(
                        child: Padding(
                          padding: new EdgeInsets.all(doublePadding),
                          child: new Text(
                              profileList[index]['username'] == null ? 'null value ' + index.toString() + ' recently listened to '+profileList[index]['song_title'] + ' by ' + profileList[index]['artist']
                                  : profileList[index]['username'] + ' recently listened to '+profileList[index]['song_title'] + ' by ' + profileList[index]['artist'],
                              textAlign: TextAlign.start),
                        )),
                  ],//end widget
                ),//end row
              );//end card
            },//end itembuilder
          ),//end listview builder
    );
  }
  //asynchronous call to hit the test endpoint
  // it's asynchronous because it might take a while
  // and we don't want the app to crash in the time
  // it takes to gather the data
  Future<String> getProfileData() async {
    http.Response response = await http.get(
        "http://ec2-52-91-42-119.compute-1.amazonaws.com:5000/getfeed?user_id=1",
        headers: {"Accept": "application/json"});

    setState(() {
      profileList = json.decode(response.body);
      profileData = 'Successfully grabbed some data!';

      print(profileData);
    });
  }

}
