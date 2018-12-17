import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smurp_app/friend_profile.dart';
import 'globals.dart' as globals;

// When the file is called to start, run the following
class RecommendedUsersPage extends StatefulWidget {
  @override
  RecommendedUsersPageState createState() => new RecommendedUsersPageState();
}

// Page body. This contains every part of the page that isn't the header
class RecommendedUsersPageState extends State<RecommendedUsersPage> {
  String recommendedUsersData = "Test Data ";
  List UserList;

  // When class is instantiated, do this before anything else
  @override
  void initState() {
    super.initState();
    this.getRecommendedUsers();
  }

  // Builds the body of the screen, including the cards for songs
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: Text('Recommended Friends')),
      body: new ListView.builder(
        itemCount: UserList == null ? 0 : UserList.length,
        itemBuilder: (BuildContext context, int index){
          return InkWell(
            onTap: (){
              globals.friend_id = UserList[index]['user_id']; //assign a friend's user id
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
                            UserList[index]['username'] == null ? 'null value' : UserList[index]['username'],
                            textAlign: TextAlign.start),
                      )),
                  Padding(
                    padding: new EdgeInsets.symmetric(
                        horizontal: globals.regularPadding, vertical: globals.halfPadding),
                    child: RaisedButton(
                      onPressed: (){
                        follow(globals.user_id, UserList[index]['user_id']);
                      },
                      child: new Text('Follow'),
                      color: Colors.lightBlue,
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

  // adds the user to your followed list
  // if already followed said user, unfollows instead
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
      print("User "+userID_2.toString()+ " followed");
    });
  }

  //async call to hit get recommended users endpoint
  Future<String> getRecommendedUsers() async {
    print('Attempting the recommended users endpoint');
    http.Response response = await http.get(
        "http://ec2-52-91-42-119.compute-1.amazonaws.com:5000/recommendusers?user_id=" +
            globals.user_id.toString() + '&session_key='+globals.session_key,
        headers: {"Accept": "application/json"});

    setState(() {
      UserList = json.decode(response.body);
      recommendedUsersData = 'Successfully grabbed some suggested users data!';

      print(recommendedUsersData);
      print(UserList);
    });
  }

} //end of Recommended State

