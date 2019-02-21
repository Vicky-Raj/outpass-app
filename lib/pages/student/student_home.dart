import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:outpass_app/main.dart';
import 'outpass_form.dart';
import 'dart:convert';
import 'student_outpass.dart';
import 'package:http/http.dart' as http;

class StudentHome extends StatefulWidget {
  @override
  _StudentHomeState createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  var outpass;
  bool isLoaded = false;

  showCancel(var pk) {
    var cancelDialog = AlertDialog(
      title: Text('Cancel Request'),
      content: Text('Are you sure you want to cancel ?'),
      actions: <Widget>[
        FlatButton(
          child: Text('Yes'),
          onPressed: () async {
            Navigator.of(context).pop();
            var prefs = await SharedPreferences.getInstance();
            http
                .put(
                    Uri(
                        scheme: 'http',
                        host: host,
                        port: port,
                        path: studentOutpass),
                    headers: {
                      'Authorization': "Token ${prefs.getString('token')}"
                    },
                    body: jsonEncode({'pk': pk}))
                .then((response){
              if (response.statusCode == 200) {
                setState(() {
                  isLoaded = false;
                  _getOutpass();
                });
              }
            });
          },
        ),
        FlatButton(
          child: Text('No'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return cancelDialog;
        });
  }

  _getOutpass() {
    SharedPreferences.getInstance().then((prefs) {
      http.get(
          Uri(scheme: 'http', host: host, port: port, path: studentOutpass),
          headers: {
            'Authorization': "Token ${prefs.getString('token')}"
          }).then((response) {
        if (response.statusCode == 200) {
          setState(() {
            outpass = jsonDecode(response.body)['outpass'];
            isLoaded = true;
          });
        }
      });
    });
  }

  @override
  void initState() {
    _getOutpass();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        centerTitle: true,
        title: Text('Student Home'),
      ),
      body: RefreshIndicator(
        color: Colors.deepPurpleAccent,
        child:isLoaded?
        ListView(
          children: <Widget>[
            outpass == '' ? Container() : getOutpassCard(outpass, showCancel)
          ],
        ):ListView(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top:200.0),
              child: Center(child:CircularProgressIndicator()) 
            )
          ],
        ),
        onRefresh: ()async{
         setState(() {
          isLoaded = false;
          _getOutpass();
         }); 
         await Future.delayed(Duration(milliseconds: 100));
        }, 
      ),
      drawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Colors.deepPurpleAccent,
              ),
              accountEmail: Text("test@rmail.com"),
              accountName: Text("sethu"),
            ),
          ],
        ),
      ),
      floatingActionButton: outpass == ''
          ? FloatingActionButton(
              child: Icon(Icons.add),
              backgroundColor: Colors.deepPurpleAccent,
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context)=>OutpassForm()))
;              },
            )
          : null,
    );
  }
}
