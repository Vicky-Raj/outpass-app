import 'package:flutter/material.dart';

class OutpassForm extends StatefulWidget {
  @override
  _OutpassFormState createState() => _OutpassFormState();
}

class _OutpassFormState extends State<OutpassForm> {
  var _date = DateTime.now();
  var _time = TimeOfDay.now();
  var tempDate = DateTime.now();
  var offset = 3;

  Future<Null> _selectDate(BuildContext context)async{
    var pickedDate = await showDatePicker(
      context: context,
      initialDate:_date,
      firstDate: _date,
      lastDate: DateTime(_date.year,_date.month,_date.day+offset)
    );
    if(pickedDate != null){
      setState(() {
       tempDate = pickedDate; 
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Request Outpass'),
        backgroundColor: Colors.deepPurpleAccent,
        centerTitle: true,
      ),
      body: ListView(
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
                  child: Text('${tempDate.day}/${tempDate.month}/${tempDate.year}',
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
        ],
      ),
    );
  }
}
