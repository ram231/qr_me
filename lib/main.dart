import 'dart:io';

import 'package:flutter/material.dart';
import 'home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "Hello World App",
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColorBrightness: Brightness.dark,
        primaryColor: Colors.teal,
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _controller = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: new Center(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Text(
            "QR Me",
            style: TextStyle(
              fontSize: 32.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          new Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 64.0, vertical: 12.0),
            child: TextField(
                
                controller: _controller,
                decoration: InputDecoration(
                    labelStyle: TextStyle(color: Colors.grey),
                    labelText: "Username",
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.all(const Radius.circular(10.0)),
                    ))),
          ),
          new Padding(
            padding: const EdgeInsets.symmetric(horizontal: 64.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                  labelText: "Password",
                  labelStyle: TextStyle(color: Colors.white30),
                  border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.all(const Radius.circular(10.0)))),
              obscureText: true,
            ),
          ),
          new Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FlatButton(
                      child: Text("Exit"),
                      onPressed: () {
                        exit(0);
                      }),
                  RaisedButton(
                    child: Text("Log in"),
                    onPressed: () {
                      Navigator.of(context).push(new MaterialPageRoute(
                          builder: (context) => MyHomePage()));
                    },
                  ),
                ],
              ))
        ],
      ),
    ));
  }
}
