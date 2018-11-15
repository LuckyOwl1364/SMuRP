// Based on: https://flutter.io/docs/catalog/samples/tabbed-app-bar


import 'package:flutter/material.dart';
import 'package:smurp_app/models/song.dart';


class TabbedAppBarSample extends StatelessWidget {
  final List<Song> _likes = new List<Song>();
  final List<Song> _dislikes = new List<Song>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: choices.length,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Rated Songs'),
            bottom: TabBar(
              isScrollable: true,
              tabs: choices.map((Choice choice) {
                return Tab(
                  text: choice.title,
                );
              }).toList(),
            ),
          ),
          body: TabBarView(
            children: choices.map((Choice choice) {
              return Padding(
                padding: const EdgeInsets.all(2.0),
                child: _buildRated(choice),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildRated(Choice choice) {
    return ListView.builder(
        List<Song> rated = choice._rated;
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
          if (index >= _rated.length) {
            // ...then generate 10 more and add them to the suggestions list.
            collectRated();
          }
          return _buildRow(_rated[index]);
        }
    );
  }

}

class Choice {
  Choice({this.title,this.rated});

  final String title;
  List<Song> rated;
}

const List<Choice> choices = const <Choice>[
  Choice(title: 'Likes', rated: ),
  Choice(title: 'Dislikes', rated: ),
];

class ChoiceCard extends StatelessWidget {
  Widget build(BuildContext context) {
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
    )
  }
}

void main() {
  runApp(TabbedAppBarSample());
}