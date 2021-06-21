import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../HomePage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  GlobalKey<FormState> _key = new GlobalKey();
  String name = "", email = "", password = "";

  SharedPreferences? prefs;

  @override
  void initState() {
    super.initState();
    initializePreference().whenComplete(() {
      setState(() {});
    });
  }

  Future<void> initializePreference() async {
    this.prefs = await SharedPreferences.getInstance();
  }

  bool showPassword = false;

  viewPassword() {
    setState(() {
      showPassword = !showPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Form(
          key: _key,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(padding: EdgeInsets.all(25.0)),
              Icon(
                Icons.task_rounded,
                size: 60.0,
              ),
              Padding(padding: EdgeInsets.all(10.0)),
              ListTile(
                title: TextFormField(
                  validator: (input) {
                    if (input == "") {
                      return 'Field is Empty';
                    }
                  },
                  decoration: InputDecoration(
                      labelText: "Name",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      icon: Icon(Icons.person)),
                  onSaved: (input) => name = input!,
                ),
              ),
              ListTile(
                title: TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  validator: (input) {
                    if (input == "") {
                      return 'Field is Empty';
                    }
                  },
                  decoration: InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      icon: Icon(Icons.mail)),
                  onSaved: (input) => email = input!,
                ),
              ),
              ListTile(
                title: TextFormField(
                  obscureText: !showPassword,
                  validator: (input) {
                    if (input == "") {
                      return 'Field is Empty';
                    }
                  },
                  decoration: InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      icon: Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: showPassword
                            ? new Icon(Icons.no_encryption_sharp)
                            : new Icon(Icons.enhanced_encryption),
                        onPressed: viewPassword,
                      )),
                  onSaved: (input) => password = input!,
                ),
              ),
              Padding(padding: EdgeInsets.all(10.0)),
              ButtonTheme(
                  minWidth: 200.0,
                  height: 45.0,
                  child: RaisedButton(
                    color: Colors.black12,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Colors.blue)),
                    onPressed: saveData,
                    splashColor: Colors.black,
                    child: Text("Signup"),
                  )),
              Padding(padding: EdgeInsets.all(10.0)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Already Have an accout? "),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Login",
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> saveData() async {
    print("Saved Data");
    if (_key.currentState!.validate()) {
      _key.currentState!.save();

      http.Response response = await http.post(
        Uri.parse("http://192.168.29.210:5000/api/user/signup"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'name': name,
          'email': email,
          'password': password
        }),
      );
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print(data['msg']);
        this.prefs?.setString("token", data['token']);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomePage()));
      } else {
        print("Error");
      }
    }
  }
}
