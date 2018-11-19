//// This file inspired by: https://medium.com/@kashifmin/flutter-login-app-using-rest-api-and-sqflite-b4815aed2149


class User{
  final int user_id;
  final String username;
  final String lastfm_name;
  final String join_date; //DateTime object?

  User(this.user_id, this.username, this.lastfm_name, this.join_date);

  User.fromJson(Map<Object, dynamic> json)
      : user_id = json['user_id'],
        lastfm_name = json['lastfm_name'],
        join_date = json['join_date'], //DateTime object?
        username = json['username'];

  Map<Object, dynamic> toJson() =>
      {
        'user_id' : user_id,
        'lastfm_name' : lastfm_name,
        'join_date' : join_date,
        'username': username,
      };

  String toString(){
    String values = "GRAB DATA FROM USER: \n"
        + "lastfm name: " + lastfm_name + '\n'
        + "join date: " + join_date + '\n'
        + "username: " + username + '\n';

    return values;
  }
}