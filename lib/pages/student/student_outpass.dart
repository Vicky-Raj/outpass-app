import 'package:flutter/material.dart';

_getIcon(String status){
  if(status == 'pending')
  return Icon(Icons.cached,color: Colors.redAccent,);
  else if(status == 'accepted')
  return Icon(Icons.check_circle,color:Colors.greenAccent[700],);
  else if(status == 'rejected')
  return Icon(Icons.highlight_off,color: Colors.redAccent,);
  else return null;
}


Widget getOutpassCard(var outpass,Function showCancel,Function getOtp){
 return Container(
        margin: EdgeInsets.only(top: 10.0),
        padding: EdgeInsets.only(left: 10.0, right: 10.0),
        child: Card(
            elevation: 10.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
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
                        outpass['req-time'],
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.w700),
                      )),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10.0),
                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        "Leaving-Datetime: ",
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.w700),
                      ),
                      Expanded(
                        child:Text(
                        // outpass.containsKey('dep-time')?outpass['dep-time']:'',
                        outpass['dep-time'],
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.w700),
                      ))
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10.0),
                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        "Requested-Days: ",
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.w700),
                      ),
                        Text(
                        // outpass.containsKey('req-days')?outpass['req-days'].toString():'',
                        outpass['req-days'].toString(),
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.w700),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10.0),
                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Reason: ",
                        style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.w700),
                      ),
                      Expanded(
                      child:Text(
                        // outpass.containsKey('reason')?outpass['reason']:'',
                        outpass['reason'],
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.w700),
                      ))
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10.0),
                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        "Tutor-Status: ",
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        // outpass.containsKey('tutor')?outpass['tutor']:'',
                        outpass['tutor'],
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.w700),
                      ),
                      Container(
                        margin: EdgeInsets.only(left:5.0),
                        child: _getIcon(outpass['tutor']),
                      ),
                    ],
                  ),
                ),
                outpass['tutor'] != 'rejected' ?
                Container(
                  margin: EdgeInsets.only(top: 10.0),
                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        "Warden-Status: ",
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.w700),
                      ),
                        Text(
                        // outpass.containsKey('warden')?outpass['warden']:'',
                        outpass['warden'],
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.w700),
                      ),
                      Container(
                        margin: EdgeInsets.only(left:5.0),
                        child: _getIcon(outpass['warden']),
                      )
                    ],
                  ),
                ):Container(),
                outpass['tutor'] != 'rejected' && outpass['warden'] != 'rejected' ?
                Container(
                  margin: EdgeInsets.only(top: 10.0,bottom: 8.0),
                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        "Security-Status: ",
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        // outpass.containsKey('security')?outpass['security']:'',
                        outpass['security'],
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.w700),
                      ),
                      Container(
                        margin: EdgeInsets.only(left:5.0),
                        child: _getIcon(outpass['security']),
                      )
                    ],
                  ),
                ):Container(),
                outpass['otp'] != null ?
                Container(
                  margin: EdgeInsets.only(top: 1.0,bottom: 10.0),
                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                  child:Text(
                        "OTP:",
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.w700),
                      ),
                ):Container(),
                outpass['otp'] != null ?
                Container(
                  margin: EdgeInsets.only(top: 1.0,bottom: 5.0),
                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Text(
                  outpass['otp'].toString(),
                  style: TextStyle(
                  fontSize: 30.0, fontWeight: FontWeight.w900,color: Colors.blueAccent[700]),
                ),
                ):Container(),
                outpass['record_no'] != null ?
                Container(
                  margin: EdgeInsets.only(top: 1.0,bottom: 10.0),
                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                  child:Text(
                        "Record-Number: ",
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.w700),
                      ),
                ):Container(),
                outpass['record_no'] != null ?
                Container(
                  margin: EdgeInsets.only(top: 1.0,bottom: 5.0),
                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Text(
                  outpass['record_no'].toString(),
                  style: TextStyle(
                  fontSize: 30.0, fontWeight: FontWeight.w900,color: Colors.blueAccent[700]),
                ),
                ):Container(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  outpass['tutor'] == 'accepted' && outpass['warden'] == 'accepted' && outpass['otp'] == null && !outpass['expired']?
                  Container(
                    margin: EdgeInsets.only(right: 10.0,bottom: 5.0),
                    child: RaisedButton(
                      color: Colors.green[400],
                      child: Text('Generate OTP',style: TextStyle(color: Colors.white),),
                      onPressed: (){
                        getOtp(outpass['pk'].toString());
                      },
                    ),
                  ):Container(),
                  Container(
                    margin: EdgeInsets.only(right: 10.0,bottom: 5.0),
                    child: RaisedButton(
                      color: Colors.redAccent,
                      child: Text('Cancel',style: TextStyle(color: Colors.white),),
                      onPressed: (){
                        showCancel(outpass['pk'].toString());
                      },
                    ),
                  )
                ],
              )
              ],
            )),
      );
}