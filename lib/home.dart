import 'dart:async';
import 'dart:io';
import 'main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';

final app = FirebaseApp.configure(
  name: "QR_Me",
  options: FirebaseOptions(
    googleAppID: "1:1056505825645:android:8b1bf5e0a61c1e77",
    apiKey: "AIzaSyDg-VWD1P7slIniG5c_VVD75XIgz0RXph0",
    databaseURL: "https://qr-me-5d860.firebaseio.com/",
  ),
);

class Events {
  String eventName;
  String eventDateTime;
  String hostName;
  String key;

  Events(this.eventName, this.eventDateTime,this.hostName);
  Events.fromSnapshot(DataSnapshot snapshot)
      : eventName = snapshot.value['eventName'],
        eventDateTime = snapshot.value['eventDateTime'],
        hostName = snapshot.value['hostName'],
        key = snapshot.key;
  toJson() {
    return {"eventName": eventName, "eventDateTime": eventDateTime,"hostName":hostName};
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Future<String> getData() async {
  //   http.Response response = await http.get(
  //       Uri.encodeFull("https://jsonplaceholder.typicode.com/posts"),
  //       headers: {"Accept": "application/json"});
  //   print(response.body);
  // }

  List<Events> events=  List();
  Events event;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  DatabaseReference eventRef;
  @override
    void initState() {
      // TODO: implement initState
      super.initState();
      event = Events("","","");
      final FirebaseDatabase database = FirebaseDatabase.instance;
      eventRef = database.reference().child('events');
      eventRef.onChildAdded.listen(_onEntryAdded);
      eventRef.onChildChanged.listen(_onEntryChanged);
    }

    _onEntryAdded(Event e) {
    setState(() {
      events.add(Events.fromSnapshot(e.snapshot));
    });
  }

  _onEntryChanged(Event e) {
    var old = events.singleWhere((entry) {
      return entry.key == e.snapshot.key;
    });
    setState(() {
      events[events.indexOf(old)] = Events.fromSnapshot(e.snapshot);
    });
  }
    void handleSubmit() {
    final FormState form = formKey.currentState;
    if (form.validate()) {
      form.save();
      form.reset();
      eventRef.push().set(event.toJson());
    }
  }
  @override
  Widget build(BuildContext context) {
    double iconSize = 24.0;
    return new Scaffold(
      floatingActionButton: _DiamondFab(
        notchMargin: 8.0,
        child: Icon(Icons.center_focus_weak),
        onPressed: () {},
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: new BottomAppBar(
          elevation: 8.0,
          hasNotch: false,
          color: Colors.black54,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              FlatButton(
                child: Row(
                  children: <Widget>[
                    Icon(Icons.home, size: iconSize),
                    Text(
                      "Home",
                      style: TextStyle(fontSize: 16.0),
                    )
                  ],
                ),
                onPressed: () {},
              ),
              FlatButton(
                child: Row(
                  children: <Widget>[
                    Icon(Icons.person, size: iconSize),
                    Text(
                      "Profile",
                      style: TextStyle(fontSize: 16.0),
                    )
                  ],
                ),
                onPressed: () {},
              ),
              FlatButton(
                child: Row(
                  children: <Widget>[
                    Icon(Icons.event_note, size: iconSize),
                    Text(
                      "Events",
                      style: TextStyle(fontSize: 16.0),
                    )
                  ],
                ),
                onPressed: () {},
              ),
              FlatButton(
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.settings_applications,
                      size: iconSize,
                    ),
                    Text(
                      "Settings ",
                      style: TextStyle(fontSize: 16.0),
                    )
                  ],
                ),
                onPressed: () {},
              ),
              // IconButton(
              //   icon: Icon(Icons.group_work),
              //   iconSize: 32.0,
              //   onPressed: () {},
              // ),
              // IconButton(
              //   icon: Icon(Icons.event_note),
              //   iconSize: 32.0,
              //   onPressed: () {},
              // ),
              // IconButton(
              //   icon: Icon(Icons.settings),
              //   iconSize: 32.0,
              //   onPressed: () {},
              // ),
            ],
          )),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return Card(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.add),
                subtitle: Text(
                    "Just a subcontent of a CARD, basically it does provide description to what you are reading right now."),
                title: Text("Just a sample project Number: ${index+1}"),
              ),
              ButtonTheme.bar(
                child: ButtonBar(
                  children: <Widget>[
                    FlatButton(
                      child: Text("Okay Number ${index + 1}"),
                      onPressed: () {},
                    )
                  ],
                ),
              )
            ],
          ));
        },
      ),
      appBar: AppBar(
        title: Text("QR Me"),
        actions: <Widget>[
          IconButton(
            tooltip: "About",
            icon: Icon(Icons.info),
            onPressed: () {},
            iconSize: 24.0,
          )
        ],
      ),
      drawer: new Drawer(
        child: ListView(
          children: <Widget>[
            userProfile,
            ListTile(
              title: Text("Home"),
              leading: Icon(Icons.home),
            ),
            ListTile(
              title: Text("Profile"),
              leading: Icon(Icons.person),
            ),
            ListTile(
                title: Text("Exit"),
                leading: Icon(Icons.exit_to_app),
                onTap: () async {
                  await signOutGoogle();
                  exit(0);
                  // Navigator.of(context).pushReplacementNamed('/');
                })
          ],
        ),
      ),
    );
  }
}

Future<Null> signOutGoogle() async {
  await auth.signOut();
  await googleSignIn.signOut();
}

final FutureBuilder<FirebaseUser> userProfile = new FutureBuilder(
  future: FirebaseAuth.instance.currentUser(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      return UserAccountsDrawerHeader(
        onDetailsPressed: () {},
        accountName: Text(snapshot.data.displayName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            )),
        accountEmail: Text(snapshot.data.email),
        currentAccountPicture: CircleAvatar(
          backgroundImage: NetworkImage(snapshot.data.photoUrl),
          minRadius: 4.0,
        ),
      );
    } else {
      return Text("Loading...");
    }
  },
);

class _DiamondFab extends StatefulWidget {
  const _DiamondFab({
    this.child,
    this.notchMargin: 6.0,
    this.onPressed,
  });

  final Widget child;
  final double notchMargin;
  final VoidCallback onPressed;

  @override
  State createState() => new _DiamondFabState();
}

class _DiamondFabState extends State<_DiamondFab> {
  VoidCallback _clearComputeNotch;

  @override
  Widget build(BuildContext context) {
    return new Material(
      shape: const _DiamondBorder(),
      color: Colors.teal,
      child: new InkWell(
        onTap: widget.onPressed,
        child: new Container(
          width: 56.0,
          height: 56.0,
          child: IconTheme.merge(
            data: new IconThemeData(
                color: Theme.of(context).accentIconTheme.color),
            child: widget.child,
          ),
        ),
      ),
      elevation: 6.0,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _clearComputeNotch =
        Scaffold.setFloatingActionButtonNotchFor(context, _computeNotch);
  }

  @override
  void deactivate() {
    if (_clearComputeNotch != null) _clearComputeNotch();
    super.deactivate();
  }

  Path _computeNotch(Rect host, Rect guest, Offset start, Offset end) {
    final Rect marginedGuest = guest.inflate(widget.notchMargin);
    if (!host.overlaps(marginedGuest))
      return new Path()..lineTo(end.dx, end.dy);

    final Rect intersection = marginedGuest.intersect(host);
    // We are computing a "V" shaped notch, as in this diagram:
    //    -----\****   /-----
    //          \     /
    //           \   /
    //            \ /
    //
    //  "-" marks the top edge of the bottom app bar.
    //  "\" and "/" marks the notch outline
    //
    //  notchToCenter is the horizontal distance between the guest's center and
    //  the host's top edge where the notch starts (marked with "*").
    //  We compute notchToCenter by similar triangles:
    final double notchToCenter = intersection.height *
        (marginedGuest.height / 2.0) /
        (marginedGuest.width / 2.0);

    return new Path()
      ..lineTo(marginedGuest.center.dx - notchToCenter, host.top)
      ..lineTo(
          marginedGuest.left + marginedGuest.width / 2.0, marginedGuest.bottom)
      ..lineTo(marginedGuest.center.dx + notchToCenter, host.top)
      ..lineTo(end.dx, end.dy);
  }
}

class _DiamondBorder extends ShapeBorder {
  const _DiamondBorder();

  @override
  EdgeInsetsGeometry get dimensions {
    return const EdgeInsets.only();
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection textDirection}) {
    return getOuterPath(rect, textDirection: textDirection);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection textDirection}) {
    return new Path()
      ..moveTo(rect.left + rect.width / 2.0, rect.top)
      ..lineTo(rect.right, rect.top + rect.height / 2.0)
      ..lineTo(rect.left + rect.width / 2.0, rect.bottom)
      ..lineTo(rect.left, rect.top + rect.height / 2.0)
      ..close();
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection textDirection}) {}

  // This border doesn't support scaling.
  @override
  ShapeBorder scale(double t) {
    return null;
  }
}
