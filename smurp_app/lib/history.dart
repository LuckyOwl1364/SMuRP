import 'package:flutter/material.dart';
import 'package:smurp_app/models/song.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'globals.dart' as globals;

import 'package:smurp_app/data/rest_ds.dart';


// Page body boot-up class. Includes the header; makes a call for the body
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

// Page body. This contains every part of the page that isn't the header
class HistoryPageState extends State<HistoryWidget> {
  List history;

  final RestDatasource rest = new RestDatasource();   // object for talking to the database

  // When class is instantiated, do this before anything else
  @override
  void initState() {
    super.initState();
    this.getHistoryData();
    print("called getHistoryData()");
  }

  // Builds the body of the screen, including the feed and the sidebar
  @override
  Widget build(BuildContext context) {
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

  // Adds a song to the 'likes' list
  // If already liked, removes instead
  // If currently dislikes, removes from that list then adds to likes
  void like(int index) async{
    print("Calling like(${history[index]['song_id']})");
    rest.likeSong(globals.user_id, history[index]['song_id']);
    initState();
    print('Song with id of: ' + history[index]['song_id'].toString() + 'was liked');
  }

  // Adds a song to the 'dislikes' list
  // If already disliked, removes instead
  // If currently in likes, removes from that list then adds to dislikes
  void dislike(int index) async {
    print("Calling dislike(${history[index]['song_id']})");
    rest.dislikeSong(globals.user_id, history[index]['song_id']);
    setState(() {
      initState();
      print('Song with id of: ' + history[index]['song_id'].toString() +
          'was disliked');
    });
  }

  // asynchronous call to hit the test endpoint
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

} // end HistoryPageState

// When file called to run, do the following
class HistoryWidget extends StatefulWidget {
  @override
  HistoryPageState createState() => new HistoryPageState();
}





