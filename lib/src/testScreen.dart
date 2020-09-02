import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final Firestore _firestore = Firestore.instance;
FirebaseUser loggedInUser;

class TestScreen extends StatefulWidget {
  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
      return;
    }
  }

  var categories = _firestore
      .collection("Users")
      .document(loggedInUser.uid.toString())
      .collection("{collection}")
      .getDocuments();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(categories.toString()),
    );
  }
}
