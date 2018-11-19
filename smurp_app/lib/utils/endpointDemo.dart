import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smurp_app/models/user.dart';

class EndpointDemoPage extends StatefulWidget {
  @override
  EndpointDemoState createState()=> new EndpointDemoState();

}

class EndpointDemoState extends State<EndpointDemoPage> {

  String endPtData = "Test Data ";

  @override
  Widget build(BuildContext context){
    return new Scaffold(
        body: new Center(
            child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new RaisedButton( child: new Text("Get endpoint data"), onPressed: getTestEndpointData),
                  new Text(endPtData)]
            )
        )
    );
  }


  //asynchronous call to hit the test endpoint
  // it's asynchronous because it might take a while
  // and we don't want the app to crash in the time
  // it takes to gather the data
  Future<String> getTestEndpointData() async{
    http.Response response = await http.get("http://ec2-52-91-42-119.compute-1.amazonaws.com:5000/database",
        headers: {
          "Accept" : "application/json"
        }
    );

    //print(response.body);
    Map userMap = json.decode(response.body);
    var user = new User.fromJson(userMap);
    //print('User name: ${user.username}');
    //print(userMap);
    setState((){
      endPtData = 'DATA RECIEVED FROM ENDPOINT\n'
          'User name: ${user.username}\n'
          'LastFM name: ${user.lastfm_name}\n'
          'Join Date: ${user.join_date}\n'
          'Password: ${user.password}\n'
          'Email Address: ${user.email}\n';
      //endPtData = user.toString();
      //endPtData = userMap.toString();
    });

  }

}

