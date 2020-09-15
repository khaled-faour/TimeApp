import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeapp/main.dart';
import 'package:timeapp/src/activeTask.dart';

var taskData;

class MyTasks extends StatefulWidget {
  @override
  _MyTasksState createState() => _MyTasksState();
}

class _MyTasksState extends State<MyTasks> {
  final _firestore =
      Firestore.instance.collection("UsersTasks").document(loggedInUser.uid);

  @override
  Widget build(BuildContext context) {
    return loggedInUser.uid != null
        ? Container(
            child: StreamBuilder(
              stream: _firestore.collection("Tasks").snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if ((!snapshot.hasData || snapshot.data.documents.isEmpty)) {
                  return Center(child: Text("No Tasks"));
                } else if (snapshot.hasData) {
                  final tasks = snapshot.data.documents;
                  List<TaskCard> taskCards = [];
                  for (var task in tasks) {
                    final taskCard = TaskCard(task: task);
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
        : Center(child: CircularProgressIndicator());
  }
}

class TaskCard extends StatelessWidget {
  final task;
  TaskCard({this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(
        left: 10,
        right: 10,
        top: 8,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: ListTile(
        leading: Icon(Icons.track_changes),
        title: Row(
          children: [
            Text(
              task["name"] != null ? task["name"] : "No name",
              style:
                  TextStyle(color: Theme.of(context).textTheme.bodyText2.color),
            ),
            task["endTime"] != null
                ? Text("")
                : Text(
                    " (Active)",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 12,
                    ),
                  )
          ],
        ),
        trailing: RaisedButton(
          child: Text("View"),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) =>
                    ActiveTaskScreen(documentId: task.documentID),
              ),
            );
          },
        ),
      ),
    );
  }
}
