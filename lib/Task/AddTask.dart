import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/HomePage.dart';

class AddTask extends StatefulWidget {
  const AddTask({Key? key}) : super(key: key);

  @override
  _AddTaskState createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  GlobalKey<FormState> _key = new GlobalKey();
  SharedPreferences? prefs;
  String? token;

  String title = "", description = "";

  @override
  void initState() {
    super.initState();
    initializePreference();
  }

  Future<void> initializePreference() async {
    this.prefs = await SharedPreferences.getInstance();
    setState(() {
      token = this.prefs?.getString('token');
      print(token);
      if (token != null) {
        print(token);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Task'),
      ),
      body: Center(
        child: Form(
          key: _key,
          child: Column(
            children: [
              Padding(padding: EdgeInsets.all(10.0)),
              ListTile(
                title: TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  enableSuggestions: true,
                  validator: (input) {
                    if (input == "") {
                      return 'Field is Empty';
                    }
                  },
                  decoration: InputDecoration(
                      labelText: "Title",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      icon: Icon(Icons.title)),
                  onSaved: (input) => title = input!,
                ),
              ),
              Padding(padding: EdgeInsets.all(10.0)),
              ListTile(
                title: TextFormField(
                  maxLines: 10,
                  keyboardType: TextInputType.emailAddress,
                  enableSuggestions: true,
                  validator: (input) {
                    if (input == "") {
                      return 'Field is Empty';
                    }
                  },
                  decoration: InputDecoration(
                      labelText: "Description",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      icon: Icon(Icons.description)),
                  onSaved: (input) => description = input!,
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
                    onPressed: addTask,
                    splashColor: Colors.black,
                    child: Text("Add"),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> addTask() async {
    if (_key.currentState!.validate()) {
      _key.currentState!.save();
      http.Response response = await http.post(
        Uri.parse("http://192.168.29.210:5000/api/user/create-task"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token!
        },
        body: jsonEncode(
            <String, String>{'title': title, 'description': description}),
      );
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print(data);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (BuildContext context) => HomePage()));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(data['msg']),
        ));
      }
    }
  }
}
