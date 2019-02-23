import 'package:flutter/material.dart';
import 'package:outpass_app/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:outpass_app/main.dart';
import 'security_outpass.dart';

class SecurityHome extends StatefulWidget {
  @override
  _SecurityHomeState createState() => _SecurityHomeState();
}

class _SecurityHomeState extends State<SecurityHome> {

  var _formKey = GlobalKey<FormState>();
  var _otpController = TextEditingController();
  var duration =Duration(seconds: 5);
  var first = true;
  bool isLoaded = true;
  Map<dynamic,dynamic> outpass = {};


  accept(){
    SharedPreferences.getInstance().then((prefs){
    http.put(
      Uri(scheme: 'http',host: host,port: port,path: securityOutpass),
      headers: {'Authorization': "Token ${prefs.getString('token')}"},
      body: jsonEncode({'otp':_otpController.text,'task':'accept'}) 
    ).then((response){
      if(response.statusCode == 200){
        _refresh();
      }
    });
  });
  }

  reject(){
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
          Uri(scheme: 'http',host: host,port: port,path: securityOutpass),
          headers: {'Authorization': "Token ${prefs.getString('token')}"},
          body: jsonEncode({'otp':_otpController.text,'task':'reject'}) 
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
 
_getOutpass(String otp){
SharedPreferences.getInstance().then((prefs){
http.post(
    Uri(scheme:'http',host:host,port: port,path: securityOutpass),
    headers: {'Authorization': "Token ${prefs.getString('token')}"},
    body: {'otp':otp}).then((response){
      setState(() {
       isLoaded = true; 
      });
      if(response.statusCode == 200){
        setState(() {
         outpass =jsonDecode(response.body)['outpass']; 
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

Future<Null> _refresh()async{
  await Future.delayed(Duration(milliseconds: 100));
  setState(() {
    _otpController.text = '';
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
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
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
                  child:Text('OTP: ',textAlign: TextAlign.left,
                  style:TextStyle(fontWeight: FontWeight.w700,fontSize: 30.0)
                    )
                  ),
                  Container(
                  padding: EdgeInsets.only(left:20.0,right:20.0),
                  margin: EdgeInsets.only(bottom: 8.0),
                  child:TextFormField(
                    controller: _otpController,
                    maxLength: 5,
                    maxLengthEnforced: true,
                    keyboardType: TextInputType.number,
                    validator: (String value){
                      if(value.isEmpty)
                      return "Enter OTP";
                    },
                    decoration: InputDecoration(
                      labelText: 'Enter OTP of student',
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
                            _getOutpass(_otpController.text);
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
          isLoaded ? outpass.isEmpty
           ? Container(
             margin: EdgeInsets.only(top: 40.0),
             child:Center(
               child: 
               Text('Outpass does not exit',
               style: TextStyle(
                 color: Colors.redAccent,
                 fontSize: 20.0
               ),),),) 
               : getOutpassCard(outpass,accept,reject)
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