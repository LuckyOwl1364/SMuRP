import 'package:flutter/material.dart';

void main() => runApp(new Login());



class Login extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Login',
      theme: new ThemeData(
        primaryColor: Colors.blue,
      ),
      home: new LoginScreen(),
    );
  }

}


class LoginScreen extends StatefulWidget{

  @override
  State createState() => new _LoginScreenState();


}


class _LoginScreenState extends State<LoginScreen>{
  String _email = "works";
  String _password = "";
  final _emailInputController = TextEditingController();
  final _passwordInputController = TextEditingController();


  _onLogin() {
    // update the state (email & password)
    setState((){
        _email = Text(_emailInputController.text).toString();
        _password = Text(_passwordInputController.text).toString();
      }
    );

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(_email)
        );
      }
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold (
      backgroundColor: Colors.blue,
      body: new Container(
        padding: const EdgeInsets.all(30.0),
        child: new Form(
          autovalidate: true,
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
                controller: _emailInputController,
              ),
              new TextFormField(
                decoration: new InputDecoration(
                    labelText: "Enter Password"
                ),
                obscureText: true,
                keyboardType: TextInputType.text,
                controller: _passwordInputController,
              ),
              new Padding(
                  padding: const EdgeInsets.all(20.0)
              ),
              new RaisedButton(
                onPressed: _onLogin,
                child: new Text("Log in")
              ),
            ]
          )
        )
      ),
    );
  }

}












