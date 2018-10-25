import 'package:english_words/english_words.dart';

class Song{
  final WordPair title;
  final Artist artist;

  Song(this.title, this.artist);
}


class Artist{
  final String name;
  final String genre;

  Artist(this.name,this.genre);
}