import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:intl/intl.dart';

class EventPage extends StatefulWidget {
  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  DateTime _date = DateTime.now();
  List<MyEvents> events = List();
  MyEvents myEvents;
  DatabaseReference eventRef;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  void initState() {
    // TODO: implement initState

    myEvents = MyEvents("", "", null);
    final FirebaseDatabase database = FirebaseDatabase.instance;
    eventRef = database.reference().child('events');
    eventRef.onChildAdded.listen(_onEntryAdded);
    eventRef.onChildChanged.listen(_onEntryChanged);
    super.initState();
  }

  _onEntryAdded(Event event) {
    setState(() {
      events.add(MyEvents.fromSnapshot(event.snapshot));
    });
  }

  _onEntryChanged(Event event) {
    var old = events.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    setState(() {
      events[events.indexOf(old)] = MyEvents.fromSnapshot(event.snapshot);
    });
  }

  void handleSubmit() {
    final FormState form = formKey.currentState;
    if (form.validate()) {
      form.save();
      form.reset();
      eventRef.push().set(myEvents.toJson());
    }
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: new DateTime(2015, 8),
        lastDate: new DateTime(2101));
    if (picked != null && picked != _date) {
      setState(() {
        _date = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Flexible(
          flex: 0,
          child: Center(
            child: Form(
              key: formKey,
              child: Flex(
                direction: Axis.vertical,
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.event),
                    title: TextFormField(
                      onFieldSubmitted: (controller) {},
                      initialValue: "",
                      onSaved: (val) => myEvents.eventName = val,
                      validator: (val) => val == "" ? val : null,
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.description),
                    title: TextFormField(
                      onFieldSubmitted: (controller) {},
                      initialValue: "",
                      onSaved: (val) => myEvents.eventDesc = val,
                      validator: (val) => val == "" ? val : null,
                    ),
                  ),
                  ListTile(
                    leading: IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          _selectDate(context);
                        });
                      },
                    ),
                    title: TextFormField(
                      initialValue: "",
                      onFieldSubmitted: (controller) {},
                      onSaved: (val) {
                        myEvents.eventDate = DateFormat.yMMMd().format(_date);
                        val = DateFormat.yMMMd().format(_date);
                      },
                      validator: (val) => val == "" ? val : null,
                    ),
                  ),
                  RaisedButton(
                    child: Text("Send"),
                    onPressed: () => handleSubmit(),
                    color: Theme.of(context).primaryColor,
                  )
                ],
              ),
            ),
          ),
        ),
        Flexible(
          child: FirebaseAnimatedList(
            query: eventRef,
            itemBuilder: (context, snapshot, animation, index) {
              return Card(
                elevation: 8.0,
                margin: EdgeInsets.only(bottom:24.0),
                shape: BeveledRectangleBorder(),
                child: Column(
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.event,size: 48.0,),
                      title: Text(events[index].eventName),
                      subtitle: Text(events[index].eventDesc),
                    ),
                    ButtonTheme.bar(
                      child: ButtonBar(
                        children: <Widget>[
                          Text(events[index].eventDate.toString()),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class MyEvents {
  String eventName, eventDesc, eventDate, key;

  MyEvents(this.eventName, this.eventDesc, this.eventDate);

  MyEvents.fromSnapshot(DataSnapshot snapshot)
      : eventName = snapshot.value['eventName'],
        eventDesc = snapshot.value['eventDesc'],
        eventDate = snapshot.value['eventDate'],
        key = snapshot.key;

  toJson() {
    return {
      "eventName": eventName,
      "eventDesc": eventDesc,
      "eventDate": eventDate
    };
  }
}
