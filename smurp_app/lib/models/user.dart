//// This file inspired by: https://medium.com/@kashifmin/flutter-login-app-using-rest-api-and-sqflite-b4815aed2149
//
//class User {
//  String _username;
//  String _password;
//  User(this._username, this._password);
//
//  User.map(dynamic obj) {
//    this._username = obj["username"];
//    this._password = obj["password"];
//  }
//
//  String get username => _username;
//  String get password => _password;
//
//  Map<String, dynamic> toMap() {
//    var map = new Map<String, dynamic>();
//    map["username"] = _username;
//    map["password"] = _password;
//
//    return map;
//  }
//}

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