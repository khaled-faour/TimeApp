import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeapp/src/forgotPasswordPage.dart';
import 'package:timeapp/src/loginPage.dart';
import 'package:timeapp/src/signup.dart';
import 'package:timeapp/src/homeScreen.dart';
import 'src/welcomePage.dart';
import 'package:page_transition/page_transition.dart';

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
      routes: {
        //'welcomeScreen': (context) => WelcomePage(),
        //'loginScreen': (context) => LoginPage(),
        //'registerScreen': (context) => SignUpPage(),
        //'mainScreen': (context) => HomeScreen(),
        //'forgotPasswordScreen': (context) => ForgotPasswordScreen()
      },
      theme: ThemeData(
        primaryColor: Color(0xfffbb448),
        accentColor: Color(0xffe46b10),
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.latoTextTheme(textTheme).copyWith(
          bodyText2: GoogleFonts.montserrat(textStyle: textTheme.bodyText2),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: loggedInUser == null ? WelcomePage() : HomeScreen(),
    );
  }
}
