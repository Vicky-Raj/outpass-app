import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:outpass_app/main.dart';
import 'outpass_form.dart';
import 'package:outpass_app/homepage.dart';
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
  var _scaffoldState = GlobalKey<ScaffoldState>();

  showCancel(String pk) {
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
                    body: jsonEncode({'pk': pk,'task':'delete'}))
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

  showLogout(){
    var logoutDialog =AlertDialog(
      title: Text('Logout'),
      content: Text('Are you sure you want to logout?'),
      actions: <Widget>[
        FlatButton(
          child: Text('Yes'),
          onPressed: ()async{
            Navigator.of(context).pop();
            var prefs = await SharedPreferences.getInstance();
            await prefs.remove('token');
            await prefs.remove('role');
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (BuildContext context)=>HomePage()
              )
            );
          },
        ),
        FlatButton(
          child: Text('No'),
          onPressed: (){
            Navigator.of(context).pop();
          },
        )
      ],
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context){
        return logoutDialog;
      }
    );
  }

  _getOutpass() {
    SharedPreferences.getInstance().then((prefs) {
      http.get(
          Uri(scheme: 'http', host: host, port: port, path: studentOutpass),
          headers: {
            'Authorization': "Token ${prefs.getString('token')}"
          },
          ).then((response) {
        if (response.statusCode == 200) {
          setState(() {
            outpass = jsonDecode(response.body)['outpass'];
            isLoaded = true;
          });
        }
      });
    });
  }

  getOtp(String pk){
    SharedPreferences.getInstance().then((prefs){
      http.put(
        Uri(scheme:'http',host: host,port: port,path: studentOutpass),
        headers: {'Authorization': "Token ${prefs.getString('token')}"},
        body: jsonEncode({'pk':pk,'task':'otp'})
      ).then((response){
        if(response.statusCode == 200){
          setState(() {
           isLoaded = false;
           _getOutpass(); 
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
      key: _scaffoldState,
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
            outpass == '' ? Container() : getOutpassCard(outpass, showCancel,getOtp)
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
            ListTile(
              title: Text('Logout'),
              leading: Icon(Icons.exit_to_app),
              onTap: (){
                showLogout();
              },
            )
          ],
        ),
      ),
      floatingActionButton: outpass == ''
          ? FloatingActionButton(
              child: Icon(Icons.add),
              backgroundColor: Colors.deepPurpleAccent,
              onPressed: ()async{
                var result = await Navigator.of(context).push(MaterialPageRoute(builder: (context)=>OutpassForm()));
                if(result ?? false){
                  _scaffoldState.currentState.showSnackBar(SnackBar(
                    content: Text('Outpass Requested',textAlign: TextAlign.center,),
                  ));
                  setState(() {
                    isLoaded =false;
                    _getOutpass();
                  });
                }
              },
            )
          : null,
    );
  }
}
