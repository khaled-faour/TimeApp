import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:timeapp/src/myTasks.dart';
import 'package:timeapp/src/tasksScreen.dart';

final _firestore = Firestore.instance;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _children = [
    CategoriesList(),
    MyTasks(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(_selectedIndex == 0 ? "Categories" : "My Tasks"),
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
              icon: Icon(Icons.category),
              title: Text('Categories'),
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

class CategoriesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _firestore.collection("Categories").orderBy("name").snapshots(),
        builder: buildCategoriesList);
  }
}

Widget buildCategoriesList(
    BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
  if (snapshot.hasData) {
    return ListView.builder(
        itemCount: snapshot.data.documents.length,
        itemBuilder: (context, index) {
          DocumentSnapshot category = snapshot.data.documents[index];
          return Card(
            margin: EdgeInsets.only(
              left: 10,
              right: 10,
              top: 8,
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            child: ListTile(
              leading: Icon(Icons.category),
              title: Text(
                category.data["name"],
                style: TextStyle(
                    color: Theme.of(context).textTheme.bodyText2.color),
              ),
              subtitle: Text(
                "subtitle",
                style: TextStyle(
                    color: Theme.of(context).textTheme.bodyText1.color),
              ),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                    context,
                    PageTransition(
                        type: PageTransitionType.fade,
                        child: TasksScreen(
                          documentID: category.documentID,
                        )));
              },
            ),
          );
        });
  } else if ((!snapshot.hasData || snapshot.data.documents.isEmpty) &&
      snapshot.connectionState == ConnectionState.done) {
    return Text("No Categories");
  } else {
    return Center(child: CircularProgressIndicator());
  }
}
