import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smurp_app/models/user.dart';
import 'package:smurp_app/history.dart';
import 'package:smurp_app/rated.dart';
import 'package:smurp_app/friends.dart';
import 'package:smurp_app/profile.dart';
import 'package:smurp_app/recommended.dart';
import 'package:smurp_app/data/rest_ds.dart';
import 'package:smurp_app/main.dart';
import 'globals.dart' as globals;


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
  final RestDatasource rest = new RestDatasource();
  String endPtData = "Endpoint Data Username";
  String feedData = "Testing Feed. . . Did it work? ";
  List feedList;

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
                  accountName: Text(globals.username == null ? 'empty username' : globals.username),
                  accountEmail: Text('SMuRP'),
                  decoration: BoxDecoration(
                    color: Colors.lightBlue,
                  )),
              ListTile(
                contentPadding: EdgeInsets.symmetric(
                    vertical: globals.halfPadding, horizontal: globals.doublePadding),
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
                    vertical: globals.halfPadding, horizontal: globals.doublePadding),
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
                    vertical: globals.halfPadding, horizontal: globals.doublePadding),
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
                    vertical: globals.halfPadding, horizontal: globals.doublePadding),
                leading: const Icon(Icons.history),
                title: Text('History'),
                onTap: () {
                  Navigator.push(context,
                      new MaterialPageRoute(builder: (context) => new HistoryPage()));
                }, //code to navigate to appropriate screen
              ),
              ListTile(
                contentPadding: EdgeInsets.symmetric(
                    vertical: globals.halfPadding, horizontal: globals.doublePadding),
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
                    vertical: globals.halfPadding, horizontal: globals.doublePadding),
                leading: const Icon(Icons.exit_to_app),
                title: Text('Log Out'),
                onTap: () {
                  globals.isLoggedIn = false;
                  logOut();
                  //Navigator.pop(context); // TODO: Make it actually exit the app & session  ~~~~~~~~~~~~~
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
                children : <Widget>[
                  Expanded(
                    child: Padding(
                      padding: new EdgeInsets.all(globals.doublePadding),
                        child : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children : [
                            Text(
                              //if there's no username, replace it with the string 'null value' otherwise display the username.
                              //Also decide on whether the user 'listened to' or 'liked a song'
                                feedList[index]['username'] == null ? 'null value ' + index.toString() + (feedList[index]['rating'] == 1 ? ' liked ' : ' recently listened to ')
                                          : feedList[index]['username'] + (feedList[index]['rating'] == 1 ? ' liked ' : ' recently listened to '),
                                textAlign: TextAlign.start,
                                style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              //display the song's title and artist
                                feedList[index]['song_title'] + ' by ' + feedList[index]['artist'],
                                textAlign: TextAlign.start),

                          ]//end of column children
                        )//end of column
                    ),//end of padding
                  ), //end of expanded
                   Padding(
                      padding: new EdgeInsets.symmetric(
                          horizontal: globals.halfPadding, vertical: globals.halfPadding),
                      child: IconButton(//this icon is the thumbs up button
                        icon: const Icon(Icons.thumb_up),
                        color: feedList[index]['rating'] == 1 ? Colors.lightBlue : Colors.grey,
                        onPressed: (){
                          like(feedList[index]['song_id']);
                        },
                      ),
                  ),
                  Padding(
                    padding: new EdgeInsets.symmetric(
                        horizontal: globals.halfPadding, vertical: globals.halfPadding),
                    child: IconButton(//this icon is the thumbs down button
                      icon: const Icon(Icons.thumb_down),
                      color: feedList[index]['rating'] == 0 ? Colors.lightBlue : Colors.grey,
                      onPressed: (){
                        dislike(feedList[index]['song_id']);
                      },
                    ),
                  )
                ],//end widget
              ),//end row
            );//end card
          },//end itembuilder
        ),//end listview builder
    );
  }

  //pass in the songID
  void like(int songID) async{
    print("Calling like("+songID.toString()+")");
    rest.likeSong(globals.user_id, songID);
//    initState();
    print('Song with id of: ' + songID.toString() + ' was liked');
  }

  //pass in the songID
  void dislike(int songID) async {
    print("Calling dislike("+songID.toString()+")");
    rest.dislikeSong(globals.user_id, songID);
//    initState();
    print('Song with id of: ' + songID.toString() + ' was disliked');
  }

  //asynchronous call to hit endpoint
  // it's asynchronous because it might take a while
  // and we don't want the app to crash in the time
  // it takes to gather the data
//  Future<String> getFeedData() async {
//    print("Going to call getfeed endpoint with: "+globals.user_id.toString()+" and "+globals.session_key);
//    http.Response response = await http.get(
//        "http://ec2-52-91-42-119.compute-1.amazonaws.com:5000/getfeed?user_id="+globals.user_id.toString()+"&session_key="+globals.session_key,
//        headers: {"Accept": "application/json"});
//
//    setState(() {
//      feedList = json.decode(response.body);
//      feedData = 'Successfully grabbed some data!';
//
//      print(feedData);
//    });
//  }

  //TODO:NEW STUFF~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  Future<String> getFeedData() async {
    print("Using the client to call getfeed endpoint with: " +
        globals.user_id.toString() + " and " + globals.session_key);
    globals.client.getUrl(Uri.parse(
        "http://ec2-52-91-42-119.compute-1.amazonaws.com:5000/getfeed?user_id="
            + globals.user_id.toString() + "&session_key=" +
            globals.session_key))
        .then((request) => request.close())
        .then((response) =>
          response.transform(utf8.decoder).listen(print));
  }
  //TODO:NEW STUFF~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  Future<Null> logOut() async {
    print('Log out endoint ahead ');
    http.Response response = await http.get(
        "http://ec2-52-91-42-119.compute-1.amazonaws.com:5000/logout?username="+globals.user_id.toString(),
        headers: {"Accept": "application/html"});

    print('cool. we back');
    //exit(0);
    sleep(const Duration(seconds:1));
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/',(Route<dynamic> route) => false);
   }

}