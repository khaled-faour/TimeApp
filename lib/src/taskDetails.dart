import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timeapp/src/activeTask.dart';

Firestore _firestore = Firestore.instance;
FirebaseUser currentUser;

final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

class TaskDetailsScreen extends StatefulWidget {
  final String categoryId;
  final String taskId;

  TaskDetailsScreen({Key key, this.categoryId, this.taskId}) : super(key: key);

  @override
  _TaskDetailsScreenState createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  var _data;
  Map<String, dynamic> _userData;
  @override
  void initState() {
    _data = null;
    super.initState();
    getUser();
    getData();
  }

  getUser() async {
    try {
      await FirebaseAuth.instance.currentUser().then((user) {
        if (user != null) {
          currentUser = user;
          print(currentUser);
        } else {
          print("No User");
        }
      });
    } catch (e) {
      print("getUserError: $e");
    }
  }

  getData() async {
    await _firestore
        .collection("Categories")
        .document(widget.categoryId)
        .collection("Tasks")
        .document(widget.taskId)
        .get()
        .then((value) {
      setState(() {
        _data = value.data;
      });
    });
    await _firestore
        .collection("UsersTasks")
        .document(currentUser.uid)
        .get()
        .then((value) async {
      setState(() {
        _userData = value.data;
      });
    });
  }

  confrimTask() async {
    if (_userData.containsKey("activeTask") == true &&
        _userData["activeTask"] == true) {
      Navigator.pop(context);
      final snackBar =
          SnackBar(content: Text("Only one active task is allowed"));
      _scaffoldKey.currentState.showSnackBar(snackBar);
    } else {
      await _firestore
          .collection("UsersTasks")
          .document(currentUser.uid)
          .collection("Tasks")
          .document()
          .setData({
        "name": _data["name"],
        "taskId": widget.taskId,
        "categoryId": widget.categoryId,
        "startTime": Timestamp.now(),
        "avgTime": _data["avgTime"],
        "description": _data["description"]
      });

      await _firestore
          .collection("UsersTasks")
          .document(currentUser.uid)
          .setData({"activeTask": true}, merge: true);

      _firestore
          .collection("UsersTasks")
          .document(currentUser.uid)
          .collection("Tasks")
          .snapshots()
          .listen((snapshot) {
        for (int i = 0; i < snapshot.documents.length; i++) {
          var document = snapshot.documents[i];
          if (document.data["taskId"] == widget.taskId &&
              document.data["endTime"] == null) {
            return Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => ActiveTaskScreen(
                  documentId: document.documentID,
                ),
              ),
            );
          }
        }
      });

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(),
      body: _data != null
          ? Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: ListView(
                children: [
                  Card(
                    margin: EdgeInsets.all(10),
                    child: ListTile(
                      title: Center(
                        child: Text(
                          _data["name"] != null ? _data["name"] : "",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text("Description"),
                        ),
                        Divider(
                          indent: 20,
                          endIndent: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: _data["description"] != null
                              ? Text(_data["description"])
                              : Center(child: CircularProgressIndicator()),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Avg. Time: ${_data["avgTime"]}"),
                              VerticalDivider(),
                              RaisedButton(
                                child: Text("Start"),
                                onPressed: () {
                                  showDialog(
                                      context: (context),
                                      barrierDismissible: false,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text(
                                            "Confirm",
                                          ),
                                          content: Text(
                                              "Are you sure you want to start this task?"),
                                          actions: [
                                            FlatButton(
                                              child: Text("Cancle"),
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                            ),
                                            RaisedButton(
                                                child: Text("Yes"),
                                                onPressed: confrimTask)
                                          ],
                                          actionsPadding: EdgeInsets.all(8.0),
                                        );
                                      });
                                  print("object");
                                },
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
