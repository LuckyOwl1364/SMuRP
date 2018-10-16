import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;


class EndopintDemoPage extends StatefulWidget {
  @override
  EndopintDemoState createState()=> new EndopintDemoState();

}

class EndopintDemoState extends State<EndopintDemoPage> {

  String endPtData = "Test Data ";

  @override
  Widget build(BuildContext context){
    return new Scaffold(
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new RaisedButton( child: new Text("Get endpoint data"), onPressed: getTestEndpointData),
            new Text(endPtData)]
      )
    )
    );
  }


  //asynchronous call to hit the test endpoint
  // it's asynchronous because it might take a while
  // and we don't want the app to crash in the time
  // it takes to gather the data
  Future<String> getTestEndpointData() async{
    http.Response response = await http.get("http://ec2-52-91-42-119.compute-1.amazonaws.com:5000/test",
        headers: {
          "Accept" : "application/json"
        }
    );

    //print(response.body);
    var data = json.decode(response.body);
    print(data);

    setState((){
      endPtData = data.toString();
    });

  }

}

