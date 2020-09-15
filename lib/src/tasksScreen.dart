import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timeapp/src/myTasks.dart';
import 'package:timeapp/src/taskDetails.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
final _firestore = Firestore.instance;
String _categoryId;

class TasksScreen extends StatefulWidget {
  final String documentID;

  TasksScreen({Key key, this.documentID}) : super(key: key);
  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  @override
  void initState() {
    super.initState();
    _categoryId = widget.documentID;
  }

  final List<Widget> _children = [TasksList(), MyTasks()];
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(_selectedIndex == 0 ? "Tasks" : "My Tasks"),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.cancel),
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, 'welcomeScreen');
              },
              tooltip: "Logout",
            ),
          ],
        ),
        body: _children[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(
                Icons.track_changes,
              ),
              title: Text('All'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              title: Text('My Tasks'),
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Theme.of(context).primaryColor,
          onTap: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ));
  }
}

class TasksList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _firestore
            .collection("Categories")
            .document(_categoryId)
            .collection("Tasks")
            .snapshots(),
        builder: buildTasksList);
  }
}

Widget buildTasksList(
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
              title: Text(
                task.data["name"] != null ? task.data["name"] : "No name",
                style: TextStyle(
                    color: Theme.of(context).textTheme.bodyText2.color),
              ),
              children: [
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Flexible(
                      child: task.data["description"] != null
                          ? Text(
                              task.data["description"],
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
                        if (task.data["isTaken"] != true) {
                          return Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TaskDetailsScreen(
                                      categoryId: _categoryId,
                                      taskId: task.documentID)));
                        }
                        final snackBar =
                            SnackBar(content: Text("Task already taken!"));
                        _scaffoldKey.currentState.showSnackBar(snackBar);
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
