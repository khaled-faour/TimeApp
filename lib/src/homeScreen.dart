import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final _firestore = Firestore.instance;
FirebaseUser loggedInUser;
bool _isLoading = true;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
        title: Text("Home Screen"),
        centerTitle: true,
        actions: <Widget>[
          InkWell(
            child: Icon(Icons.cancel),
            onTap: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, 'welcomeScreen');
            },
          )
        ],
      ),
      body: _isLoading ? CircularProgressIndicator() : CategoriesList(),
    );
  }
}

class CategoriesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _firestore.collection("Categories").snapshots(),
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
          return ListTile(
            leading: Icon(Icons.category),
            title: Text(category.data["name"]),
            subtitle: Text("subtitle"),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              print(category.data["name"] + " tapped");
            },
          );
        });
  } else if (snapshot.connectionState == ConnectionState.done &&
      !snapshot.hasData) {
    return Text("No Categories");
  } else {
    return CircularProgressIndicator();
  }
}
