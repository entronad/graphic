import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart' as graphic;

const data = [
  { 'genre': 'Sports', 'sold': 275.0 },
  { 'genre': 'Strategy', 'sold': 115.0 },
  { 'genre': 'Action', 'sold': 120.0 },
  { 'genre': 'Shooter', 'sold': 350.0 },
  { 'genre': 'Other', 'sold': 150.0 },
];

class Basic extends StatefulWidget {
  @override
  _BasicState createState() => _BasicState();
}

class _BasicState extends State<Basic> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('shape'),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              Container(
                width: 500,
                height: 500,
                child: graphic.Chart(graphic.ChartCfg(
                  width: 500,
                  height: 500,
                  data: data,
                  geoms: [graphic.GeomCfg(
                    type: graphic.GeomType.interval,
                    position: graphic.AttrCfg(field: 'genre*sold'),
                    color: graphic.AttrCfg(field: 'genre'),
                  )],
                ))
              ),
            ],
          ),
        ),
      ),
    );
  }
}
