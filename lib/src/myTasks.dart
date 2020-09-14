import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timeapp/src/activeTask.dart';

final Firestore _firestore = Firestore.instance;
FirebaseUser _user;
var taskData;

class MyTasks extends StatefulWidget {
  final String categoryId;
  final String taskId;
  MyTasks({Key key, this.categoryId, this.taskId}) : super(key: key);
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
      await FirebaseAuth.instance.currentUser().then((value) {
        setState(() {
          _user = value;
        });
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _user != null
        ? Container(
            child: StreamBuilder(
              stream: _firestore
                  .collection("UsersTasks")
                  .document(_user.uid)
                  .collection("Tasks")
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData &&
                    snapshot.connectionState == ConnectionState.done) {
                  return Text("No Tasks");
                } else if (snapshot.hasData) {
                  final tasks = snapshot.data.documents;
                  List<TaskCard> taskCards = [];
                  for (var task in tasks) {
                    final categotyId = task["categoryId"];
                    final taskId = task["taskId"];

                    final taskCard = TaskCard(
                      categoryId: categotyId,
                      taskId: taskId,
                    );

                    taskCards.add(taskCard);
                  }
                  return ListView(children: taskCards);
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          )
        : CircularProgressIndicator();
  }
}

class TaskCard extends StatelessWidget {
  final String categoryId;
  final String taskId;
  TaskCard({this.categoryId, this.taskId});

  getData() async {
    try {
      await _firestore
          .collection("Categories")
          .document(categoryId)
          .collection("Tasks")
          .document(taskId)
          .get()
          .then((value) => taskData = value.data);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    getData();
    return taskData != null
        ? Card(
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
                    taskData["name"] != null
                        ? taskData["name"]
                        : LinearProgressIndicator(),
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyText2.color),
                  ),
                  taskData["isDone"] == false ? Text("Active") : Text("")
                ],
              ),
              children: [
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Flexible(
                      child: taskData["description"] != null
                          ? Text(
                              taskData["description"],
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => ActiveTaskScreen(
                              categoryId: categoryId,
                              taskId: taskId,
                            ),
                          ),
                        );
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) => TaskDetailsScreen(
                        //             categoryId: _documentID,
                        //             taskId: task.documentID)));
                      },
                      child: Text("View"),
                    ),
                  ],
                ),
              ],
            ),
          )
        : LinearProgressIndicator();
  }
}

// class MyTasksList extends StatefulWidget {
//   final String categoryId;
//   final String taskId;
//   MyTasksList({Key key, this.categoryId, this.taskId}) : super(key: key);

//   @override
//   _MyTasksListState createState() => _MyTasksListState();
// }

// class _MyTasksListState extends State<MyTasksList> {
//   @override
//   Widget build(BuildContext context) {
//     return _user != null
//         ? StreamBuilder(
//             stream: _firestore
//                 .collection("UsersTasks")
//                 .document(_user.uid)
//                 .collection("Tasks")
//                 .snapshots(),
//             builder: buildMyTasksList,
//           )
//         : Center(
//             child: CircularProgressIndicator(),
//           );
//   }

//   Widget buildMyTasksList(
//       BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//     if ((!snapshot.hasData || snapshot.data.documents.isEmpty) &&
//         snapshot.connectionState == ConnectionState.done) {
//       return Text("No Tasks");
//     } else if (snapshot.hasData) {
//       return ListView.builder(
//           itemCount: snapshot.data.documents.length,
//           itemBuilder: (context, index) {
//             DocumentSnapshot task = snapshot.data.documents[index];
//             return Card(
//               margin: EdgeInsets.only(
//                 left: 10,
//                 right: 10,
//                 top: 8,
//               ),
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10.0)),
//               child: ExpansionTile(
//                 childrenPadding: EdgeInsets.all(20),
//                 expandedAlignment: Alignment.centerLeft,
//                 leading: Icon(Icons.track_changes),
//                 title: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       task.data["name"] != null
//                           ? task.data["name"]
//                           : LinearProgressIndicator(),
//                       style: TextStyle(
//                           color: Theme.of(context).textTheme.bodyText2.color),
//                     ),
//                   ],
//                 ),
//                 children: [
//                   Divider(),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       Flexible(
//                         child: task.data["name"] != null
//                             ? Text(
//                                 task.data["name"],
//                                 overflow: TextOverflow.ellipsis,
//                                 maxLines: 3,
//                               )
//                             : CircularProgressIndicator(),
//                       ),
//                     ],
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       RaisedButton(
//                         onPressed: () {
//                           print(
//                               "cat: ${widget.categoryId}, task: ${widget.taskId}");
//                           // Navigator.push(
//                           //   context,
//                           //   MaterialPageRoute(
//                           //     builder: (BuildContext context) => ActiveTaskScreen(
//                           //       categoryId: _categoryId,
//                           //       taskId: _taskId,
//                           //     ),
//                           //   ),
//                           // );
//                           // Navigator.push(
//                           //     context,
//                           //     MaterialPageRoute(
//                           //         builder: (context) => TaskDetailsScreen(
//                           //             categoryId: _documentID,
//                           //             taskId: task.documentID)));
//                         },
//                         child: Text("View"),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             );
//           });
//     } else {
//       return Center(child: CircularProgressIndicator());
//     }
//   }
// }
