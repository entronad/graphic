import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart' as graphic;

import 'data.dart';

class LineAreaPage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Line/Area Charts'),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              Padding(
                child: Text('Smooth Line and Area', style: TextStyle(fontSize: 20)),
                padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
              ),
              Container(
                width: 350,
                height: 300,
                child: graphic.Chart(
                  data: lineData,
                  scales: {
                    'Date': graphic.CatScale(
                      accessor: (map) => map['Date'] as String,
                      range: [0, 1],
                      tickCount: 5,
                    ),
                    'Close': graphic.NumScale(
                      accessor: (map) => map['Close'] as num,
                      nice: true,
                      min: 100,
                    )
                  },
                  geoms: [
                    graphic.AreaGeom(
                      position: graphic.PositionAttr(field: 'Date*Close'),
                      shape: graphic.ShapeAttr(values: [graphic.Shapes.smoothArea]),
                      color: graphic.ColorAttr(values: [
                        graphic.Defaults.theme.colors.first.withAlpha(80),
                      ]),
                    ),
                    graphic.LineGeom(
                      position: graphic.PositionAttr(field: 'Date*Close'),
                      shape: graphic.ShapeAttr(values: [graphic.Shapes.smoothLine]),
                      size: graphic.SizeAttr(values: [0.5]),
                    ),
                  ],
                  axes: {
                    'Date': graphic.Defaults.horizontalAxis,
                    'Close': graphic.Defaults.verticalAxis,
                  },
                ),
              ),

              Padding(
                child: Text('Multi Line (No Stack)', style: TextStyle(fontSize: 20)),
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
                      range: [0, 1],
                    ),
                    'type': graphic.CatScale(
                      accessor: (map) => map['type'] as String,
                    ),
                    'value': graphic.NumScale(
                      accessor: (map) => map['value'] as num,
                      nice: true,
                    ),
                  },
                  geoms: [graphic.LineGeom(
                    position: graphic.PositionAttr(field: 'index*value'),
                    color: graphic.ColorAttr(field: 'type'),
                    shape: graphic.ShapeAttr(values: [graphic.Shapes.smoothLine]),
                  )],
                  axes: {
                    'index': graphic.Defaults.horizontalAxis,
                    'value': graphic.Defaults.verticalAxis,
                  },
                ),
              ),

              Padding(
                child: Text('Stack Area', style: TextStyle(fontSize: 20)),
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
                      range: [0, 1],
                    ),
                    'type': graphic.CatScale(
                      accessor: (map) => map['type'] as String,
                    ),
                    'value': graphic.NumScale(
                      accessor: (map) => map['value'] as num,
                      max: 1800,
                    ),
                  },
                  geoms: [graphic.AreaGeom(
                    position: graphic.PositionAttr(field: 'index*value'),
                    color: graphic.ColorAttr(field: 'type'),
                    shape: graphic.ShapeAttr(values: [graphic.Shapes.smoothArea]),
                    adjust: graphic.StackAdjust(),
                  )],
                  axes: {
                    'index': graphic.Defaults.horizontalAxis,
                    'value': graphic.Defaults.verticalAxis,
                  },
                ),
              ),

              Padding(
                child: Text('Polar Coord Line', style: TextStyle(fontSize: 20)),
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
                  coord: graphic.PolarCoord(),
                  geoms: [graphic.LineGeom(
                    position: graphic.PositionAttr(field: 'index*value'),
                    color: graphic.ColorAttr(field: 'type'),
                  )],
                  axes: {
                    'index': graphic.Defaults.circularAxis,
                    'value': graphic.Defaults.radialAxis,
                  },
                ),
              ),

              Padding(
                child: Text('Polar Coord Area Stack', style: TextStyle(fontSize: 20)),
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
                      max: 1800,
                    ),
                  },
                  coord: graphic.PolarCoord(),
                  geoms: [graphic.AreaGeom(
                    position: graphic.PositionAttr(field: 'index*value'),
                    color: graphic.ColorAttr(field: 'type'),
                    adjust: graphic.StackAdjust(),
                  )],
                  axes: {
                    'index': graphic.Defaults.circularAxis,
                    'value': graphic.Defaults.radialAxis
                      ..label = null,
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
