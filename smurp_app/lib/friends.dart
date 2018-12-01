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
                  leading: new IconButton(//this is the backbutton
                    icon: new Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(null),
                  ),
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

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//this widget is what should be under the first tab
class FirstWidget extends StatefulWidget {
  @override
  FollowingPageState createState() => new FollowingPageState();
}
//this is the state that fills the first widget
class FollowingPageState extends State<FirstWidget> {
  String followingData = "Testing Following. . . Did it work? ";
  List followingList;
  double regularPadding = 8.0;
  double halfPadding = 4.0;
  double doublePadding = 16.0;

  @override
  void initState() {
    super.initState();
    this.getFollowingData();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
       body: new ListView.builder(
          itemCount: followingList == null ? 0 : followingList.length,
          itemBuilder: (BuildContext context, int index){
            return new Card(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Expanded(
                        child: Padding(
                          padding: new EdgeInsets.all(regularPadding),
                          child: new Text(
                              followingList[index]['User name'] == null ? 'null value' : followingList[index]['User name'],
                              textAlign: TextAlign.start),
                        )),
                    Padding(
                      padding: new EdgeInsets.symmetric(
                          horizontal: regularPadding, vertical: halfPadding),
                      child: RaisedButton(
                        onPressed: (){
                          unfollow();
                        },
                        child: const Text('Unfollow'),
                        color: Colors.lightBlue,
                        textColor: Colors.white,
                      ),
                    )
                  ],//end widget
              ),//end row
            );//end card
          },//end itembuilder
        ),//end listview builder
    );
  }

  //async call to get data from endpoint
  Future<String> getFollowingData() async {
    http.Response response = await http.get(
        "http://ec2-52-91-42-119.compute-1.amazonaws.com:5000/getfollowing?user_id=3",
        headers: {"Accept": "application/json"});

    setState(() {
      followingList = json.decode(response.body);
      followingData = 'Successfully grabbed some data!';

      print(followingData);
    });
  }

  void unfollow() {
    setState(() {
      //hit the endpoint
      followingData += " Unfollowed";
    });
  }
}//end of first widget (following) state

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//this widget is what should be under the second tab
class SecondWidget extends StatefulWidget {
  @override
  FollowersPageState createState() => new FollowersPageState();
}
//this is the state for the second widget tab (followers)
class FollowersPageState extends State<SecondWidget> {
  String followingData = "Testing Following. . . Did it work? ";
  List followingList;
  String followerData = "Testing Followers. . . Did it work? ";
  List followerList;
  double regularPadding = 8.0;
  double halfPadding = 4.0;
  double doublePadding = 16.0;

  @override
  void initState() {
    super.initState();
    this.getFollowerData();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new ListView.builder(
        itemCount: followerList == null ? 0 : followerList.length,
        itemBuilder: (BuildContext context, int index){
          return new Card(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                    child: Padding(
                      padding: new EdgeInsets.all(regularPadding),
                      child: new Text(
                          followerList[index]['User name'] == null ? 'null value' : followerList[index]['User name'],
                          textAlign: TextAlign.start),
                    )),
                Padding(
                  padding: new EdgeInsets.symmetric(
                      horizontal: regularPadding, vertical: halfPadding),
                  child: RaisedButton(
                    onPressed: (){follow();},
                    child: const Text('Follow'),
                    color: checkFollowing(followerList[index]['User ID']) ? Colors.lightBlue : Colors.grey,
                    textColor: Colors.white,
                  ),
                )
              ],//end widget
            ),//end row
          );//end card
        },//end itembuilder
      ),//end listview builder
    );
  }

  //async call to get data from endpoint
  Future<String> getFollowerData() async {
    http.Response response = await http.get(
        "http://ec2-52-91-42-119.compute-1.amazonaws.com:5000/getfollowers?user_id=3",
        headers: {"Accept": "application/json"});

    setState(() {
      followerList = json.decode(response.body);
      followerData = 'Successfully grabbed some data!';

      print(followerData);
    });
  }


  //async call to get data from endpoint
  Future<String> getFollowingData() async {
    http.Response response = await http.get(
        "http://ec2-52-91-42-119.compute-1.amazonaws.com:5000/getfollowing?user_id=3",
        headers: {"Accept": "application/json"});

    setState(() {
      followingList = json.decode(response.body);
      followingData = 'Successfully grabbed some data!';

      print(followingData);
    });
  }

  void follow() {
    setState(() {
      //hit the endpoint
      followerData += " followed";
    });
  }

  //method to check if you are following the other user
  bool checkFollowing(int userID){

    if(userID == null){
      return false;
    } else {
      getFollowingData();
      bool isFollowing = false;
      int numFollowing = followingList.length();

      for(int index = 0; index < numFollowing; index ++){
        if (followingList[index]['User ID'] == userID) {
          isFollowing = true;
        }
      }

      return isFollowing;
    }
  }
}