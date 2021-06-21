import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/Task/AddTask.dart';
import 'package:todo/Task/EditTask.dart';
import './Auth/LoginPage.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomePage> {
  GlobalKey<FormState> _key = new GlobalKey();
  String name = "", email = "";
  SharedPreferences? prefs;
  List tasks = [];
  bool isLoading = true;

  String? token;
  @override
  void initState() {
    super.initState();
    initializePreference();
  }

  Future<void> getUserData() async {
    try {
      http.Response response = await http.get(
          Uri.parse("http://192.168.29.210:5000/api/user/me"),
          headers: <String, String>{"x-auth-token": token!});
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          print(data['name']);
          name = data['name'];
          email = data['email'];
        });
      }
      response = await http.get(
          Uri.parse("http://192.168.29.210:5000/api/user/get-tasks"),
          headers: <String, String>{"x-auth-token": token!});
      if (response.statusCode == 200) {
        setState(() {
          tasks = jsonDecode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> initializePreference() async {
    this.prefs = await SharedPreferences.getInstance();
    setState(() {
      token = this.prefs?.getString('token');
      print(token);
      if (token != null) {
        print(token);
        getUserData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("HomePage"),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(name),
              accountEmail: Text(email),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.red,
                child: Icon(Icons.verified_user),
              ),
            ),
            ListTile(
                title: Text("Logout"),
                trailing: Icon(Icons.logout),
                onTap: logoutUser),
          ],
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
              color: Colors.teal,
            ))
          : tasks.length == 0
              ? Center(
                  child: Text("No Tasks Created"),
                )
              : ListView.builder(
                  itemBuilder: (context, index) {
                    return Card(
                      shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.teal, width: 1.0)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                    tasks[index]['title'],
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  ),
                                  Padding(padding: EdgeInsets.all(10.0)),
                                  Text(tasks[index]['description'])
                                ]
                                    .map((e) => Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              8, 0, 0, 0),
                                          child: e,
                                        ))
                                    .toList()),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    updateTask(
                                        tasks[index]['title'],
                                        tasks[index]['description'],
                                        tasks[index]['_id']);
                                  },
                                  icon: Icon(Icons.edit)),
                              IconButton(
                                  onPressed: () {
                                    deleteTask(tasks[index]["_id"]);
                                  },
                                  icon: Icon(Icons.delete))
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                  itemCount: tasks.length),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => AddTask()));
        },
      ),
    );
  }

  Future<void> logoutUser() async {
    await this.prefs!.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => LoginPage(),
      ),
      (route) => false,
    );
  }

  Future<void> updateTask(String title, String description, String id) async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                EditTask(title: title, description: description, id: id)));
  }

  Future<void> deleteTask(String id) async {
    print(id);

    http.Response response = await http.delete(
      Uri.parse("http://192.168.29.210:5000/api/user/delete-task/" + id),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': token!
      },
    );
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      print(data['msg']);
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (BuildContext context) => HomePage()));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(data['msg']),
      ));
    } else {
      print("Error");
    }
  }
}
