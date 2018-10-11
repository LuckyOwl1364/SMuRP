import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:english_words/english_words.dart';

// Note: for simplicity, this is a stateless widget but, in a real app,
// a full screen is likely to be a stateful widget.
class RatedPage extends StatelessWidget {

  final List<WordPair> likes;
  final List<WordPair> dislikes;

  RatedPage({@required this.likes, @required this.dislikes});

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'History',
      theme: new ThemeData(
        primaryColor: Colors.blue,
      ),
      home: new ShowWords(likes: this.likes, dislikes: this.dislikes),
    );
  }


}



class ShowWordsState extends State<ShowWords> {

  bool onLikes = true;


  @override
  Widget build(BuildContext context) {
    return Scaffold (
      appBar: AppBar(
        title: onLikes ? Text('Liked Songs') : Text('Disiked Songs'),
        actions: <Widget>[
          new IconButton(icon: Icon(onLikes ? Icons.thumb_down : Icons.thumb_up), onPressed: _switchOnLikes() ),
        ],
      ),
      body: _buildRates(),
    );
  }
  Widget _buildRates() {
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
          if (onLikes){
            _buildRow(widget.likes[index]);
          }
          else{
            _buildRow(widget.dislikes[index]);
          }
        }
    );
  }
  Widget _buildRow(WordPair pair) {
    final bool liked = widget.likes.contains(pair);
    final bool disliked = widget.dislikes.contains(pair);
    return ListTile(
        title: Text(
          pair.asPascalCase,
          style: const TextStyle(fontSize: 18.0),
        ),
        trailing: new Row(
            children: <Widget>[
              new IconButton(
                  icon: new Icon( (liked) ? Icons.thumb_up : Icons.add_circle_outline,
                    color: liked ? Colors.orange : null,
                  ),
                  onPressed: () { setState(() {
                    if (disliked) {
                      widget.dislikes.remove(pair); // if currently disliked, remove from dislikes
                    }
                    if (liked){
                      widget.likes.remove(pair); // if already disliked, remove from dislikes
                    }
                    else{
                      widget.likes.add(pair);
                    }
                  }); }
              ),
              new IconButton(
                  icon: new Icon( (disliked) ? Icons.thumb_down : Icons.remove_circle_outline,
                    color: disliked ? Colors.orange : null,
                  ),
                  onPressed: () { setState(() {
                    if (liked) {
                      widget.likes.remove(pair); // if currently liked, remove from likes
                    }
                    if (disliked){
                      widget.dislikes.remove(pair); // if already disliked, remove from dislikes
                    }
                    else{
                      widget.dislikes.add(pair); // else add to dislikes
                    }
                  }); }
              ),
            ],
            mainAxisSize: MainAxisSize.min)
    );
  }
  _switchOnLikes(){
//    onLikes = !widget.onLikes;

    setState(() { onLikes = !onLikes; });
  }





}

class ShowWords extends StatefulWidget {

  final List<WordPair> likes;
  final List<WordPair> dislikes;

//  bool onLikes = true;

  ShowWords({@required this.likes, @required this.dislikes});

  @override
  ShowWordsState createState() => new ShowWordsState();
}