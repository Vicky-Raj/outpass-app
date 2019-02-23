import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  checkAndRedirect()async{
    var prefs = await SharedPreferences.getInstance();
    if(!(prefs.getString('token') == null)){
      Navigator.of(context).pushReplacementNamed('/home/${prefs.getString('role')}');
    }
  }

  @override
  void initState() {
    super.initState();
    checkAndRedirect();
  }
@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        title: Text('Outpass'),
        centerTitle: true,
      ),
      body: ListView(
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
              'Welcome to SKCT outpass',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
              margin: EdgeInsets.only(top: 45.0, left: 40.0, right: 40.0),
              height: 50.0,
              child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0)),
                  elevation: 8.0,
                  child: Text('TUTOR LOGIN',
                      style: TextStyle(color: Colors.white)),
                  color: Colors.purple[400],
                  onPressed: () {
                    Navigator.of(context).pushNamed('/login/tutor/');
                  })),
          Container(
              margin: EdgeInsets.only(top: 20.0, left: 40.0, right: 40.0),
              height: 50.0,
              child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0)),
                  elevation: 8.0,
                  child: Text('WARDEN LOGIN',
                      style: TextStyle(color: Colors.white)),
                  color: Colors.purple[400],
                  onPressed: () {
                    Navigator.of(context).pushNamed('/login/warden/');
                  })),
          Container(
              margin: EdgeInsets.only(top: 20.0, left: 40.0, right: 40.0),
              height: 50.0,
              child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0)),
                  elevation: 8.0,
                  child: Text('STUDENT LOGIN',
                      style: TextStyle(color: Colors.white)),
                  color: Colors.purple[400],
                  onPressed: () {
                    Navigator.of(context).pushNamed('/login/student/');
                  })),
          Container(
              margin: EdgeInsets.only(top: 20.0, left: 40.0, right: 40.0),
              height: 50.0,
              child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0)),
                  elevation: 8.0,
                  child: Text('SECURITY LOGIN',
                      style: TextStyle(color: Colors.white)),
                  color: Colors.purple[400],
                  onPressed: () {
                    Navigator.of(context).pushNamed('/login/security/');
                  })),
        ],
      ),
    );
  }
  }