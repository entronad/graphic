import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart' as graphic;

import 'data.dart';

class IntervalPage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Interval Charts'),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              Padding(
                child: Text('Radius Rect', style: TextStyle(fontSize: 20)),
                padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
              ),
              Container(
                width: 350,
                height: 300,
                child: graphic.Chart(
                  data: basicData,
                  scales: {
                    'genre': graphic.CatScale(
                      accessor: (map) => map['genre'] as String,
                    ),
                    'sold': graphic.NumScale(
                      accessor: (map) => map['sold'] as num,
                      nice: true,
                    )
                  },
                  geoms: [graphic.IntervalGeom(
                    position: graphic.PositionAttr(field: 'genre*sold'),
                    shape: graphic.ShapeAttr(values: [
                      graphic.Shapes.rrectInterval(radius: Radius.circular(5))
                    ]),
                  )],
                  axes: {
                    'genre': graphic.Defaults.horizontalAxis,
                    'sold': graphic.Defaults.verticalAxis,
                  },
                ),
              ),

              Padding(
                child: Text('Dodge Adjust', style: TextStyle(fontSize: 20)),
                padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
              ),
              Container(
                width: 350,
                height: 300,
                child: graphic.Chart(
                  data: adjustData,
                  scales: {
                    'index': graphic.CatScale(
                      accessor: (map) => map['index'].toString(),
                    ),
                    'type': graphic.CatScale(
                      accessor: (map) => map['type'] as String,
                    ),
                    'value': graphic.NumScale(
                      accessor: (map) => map['value'] as num,
                      nice: true,
                    ),
                  },
                  geoms: [graphic.IntervalGeom(
                    position: graphic.PositionAttr(field: 'index*value'),
                    color: graphic.ColorAttr(field: 'type'),
                    adjust: graphic.DodgeAdjust(),
                    size: graphic.SizeAttr(values: [4]),
                  )],
                  axes: {
                    'index': graphic.Defaults.horizontalAxis,
                    'value': graphic.Defaults.verticalAxis,
                  },
                ),
              ),

              Padding(
                child: Text('Stack Adjust', style: TextStyle(fontSize: 20)),
                padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
              ),
              Container(
                width: 350,
                height: 300,
                child: graphic.Chart(
                  data: adjustData,
                  scales: {
                    'index': graphic.CatScale(
                      accessor: (map) => map['index'].toString(),
                    ),
                    'type': graphic.CatScale(
                      accessor: (map) => map['type'] as String,
                    ),
                    'value': graphic.NumScale(
                      accessor: (map) => map['value'] as num,
                      max: 2000,
                    ),
                  },
                  geoms: [graphic.IntervalGeom(
                    position: graphic.PositionAttr(field: 'index*value'),
                    color: graphic.ColorAttr(field: 'type'),
                    adjust: graphic.StackAdjust(),
                  )],
                  axes: {
                    'index': graphic.Defaults.horizontalAxis,
                    'value': graphic.Defaults.verticalAxis,
                  },
                ),
              ),

              Padding(
                child: Text('Polar Coord', style: TextStyle(fontSize: 20)),
                padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
              ),
              Container(
                width: 350,
                height: 300,
                child: graphic.Chart(
                  data: basicData,
                  scales: {
                    'genre': graphic.CatScale(
                      accessor: (map) => map['genre'] as String,
                    ),
                    'sold': graphic.NumScale(
                      accessor: (map) => map['sold'] as num,
                      nice: true,
                    )
                  },
                  coord: graphic.PolarCoord(),
                  geoms: [graphic.IntervalGeom(
                    position: graphic.PositionAttr(field: 'genre*sold'),
                    color: graphic.ColorAttr(field: 'genre'),
                  )],
                  axes: {
                    'genre': graphic.Defaults.circularAxis,
                    'sold': graphic.Defaults.radialAxis
                      ..label = null,
                  },
                ),
              ),

              Padding(
                child: Text('Polar Coord Transposed', style: TextStyle(fontSize: 20)),
                padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
              ),
              Container(
                width: 350,
                height: 300,
                child: graphic.Chart(
                  data: basicData,
                  scales: {
                    'genre': graphic.CatScale(
                      accessor: (map) => map['genre'] as String,
                    ),
                    'sold': graphic.NumScale(
                      accessor: (map) => map['sold'] as num,
                      nice: true,
                    )
                  },
                  coord: graphic.PolarCoord(transposed: true, innerRadius: 0.5),
                  geoms: [graphic.IntervalGeom(
                    position: graphic.PositionAttr(field: 'genre*sold'),
                    color: graphic.ColorAttr(field: 'genre'),
                  )],
                  padding: EdgeInsets.zero,
                  margin: EdgeInsets.all(20),
                ),
              ),

              Padding(
                child: Text('Polar Coord Stack', style: TextStyle(fontSize: 20)),
                padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
              ),
              Container(
                width: 350,
                height: 300,
                child: graphic.Chart(
                  data: adjustData,
                  scales: {
                    'index': graphic.CatScale(
                      accessor: (map) => map['index'].toString(),
                    ),
                    'type': graphic.CatScale(
                      accessor: (map) => map['type'] as String,
                    ),
                    'value': graphic.NumScale(
                      accessor: (map) => map['value'] as num,
                      max: 1800,
                      tickCount: 5,
                    ),
                  },
                  coord: graphic.PolarCoord(),
                  geoms: [graphic.IntervalGeom(
                    position: graphic.PositionAttr(field: 'index*value'),
                    color: graphic.ColorAttr(field: 'type'),
                    adjust: graphic.StackAdjust(),
                  )],
                  axes: {
                    'index': graphic.Defaults.circularAxis
                      ..top = true,
                    'value': graphic.Defaults.radialAxis
                      ..grid = null
                      ..top = true
                      ..label.style = TextStyle(color: Colors.white, fontSize: 10)
                      ..label.offset = Offset(-4, 0),
                  },
                ),
              ),

              Padding(
                child: Text('Pyramid', style: TextStyle(fontSize: 20)),
                padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
              ),
              Container(
                width: 350,
                height: 300,
                child: graphic.Chart(
                  data: List.from(basicData)
                    ..sort((a, b) => (b['sold'] as num) - (a['sold'] as num)),
                  scales: {
                    'genre': graphic.CatScale(
                      accessor: (map) => map['genre'] as String,
                      range: [0.2, 0.9],
                    ),
                    'sold': graphic.NumScale(
                      max: 200,
                      min: -200,
                      accessor: (map) => map['sold'] as num,
                      nice: true,
                    )
                  },
                  coord: graphic.CartesianCoord(transposed: true),
                  geoms: [graphic.IntervalGeom(
                    position: graphic.PositionAttr(field: 'genre*sold'),
                    shape: graphic.ShapeAttr(values: [graphic.Shapes.pyramidInterval]),
                    color: graphic.ColorAttr(field: 'genre'),
                    adjust: graphic.SymmetricAdjust(),
                  )],
                  padding: EdgeInsets.zero,
                  margin: EdgeInsets.all(20),
                ),
              ),

              Padding(
                child: Text('Funnel', style: TextStyle(fontSize: 20)),
                padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
              ),
              Container(
                width: 350,
                height: 300,
                child: graphic.Chart(
                  data: List.from(basicData)
                    ..sort((a, b) => (b['sold'] as num) - (a['sold'] as num)),
                  scales: {
                    'genre': graphic.CatScale(
                      accessor: (map) => map['genre'] as String,
                      range: [0.9, 0.2],
                    ),
                    'sold': graphic.NumScale(
                      max: 200,
                      min: -200,
                      accessor: (map) => map['sold'] as num,
                      nice: true,
                    )
                  },
                  coord: graphic.CartesianCoord(transposed: true),
                  geoms: [graphic.IntervalGeom(
                    position: graphic.PositionAttr(field: 'genre*sold'),
                    shape: graphic.ShapeAttr(values: [graphic.Shapes.funnelInterval]),
                    color: graphic.ColorAttr(field: 'genre'),
                    adjust: graphic.SymmetricAdjust(),
                  )],
                  padding: EdgeInsets.zero,
                  margin: EdgeInsets.all(20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
