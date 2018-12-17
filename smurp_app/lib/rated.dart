import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smurp_app/models/song.dart';
import 'package:smurp_app/data/rest_ds.dart';
import 'globals.dart' as globals;


// When file called to run, do the following
class RatedPage extends StatefulWidget {
  @override
  RatedPageState createState() => new RatedPageState();
}

// Page body. This contains every part of the page that isn't the header
class RatedPageState extends State<RatedPage> {

  List likes;
  List dislikes;

  final RestDatasource rest = new RestDatasource();   // object for talking to the database

  // When class is instantiated, do this before anything else
  @override
  void initState() {
    super.initState();
    this.getRatedData();
    print("called getRatedData()");
  }

  // Builds the body of the screen, including the feed and the sidebar
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "Rated page",
      home: new DefaultTabController(
        length:2,
        child:  new Scaffold(
            appBar: new AppBar(
                leading: new IconButton(//this is the backbutton
                  icon: new Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(null),
                ),
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


  // Build the screen tab body for each tab
  // grabLikes -> get the likes list
  // !grabLikes -> get the dislikes list
  Widget _buildSuggestions(bool grabLikes) {
    List list = grabLikes ? likes : dislikes;
    return ListView.builder(
      itemCount: list == null ? 0 : list.length,
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
                            //display the song's title and artist
                              list[index]['song_title'] + ' by ' + list[index]['artist'],
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
                  color: list[index]['rating'] == 1 ? Colors.lightBlue : Colors.grey,
                  onPressed: (){
                    like(list, index);
                  },
                ),
              ),
              Padding(
                padding: new EdgeInsets.symmetric(
                    horizontal: globals.halfPadding, vertical: globals.halfPadding),
                child: IconButton(//this icon is the thumbs down button
                  icon: const Icon(Icons.thumb_down),
                  color: list[index]['rating'] == 0 ? Colors.lightBlue : Colors.grey,
                  onPressed: (){
                    dislike(list, index);
                  },
                ),
              )
            ],
          ),
        );
      },
    );
  }

  // Adds a song to the 'likes' list
  // If already liked, removes instead
  // If currently dislikes, removes from that list then adds to likes
  void like(List list, int index) async{
    print("Calling like(${list[index]['song_id']})");
    rest.likeSong(globals.user_id, list[index]['song_id']);
    initState();
    print('Song with id of: ' + list[index]['song_id'].toString() + 'was liked');
  }

  // Adds a song to the 'dislikes' list
  // If already disliked, removes instead
  // If currently in likes, removes from that list then adds to dislikes
  void dislike(List list, int index) async {
    print("Calling dislike(${list[index]['song_id']})");
    rest.dislikeSong(globals.user_id, list[index]['song_id']);
    setState(() {
      initState();
      print('Song with id of: ' + list[index]['song_id'].toString() +
          'was disliked');
    });
  }

  //asynchronous call to hit the test endpoint
  // it's asynchronous because it might take a while
  // and we don't want the app to crash in the time
  // it takes to gather the data
  void getRatedData() async {
    http.Response lResponse = await http.get(
        "http://ec2-52-91-42-119.compute-1.amazonaws.com:5000/likedsongs?user_id="+globals.user_id.toString(),
        headers: {"Accept": "application/json"});
    http.Response dResponse = await http.get(
        "http://ec2-52-91-42-119.compute-1.amazonaws.com:5000/dislikedsongs?user_id="+globals.user_id.toString(),
        headers: {"Accept": "application/json"});
    print(lResponse.body.toString());
    print(dResponse.body.toString());
    setState(() {
      likes = json.decode(lResponse.body);
      dislikes = json.decode(dResponse.body);

      print("Successfully grabbed likes/dislikes !");
    });
  }

  // get the songs from the database, depending on whether to get the likes or dislikes list
  void collectSongs(bool grabLikes) async{
    if (grabLikes){
      List<Song> nextSongs = await rest.getLikedSongs(globals.user_id);
      likes.addAll(nextSongs);
    }
    else{
      List<Song> nextSongs = await rest.getDislikedSongs(globals.user_id);
      dislikes.addAll(nextSongs);
    }
  }

}