import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeapp/src/loginPage.dart';
import 'package:timeapp/src/signup.dart';
import 'package:timeapp/src/homeScreen.dart';
import 'src/welcomePage.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FirebaseUser loggedInUser;

  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await FirebaseAuth.instance.currentUser();
      if (user != null) {
        setState(() {
          loggedInUser = user;
        });

        print(loggedInUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return MaterialApp(
      routes: {
        'welcomeScreen': (context) => WelcomePage(),
        'loginScreen': (context) => LoginPage(),
        'registerScreen': (context) => SignUpPage(),
        'mainScreen': (context) => HomeScreen()
      },
      theme: ThemeData(
        primaryColor: Color(0xfffbb448),
        accentColor: Color(0xffe46b10),
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.latoTextTheme(textTheme).copyWith(
          body1: GoogleFonts.montserrat(textStyle: textTheme.body1),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: loggedInUser == null ? WelcomePage() : HomeScreen(),
    );
  }
}
