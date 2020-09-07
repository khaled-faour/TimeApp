import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timeapp/src/Widget/bezierContainer.dart';
import 'package:timeapp/src/Widget/entryField.dart';
import 'package:timeapp/src/Widget/switchScreen.dart';
import 'package:timeapp/src/Widget/title.dart';
import 'package:timeapp/src/Widget/backButton.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeapp/src/homeScreen.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  bool _isLoading = false;
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
                  color: MediaQuery.of(context).platformBrightness ==
                          Brightness.dark
                      ? Theme.of(context).primaryColor.withAlpha(100)
                      : Colors.grey.shade200,
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
          'Register Now',
          style: TextStyle(
              fontSize: 20,
              color:
                  MediaQuery.of(context).platformBrightness == Brightness.dark
                      ? Colors.white70
                      : Colors.white),
        ),
      ),
      onTap: () async {
        if (nameController.text.isEmpty ||
            emailController.text.isEmpty ||
            passwordController.text.isEmpty) {
          final snackBar =
              SnackBar(content: Text("Please fill all the fields"));
          return _scaffoldKey.currentState.showSnackBar(snackBar);
        }
        try {
          setState(() {
            _isLoading = true;
          });
          FirebaseUser user = (await FirebaseAuth.instance
                  .createUserWithEmailAndPassword(
                      email: emailController.text,
                      password: passwordController.text))
              .user;
          setState(() {
            _isLoading = false;
          });
          if (user != null) {
            setState(() {
              loggedInUser = user;
            });
            Navigator.pop(context);
            Navigator.pushReplacementNamed(context, 'mainScreen');
          } else {
            final snackBar = SnackBar(
                content: Text("Something went wrong, please try again"));
            _scaffoldKey.currentState.showSnackBar(snackBar);
          }
        } on PlatformException catch (e) {
          print(e.code);
          setState(() {
            _isLoading = false;
          });
          final snackBar = SnackBar(content: Text(e.code));
          _scaffoldKey.currentState.showSnackBar(snackBar);
        }
      },
    );
  }

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        entryField("Name", context,
            hintText: "First and last name", controller: nameController),
        entryField("Email id", context,
            hintText: 'example@example.com', controller: emailController),
        entryField("Password", context,
            isPassword: true,
            hintText: "Password",
            controller: passwordController),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      key: _scaffoldKey,
      body: ModalProgressHUD(
        inAsyncCall: _isLoading,
        child: Container(
          height: height,
          child: Stack(
            children: <Widget>[
              Positioned(
                top: -MediaQuery.of(context).size.height * .15,
                right: -MediaQuery.of(context).size.width * .4,
                child: BezierContainer(),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: height * .2),
                      title(context),
                      SizedBox(
                        height: 50,
                      ),
                      _emailPasswordWidget(),
                      SizedBox(
                        height: 20,
                      ),
                      _submitButton(),
                      SizedBox(height: height * .14),
                      switchScreen(
                          context, 'Already have an account ?', 'Login',
                          onTap: () {
                        Navigator.pushReplacementNamed(context, 'loginScreen');
                      }),
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
