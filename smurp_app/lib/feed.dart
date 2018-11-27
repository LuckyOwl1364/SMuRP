import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smurp_app/models/user.dart';
import 'package:smurp_app/history.dart';
import 'package:smurp_app/rated.dart';
import 'package:smurp_app/friends.dart';
import 'package:smurp_app/profile.dart';
import 'package:smurp_app/recommended.dart';

void main() {
  runApp(new MaterialApp(
    home: new FeedPage(),
  ));
}

class FeedPage extends StatefulWidget {
  @override
  FeedState createState()=> new FeedState();

}

class FeedState extends State<FeedPage> {
  String endPtData = "Test Data ";
  List data;
  double regularPadding = 8.0;
  double halfPadding = 4.0;
  double doublePadding = 16.0;

  //async call to get data from endpoint
  Future<String> getData() async {
    http.Response response = await http.get(
        "http://ec2-52-91-42-119.compute-1.amazonaws.com:5000/database",
        headers: {"Accept": "application/json"});

    setState(() {
      Map userMap = json.decode(response.body);
      var user = new User.fromJson(userMap);

//      endPtData = 'DATA RECIEVED FROM ENDPOINT\n'
//          'User name: ${user.username}\n'
//          'LastFM name: ${user.lastfm_name}\n';

      endPtData = '${user.username}';

      print(endPtData);
    });
  }

  @override
  Widget build(BuildContext context){
    return new Scaffold(
        appBar: new AppBar(title: Text('Home Feed')),
        drawer: new Drawer(
          child: ListView(
            children: <Widget>[
              UserAccountsDrawerHeader(
                  accountName: Text(endPtData),
                  accountEmail: Text('hardCodedEmail@email.com'),
                  decoration: BoxDecoration(
                    color: Colors.lightBlue,
                  )),
              ListTile(
                contentPadding: EdgeInsets.symmetric(
                    vertical: halfPadding, horizontal: doublePadding),
                leading: const Icon(Icons.account_circle),
                title: Text('Profile'),
                onTap: () {
                  // ignore: return_of_invalid_type_from_closure
                  Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (context) => new ProfilePage()));
                }, //code to navigate to appropriate screen
              ),
              ListTile(
                contentPadding: EdgeInsets.symmetric(
                    vertical: halfPadding, horizontal: doublePadding),
                leading: const Icon(Icons.stars),
                title: Text('Recommended'),
                onTap: () {
                  Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (context) => new RecommendedPage()));
                }, //code to navigate to appropriate screen
              ),
              ListTile(
                contentPadding: EdgeInsets.symmetric(
                    vertical: halfPadding, horizontal: doublePadding),
                leading: const Icon(Icons.thumbs_up_down),
                title: Text('Rated Songs'),
                onTap: () {
                  Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (context) => new RatedPage()));
                }, //code to navigate to appropriate screen
              ),
              ListTile(
                contentPadding: EdgeInsets.symmetric(
                    vertical: halfPadding, horizontal: doublePadding),
                leading: const Icon(Icons.history),
                title: Text('History'),
                onTap: () {
                  Navigator.push(context,
                      new MaterialPageRoute(builder: (context) => new MyApp()));
                }, //code to navigate to appropriate screen
              ),
              ListTile(
                contentPadding: EdgeInsets.symmetric(
                    vertical: halfPadding, horizontal: doublePadding),
                leading: const Icon(Icons.account_circle),
                title: Text('Friends'),
                onTap: () {
                  Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (context) => new FriendsPage()));
                }, //code to navigate to appropriate screen
              ),
            ],
          ),
        ),
        body: new Center(
            child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new RaisedButton(
                      child: new Text("Get endpoint data"),
                      onPressed: getTestEndpointData
                  ),
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
          'User name: ${user.username}\n';
//          'LastFM name: ${user.lastfm_name}\n'
//          'Join Date: ${user.join_date}\n'
//          'Email Address: ${user.email}\n';
      //endPtData = user.toString();
      //endPtData = userMap.toString();
    });

  }

}