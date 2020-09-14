import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timeapp/src/activeTask.dart';

FirebaseUser _user;
Firestore _firestore = Firestore.instance;
var _data;
var _userData;
final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

class TaskDetailsScreen extends StatefulWidget {
  final String categoryId;
  final String taskId;

  TaskDetailsScreen({Key key, @required this.categoryId, @required this.taskId})
      : super(key: key);

  @override
  _TaskDetailsScreenState createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  @override
  void initState() {
    super.initState();
    _data = null;
    getCurrentUser();
    getData();
  }

  getCurrentUser() async {
    try {
      final user = await FirebaseAuth.instance.currentUser();
      if (user != null) {
        setState(() {
          _user = user;
        });
        print(_user.email);
      } else {
        print("No User Found");
      }
    } catch (e) {
      print(e);
    }
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
    await _firestore
        .collection("UsersTasks")
        .document(_user.uid)
        .get()
        .then((value) async {
      _userData = value.data;
    });
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
                                onPressed: () {
                                  showDialog(
                                      context: (context),
                                      barrierDismissible: false,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text(
                                            "Are you sure you want to start this task?",
                                          ),
                                          content: Text("Accepting..."),
                                          actions: [
                                            FlatButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: Text("Cancle")),
                                            RaisedButton(
                                              onPressed: () async {
                                                if (_userData["activeTask"] !=
                                                    true) {
                                                  await _firestore
                                                      .collection("UsersTasks")
                                                      .document(_user.uid)
                                                      .collection("Tasks")
                                                      .document()
                                                      .setData({
                                                    "name": _data["name"],
                                                    "taskId": widget.taskId,
                                                    "categoryId":
                                                        widget.categoryId
                                                  });
                                                  await _firestore
                                                      .collection("UsersTasks")
                                                      .document(_user.uid)
                                                      .setData(
                                                          {"activeTask": true});
                                                  await _firestore
                                                      .collection("Categories")
                                                      .document(
                                                          widget.categoryId)
                                                      .collection("Tasks")
                                                      .document(widget.taskId)
                                                      .setData({
                                                    "isTaken": true,
                                                    "startTime":
                                                        Timestamp.now(),
                                                    "takenBy": _user.uid
                                                  }, merge: true);
                                                  Navigator.popUntil(
                                                      context,
                                                      ModalRoute.withName(
                                                          'mainScreen'));
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (BuildContext
                                                              context) =>
                                                          ActiveTaskScreen(
                                                        categoryId:
                                                            widget.categoryId,
                                                        taskId: widget.taskId,
                                                      ),
                                                    ),
                                                  );
                                                } else {
                                                  final snackBar = SnackBar(
                                                      content: Text(
                                                          "Only one active task is allowed"));
                                                  _scaffoldKey.currentState
                                                      .showSnackBar(snackBar);
                                                  Navigator.pop(context);
                                                }
                                              },
                                              child: Text("Yes"),
                                            )
                                          ],
                                          actionsPadding: EdgeInsets.all(8.0),
                                        );
                                      });
                                  print("object");
                                },
                                child: Text("Start"),
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
