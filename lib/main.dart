import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeapp/src/forgotPasswordPage.dart';
import 'package:timeapp/src/loginPage.dart';
import 'package:timeapp/src/signup.dart';
import 'package:timeapp/src/homeScreen.dart';
import 'package:timeapp/src/welcomePage.dart';
import 'package:page_transition/page_transition.dart';
import 'package:timeapp/src/push_notification.dart';

FirebaseUser loggedInUser;
void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var notificationsManager = PushNotificationsManager();
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      await FirebaseAuth.instance.currentUser().then((user) {
        setState(() {
          loggedInUser = user;
        });
      });
      if (loggedInUser != null) {
        setState(() {
          notificationsManager.init();
        });

        print(loggedInUser.email);
      } else {
        Navigator.pushReplacementNamed(context, 'welcomeScreen');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return MaterialApp(
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case 'welcomeScreen':
            return PageTransition(
                child: WelcomePage(), type: PageTransitionType.fade);
            break;
          case 'loginScreen':
            return PageTransition(
                child: LoginPage(), type: PageTransitionType.fade);
            break;
          case 'registerScreen':
            return PageTransition(
                child: SignUpPage(), type: PageTransitionType.fade);
            break;
          case 'mainScreen':
            return PageTransition(
                child: HomeScreen(), type: PageTransitionType.fade);
            break;
          case 'forgotPasswordScreen':
            return PageTransition(
                child: ForgotPasswordScreen(), type: PageTransitionType.fade);
            break;
          default:
            return null;
        }
      },
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Color(0xfffbb448),
        accentColor: Color(0xffe46b10),
        textTheme: GoogleFonts.latoTextTheme(textTheme),
      ),
      darkTheme: ThemeData.dark().copyWith(
        brightness: Brightness.dark,
        accentColor: Colors.grey[900],
        textTheme: GoogleFonts.latoTextTheme(textTheme).copyWith(
          bodyText2: GoogleFonts.montserrat(
              textStyle: textTheme.bodyText2, color: Colors.white),
          bodyText1: GoogleFonts.montserrat(
              textStyle: textTheme.bodyText1, color: Colors.white60),
        ),
      ),
      //themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: loggedInUser == null ? WelcomePage() : HomeScreen(),
    );
  }
}
