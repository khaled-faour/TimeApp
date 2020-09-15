import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeapp/main.dart';

DocumentReference _firestore =
    Firestore.instance.collection("UsersTasks").document(loggedInUser.uid);

class ActiveTaskScreen extends StatefulWidget {
  final String documentId;

  ActiveTaskScreen({Key key, this.documentId}) : super(key: key);

  @override
  _ActiveTaskScreenState createState() => _ActiveTaskScreenState();
}

class _ActiveTaskScreenState extends State<ActiveTaskScreen> {
  Timestamp endTime;
  Timestamp timeNow;
  Duration timeAgo;
  String avgTime;
  Timestamp startTime;
  String name;
  String description;
  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() {
    _firestore
        .collection("Tasks")
        .document(widget.documentId)
        .get()
        .then((value) {
      name = value.data["name"];
      description = value.data["description"];
      startTime = value.data["startTime"];
      avgTime = value.data["avgTime"];
      Timer timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
        timeNow = Timestamp.now();
        setState(() {
          timeAgo = timeNow.toDate().difference(startTime.toDate());
        });
      });
      if (value.data.containsKey("endTime")) {
        setState(() {
          timer.cancel();
          endTime = value.data["endTime"];
          timeAgo = endTime.toDate().difference(startTime.toDate());
        });
      } else {
        endTime = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Active Task"),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          Card(
            margin: EdgeInsets.only(
              left: 10,
              right: 10,
              top: 8,
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            child: ListTile(
              title: Center(
                child: Text(
                  name != null ? name : "task name",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          Card(
            margin: EdgeInsets.only(
              left: 10,
              right: 10,
              top: 8,
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Center(
                    child: Text(
                      "Elpased Time",
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Center(
                    child: timeAgo != null
                        ? Text(
                            "${timeAgo.inHours.toString().padLeft(2, '0')}:${timeAgo.inMinutes.remainder(60).toString().padLeft(2, '0')}:${timeAgo.inSeconds.remainder(60).toString().padLeft(2, '0')}",
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold),
                          )
                        : Center(
                            child: CircularProgressIndicator(),
                          ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Center(
                    child: RaisedButton.icon(
                      label: Text(
                        endTime != null ? "Finished" : "Finish Task",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: endTime != null
                          ? null
                          : () {
                              _firestore
                                  .collection("Tasks")
                                  .document(widget.documentId)
                                  .setData({
                                "endTime": Timestamp.now(),
                              }, merge: true);
                              _firestore.updateData({
                                "activeTask": false,
                              });
                              getData();
                              Navigator.pop(context);
                            },
                      icon: Icon(Icons.check),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text("Description"),
                ),
                Divider(
                  indent: 20.0,
                  endIndent: 20.0,
                ),
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                      description != null ? description : "Task description"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
