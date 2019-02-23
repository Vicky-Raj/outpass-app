import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:outpass_app/homepage.dart';
import 'package:outpass_app/main.dart';
import 'tutor_outpass.dart';
import 'package:http/http.dart' as http;

class TutorHome extends StatefulWidget {
  @override
  _TutorHomeState createState() => _TutorHomeState();
}

class _TutorHomeState extends State<TutorHome> {

  var isLoaded = false;
  var outpass = [];
  var _scrollController = ScrollController();
  var _page = 1;

  _getOutpass() {
    SharedPreferences.getInstance().then((prefs) {
      http.get(
          Uri(scheme: 'http', host: host, port: port, path: tutorOutpass,queryParameters:{'page':_page.toString()}),
          headers: {
            'Authorization': "Token ${prefs.getString('token')}"
          }).then((response) {
        if (response.statusCode == 200) {
          setState(() {
            outpass.add(jsonDecode(response.body)['outpass']);
            _page++;
            isLoaded = true;
          });
        }
      });
    });
  }
  accept(String pk){
    SharedPreferences.getInstance().then((prefs){
    http.put(
      Uri(scheme: 'http',host: host,port: port,path: tutorOutpass),
      headers: {'Authorization': "Token ${prefs.getString('token')}"},
      body: jsonEncode({'pk':pk,'task':'accept'}) 
    ).then((response){
      if(response.statusCode == 200){
        _refresh();
      }
    });
  });
}

  reject(String pk){
    var rejectDialog =AlertDialog(
      title: Text('Reject'),
      content: Text('Are you sure you want to reject?'),
      actions: <Widget>[
        FlatButton(
          child: Text('Yes'),
          onPressed: (){
          Navigator.of(context).pop();
          SharedPreferences.getInstance().then((prefs){
          http.put(
          Uri(scheme: 'http',host: host,port: port,path: tutorOutpass),
          headers: {'Authorization': "Token ${prefs.getString('token')}"},
          body: jsonEncode({'pk':pk,'task':'reject'}) 
          ).then((response){
            if(response.statusCode == 200){
              _refresh();
            }
          });
        });
        },
        ),
        FlatButton(
          child: Text('No'),
          onPressed: (){Navigator.of(context).pop();},
        )
      ],
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context){
        return rejectDialog;
      }
    );
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

Future<Null> _refresh()async{
  await Future.delayed(Duration(milliseconds: 100));
  setState(() {
    outpass.clear();
   _page = 1; 
   isLoaded = false;
  });
  _getOutpass();
  return null;
}

  @override
  void initState() {
    super.initState();
    _scrollController.addListener((){
      if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent){
        _getOutpass();
      }
    }
  );
  _getOutpass();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        centerTitle: true,
        title: Text('Tutor Home'),
      ),
      drawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            DrawerHeader(
              child: Text(''),
              decoration: BoxDecoration(
                color: Colors.deepPurpleAccent
              ),
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
      body:RefreshIndicator(
        color: Colors.deepPurpleAccent,  
        child:Scrollbar( 
        child:isLoaded ? outpass[0].isEmpty ? ListView(): outpass[0].length < 3 ?
        ListView(
          children: <Widget>[
            getOutpassCard(outpass[0],accept,reject)
          ],
        ) 
        :ListView.builder(
        controller: _scrollController,
        itemCount: outpass.length,
        itemBuilder: (context, page){
          return getOutpassCard(outpass[page],accept,reject);
        },
      ):ListView(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top:200.0),
              child: Center(child:CircularProgressIndicator()) 
            )
          ],
        )),
        onRefresh: _refresh
    )
  );
  }
}