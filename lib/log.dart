import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'homepage.dart';
import 'dart:convert';
import 'log_detail.dart';
import 'package:outpass_app/pages/warden/emergency_form.dart';
import 'package:outpass_app/pages/warden/warden_home.dart';
import 'package:http/http.dart' as http;
import 'main.dart';
import 'package:outpass_app/pages/tutor/tutor_home.dart';

class LogView extends StatefulWidget {
  final isWarden;
  LogView(this.isWarden);
  @override
  _LogViewState createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {

  String title;
  String role;
  var _scrollController = ScrollController();
  var records = [];
  var _date = DateTime.now();
  int _page = 1;
  bool isLoaded = false;

  Future<Null> _selectDate(BuildContext context)async{
    var pickedDate = await showDatePicker(
      context: context,
      initialDate:_date,
      firstDate: DateTime(2018),
      lastDate: DateTime(2050)
    );
    if(pickedDate != null){
      setState(() {
       _date = pickedDate;
      records.clear();
      _page = 1; 
      isLoaded = false;
      });
    _getLogs('${_date.day}/${_date.month}/${_date.year}');
    }
    return null;
  }

  List<Widget> _getTile(List records){
    return records.map((record) => ListTile(
          leading: record['emergency']?Icon(Icons.insert_drive_file,color: Colors.redAccent,):Icon(Icons.insert_drive_file,),
          title: Text(record['name'].toString()),
          subtitle: Text('Departure: ${record['dep-date']}'),
          onTap: (){
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context)=>LogDetail(widget.isWarden,record['pk'].toString()))
            );
          },
    )).toList();
  }

  _getLogs(String date){
    SharedPreferences.getInstance().then((prefs){
      http.get(
        Uri(scheme:'http',host:host,port: port,path: 'api/$role/log/',queryParameters: {'date':date,'page':_page.toString()}),
        headers: {'Authorization': "Token ${prefs.getString('token')}"}
      ).then((response){
        if(response.statusCode == 200){
        setState(() {
          records.add(jsonDecode(response.body)['records']);
          _page++;
          isLoaded = true;
          print(jsonDecode(response.body)['records']);  
        });
        }
      });
    });
  }
  Future<Null> _refresh()async{
  await Future.delayed(Duration(milliseconds: 100));
  setState(() {
    records.clear();
   _page = 1; 
   isLoaded = false;
  });
  _getLogs('${_date.day}/${_date.month}/${_date.year}');
  return null;
}

    @override
    void initState() {
    super.initState();
    if(widget.isWarden){
      title = 'Warden Log';
      role = 'warden';
    }
    else{
      title = 'Tutor Log';
      role = 'tutor';
    }
    _scrollController.addListener((){
      if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent){
        _getLogs('${_date.day}/${_date.month}/${_date.year}');
      }
    }
  );
    _getLogs('${_date.day}/${_date.month}/${_date.year}');
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title),centerTitle: true,backgroundColor: Colors.deepPurpleAccent,
      actions: <Widget>[
        FlatButton(
          child: Text('${_date.day}/${_date.month}/${_date.year}',style: TextStyle(color: Colors.white),),
          onPressed: ()async{
            await _selectDate(context);
          },
        )
      ],),
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
              title: Text('HOME'),
              leading: Icon(Icons.home),
              onTap: (){
                widget.isWarden?
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>WardenHome())):
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>TutorHome()));
              },
            ),
            ListTile(
              title: Text('LOGS'),
              leading: Icon(Icons.insert_drive_file),
              selected: true,
              onTap: (){},
            ),
            role == 'warden'?
              ListTile(
              title: Text('EMERGENCY'),
              leading: Icon(Icons.local_hospital),
              onTap: (){
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context)=>EmergencyForm()
                  )
                );
              },
            ):Container(),
            ListTile(
              title: Text('LOGOUT'),
              leading: Icon(Icons.exit_to_app),
              onTap: (){
                showLogout();
              },
            )
          ],
        ),
      ),
      body:RefreshIndicator( 
      onRefresh: _refresh,
      color: Colors.deepPurpleAccent,
      child:Scrollbar( 
      child:isLoaded ? records[0].isEmpty ? Container(): records[0].length < 12 ? 
      ListView(
        children: _getTile(records[0]),
      ):ListView.builder(
        controller: _scrollController,
        itemCount: records.length,
        itemBuilder: (context, page){
          return Column(
            children: _getTile(records[page]),
          );
        },
      ):ListView(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top:200.0),
              child: Center(child:CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.deepPurpleAccent),)) 
            )
        ],
    ), 
    )
    )
  );
  }
}