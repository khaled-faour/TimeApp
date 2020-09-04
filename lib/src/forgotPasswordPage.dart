import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:timeapp/src/Widget/backButton.dart';
import 'package:timeapp/src/Widget/bezierContainer.dart';
import 'package:timeapp/src/Widget/entryField.dart';
import 'package:timeapp/src/Widget/title.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController emailController = TextEditingController();
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  bool _isLoading = false;
  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        entryField("Email id",
            hintText: "example@example.com", controller: emailController),
      ],
    );
  }

  Widget _submitButton() {
    return InkWell(
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.grey.shade200,
                  offset: Offset(2, 4),
                  blurRadius: 5,
                  spreadRadius: 2)
            ],
            gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).accentColor
                ])),
        child: Text(
          'Send Email',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
      onTap: () async {
        try {
          setState(() {
            _isLoading = true;
          });
          await _firebaseAuth.sendPasswordResetEmail(
              email: emailController.text);
          setState(() {
            _isLoading = false;
          });
          final snackBar = SnackBar(
            content: Text("Password reset email has been sent."),
          );
          return _scaffoldKey.currentState.showSnackBar(snackBar);
        } on PlatformException catch (e) {
          setState(() {
            _isLoading = false;
          });
          final snackBar = SnackBar(
            content: Text(e.code),
          );
          return _scaffoldKey.currentState.showSnackBar(snackBar);
        }
        // if (emailController.text.isEmpty || passwordController.text.isEmpty) {
        //   final snackBar =
        //       SnackBar(content: Text("Please fill all the fields"));
        //   return _scaffoldKey.currentState.showSnackBar(snackBar);
        // }
        // setState(() {
        //   _isLoading = true;
        // });
        // try {
        //   user = (await FirebaseAuth.instance.signInWithEmailAndPassword(
        //           email: emailController.text,
        //           password: passwordController.text))
        //       .user;
        //   if (user != null) {
        //     final snackBar = SnackBar(content: Text("Welcome, ${user.email}"));
        //     _scaffoldKey.currentState.showSnackBar(snackBar);
        //     Navigator.pop(context);
        //     Navigator.pushReplacementNamed(context, 'mainScreen');
        //   } else {
        //     final snackBar = SnackBar(
        //         content: Text("Something went wron, please try again"));
        //     _scaffoldKey.currentState.showSnackBar(snackBar);
        //   }
        // } on PlatformException catch (e) {
        //   print(e.code);
        //   final snackBar = SnackBar(content: Text(e.code));
        //   _scaffoldKey.currentState.showSnackBar(snackBar);
        // }
        // setState(() {
        //   _isLoading = false;
        // });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return ModalProgressHUD(
      inAsyncCall: _isLoading,
      child: Scaffold(
        key: _scaffoldKey,
        body: Container(
          height: height,
          child: Stack(
            children: <Widget>[
              Positioned(
                  top: -height * .15,
                  right: -MediaQuery.of(context).size.width * .4,
                  child: BezierContainer()),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: height * .2),
                      title(context),
                      SizedBox(height: 50),
                      _emailPasswordWidget(),
                      SizedBox(height: 20),
                      _submitButton(),
                    ],
                  ),
                ),
              ),
              Positioned(top: 40, left: 0, child: backButton(context)),
            ],
          ),
        ),
      ),
    );
  }
}
