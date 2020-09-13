import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

Firestore _firestore = Firestore.instance;
var _data;

class ActiveTaskScreen extends StatefulWidget {
  final String categoryId;
  final String taskId;

  ActiveTaskScreen({Key key, this.categoryId, this.taskId}) : super(key: key);

  @override
  _ActiveTaskScreenState createState() => _ActiveTaskScreenState();
}

class _ActiveTaskScreenState extends State<ActiveTaskScreen> {
  Timestamp dateNow;
  Timestamp startTime;
  Duration timeAgo;
  @override
  void initState() {
    super.initState();
    _data = null;
    getData();
    Timer.periodic(const Duration(seconds: 1), (Timer t) => setTime());
  }

  getData() async {
    await _firestore
        .collection("Categories")
        .document(widget.categoryId)
        .collection("Tasks")
        .document(widget.taskId)
        .get()
        .then((value) async {
      setState(() {
        _data = value.data;
      });
    });
  }

  setTime() {
    setState(() {
      dateNow = Timestamp.now();
      startTime = _data["startTime"];
      timeAgo = dateNow.toDate().difference(startTime.toDate());
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
