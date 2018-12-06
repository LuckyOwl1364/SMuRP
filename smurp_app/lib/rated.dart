import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smurp_app/models/song.dart';
import 'package:smurp_app/data/rest_ds.dart';
import 'globals.dart' as globals;


//  If starting the program here, creates the following page
void main() => runApp(RatedPage());

class RatedPage extends StatefulWidget {
  @override
  RatedPageState createState() => new RatedPageState();
}



//  This is the page body
class RatedPageState extends State<RatedPage> {
  final _biggerFont = const TextStyle(fontSize: 18.0);

  List likes;
  List dislikes;

  final RestDatasource rest = new RestDatasource();

  //  When the page is being built, do this first
  @override
  void initState() {
    super.initState();
    this.getRatedData();
    print("called getRatedData()");
  }

  // Builds the page
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "Rated page",
      home: new DefaultTabController(
        length:2,
        child:  new Scaffold(
            appBar: new AppBar(
                leading: new IconButton(  // this is the back button
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
    List list = grabLikes ? likes : dislikes;
    return new ListView.builder(
      itemCount: list == null ? 0 : list.length,
      itemBuilder: (BuildContext context, int index){   //  Puts together all the song cards (with the like and dislike
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
                              list[index]['song_title'] + ' by ' + list[index]['artists'],  // The song's title and artist
                              textAlign: TextAlign.start),
                        ]// end children
                    )
                ),
              ),
              Padding(  // Give some space, then add a thumbs-up button for liking a song
                padding: new EdgeInsets.symmetric(
                    horizontal: globals.halfPadding, vertical: globals.halfPadding),
                child: IconButton(
                  icon: const Icon(Icons.thumb_up),
                  color: Colors.grey,
                  onPressed: (){
                    like(list, index);
                  },
                ),
              ),
              Padding(  // Give some space, then add a thumbs-down button for disliking a song
                padding: new EdgeInsets.symmetric(
                    horizontal: globals.halfPadding, vertical: globals.halfPadding),
                child: IconButton(//this icon is the thumbs down button
                  icon: const Icon(Icons.thumb_down),
                  color: Colors.grey,
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


}