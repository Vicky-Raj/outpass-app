import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'main.dart';
import 'dart:async';

class LoginPage extends StatefulWidget {
  @override
  final bool tutor, warden, student, security;
  LoginPage({Key key, this.tutor, this.warden, this.student, this.security})
      : super(key: key);
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var _formKey = GlobalKey<FormState>();
  var _emailController = TextEditingController();
  var _passwordController = TextEditingController();
  var isLoading = false;
  bool wrongCreds = false;
  var duration = Duration(seconds: 5);
  String home;
  String role;
  Uri uri =Uri(scheme: "http",host: host,port: port,path: login);
  String title;

  @override
  void initState() {
    super.initState();
    if (widget.tutor ?? false) {
      title = "TUTOR LOGIN";
      home = '/home/tutor/';
      role = "tutor";
    } else if (widget.warden ?? false) {
      title = "WARDEN LOGIN";
      home = '/home/warden/';
      role = "warden";
    } else if (widget.student ?? false) {
      title = "STUDENT LOGIN";
      home = '/home/student/';
      role = "student";
    } else if (widget.security ?? false) {
      title = "SECURITY LOGIN";
      home = '/home/security/';
      role = "security";
    }
  }

  startedLoading(){
    return Timer(this.duration,(){
      setState(() {
       isLoading = false; 
      });
    });
  }

getAndSetToken(String email, String pass){
  http.post(uri,body: {'email':email,'password':pass,'role':role}).then((response)async{
    if(response.statusCode == 200){
      var prefs = await SharedPreferences.getInstance();
      await prefs.setString('token',jsonDecode(response.body)['token']);
      await prefs.setString('role', role);
      setState(() {
       isLoading =false;
       Navigator.of(context).pop();
       Navigator.of(context).pushReplacementNamed(home);
      });
  }
    else if(response.statusCode == 400){
      setState(() {
        wrongCreds = true;
        isLoading = false;
      });
    }
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepPurpleAccent,
          title: Text('Login'),
          centerTitle: true,
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 40.0),
                child: Image(
                  image: AssetImage('images/skct-logo.jpg'),
                  width: 125.0,
                  height: 125.0,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 20.0),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 27.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              wrongCreds?
              Container(
                margin: EdgeInsets.only(top: 20.0),
                child: Text("Email or Password is incorrect",
                style: TextStyle(color: Colors.redAccent,fontSize: 17.0),textAlign: TextAlign.center,),
              ):Container(),
              Container(
                margin: EdgeInsets.only(left: 30.0, right: 30.0, top: 25.0),
                child: TextFormField(
                  controller: _emailController,
                  validator: (String value) {
                    if (value.isEmpty) 
                    return 'Enter your email';
                  RegExp regExp = RegExp(r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
                  if(!regExp.hasMatch(value))
                    return 'Enter a valid email';
                  },
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0)),
                    errorStyle: TextStyle(fontSize: 15.0),
                    labelText: 'Email',
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 30.0, right: 30.0, top: 20.0),
                child: TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  controller: _passwordController,
                  obscureText: true,
                  validator: (String value) {
                    if (value.isEmpty) 
                    return 'Enter your password';
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0)),
                    errorStyle: TextStyle(fontSize: 15.0),
                    labelText: 'Password',
                  ),
                ),
              ),
              isLoading?
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: 49.0),
                  child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurpleAccent),),
                ),
              ):
              Container(
                margin: EdgeInsets.only(top: 35.0, left: 40.0, right: 40.0),
                height: 50.0,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)),
                  elevation: 8.0,
                  child: Text(
                    'LOGIN',
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Colors.deepPurpleAccent,
                  onPressed: () {
                    setState(() {
                    if(_formKey.currentState.validate()){
                    isLoading = true;
                    startedLoading();
                    getAndSetToken(_emailController.text,_passwordController.text);
                    } 
                    });
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  top: 20.0,
                ),
                child: FlatButton(
                  child: Text('Don\'t have an account? register',style: TextStyle(fontWeight:FontWeight.w800),),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ));
  }
}
