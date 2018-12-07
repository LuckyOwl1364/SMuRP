import 'package:flutter/material.dart';
import 'package:smurp_app/models/song.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'globals.dart' as globals;

import 'package:smurp_app/utils/rest_ds.dart';


void main() => runApp(HistoryPage());

class HistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Listen History',
      theme: new ThemeData(
        primaryColor: Colors.blue,
      ),
      home: new HistoryWidget(),
    );
  }
}


class HistoryPageState extends State<HistoryWidget> {
  List history;
  List _likes = new List<Song>();
  List _dislikes = new List<Song>();
  final _biggerFont = const TextStyle(fontSize: 18.0);


  final RestDatasource rest = new RestDatasource();


  @override
  void initState() {
    super.initState();
    this.getHistoryData();
    print("called getHistoryData()");
  }


  @override
  Widget build(BuildContext context) {
//    this.collectSongs();
    return Scaffold (
      appBar: AppBar(
        title: Text('Listening History'),
      ),
      body: new ListView.builder(
        itemCount: history == null ? 0 : history.length,
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
                                history[index]['song_title'] + ' by ' + history[index]['artist'],
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
                    color: history[index]['rating'] == 1 ? Colors.lightBlue : Colors.grey,
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
                    color: history[index]['rating'] == 0 ? Colors.lightBlue : Colors.grey,
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


  void collectSongs() async{
    print("before call : history.length = " + history.length.toString());
    List<Song> nextSongs = await rest.getListenedSongs(23);
    history.addAll(nextSongs);

    print("after calls : history.length = " + history.length.toString());
//    setState((){});
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
                      rest.dislikeSong(globals.user_id, song.song_id); // tell Database to remove song
                    }

                    if (liked){
                      _likes.remove(song); // if already disliked, remove from dislikes
                    }
                    else{
                      _likes.add(song);
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
                      _likes.remove(song); // if currently liked, remove from likes
                      rest.likeSong(globals.user_id, song.song_id); // tell Database to remove song
                    }

                    if (disliked){
                      _dislikes.remove(song); // if already disliked, remove from dislikes
                    }
                    else{
                      _dislikes.add(song); // else add to dislikes
                    }
                    rest.dislikeSong(globals.user_id, song.song_id);  // tell Database to add/remove song, whichever is appropriate

                  }); }
              ),
            ],
            mainAxisSize: MainAxisSize.min)
    );
  }


  void like(int index) async{
    print("Calling like(${history[index]['song_id']})");
    rest.likeSong(globals.user_id, history[index]['song_id']);
    initState();
    print('Song with id of: ' + history[index]['song_id'].toString() + 'was liked');
  }

  void dislike(int index) async {
    print("Calling dislike(${history[index]['song_id']})");
    rest.dislikeSong(globals.user_id, history[index]['song_id']);
    setState(() {
      initState();
      print('Song with id of: ' + history[index]['song_id'].toString() +
          'was disliked');
    });
  }

  //asynchronous call to hit the test endpoint
  // it's asynchronous because it might take a while
  // and we don't want the app to crash in the time
  // it takes to gather the data
  void getHistoryData() async {
    http.Response hResponse = await http.get(
        "http://ec2-52-91-42-119.compute-1.amazonaws.com:5000/getListened?user_id="+globals.user_id.toString(),
        headers: {"Accept": "application/json"});
//    http.Response lResponse = await http.get(
//        "http://ec2-52-91-42-119.compute-1.amazonaws.com:5000/likedsongs?user_id="+user_id.toString(),
//        headers: {"Accept": "application/json"});
//    http.Response dResponse = await http.get(
//        "http://ec2-52-91-42-119.compute-1.amazonaws.com:5000/dislikedsongs?user_id="+user_id.toString(),
//        headers: {"Accept": "application/json"});
    print(hResponse.body.toString());
    setState(() {
      history = json.decode(hResponse.body);
//      _likes = json.decode(lResponse.body);
//      _dislikes = json.decode(dResponse.body);

      print("Successfully grabbed history !");
    });
  }




} // end RandomWordsState


class HistoryWidget extends StatefulWidget {
  @override
  HistoryPageState createState() => new HistoryPageState();
}





