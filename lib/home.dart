import 'dart:async';
import 'dart:io';
import 'main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'group.dart';
import 'events.dart';
import 'package:firebase_database/firebase_database.dart';
import 'datepick.dart';

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

  BodyOfHomePage bodyHome;
  MyGroupPage groupPage;
  EventPage eventPage;
  DateAndTimePickerDemo datePage;
  List<Widget> pages;
  Widget currentPage;
  int currentTab = 0;
  @override
  void initState() {
    // TODO: implement initState
    bodyHome = BodyOfHomePage();
    groupPage = MyGroupPage();
    eventPage = EventPage();
    datePage = DateAndTimePickerDemo();
    pages = [bodyHome,groupPage,  eventPage,datePage,];
    currentPage = bodyHome;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      floatingActionButton: _DiamondFab(
        notchMargin: 8.0,
        child: Icon(Icons.center_focus_weak),
        onPressed: () {},
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentTab,
          onTap: (int index) {
            setState(() {
              currentTab = index;
              currentPage = pages[index];
            });
          },
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.home), title: Text("Home")),
            BottomNavigationBarItem(
                icon: Icon(Icons.group), title: Text("Groups")),
            BottomNavigationBarItem(
              icon: Icon(Icons.event_available),
              title: Text("Events"),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add),
              title: Text("New")
            )
          ]),
      body: currentPage,
      appBar: AppBar(
        title: Text("QR Me"),
        centerTitle: true,
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

class BodyOfHomePage extends StatefulWidget {
  @override
  _BodyHomeState createState() => _BodyHomeState();
}

class _BodyHomeState extends State<BodyOfHomePage> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return Card(
            color: index % 2 == 0 ? Colors.teal : Colors.deepOrange,
            elevation: 8.0,
            margin: EdgeInsets.all(32.0),
            shape: BeveledRectangleBorder(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.event,
                  size: 64.0,
                  color: Colors.green,
                ),
                ListTile(
                  leading: Icon(Icons.add),
                  subtitle: new Container(child: new Text("Hello World")),
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
    );
  }
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
