import 'package:flutter/material.dart';
import 'package:smurp_app/models/song.dart';

import 'package:smurp_app/utils/rest_ds.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'globals.dart' as globals;



void main() => runApp(RecommendedPage());

class RecommendedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Recommended Songs',
      theme: new ThemeData(
        primaryColor: Colors.blue,
      ),
      home: new RecommendWidget(),
    );
  }
}


class RecommendPageState extends State<RecommendWidget> { // TODO: Change out WordPair for Song
  List recs;

  final RestDatasource rest = new RestDatasource();

  @override
  void initState() {
    super.initState();
    this.getRecommendData();
  }


  @override
  Widget build(BuildContext context) {
//    collectSongs();
    return Scaffold (
      appBar: AppBar(
        title: Text('Song Recommendations'),
      ),
      body:new ListView.builder(
        itemCount: recs == null ? 0 : recs.length,
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
                                recs[index]['song_title'] + ' by ' + recs[index]['artists'],
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
                    color: Colors.grey, // TODO: change endpoint to return song rating?
                    onPressed: (){
                      like(index);
                    },
                  ),
                ),
                Padding(
                  padding: new EdgeInsets.symmetric(
                      horizontal: globals.halfPadding, vertical: globals.halfPadding),
                  child: IconButton(//this icon is the thumbs down button
                    icon: const Icon(Icons.thumb_down),
                    color: Colors.grey, // TODO: change endpoint to return song rating?
                    onPressed: (){
                      dislike(index);
                    },
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }



  // Tells the database to add the song at the passed index to the user's list of likes
  // If it already is in their likes, removes instead
  void like(int index) async{
    print("Calling like(${recs[index]['song_id']})");
    rest.likeSong(globals.user_id, recs[index]['song_id']);
    initState();
    print('Song with id of: ' + recs[index]['song_id'].toString() + 'was liked');
  }

  void dislike(int index) async {
    print("Calling dislike(${recs[index]['song_id']})");
    rest.dislikeSong(globals.user_id, recs[index]['song_id']);
    setState(() {
      initState();
      print('Song with id of: ' + recs[index]['song_id'].toString() +
          'was disliked');
    });
  }

  //asynchronous call to hit the test endpoint
  // it's asynchronous because it might take a while
  // and we don't want the app to crash in the time
  // it takes to gather the data
  void getRecommendData() async {
    http.Response rResponse = await http.get(
        "http://ec2-52-91-42-119.compute-1.amazonaws.com:5000/recommend?user_id="+globals.user_id.toString()+"&session_key="+globals.session_key,
        headers: {"Accept": "application/json"});
    print(rResponse.body.toString());
    setState(() {
      recs = json.decode(rResponse.body);

      print("Successfully grabbed recs !");
    });
  }


//  Widget _buildSuggestions() {
//    this.collectSongs();
//    return ListView.builder(
//        padding: const EdgeInsets.all(16.0),
//        // The itemBuilder callback is called once per suggested word pairing,
//        // and places each suggestion into a ListTile row.
//        // For even rows, the function adds a ListTile row for the word pairing.
//        // For odd rows, the function adds a Divider widget to visually
//        // separate the entries. Note that the divider may be difficult
//        // to see on smaller devices.
//        itemBuilder: (context, i) {
//          // Add a one-pixel-high divider widget before each row in theListView.
//          if (i.isOdd) return Divider();
//
//          // The syntax "i ~/ 2" divides i by 2 and returns an integer result.
//          // For example: 1, 2, 3, 4, 5 becomes 0, 1, 1, 2, 2.
//          // This calculates the actual number of word pairings in the ListView,
//          // minus the divider widgets.
//          final index = i ~/ 2;
//          // If you've reached the end of the available word pairings...
//          if (index >= recs.length) {
//            // ...then generate 10 more and add them to the suggestions list.
////            this.collectSongs();
//          }
//
//          return _buildRow(recs[index]);
//        }
//    );
//  }



  void collectSongs() async{
    List<Song> nextSongs = await rest.getRecommendations(23);
    recs.addAll(nextSongs);
  }

//  Widget _buildRow(Song song) {
//    final bool liked = _likes.contains(song);
//    final bool disliked = _dislikes.contains(song);
//    return ListTile(
//        title: Text(
//          (song.artist + " - " + song.title),//song.title.asPascalCase,ddd
//          style: _biggerFont,
//        ),
//        trailing: new Row(
//            children: <Widget>[
//              new IconButton(
//                  icon: new Icon( (liked) ? Icons.thumb_up : Icons.add_circle_outline,
//                    color: liked ? Colors.orange : null,
//                  ),
//                  onPressed: () { setState(() {
//                    if (disliked) {
//                      _dislikes.remove(song); // if currently disliked, remove from dislikes
//                      rest.dislikeSong(user_id, song.song_id); // tell Database to remove song
//                    }
//
//                    if (liked){
//                      _likes.remove(song); // if already disliked, remove from dislikes
//                    }
//                    else{
//                      _likes.add(song);
//                    }
//                    rest.likeSong(user_id, song.song_id);  // tell Database to add/remove song, whichever is appropriate
//                  }); }
//              ),
//              new IconButton(
//                  icon: new Icon( (disliked) ? Icons.thumb_down : Icons.remove_circle_outline,
//                    color: disliked ? Colors.orange : null,
//                  ),
//                  onPressed: () { setState(() {
//                    if (liked) {
//                      _likes.remove(song); // if currently liked, remove from likes
//                      rest.likeSong(user_id, song.song_id); // tell Database to remove song
//                    }
//
//                    if (disliked){
//                      _dislikes.remove(song); // if already disliked, remove from dislikes
//                    }
//                    else{
//                      _dislikes.add(song); // else add to dislikes
//                    }
//                    rest.dislikeSong(user_id, song.song_id);  // tell Database to add/remove song, whichever is appropriate
//
//                  }); }
//              ),
//            ],
//            mainAxisSize: MainAxisSize.min)
//    );
//  }

} // end RandomWordsState


class RecommendWidget extends StatefulWidget {
  @override
  RecommendPageState createState() => new RecommendPageState();
}





