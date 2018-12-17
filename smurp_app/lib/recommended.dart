import 'package:flutter/material.dart';

import 'package:smurp_app/data/rest_ds.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'globals.dart' as globals;





// Page body boot-up class
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

// Page body. This contains every part of the page that isn't the header
class RecommendPageState extends State<RecommendWidget> { // TODO: Change out WordPair for Song
  List recs;

  final RestDatasource rest = new RestDatasource();

  // When class is instantiated, do this before anything else
  @override
  void initState() {
    super.initState();
    this.getRecommendData();
  }

  // Builds the body of the screen, including the cards for songs
  @override
  Widget build(BuildContext context) {
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
                  child: IconButton(    //this icon is the thumbs up button
                    icon: const Icon(Icons.thumb_up),
                    color: Colors.grey,
                    onPressed: (){
                      like(index);
                    },
                  ),
                ),
                Padding(
                  padding: new EdgeInsets.symmetric(
                      horizontal: globals.halfPadding, vertical: globals.halfPadding),
                  child: IconButton(    //this icon is the thumbs down button
                    icon: const Icon(Icons.thumb_down),
                    color: Colors.grey,
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

  // Tells the database to add the song at the passed index to the user's list of likes
  // If it already is in their likes, removes instead
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

}

// When the file is called to start, run the following
class RecommendWidget extends StatefulWidget {
  @override
  RecommendPageState createState() => new RecommendPageState();
}





