import 'package:flutter/material.dart';



Widget getOutpassCard(List outpass,Function accept,Function reject){
 return Column(
  children:outpass.map((item)=> Container(
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
                        "Student: ",
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        // outpass.containsKey('req-time')?outpass['req-time']:'',
                        item['student'],
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
                    children: <Widget>[
                      Text(
                        "Requested-Datetime: ",
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.w700),
                      ),
                      Expanded(
                      child:Text(
                        // outpass.containsKey('req-time')?outpass['req-time']:'',
                        item['req-date'],
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
                        "Leaving-Datetime: ",
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.w700),
                      ),
                      Expanded(
                        child:Text(
                        // outpass.containsKey('dep-time')?outpass['dep-time']:'',
                        item['dep-date'],
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
                        item['req-days'].toString(),
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
                        item['reason'],
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.w700),
                      ))
                    ],
                  ),
                ),
              Container(
                margin: EdgeInsets.only(top: 10.0,bottom:10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(right: 20.0),
                      child: RaisedButton(
                        color: Colors.green,
                        child: Text('Accept',style: TextStyle(color:Colors.white),),
                        onPressed: (){
                          accept(item['pk'].toString());
                        },
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(right: 10.0),
                      child: RaisedButton(
                        color: Colors.redAccent,
                        child: Text('Reject',style: TextStyle(color: Colors.white),),
                        onPressed: (){
                          reject(item['pk'].toString());
                        },
                      ),
                    )
                  ],
                ),
              )
              ],
            )),
      )
    ).toList()
    );
}