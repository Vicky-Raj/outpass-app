import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'main.dart';

class LogDetail extends StatefulWidget {
  final String pk;
  final bool isWarden;
  LogDetail(this.isWarden,this.pk);
  @override
  _LogDetailState createState() => _LogDetailState();
}

class _LogDetailState extends State<LogDetail> {

  String role;
  Map record;
  bool isLoaded = false;

  _getLogDetail(){
    SharedPreferences.getInstance().then((prefs){
      http.post(
        Uri(scheme:'http',host:host,port: port,path: 'api/$role/log/detail/'),
        headers: {'Authorization': "Token ${prefs.getString('token')}"},
        body: {'pk':widget.pk}
      ).then((response){
        if(response.statusCode == 200){
          setState(() {
            print(jsonDecode(response.body)['record']);
            record = jsonDecode(response.body)['record'];
            isLoaded = true;
          });
        }
      });
    });
  }

  Future<Null> _refresh()async{
    await Future.delayed(Duration(milliseconds: 100));
    setState(() {
     isLoaded =false; 
    });
    _getLogDetail();
  }

  @override
  void initState() {
    super.initState();
    if(widget.isWarden){
      role = 'warden';
    }
    else{
      role = 'tutor';
    }
    _getLogDetail();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:Text('Detail'),centerTitle: true,backgroundColor: Colors.deepPurpleAccent,),
      body: RefreshIndicator(
        color: Colors.deepPurpleAccent,
        onRefresh: _refresh,
        child: isLoaded ? ListView(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left:5.0,right:5.0,top:10.0),
              child: Card(
                elevation: 10.0,
                child:Column(
                children: <Widget>[
                  record['emergency']?
                  Container(
                    margin: EdgeInsets.only(top:15.0),
                    child: Text(
                      'EMERGENCY OUTPASS',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w900,
                        color: Colors.redAccent
                      ),
                    ),
                  ):Container(),
                Container(
                  margin: EdgeInsets.only(top: 15.0),
                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        "Name: ",
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.w700),
                      ),
                      Expanded(child:Text(
                        // outpass.containsKey('req-time')?outpass['req-time']:'',
                        record['name'].toString(),
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.w700),
                      )),
                    ],
                  ),
                ),
                  Container(
                  margin: EdgeInsets.only(top: 20.0),
                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        "Accepted-Warden: ",
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.w700),
                      ),
                      Expanded(child:Text(
                        // outpass.containsKey('req-time')?outpass['req-time']:'',
                        record['acc-warden'].toString(),
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.w700),
                      )),
                    ],
                  ),
                ),
                  Container(
                  margin: EdgeInsets.only(top: 20.0),
                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        "Accepted-Tutor: ",
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.w700),
                      ),
                      Expanded(child:Text(
                        // outpass.containsKey('req-time')?outpass['req-time']:'',
                        record['acc-tutor'].toString(),
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.w700),
                      )),
                    ],
                  ),
                ),
                  Container(
                  margin: EdgeInsets.only(top: 20.0),
                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        "Accepted-Security: ",
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.w700),
                      ),
                      Expanded(child:Text(
                        // outpass.containsKey('req-time')?outpass['req-time']:'',
                        record['acc-sec'].toString(),
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.w700),
                      )),
                    ],
                  ),
                ),
                  Container(
                  margin: EdgeInsets.only(top: 20.0),
                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        "Requested-Datetime: ",
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.w700),
                      ),
                      Expanded(child:Text(
                        // outpass.containsKey('req-time')?outpass['req-time']:'',
                        record['req_date'],
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.w700),
                      )),
                    ],
                  ),
                ),
                  Container(
                  margin: EdgeInsets.only(top: 20.0),
                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        "Departure-Datetime: ",
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.w700),
                      ),
                      Expanded(child:Text(
                        // outpass.containsKey('req-time')?outpass['req-time']:'',
                        record['dep_date'],
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.w700),
                      )),
                    ],
                  ),
                ),
                  Container(
                  margin: EdgeInsets.only(top: 20.0),
                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Reason: ",
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.w700),
                      ),
                      Expanded(child:Text(
                        // outpass.containsKey('req-time')?outpass['req-time']:'',
                        record['reason'],
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.w700),
                      )),
                    ],
                  ),
                ),
                  Container(
                  margin: EdgeInsets.only(top: 20.0,bottom: 10.0),
                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        "Requested-Days: ",
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.w700),
                      ),
                      Expanded(child:Text(
                        // outpass.containsKey('req-time')?outpass['req-time']:'',
                        record['req_days'].toString(),
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.w700),
                      )),
                    ],
                  ),
                ),
                record['in_time'] != null?
                Container(
                  margin: EdgeInsets.only(top: 10.0,bottom: 20.0),
                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        "In-Time:  ",
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.w700),
                      ),
                      Expanded(child:Text(
                        // outpass.containsKey('req-time')?outpass['req-time']:'',
                        record['in_time'].toString(),
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.w700),
                      )),
                    ],
                  ),
                ):Container(
                  margin: EdgeInsets.only(top: 10.0,bottom: 20.0),
                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        "In-Time:  ",
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.w700),
                      ),
                      Expanded(child:Text(
                        // outpass.containsKey('req-time')?outpass['req-time']:'',
                        'Waiting...',
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.w700),
                      )),
                    ],
                  ),
                ),
                ],
              ),
            )
          )
          ],
        ):ListView(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top:200.0),
              child: Center(child:CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.deepPurpleAccent),)) 
            )
          ],
        ),
      ),
    );
  }
}