import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smurp_app/history.dart';
import 'package:smurp_app/models/user.dart';
import 'package:smurp_app/utils/endpointDemo.dart';

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
  void initState() {
    super.initState();
    this.getData();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Following"),
      ),
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
                        builder: (context) => new EndpointDemoPage()));
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
                        builder: (context) => new EndpointDemoPage()));
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
                        builder: (context) => new EndpointDemoPage()));
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
              title: Text('Log Out'),
              onTap: () {
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (context) => new EndpointDemoPage()));
              }, //code to navigate to appropriate screen
            ),
          ],
        ),
      ),
      body: new ListView.builder(
        itemCount: 1,
        itemBuilder: (BuildContext context, int index) {
          return new Card(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                    child: Padding(
                  padding: new EdgeInsets.all(regularPadding),
                  child: new Text(endPtData, textAlign: TextAlign.start),
                )),
                Padding(
                  padding: new EdgeInsets.symmetric(
                      horizontal: regularPadding, vertical: halfPadding),
                  child: RaisedButton(
                    onPressed: unfollow,
                    child: const Text('Unfollow'),
                    color: Colors.lightBlue,
                    textColor: Colors.white,
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  } //build

  void unfollow() {
    setState(() {
      //hit the endpoint
      endPtData += " Unfollowed";
    });
  }
} //FollowingPageState
