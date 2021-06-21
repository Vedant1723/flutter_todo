import 'package:flutter/material.dart';
import './Task/AddTask.dart';
import './Auth/SignUpPage.dart';
import './Auth/LoginPage.dart';
import 'HomePage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? token;

  SharedPreferences? prefs;

  bool isAuth = false;

  @override
  void initState() {
    super.initState();
    initializePreference();
  }

  Future<void> initializePreference() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs?.getString('token');
      if (token != null) {
        isAuth = true;
        print(token!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: token != null ? HomePage() : LoginPage(),
        routes: <String, WidgetBuilder>{
          "/login": (BuildContext context) => LoginPage(),
          "/signup": (BuildContext context) => SignUpPage(),
          "/add-tasks": (BuildContext context) => AddTask()
        });
  }
}
