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


void main() => runApp(RatedPage());

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
                      _dislikes.remove(song); // if currently disliked, remove from dislikes
                      // TODO: Tell Database to remove song
                    }

                    if (liked){
                      _likes.remove(song); // if already disliked, remove from dislikes
                      // TODO: Tell Database to remove song
                    }
                    else{
                      _likes.add(song);
                      // TODO: Tell Database to add song
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
                      // TODO: Tell Database to remove song
                    }

                    if (disliked){
                      _dislikes.remove(song); // if already disliked, remove from dislikes
                      // TODO: Tell Database to remove song
                    }
                    else{
                      _dislikes.add(song); // else add to dislikes
                      // TODO: Tell Database to add song
                    }
                  }); }
              ),
            ],
            mainAxisSize: MainAxisSize.min)
    );
  }
}