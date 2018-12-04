import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:smurp_app/routes.dart';
import 'package:smurp_app/data/rest_ds.dart';
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


  String endPtData = "Test Data ";
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
      _formKey.currentState.save();
      this.getData();
      return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              content: Text(endPtData)
          );
        }
      );
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
  Future<Null> getLoginData() async {
    print("Is that an endpoint i see? ");
    http.Response response = await http.get(
        "http://ec2-52-91-42-119.compute-1.amazonaws.com:5000/loginuser?username="+_email+"&password="+_password
    );

    setState(() {
      var loginResponse = json.decode(response.body);
      print(loginResponse.toString());
      print('ayy we got a resopnse');
    });
  }

}












