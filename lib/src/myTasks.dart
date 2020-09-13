import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final Firestore _firestore = Firestore.instance;
FirebaseUser _user;

class MyTasks extends StatefulWidget {
  @override
  _MyTasksState createState() => _MyTasksState();
}

class _MyTasksState extends State<MyTasks> {
  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await FirebaseAuth.instance.currentUser();
      if (user != null) {
        _user = user;
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: MyTasksList(),
    );
  }
}

class MyTasksList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _user != null
        ? StreamBuilder(
            stream: _firestore
                .collection("UsersTasks")
                .document(_user.uid)
                .collection("Tasks")
                .snapshots(),
            builder: buildMyTasksList)
        : Center(child: CircularProgressIndicator());
  }
}

Widget buildMyTasksList(
    BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
  if ((!snapshot.hasData || snapshot.data.documents.isEmpty) &&
      snapshot.connectionState == ConnectionState.done) {
    return Text("No Tasks");
  } else if (snapshot.hasData) {
    return ListView.builder(
        itemCount: snapshot.data.documents.length,
        itemBuilder: (context, index) {
          DocumentSnapshot task = snapshot.data.documents[index];
          return Card(
            margin: EdgeInsets.only(
              left: 10,
              right: 10,
              top: 8,
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            child: ExpansionTile(
              childrenPadding: EdgeInsets.all(20),
              expandedAlignment: Alignment.centerLeft,
              leading: Icon(Icons.track_changes),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    task.data["name"] != null
                        ? task.data["name"]
                        : LinearProgressIndicator(),
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyText2.color),
                  ),
                ],
              ),
              children: [
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Flexible(
                      child: task.data["name"] != null
                          ? Text(
                              task.data["name"],
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                            )
                          : CircularProgressIndicator(),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    RaisedButton(
                      onPressed: () {
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) => TaskDetailsScreen(
                        //             categoryId: _documentID,
                        //             taskId: task.documentID)));
                      },
                      child: Text("START"),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  } else {
    return Center(child: CircularProgressIndicator());
  }
}
