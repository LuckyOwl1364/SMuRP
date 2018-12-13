import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:smurp_app/routes.dart';
import 'package:smurp_app/feed.dart';
import 'package:http/http.dart' as http;
import 'globals.dart' as globals;


void main() => runApp(new Login());


// Page boot-up class
class Login extends StatelessWidget{
  @override
  Widget build(BuildContext context) {  // Gets the page built
    return new MaterialApp(
      title: 'Login',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }

}

// Page body boot-up class
class LoginScreen extends StatefulWidget{

  @override
  State createState() => new _LoginScreenState();


}

// Page body. This contains every part of the page that isn't the header
class _LoginScreenState extends State<LoginScreen>{
//  _formKey and _autoValidate
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false; // determines if entry fields are being validated ongoing (flips when hit submit the first time)

  String _email = "works";  // These store the field values when the user hits 'submit'
  String _password = "";

  var userData;   // stores the returned user's data
  String endPtData = "{Failure : Default Value}";
  List data;



  // Builds the body of the screen, including the text fields and the login button
  @override
  Widget build(BuildContext context) {
    return Scaffold (
      backgroundColor: Colors.lightBlueAccent,
      body: new Container(
        padding: const EdgeInsets.all(30.0),
        child: new Form(
          key: _formKey,
          autovalidate: _autoValidate,
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new FlutterLogo(size: 60.0),        // placeholder for if the app had a logo
              new TextFormField(                  // text field for username
                decoration: new InputDecoration(
                  labelText: "Enter Username"
                ),
                keyboardType: TextInputType.text,
                validator: validateUsername,
                onSaved: (String val) {
                  _email = val;
                },
              ),
              new TextFormField(                  // text field for password
                decoration: new InputDecoration(
                    labelText: "Enter Password"
                ),
                obscureText: true,
                keyboardType: TextInputType.text,
                validator: validatePassword,
                onSaved: (String val) {
                  _password = val;
                },
              ),
              new Padding(
                  padding: const EdgeInsets.all(20.0)
              ),
              new RaisedButton(                   // login button
                onPressed: _validateInputs,
                child: new Text("Log in")
              ),
            ]
          )
        )
      ),
    );
  }

  // Makes sure the input fields are valid, then sends the data out to the backend
  // If the sent data is wrong (e.g wrong password) user is told about it.
  // Else, user is logged in
  _validateInputs() {
    if (_formKey.currentState.validate()) {
      sleep(const Duration(seconds:1));
      _formKey.currentState.save();
      this.getLoginData();
      print('hold on a sec...');
      sleep(const Duration(seconds:3));
      String loginResponse = endPtData.substring(1, 10).toLowerCase();
      print(userData == null ? 'Null userdata' : userData);
      print('endpointdata: '+endPtData);
      print('loginResponse: '+loginResponse);
      print('Checking response ' + loginResponse.contains('failure').toString());
      if(loginResponse.contains('failure')){  //if the response returns a login failure
        print('Wrong Data');
          return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                content: Text(endPtData)
            );
          }
        );
      } else {
        print('Correct Data');
        sleep(const Duration(seconds:1));
        print(userData == null ? 'Null userdata' : userData);
        //otherwise store the data and move onto the feed
        globals.username = userData["username"] == null ? " " : userData["username"].trim();          // save returned user object's info
        globals.lastfm_name = userData["lastfm_name"] == null ? " " : userData["lastfm_name"].trim(); // into globals
        globals.joindate = userData["join_date"] == null ? " " : userData["join_date"].trim();
        globals.user_id = userData["user_id"] == null ? " " : userData["user_id"];
        globals.session_key = userData["session_key"] == null ? " " : userData["session_key"].trim();
        globals.isLoggedIn = true;
        print('storing data as: '+globals.username+' and '+
            globals.lastfm_name +' and '+
            globals.joindate +' and '+
            globals.user_id.toString()+' and '+
            globals.isLoggedIn.toString());
        print('registered data. starting new screen in 3...2..1.');
        sleep(const Duration(seconds:3));
        Navigator.push(                                  // Send user to the feed page
            context,
            new MaterialPageRoute(
                builder: (context) => new FeedPage()));
      }

    } else {
      // If all data are not valid then start auto validation.
      setState(() {
        _autoValidate = true;
      });
      return null;
    }
  }





  // Used to validate username
  String validateUsername(String value) {
    if (value.length < 2)
      return 'Enter valid username';
    else
      return null;
  }

  // Used to validate password
  String validatePassword(String value) {
    if (value.length < 3)
      return 'Enter valid password';
    else
      return null;
  }

  //async call to get data from endpoint
  Future<Null> getLoginData() async {
    print("Is that an endpoint i see? ");
    http.Response response = await http.get(
        "http://ec2-52-91-42-119.compute-1.amazonaws.com:5000/loginuser?username="+_email+"&password="+_password
    );

    setState(() { // receives database response, saves its information
      userData = json.decode(response.body);

      endPtData = userData.toString();
      print(endPtData);
      print('ayy we got a respnse');
    });
  }

}












