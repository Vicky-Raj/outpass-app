import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:outpass_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmergencyForm extends StatefulWidget {
  @override
  _EmergencyFormState createState() => _EmergencyFormState();
}

class _EmergencyFormState extends State<EmergencyForm> {
  var _reasonController = TextEditingController();
  var _rollNoController = TextEditingController();
  var _formKey =GlobalKey<FormState>();
  List<String> _days = ['1','2'];
  String _currentDays = '1';
  bool loading = false;


  _sendRequest(String rollno,String days,String reason){
    setState(() {
     loading = true; 
    });
    SharedPreferences.getInstance().then((prefs){
      http.post(
      Uri(scheme:'http',host:host,port:port,path: emergencyOutpass),
      headers: {'Authorization':'Token ${prefs.getString('token')}'},
      body: {
        'reg_no':rollno,
        'reqDays':days,
        'reason':reason,
      }
      ).then((response){
        if(response.statusCode == 200){
          Navigator.of(context).pop(true);
        }
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Request Outpass'),
        backgroundColor: Colors.deepPurpleAccent,
        centerTitle: true,
      ),
      body: Form(
      key: _formKey,
      child:ListView(
        children: <Widget>[
          Container(
          margin: EdgeInsets.only(left:20.0,right:20.0,top:20.0),
          child:Text('Roll No: ',style: TextStyle(fontWeight: FontWeight.w700,fontSize: 20.0),),
          ),
          Container(
          margin: EdgeInsets.only(left:15.0,right:15.0,top:10.0),
          child:TextFormField(
            controller: _rollNoController,
            maxLength: 10,
            maxLengthEnforced: true,
            validator: (String value){
              if(value.isEmpty)
              return("Enter your roll no");
            },
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0)
              )
              )
            )
          ),
          Container(
          margin: EdgeInsets.only(left:20.0,right:20.0,top:25.0),
          child:Row(
            children: <Widget>[
              Container(
                child: Text('No.of days: ',style: TextStyle(fontWeight: FontWeight.w700,fontSize: 20.0),),
              ),
              Expanded(
              child:Container(
                padding: EdgeInsets.only(left: 10.0,right: 100.0),
                child: DropdownButtonFormField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0)
                    )
                  ),
                  value: _currentDays,
                  items: _days.map((item)=>DropdownMenuItem(
                    child:Text(item),
                    value:item)).toList(),
                    onChanged: (item){
                      setState(() {
                       _currentDays=item; 
                      });
                    },
                )
              )),
            ],
          )),
          Container(
          margin: EdgeInsets.only(left:20.0,right:20.0,top:20.0),
          child:Text('Reason: ',style: TextStyle(fontWeight: FontWeight.w700,fontSize: 20.0),),
          ),
          Container(
          margin: EdgeInsets.only(left:15.0,right:15.0,top:10.0),
          child:TextFormField(
            controller: _reasonController,
            maxLines: 4,
            maxLength: 100,
            maxLengthEnforced: true,
            validator: (String value){
              if(value.isEmpty)
              return("Enter your reason");
            },
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0)
              )
              )
            )
          ),
          Container(
            height: 50.0,
            margin: EdgeInsets.only(left:30.0,right:30.0,top:30.0),
            child: loading?
            Container(
              child: Center(
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurpleAccent),),
              ),
            ):
            RaisedButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
              color: Colors.deepPurpleAccent,
              child: Text('SEND',style: TextStyle(color: Colors.white),),
              onPressed: (){
                if(_formKey.currentState.validate()){
                  _sendRequest(_rollNoController.text, _currentDays,_reasonController.text);
                }
              },
            ),
          )
        ],
      ),
    )
  );
  }
}
