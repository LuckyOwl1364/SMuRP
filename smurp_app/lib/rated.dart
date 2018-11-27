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
import 'package:smurp_app/models/song.dart';
import 'package:smurp_app/data/rest_ds.dart';


void main() {
  runApp(new MaterialApp(
    home: new RatedPage(),
  ));
}

class RatedPage extends StatefulWidget {
  @override
  RatedPageState createState() => new RatedPageState();
}

class RatedPageState extends State<RatedPage> {
  double regularPadding = 8.0;
  double halfPadding = 4.0;
  double doublePadding = 16.0;
  final _biggerFont = const TextStyle(fontSize: 18.0);

  final _likes = <Song>[];
  final _dislikes = <Song>[];

  final RestDatasource rest = new RestDatasource();

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "Rated page",
      home: new DefaultTabController(
        length:2,
        child:  new Scaffold(
            appBar: new AppBar(
                title: new Text("Rated Songs"),
                //creating tabs
                bottom: new TabBar(
                    tabs: <Widget>[
                      new Tab(text: "Liked Songs"),
                      new Tab(text: "Disliked Songs"),
                    ]//end of widget
                )//end of tab bar
            ),
            body: new TabBarView(
                children: <Widget>[
                  _buildSuggestions(true),  // with grabLikes == true
                  _buildSuggestions(false), // with grabLikes == false
                ]
            )
        ),
      ),
    );
  } //build


  Widget _buildSuggestions(bool grabLikes) {
    this.collectSongs(grabLikes);
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        // The itemBuilder callback is called once per suggested word pairing,
        // and places each suggestion into a ListTile row.
        // For even rows, the function adds a ListTile row for the word pairing.
        // For odd rows, the function adds a Divider widget to visually
        // separate the entries. Note that the divider may be difficult
        // to see on smaller devices.
        itemBuilder: (context, i) {
          // Add a one-pixel-high divider widget before each row in theListView.
          if (i.isOdd) return Divider();

          // The syntax "i ~/ 2" divides i by 2 and returns an integer result.
          // For example: 1, 2, 3, 4, 5 becomes 0, 1, 1, 2, 2.
          // This calculates the actual number of word pairings in the ListView,
          // minus the divider widgets.
          final index = i ~/ 2;
          // If you've reached the end of the available word pairings...

          return _buildRow( ((grabLikes) ? _likes[index] : _dislikes[index]), grabLikes);
        }
    );
  }



  void collectSongs(bool grabLikes) async{
    if (grabLikes){
      List<Song> nextSongs = await rest.getLikedSongs(23);
      _likes.addAll(nextSongs);
    }
    else{
      List<Song> nextSongs = await rest.getDislikedSongs(23);
      _dislikes.addAll(nextSongs);
    }
  }

  Widget _buildRow(Song song, bool grabLikes) {
    final bool liked = _likes.contains(song);
    final bool disliked = _dislikes.contains(song);
    return ListTile(
        title: Text(
          (song.artist + " - " + song.title),//song.title.asPascalCase,ddd
          style: _biggerFont,
        ),
        trailing: new Row(
            children: <Widget>[
              new IconButton(
                  icon: new Icon( (liked) ? Icons.thumb_up : Icons.add_circle_outline,
                    color: liked ? Colors.orange : null,
                  ),
                  onPressed: () { setState(() {
                    if (disliked) {
                      _dislikes.remove(song); // if currently disliked, remove from dislikes
                    }

                    if (liked){
                      _likes.remove(song); // if already disliked, remove from dislikes
                    }
                    else{
                      _likes.add(song);
                    }
                  }); }
              ),
              new IconButton(
                  icon: new Icon( (disliked) ? Icons.thumb_down : Icons.remove_circle_outline,
                    color: disliked ? Colors.orange : null,
                  ),
                  onPressed: () { setState(() {
                    if (liked) {
                      _likes.remove(song); // if currently liked, remove from likes
                    }

                    if (disliked){
                      _dislikes.remove(song); // if already disliked, remove from dislikes
                    }
                    else{
                      _dislikes.add(song); // else add to dislikes
                    }
                  }); }
              ),
            ],
            mainAxisSize: MainAxisSize.min)
    );
  }
} //end of FriendsPageState

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
    this.getData();
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
                    onPressed: unfollow,
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
  Future<String> getData() async {
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
  String followerData = "Testing Followers. . . Did it work? ";
  List followerList;
  double regularPadding = 8.0;
  double halfPadding = 4.0;
  double doublePadding = 16.0;

  @override
  void initState() {
    super.initState();
    this.getData();
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
                    onPressed: follow,
                    child: const Text('Follow'),
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
  Future<String> getData() async {
    http.Response response = await http.get(
        "http://ec2-52-91-42-119.compute-1.amazonaws.com:5000/getfollowers?user_id=3",
        headers: {"Accept": "application/json"});

    setState(() {
      followerList = json.decode(response.body);
      followerData = 'Successfully grabbed some data!';

      print(followerData);
    });
  }

  void follow() {
    setState(() {
      //hit the endpoint
      followerData += " followed";
    });
  }
}