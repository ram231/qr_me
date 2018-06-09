import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'home.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = new GoogleSignIn();

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      //showPerformanceOverlay: true,
      title: "Hello World App",
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColorBrightness: Brightness.dark,
        primaryColor: Colors.blue,
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Future<String> _message = new Future<String>.value('');
  Future<String> _testSignInWithGoogle() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    FirebaseUser user = await _auth.signInWithGoogle(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    assert(user.email != null);
    assert(user.displayName != null);
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);
    assert(user.photoUrl != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);

    return 'signInWithGoogle succeeded $user';
  }

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
                    child: Text("Log in with Google"),
                    color: Colors.red,
                    onPressed: () {
                      setState(() {
                        _message = _testSignInWithGoogle();
                        Navigator.of(context).push(new MaterialPageRoute(
                            builder: (context) => MyHomePage()));
                      });
                    },
                  ),
                  new FutureBuilder<String>(
                      future: _message,
                      builder: (_, AsyncSnapshot<String> snapshot) {
                        return Text(
                          snapshot.data ?? '',
                          style: TextStyle(
                              color: const Color.fromARGB(255, 0, 155, 0)),
                        );
                      })
                ],
              )),
        ],
      ),
    ));
  }
}
