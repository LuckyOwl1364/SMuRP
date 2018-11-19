import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:smurp_app/models/artist.dart';
import 'package:smurp_app/models/song.dart';

import 'package:smurp_app/data/rest_ds.dart';
import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Song History',
      theme: new ThemeData(
        primaryColor: Colors.blue,
      ),
      home: new SpecificWords(),
    );
  }
}


class RandomWordsState extends State<SpecificWords> { // TODO: Change out WordPair for Song
  final _history = <Song>[];
  final List<Song> _likes = new List<Song>();
  final List<Song> _dislikes = new List<Song>();
  final _biggerFont = const TextStyle(fontSize: 18.0);
  bool isLikes = false;

  final RestDatasource rest = new RestDatasource();

  @override
  Widget build(BuildContext context) {
//    collectSongs();
    return Scaffold (
      appBar: AppBar(
        title: Text('Song History'),
        actions: <Widget>[
          new IconButton(icon: const Icon(Icons.thumbs_up_down), onPressed: _resetAndPushRated),
        ],
      ),
      body: _buildSuggestions(),
    );
  }
  void _resetAndPushRated(){
    isLikes = false;
    _pushRated();
  } // Resets page so opening Likes/Dislikes from History always opens at Likes
  Widget _buildSuggestions() {
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
          if (index >= _history.length) {
            // ...then generate 10 more and add them to the suggestions list.
            collectSongs();
          }

          return _buildRow(_history[index]);
        }
    );
  }


  @override
  void initState() {
    super.initState();
    this.collectSongs();
  }

  void collectSongs() async{
    List<Song> nextSongs = await rest.getListenedSongs(23);
    _history.addAll(nextSongs);
  }

  Widget _buildRow(Song song) {
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

  void _pushRated() {
    isLikes = !isLikes;

    Navigator.of(context).push(
      new MaterialPageRoute<void>(
        builder: (BuildContext context) {
          final Iterable<ListTile> tiles = isLikes ?    _likes.map((Song song) { return _buildRow(song); }, )
              : _dislikes.map((Song song) { return _buildRow(song); }, ) ;
          final List<Widget> divided = ListTile
              .divideTiles(
            context: context,
            tiles: tiles,
          )
              .toList();

          return new Scaffold(
            appBar: new AppBar(
              title: isLikes ? const Text('Liked Songs') : const Text('Disliked Songs'),
              actions: <Widget>[
                new IconButton(icon: const Icon(Icons.thumbs_up_down), onPressed: _popAndPushRated),
              ],
            ),
            body: new ListView(children: divided),
          );
        },
      ),
    );
  } // end _pushRated

  void _popAndPushRated(){
    Navigator.pop(context);
    _pushRated();
  }
} // end RandomWordsState


class SpecificWords extends StatefulWidget {
  @override
  RandomWordsState createState() => new RandomWordsState();
}





