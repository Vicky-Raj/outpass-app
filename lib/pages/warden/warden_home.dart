import 'package:flutter/material.dart';

class WardenHome extends StatefulWidget {
  @override
  _WardenHomeState createState() => _WardenHomeState();
}

class _WardenHomeState extends State<WardenHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        centerTitle: true,
        title: Text('Warden Home'),
      ),
      drawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            DrawerHeader(
              child: null,
              decoration: BoxDecoration(
                color: Colors.deepPurpleAccent
              ),
            ),
          ],
        ),
      ),
    );
  }
}