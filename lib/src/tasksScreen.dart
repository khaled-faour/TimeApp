import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final _firestore = Firestore.instance;
FirebaseUser loggedInUser;
bool _isLoading = true;

class TasksScreen extends StatefulWidget {
  final String documentID;

  TasksScreen({Key key, this.documentID}) : super(key: key);
  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print(e);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tasks"),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.cancel),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, 'welcomeScreen');
            },
          ),
        ],
      ),
      body: _isLoading
          ? CircularProgressIndicator()
          : TasksList(
              documentID: widget.documentID,
            ),
    );
  }
}

class TasksList extends StatelessWidget {
  final String documentID;

  TasksList({Key key, this.documentID}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _firestore
            .collection("Categories")
            .document(documentID)
            .collection("Tasks")
            .snapshots(),
        builder: buildTasksList);
  }
}

Widget buildTasksList(
    BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
  if (!snapshot.hasData || snapshot.data.documents.isEmpty) {
    return Text("No Tasks");
  } else if (snapshot.hasData) {
    return ListView.builder(
        itemCount: snapshot.data.documents.length,
        itemBuilder: (context, index) {
          DocumentSnapshot task = snapshot.data.documents[index];
          print(task.data.length);
          return Card(
            child: ListTile(
              leading: Icon(Icons.track_changes),
              title: Text(
                task.data["name"],
                style: TextStyle(
                    color: Theme.of(context).textTheme.bodyText2.color),
              ),
              subtitle: Text(
                "Description",
                style: TextStyle(
                    color: Theme.of(context).textTheme.bodyText1.color),
              ),
              onTap: () {
                print(task.data["name"] + " tapped");
              },
            ),
          );
        });
  } else {
    return CircularProgressIndicator();
  }
}
