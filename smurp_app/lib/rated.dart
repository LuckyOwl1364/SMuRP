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
import 'package:smurp_app/utils/rest_ds.dart';
import 'globals.dart' as globals;


//void main() => runApp(RatedPage());

class RatedPage extends StatefulWidget {
  @override
  RatedPageState createState() => new RatedPageState();
}




class RatedPageState extends State<RatedPage> {
  final _biggerFont = const TextStyle(fontSize: 18.0);

  List likes;
  List dislikes;

  final RestDatasource rest = new RestDatasource();


  @override
  void initState() {
    super.initState();
    this.getRatedData();
    print("called getRatedData()");
  }




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


  Widget _buildSuggestions(bool grabLikes) {
//    this.collectSongs(grabLikes);
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


  void like(List list, int index) async{
    print("Calling like(${list[index]['song_id']})");
    rest.likeSong(globals.user_id, list[index]['song_id']);
    initState();
    print('Song with id of: ' + list[index]['song_id'].toString() + 'was liked');
  }

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

  Widget _buildRow(Song song, bool grabLikes) {
    final bool liked = likes.contains(song);
    final bool disliked = dislikes.contains(song);
    print("Song: ${song.artist} - ${song.title}");
    return ListTile(
        title: Text(
          (song.artist + " - " + song.title),
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
                      dislikes.remove(song); // if currently disliked, remove from dislikes
                      rest.dislikeSong(globals.user_id, song.song_id); // tell Database to remove song
                    }

                    if (liked){
                      likes.remove(song); // if already disliked, remove from dislikes
                    }
                    else{
                      likes.add(song);
                    }
                    rest.likeSong(globals.user_id, song.song_id);  // tell Database to add/remove song, whichever is appropriate
                  }); }
              ),
              new IconButton(
                  icon: new Icon( (disliked) ? Icons.thumb_down : Icons.remove_circle_outline,
                    color: disliked ? Colors.orange : null,
                  ),
                  onPressed: () { setState(() {
                    if (liked) {
                      likes.remove(song); // if currently liked, remove from likes
                      rest.likeSong(globals.user_id, song.song_id); // tell Database to remove song
                    }

                    if (disliked){
                      dislikes.remove(song); // if already disliked, remove from dislikes
                    }
                    else{
                      dislikes.add(song); // else add to dislikes
                    }
                    rest.dislikeSong(globals.user_id, song.song_id);  // tell Database to add/remove song, whichever is appropriate

                  }); }
              ),
            ],
            mainAxisSize: MainAxisSize.min)
    );
  }
}