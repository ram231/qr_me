import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'home.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = new GoogleSignIn();
Future<String> _testSignInWithGoogle() async {
  final GoogleSignInAccount googleUser = await googleSignIn.signIn();
  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
  FirebaseUser user = await auth.signInWithGoogle(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  assert(user.email != null);
  assert(user.displayName != null);
  assert(!user.isAnonymous);
  assert(await user.getIdToken() != null);
  assert(user.photoUrl != null);

  final FirebaseUser currentUser = await auth.currentUser();
  assert(user.uid == currentUser.uid);

  return 'signInWithGoogle succeeded $user';
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      //showPerformanceOverlay: true,
      title: "Hello World App",
      home: LoginPage(),
      routes: <String, WidgetBuilder>{
        '/home': (BuildContext context) => MyHomePage(),
      },
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColorBrightness: Brightness.dark,
        primaryColor: Colors.grey,
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  initState() {
    super.initState();
    auth.onAuthStateChanged.firstWhere((user) => user != null).then((user) {
      Navigator.of(context).pushReplacementNamed('/home');
    });
    Future
        .delayed(new Duration(milliseconds: 50))
        .then((_) => _testSignInWithGoogle());
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
          CircularProgressIndicator(

          ),
        ],
      ),
    ));
  }
}
