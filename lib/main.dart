import 'package:flutter/material.dart';
import "package:outpass_app/pages/student/student_home.dart";
import 'package:outpass_app/pages/tutor/tutor_home.dart';
import 'package:outpass_app/pages/warden/warden_home.dart';
import 'homepage.dart';
import 'login.dart';

var host = '10.0.2.2';
var port = 8000;
var login = 'api/login/';
var studentOutpass = 'api/student/outpass/';

void main(List<String> args) {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomePage(),
    onGenerateRoute: (RouteSettings settings){
      var path =settings.name.split('/');
      if(path[2] == 'tutor' && path[1] == 'login')
      return MaterialPageRoute(builder: (BuildContext context) => LoginPage(tutor:true));
      else if(path[2] == 'warden' && path[1] == 'login')
      return MaterialPageRoute(builder: (BuildContext context) => LoginPage(warden:true));
      else if(path[2] == 'student' && path[1] == 'login')
      return MaterialPageRoute(builder: (BuildContext context) => LoginPage(student:true));
      else if(path[2] == 'security' && path[1] == 'login')
      return MaterialPageRoute(builder: (BuildContext context) => LoginPage(security:true));
      else if(path[2] == 'student' && path[1] == 'home')
      return MaterialPageRoute(builder: (BuildContext context) => StudentHome());
      else if(path[2] == 'tutor' && path[1] == 'home')
      return MaterialPageRoute(builder: (BuildContext context) => TutorHome());
      else if(path[2] == 'warden' && path[1] == 'home')
      return MaterialPageRoute(builder: (BuildContext context) => WardenHome());    
    },
  )
);
}