import 'package:smurp_app/models/artist.dart';

class Song{
  String title;
  Artist artist;

  Song(this.title, this.artist);

  Song.map(dynamic obj) {
    this.title = obj["song_title"];
    this.artist = new Artist("fakeArtist");
  }


}