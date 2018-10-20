
class Song{
  final String title;
  final Artist artist;

  Song(this.title, this.artist);
}


class Artist{
  final String name;
  final String genre;

  Artist(this.name,this.genre);
}

class Album{
  final int album_id;
  final String album_name;
  final String album_art;

  Album(this.album_id, this.album_name, this.album_art);
}

class User{
  final int user_id;
  final String username;
  final String lastfm_name;
  final String join_date; //DateTime object?
  final String password;
  final String email;

  User(this.user_id, this.username, this.lastfm_name, this.join_date,
      this.password, this.email);

  User.fromJson(Map<Object, dynamic> json)
      : user_id = json['user_id'],
        lastfm_name = json['lastfm_name'],
        join_date = json['join_date'], //DateTime object?
        password = json['password'],
        username = json['username'],
        email = json['email'];

  Map<Object, dynamic> toJson() =>
      {
        'user_id' : user_id,
        'lastfm_name' : lastfm_name,
        'join_date' : join_date,
        'password' : password,
        'username': username,
        'email': email,
      };

  String toString(){
    String values = "GRAB DATA FROM USER: \n"
        + "lastfm name: " + lastfm_name + '\n'
        + "join date: " + join_date + '\n'
        + "password: " + password + '\n'
        + "username: " + username + '\n'
        + "email: " + email + '\n';

    return values;
  }
}

