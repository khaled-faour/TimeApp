import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Firestore _firestore = Firestore.instance;
FirebaseUser _user;
var _data;
Timestamp dateNow;
Timestamp startTime;
Duration timeAgo;

class ActiveTaskScreen extends StatefulWidget {
  final String categoryId;
  final String taskId;

  ActiveTaskScreen({Key key, this.categoryId, this.taskId}) : super(key: key);

  @override
  _ActiveTaskScreenState createState() => _ActiveTaskScreenState();
}

class _ActiveTaskScreenState extends State<ActiveTaskScreen> {
  @override
  void initState() {
    super.initState();
    getCurrentUser();
    getData();
    getTime();
  }

  getCurrentUser() async {
    try {
      _user = await FirebaseAuth.instance.currentUser();
    } catch (e) {
      print(e);
    }
  }

  getData() async {
    try {
      await _firestore
          .collection("Categories")
          .document(widget.categoryId)
          .collection("Tasks")
          .document(widget.taskId)
          .get()
          .then((value) async {
        _data = value.data;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  void getTime() {
    setState(() {
      startTime = _data["startTime"];
      Timer.periodic(const Duration(seconds: 1), (Timer t) {
        dateNow = Timestamp.now();
        setState(() {
          timeAgo = dateNow.toDate().difference(startTime.toDate());
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Active Task"),
        centerTitle: true,
      ),
      body: _data != null
          ? ListView(
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
                        _data["name"] != null ? _data["name"] : "",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
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
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold),
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
                            onPressed: () async {
                              await _firestore
                                  .collection("Categories")
                                  .document(widget.categoryId)
                                  .collection("Tasks")
                                  .document(widget.taskId)
                                  .setData({
                                "isDone": true,
                                "endTime": Timestamp.now()
                              }, merge: true);
                              await _firestore
                                  .collection("UsersTasks")
                                  .document(_user.uid)
                                  .updateData({
                                "activeTask": false,
                              });
                              Navigator.popAndPushNamed(context, 'mainScreen');
                            },
                            icon: Icon(Icons.check),
                            label: Text(
                              "Finish Task",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
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
                        child: Text(_data["description"] != null
                            ? _data["description"]
                            : "No description"),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}