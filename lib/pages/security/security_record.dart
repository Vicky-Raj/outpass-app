import 'package:flutter/material.dart';


Widget getCard(Map record, Function recordTime){
  return Container(
              margin: EdgeInsets.only(left:5.0,right:5.0,top:10.0),
              child: Card(
                elevation: 10.0,
                child:Column(
                children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 25.0),
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
                  margin: EdgeInsets.only(top: 20.0,bottom: 20.0),
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
                Container(
                  margin: EdgeInsets.only(right: 30.0,bottom: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      RaisedButton(
                        child: Text('Record Time',style: TextStyle(color: Colors.white),),
                        color: Colors.blueAccent,
                        onPressed: (){
                          recordTime();
                        },
                      )
                    ],
                  ),
                )
                ],
              ),
            )
          );
}