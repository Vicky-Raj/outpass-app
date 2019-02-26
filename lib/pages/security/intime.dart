import 'package:flutter/material.dart';
import 'package:outpass_app/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'security_home.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:outpass_app/main.dart';
import 'security_record.dart';

class SecurityInTime extends StatefulWidget {
  @override
  _SecurityInTimeState createState() => _SecurityInTimeState();
}

class _SecurityInTimeState extends State<SecurityInTime> {

  var _formKey = GlobalKey<FormState>();
  var _recordController = TextEditingController();
  var duration =Duration(seconds: 5);
  var first = true;
  bool isLoaded = true;
  Map<dynamic,dynamic> record = {};

 
_getRecord(String alias){
SharedPreferences.getInstance().then((prefs){
http.post(
    Uri(scheme:'http',host:host,port: port,path: securityRecord),
    headers: {'Authorization': "Token ${prefs.getString('token')}"},
    body: {'alias':alias}).then((response){
      setState(() {
       isLoaded = true; 
      });
      if(response.statusCode == 200){
        setState(() {
         record =jsonDecode(response.body)['record']; 
        });
      }
  });
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
  recordTime(){
    SharedPreferences.getInstance().then((prefs){
    http.put(
      Uri(scheme: 'http',host: host,port: port,path: securityRecord),
      headers: {'Authorization': "Token ${prefs.getString('token')}"},
      body: jsonEncode({'alias':_recordController.text}) 
    ).then((response){
      if(response.statusCode == 200){
        _refresh();
      }
    });
  });
  }

Future<Null> _refresh()async{
  await Future.delayed(Duration(milliseconds: 100));
  setState(() {
    _recordController.text = '';
    first =true;
  });
  return null;
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Security Home'),centerTitle: true,backgroundColor: Colors.deepPurpleAccent,),
      drawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.deepPurpleAccent
              ),
              child: Text(''),
            ),
            ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: (){
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context)=>SecurityHome()
              ));
            },
            ),
            ListTile(
            leading: Icon(Icons.timelapse),
            title: Text('InTime'),
            onTap: (){},
            selected: true,
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('LOGOUT'),
            onTap: showLogout,
          ) 
          ],
        ),
      ),
      body: RefreshIndicator(
      color: Colors.deepPurpleAccent,
      onRefresh: _refresh,
      child:Form(
        key: _formKey,
        child:ListView(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(5.0),
            child: Card(
              elevation: 5.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 20.0,bottom: 20.0,top:10.0),
                  child:Text('RECORD NO: ',textAlign: TextAlign.left,
                  style:TextStyle(fontWeight: FontWeight.w700,fontSize: 30.0)
                    )
                  ),
                  Container(
                  padding: EdgeInsets.only(left:20.0,right:20.0),
                  margin: EdgeInsets.only(bottom: 8.0),
                  child:TextFormField(
                    controller: _recordController,
                    maxLength: 5,
                    maxLengthEnforced: true,
                    keyboardType: TextInputType.number,
                    validator: (String value){
                      if(value.isEmpty)
                      return "Enter Record No";
                    },
                    decoration: InputDecoration(
                      labelText: 'Enter record number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0)
                      )
                    ),
                  )
                  ),
                  Center(
                  child: Container(
                    height: 40.0,
                    width: 120.0,
                    margin: EdgeInsets.only(bottom: 20.0),
                    child: RaisedButton(
                      child: Text('Submit',style: TextStyle(color: Colors.white),),
                      color: Colors.green[700],
                      onPressed: (){
                        if(_formKey.currentState.validate()){
                          setState(() {
                            first = false;
                            isLoaded =false;
                            _getRecord(_recordController.text);
                          });
                         }
                      },
                    ),
                  )
                ) 
                ],
              ),
            ),
          ),
          !first?
          isLoaded ? record.isEmpty
           ? Container(
             margin: EdgeInsets.only(top: 40.0),
             child:Center(
               child: 
               Text('Record does not exit',
               style: TextStyle(
                 color: Colors.redAccent,
                 fontSize: 20.0
               ),),),) 
               : getCard(record,recordTime)
           :Container(
             margin: EdgeInsets.only(top:40.0),
             child: Center(child: CircularProgressIndicator(),),
           ):Container()
        ],
      ),
    )
    )
  );
}
}