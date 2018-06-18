import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'home.dart';
import 'package:firebase_core/firebase_core.dart';

final app = FirebaseApp.configure(
  name: '',
  options: FirebaseOptions(
    googleAppID: '1:1056505825645:android:8b1bf5e0a61c1e77',
    apiKey: 'AIzaSyDg-VWD1P7slIniG5c_VVD75XIgz0RXph0',
    databaseURL: 'https://qr-me-5d860.firebaseio.com/',
  ),
);

final FirebaseAuth auth = FirebaseAuth.instance;

final GoogleSignIn googleSignIn = new GoogleSignIn();
Future<String> _testSignInWithGoogle() async {
  final GoogleSignInAccount googleUser = await googleSignIn.signInSilently();
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
void main() async {
  runApp(MyApp());
}

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
          brightness: Brightness.dark, textSelectionColor: Colors.white),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
   // this will check status
  
  initState() {
    super.initState();
    
    Future
        .delayed(new Duration(seconds: 1))
        .then((_) => _testSignInWithGoogle());
    auth.onAuthStateChanged.firstWhere((user) => user != null).then((user) {
      Navigator.of(context).pushReplacementNamed('/home');
    });
  }
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: new Center(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "QR Me",
            style: TextStyle(
              fontSize: 32.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ));
  }
}
