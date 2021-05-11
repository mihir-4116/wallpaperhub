import 'package:flutter/material.dart';
import 'package:wallpaperhub/auth/HomePage.dart';
import 'package:wallpaperhub/screens/homeScreen.dart';
import 'package:wallpaperhub/constants.dart';
import 'package:wallpaperhub/auth/sign-up.dart';
import 'package:wallpaperhub/auth/log-in.dart';
import 'package:wallpaperhub/auth/start.dart';
import 'package:wallpaperhub/auth/resetpassword.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          appBarTheme: AppBarTheme(
            color: Colors.white,
            iconTheme: IconThemeData(color: Colors.black),
          ),
        ),
        home: HomePage1(),
        routes: <String, WidgetBuilder>{
          "Login": (BuildContext context) => Login(),
          "SignUp": (BuildContext context) => SignUp(),
          "start": (BuildContext context) => Start(),
          "home": (BuildContext context) => HomeScreen(),
          "reset": (BuildContext context) => ResetScreen(),
        });
  }
}
