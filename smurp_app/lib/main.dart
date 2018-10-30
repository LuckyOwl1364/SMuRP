import 'package:flutter/material.dart';
import 'package:smurp_app/routes.dart';
//import 'package:password_hash';  TODO: Get this to work ~~~~~~~~~~~~~~~~~
import 'package:http/http.dart';
import 'package:smurp_app/data/rest_ds.dart';

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
                  labelText: "Enter Email"
                ),
                keyboardType: TextInputType.emailAddress,
                validator: validateEmail,
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



  String validatePassword(String value) {
    if (value.length < 3)
      return 'Password must be more than 2 charater';
    else
      return null;
  }

  String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Enter Valid Email';
    else
      return null;
  }

  _validateInputs() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              content: Text(_email + " , " + _password)
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



}












