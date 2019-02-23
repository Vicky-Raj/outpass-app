import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:outpass_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OutpassForm extends StatefulWidget {
  @override
  _OutpassFormState createState() => _OutpassFormState();
}

class _OutpassFormState extends State<OutpassForm> {
  var _date = DateTime.now();
  var _time = TimeOfDay.now();
  var _tempDate = DateTime.now();
  var _reasonController = TextEditingController();
  var _formKey =GlobalKey<FormState>();
  List<String> _days = ['1','2','3'];
  String _currentDays = '1';
  var offset = 3;
  bool loading = false;

  Future<Null> _selectDate(BuildContext context)async{
    var pickedDate = await showDatePicker(
      context: context,
      initialDate:_date,
      firstDate: _date,
      lastDate: DateTime(_date.year,_date.month,_date.day+offset)
    );
    if(pickedDate != null){
      setState(() {
       _tempDate = pickedDate; 
      });
    }
  }

  Future<Null> _selectTime(BuildContext context)async{
    var pickedTime = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if(pickedTime != null){
      setState(() {
       _time = pickedTime; 
      });
    }
  }

  _sendRequest(String date,String days,String reason){
    setState(() {
     loading = true; 
    });
    SharedPreferences.getInstance().then((prefs){
      http.post(
      Uri(scheme:'http',host:host,port:port,path: studentOutpass),
      headers: {'Authorization':'Token ${prefs.getString('token')}'},
      body: {
        'dep-date':date,
        'req-days':days,
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
          margin: EdgeInsets.only(left:20.0,right:20.0,top:25.0),
          child:Row(
            children: <Widget>[
              Container(
                child: Text('Leaving-Date: ',style: TextStyle(fontWeight: FontWeight.w700,fontSize: 20.0),),
              ),
              Container(
                margin: EdgeInsets.only(left:10.0),
                child: RaisedButton(
                  color: Colors.deepPurpleAccent,
                  child: Text('${_tempDate.day}/${_tempDate.month}/${_tempDate.year}',
                  style: TextStyle(color: Colors.white),),
                  onPressed: ()async{
                    await _selectDate(context);
                  },
                ),
              ),
            ],
          )),
          Container(
          margin: EdgeInsets.only(left:20.0,right:20.0,top:20.0),
          child:Row(
            children: <Widget>[
              Container(
                child: Text('Leaving-time: ',style: TextStyle(fontWeight: FontWeight.w700,fontSize: 20.0),),
              ),
              Container(
                margin: EdgeInsets.only(left:10.0),
                child: RaisedButton(
                  color: Colors.deepPurpleAccent,
                  child: Text('${_time.format(context)}',
                  style: TextStyle(color: Colors.white),),
                  onPressed: ()async{
                    await _selectTime(context);
                  },
                ),
              ),
            ],
          )),
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
              child: Text('REQUEST',style: TextStyle(color: Colors.white),),
              onPressed: (){
                if(_formKey.currentState.validate()){
                  _sendRequest(
                    '${_tempDate.day}/${_tempDate.month}/${_tempDate.year} ${_time.format(context)}',
                    _currentDays,
                    _reasonController.text
                  );
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
