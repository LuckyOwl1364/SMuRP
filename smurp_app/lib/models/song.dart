
class Song{
  int song_id;
  String title;
  String artist;

  Song(this.song_id, this.title, this.artist);

  Song.map(dynamic obj) {
    this.song_id = obj["song_id"];
    this.title = obj["song_title"];
    this.artist = "fakeArtist";
  }


}