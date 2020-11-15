import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tab/root_component.dart';

class HomeWidget extends StatefulWidget {
  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Toad Artilary'),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: RootComponent(),
    );
  }
}
