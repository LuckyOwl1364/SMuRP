import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:smurp_app/routes.dart';
import 'package:smurp_app/data/rest_ds.dart';
import 'package:smurp_app/feed.dart';
import 'package:http/http.dart' as http;
import 'globals.dart' as globals;


void main() => runApp(new Login());



class Login extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Login',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: routes,
    );
  }

}


class LoginScreen extends StatefulWidget{

  @override
  State createState() => new _LoginScreenState();


}


class _LoginScreenState extends State<LoginScreen>{
//  _formKey and _autoValidate
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;

  String _email = "works";
  String _password = "";

  var userData;
  //String endPtData = "{Failure : Default Value}";
  String endPtData = '{"username": "UnquietNights", "user_id": 23, "join_date": "November 13, 2018", "session_key": "unquietnights", "lastfm_name": "UnquietNights"}';
  List data;

  //async call to get data from endpoint
  void getData() async{
//    RestDatasource restDS = new RestDatasource();
//    print('calling login endpoint');
//    var user = await restDS.login(_email,_password);
//    print('login endopint hit. Continuing code: ');
//    setState((){
//      endPtData = 'DATA RECIEVED FROM ENDPOINT\n'
//          '$user\n';
//      print(endPtData);
//      //data.add(user);
//    });
    getLoginData();
  } // end getData()



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
              new FlutterLogo(size: 60.0),
              new TextFormField(
                decoration: new InputDecoration(
                  labelText: "Enter Username"
                ),
                keyboardType: TextInputType.text,
                validator: validateUsername,
                onSaved: (String val) {
                  _email = val;
                },
              ),
              new TextFormField(
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
              new RaisedButton(
                onPressed: _validateInputs,
                child: new Text("Log in")
              ),
            ]
          )
        )
      ),
    );
  }

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
      sleep(const Duration(seconds:3));
      print('waiting just a liitle longer to see if that makes a difference');
      if(loginResponse.contains('failure')){//if the response returns a login failure
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
        globals.username = userData["username"] == null ? " " : userData["username"].trim();
        globals.lastfm_name = userData["lastfm_name"] == null ? " " : userData["lastfm_name"].trim();
        globals.joindate = userData["join_date"] == null ? " " : userData["join_date"].trim();
        globals.user_id = userData["user_id"] == null ? " " : userData["user_id"];
        globals.session_key = userData["session_key"] == null ? " " : userData["session_key"].trim();
        globals.isLoggedIn = true;
        print('storing data as: '+globals.username+' and '+
            globals.lastfm_name +' and '+
            globals.joindate +' and '+
            globals.user_id.toString()+' and '+
            globals.isLoggedIn.toString()+' and '+
            globals.session_key);
        print('registered data. starting new screen in 3...2..1.');
        sleep(const Duration(seconds:3));
        Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (context) => new FeedPage()));
      }

    } else {
//    If all data are not valid then start auto validation.
      setState(() {
        _autoValidate = true;
      });
      return null;
    }
  }






  String validatePassword(String value) {
    if (value.length < 3)
      return 'Password must be more than 2 charater';
    else
      return null;
  }

  String validateUsername(String value) {
    if (value.length < 2)
      return 'Enter Valid Username';
    else
      return null;
  }

  //async call to get data from endpoint
  Future<Null> getLoginData2() async {
    print("Is that an endpoint i see? ");
    http.Response response = await http.get(
        "http://ec2-52-91-42-119.compute-1.amazonaws.com:5000/loginuser?username="+_email+"&password="+_password
    );

    setState(() {
      userData = json.decode(response.body);

      endPtData = userData.toString();
      print(endPtData);
      print('ayy we got a response');
    });
  }

  //TODO:NEW STUFF~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  Future<String> getLoginData() async {
    print("Using the client to call login endpoint.");
    globals.client.getUrl(Uri.parse(
        "http://ec2-52-91-42-119.compute-1.amazonaws.com:5000/loginuser?username="+_email+"&password="+_password))
        .then((request) => request.close())
        .then((response) =>
        response.transform(utf8.decoder).listen(print));

    setState(() {
      userData = json.decode(endPtData);

      endPtData = userData.toString();
      print(endPtData);
      print('ayy we got a response');
    });
  }
//TODO:NEW STUFF~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


}












