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
import 'package:smurp_app/friend_profile.dart';
import 'globals.dart' as globals;


class FriendsPage extends StatefulWidget {
  @override
  FriendsPageState createState() => new FriendsPageState();
}

class FriendsPageState extends State<FriendsPage> {
  String endPtData = "Test Data ";
  List data;

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
            return InkWell(
              onTap: (){
                globals.friend_id = followingList[index]['user_id']; //assign a friend's user id
                Navigator.push( //code to open up a new friend's profile screen
                    context,
                    new MaterialPageRoute(
                        builder: (context) => new FriendProfilePage()));
              },
              child: new Card(
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(
                          child: Padding(
                            padding: new EdgeInsets.all(globals.regularPadding),
                            child: new Text(
                                followingList[index]['username'] == null ? 'null value' : followingList[index]['username'],
                                textAlign: TextAlign.start),
                          )),
                      Padding(
                        padding: new EdgeInsets.symmetric(
                            horizontal: globals.regularPadding, vertical: globals.halfPadding),
                        child: RaisedButton(
                          onPressed: (){
                            unfollow(globals.user_id, followingList[index]['user_id']);
                          },
                          child: new Text('Unfollow'),
                          color: Colors.grey,
                          textColor: Colors.white,
                        ),
                      )
                    ],//end widget
                ),//end row
              ),//end card
            );//end inkwell
          },//end itembuilder
        ),//end listview builder
    );
  }

  //async call to get data from endpoint
  Future<String> getFollowingData() async {
    http.Response response = await http.get(
        "http://ec2-52-91-42-119.compute-1.amazonaws.com:5000/getfollowing?user_id="+globals.user_id.toString(),
        headers: {"Accept": "application/json"});

    setState(() {
      followingList = json.decode(response.body);
      followingData = 'Successfully grabbed some following data!';

      print(followingData);
    });
  }

  void unfollow(int userID_1, int userID_2) {
      if(userID_1 == null || userID_2 == null){
        print("ERROR, one of the user id's provided was invalid.");
      } else {
        hitUnfollowsEndpoint(userID_1, userID_2);
      }
  }

  //async call to hit unfollows endpoint
  Future<String> hitUnfollowsEndpoint(int userID_1, int userID_2) async {
    print('Attempting the follow endpoint');
    http.Response response = await http.get(
        "http://ec2-52-91-42-119.compute-1.amazonaws.com:5000/unfollows?user_id1=" +
            userID_1.toString() + "&user_id2=" + userID_2.toString()+'&session_key='+globals.session_key,
        headers: {"Accept": "application/json"});

    setState(() {
      var unfollowResponse = json.decode(response.body);
      print(unfollowResponse.toString());
      followingData += " unfollowed";
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

  @override
  void initState() {
    super.initState();
    this.getFollowerData();
    this.getFollowingData();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new ListView.builder(
        itemCount: followerList == null ? 0 : followerList.length,
        itemBuilder: (BuildContext context, int index){
          return InkWell(//this inkwell gives the user the ability to tap on cards
            onTap: (){
              globals.friend_id = followerList[index]['user_id']; //assign a friend's user id
              Navigator.push( //code to open up a new friend's profile screen
                  context,
                  new MaterialPageRoute(
                      builder: (context) => new FriendProfilePage()));
            },
            child: new Card(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                      child: Padding(
                        padding: new EdgeInsets.all(globals.regularPadding),
                        child: new Text(
                            followerList[index]['username'] == null ? 'null value' : followerList[index]['username'],
                            textAlign: TextAlign.start),
                      )),
                  Padding(
                    padding: new EdgeInsets.symmetric(
                        horizontal: globals.regularPadding, vertical: globals.halfPadding),
                    child: RaisedButton(
                      onPressed: (){
                        checkFollowing(followerList[index]['user_id']) ? unfollow(globals.user_id,followerList[index]['user_id'])
                            :follow(globals.user_id,followerList[index]['user_id']);
                      },
                      child: new Text(checkFollowing(followerList[index]['user_id']) ? 'Unfollow' : 'Follow'),
                      color: checkFollowing(followerList[index]['user_id']) ? Colors.grey : Colors.lightBlue,
                      textColor: Colors.white,
                    ),
                  )
                ],//end widget
              ),//end row
            ),//end card
          );//end InkWell
        },//end itembuilder
      ),//end listview builder
    );
  }

  //async call to get data from endpoint
  Future<String> getFollowerData() async {
    http.Response response = await http.get(
        "http://ec2-52-91-42-119.compute-1.amazonaws.com:5000/getfollowers?user_id="+globals.user_id.toString(),
        headers: {"Accept": "application/json"});

    setState(() {
      followerList = json.decode(response.body);
      followerData = 'Successfully grabbed some follower data!';

      print(followerData);
    });
  }


  //async call to get data from endpoint
  Future<String> getFollowingData() async {
    http.Response response = await http.get(
        "http://ec2-52-91-42-119.compute-1.amazonaws.com:5000/getfollowing?user_id="+globals.user_id.toString(),
        headers: {"Accept": "application/json"});

    setState(() {
      followingList = json.decode(response.body);
      followingData = 'Successfully grabbed some following data!';

      print(followingData);
    });
  }

  void follow(int userID_1, int userID_2) {
    if(userID_1 == null || userID_2 == null){
      print("ERROR, one of the user id's provided was invalid.");
    } else {
      hitFollowsEndpoint(userID_1, userID_2);
    }
  }

  //async call to hit follows endpoint
  Future<String> hitFollowsEndpoint(int userID_1, int userID_2) async {
    print('Attempting the follow endpoint');
    http.Response response = await http.get(
        "http://ec2-52-91-42-119.compute-1.amazonaws.com:5000/follows?user_id1=" +
            userID_1.toString() + "&user_id2=" + userID_2.toString()+'&session_key='+globals.session_key,
        headers: {"Accept": "application/json"});

    setState(() {
      var followResponse = json.decode(response.body);
      print(followResponse.toString());
      followerData += " followed";
    });
  }

  void unfollow(int userID_1, int userID_2) {
    if(userID_1 == null || userID_2 == null){
      print("ERROR, one of the user id's provided was invalid.");
    } else {
      hitUnfollowsEndpoint(userID_1, userID_2);
    }
  }

  //async call to hit unfollows endpoint
  Future<String> hitUnfollowsEndpoint(int userID_1, int userID_2) async {
    print('Attempting the unfollow endpoint with:' + globals.session_key+".Fingers crossed hope it works");

    http.Response response = await http.get(
        "http://ec2-52-91-42-119.compute-1.amazonaws.com:5000/unfollows?user_id1=" +
            userID_1.toString() + "&user_id2=" + userID_2.toString() + '&session_key=' + globals.session_key,
        headers: {"Accept": "application/json"});

    setState(() {
      var unfollowResponse = json.decode(response.body);
      print(unfollowResponse.toString());
      followingData += " unfollowed";
    });
  }


  //method to check if you are following the other user.
  //Returns true if you're following them. False if you're not following them
  bool checkFollowing(int userID){
    bool isFollowing = false;
    int numFollowing = (followingList == null ? 0 : followingList.length); //check to see if the list is empty

      if(userID == null){//check to see if userid is empty
        return false;
      } else {
        for(int index = 0; index < numFollowing; index ++){ //check to see if the userid is in the list of following
          if (followingList[index]['user_id'] == userID) {
            isFollowing = true;
          }
        }
        return isFollowing;
      }
    }
}