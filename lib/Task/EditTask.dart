import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/HomePage.dart';

class EditTask extends StatefulWidget {
  String title, description, id;
  EditTask(
      {Key? key,
      required this.title,
      required this.description,
      required this.id})
      : super(key: key);

  @override
  _EditTaskState createState() => _EditTaskState();
}

class _EditTaskState extends State<EditTask> {
  GlobalKey<FormState> _key = new GlobalKey();
  SharedPreferences? prefs;
  String? token, id;

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
      id = this.prefs?.getString('id');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Task'),
      ),
      body: Center(
        child: Form(
          key: _key,
          child: Column(
            children: [
              Padding(padding: EdgeInsets.all(10.0)),
              ListTile(
                title: TextFormField(
                  initialValue: widget.title,
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
                  initialValue: widget.description,
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
                    onPressed: updateTask,
                    splashColor: Colors.black,
                    child: Text("Update"),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> updateTask() async {
    if (_key.currentState!.validate()) {
      _key.currentState!.save();
      print(title);
      http.Response response = await http.put(
        Uri.parse(
            "http://192.168.29.210:5000/api/user/update-task/" + widget.id),
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
