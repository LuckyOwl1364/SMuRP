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
  String endPtData = "Endpoint Data Username";
  String feedData = "Testing Feed. . . Did it work? ";
  List feedList;
  double regularPadding = 8.0;
  double halfPadding = 4.0;
  double doublePadding = 16.0;

  @override
  void initState() {
    super.initState();
    this.getFeedData();
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
                  accountEmail: Text('SMuRP'),
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
                      new MaterialPageRoute(builder: (context) => new HistoryPage()));
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
              ListTile(
                contentPadding: EdgeInsets.symmetric(
                    vertical: halfPadding, horizontal: doublePadding),
                leading: const Icon(Icons.exit_to_app),
                title: Text('Log Out'),
                onTap: () {
                  Navigator.pop(context); // TODO: Make it actually exit the app & session  ~~~~~~~~~~~~~
                }, //code to navigate to appropriate screen
              )
            ],
          ),
        ),
        body: new ListView.builder(
          itemCount: feedList == null ? 0 : feedList.length,
          itemBuilder: (BuildContext context, int index){
            return new Card(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                      child: Padding(
                        padding: new EdgeInsets.all(doublePadding),
                        child: new Text(
                            feedList[index]['username'] == null ? 'null value ' + index.toString() + ' recently listened to '+feedList[index]['song_title'] + ' by ' + feedList[index]['artist']
                                : feedList[index]['username'] + ' recently listened to '+feedList[index]['song_title'] + ' by ' + feedList[index]['artist'],
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
  Future<String> getFeedData() async {
    http.Response response = await http.get(
        "http://ec2-52-91-42-119.compute-1.amazonaws.com:5000/getfeed?user_id=1",
        headers: {"Accept": "application/json"});

    setState(() {
      feedList = json.decode(response.body);
      feedData = 'Successfully grabbed some data!';

      print(feedData);
    });
  }

}