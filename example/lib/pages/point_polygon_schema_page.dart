import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart' as graphic;

import 'data.dart';

class PointPolygonSchemaPage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Point/Polygon/Schema Charts'),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              Padding(
                child: Text('Various Shapes Scatter', style: TextStyle(fontSize: 20)),
                padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
              ),
              Container(
                width: 350,
                height: 300,
                child: graphic.Chart(
                  data: scatterData,
                  scales: {
                    '0': graphic.NumScale(
                      accessor: (list) => list[0] as num,
                      range: [0.1, 0.9],
                      nice: true,
                    ),
                    '1': graphic.NumScale(
                      accessor: (list) => list[1] as num,
                      range: [0.1, 0.9],
                      nice: true,
                      min: 55,
                    ),
                    '2': graphic.NumScale(
                      accessor: (list) => list[2] as num,
                    ),
                    '4': graphic.CatScale(
                      accessor: (list) => list[4].toString(),
                    ),
                  },
                  geoms: [graphic.PointGeom(
                    position: graphic.PositionAttr(field: '0*1'),
                    size: graphic.SizeAttr(field: '2', values: [5, 20]),
                    color: graphic.ColorAttr(field: '4'),
                    shape: graphic.ShapeAttr(field: '4', values: [
                      graphic.Shapes.hollowCirclePoint,
                      graphic.Shapes.hollowRectPoint,
                    ], isTween: true),
                  )],
                  axes: {
                    '0': graphic.Defaults.horizontalAxis,
                    '1': graphic.Defaults.verticalAxis,
                  },
                ),
              ),

              Padding(
                child: Text('Polar Coord Point', style: TextStyle(fontSize: 20)),
                padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
              ),
              Container(
                width: 350,
                height: 300,
                child: graphic.Chart(
                  data: scatterData,
                  scales: {
                    '0': graphic.NumScale(
                      accessor: (list) => list[0] as num,
                      nice: true,
                    ),
                    '1': graphic.NumScale(
                      accessor: (list) => list[1] as num,
                      nice: true,
                      min: 55,
                    ),
                    '2': graphic.NumScale(
                      accessor: (list) => list[2] as num,
                    ),
                    '4': graphic.CatScale(
                      accessor: (list) => list[4].toString(),
                    ),
                  },
                  coord: graphic.PolarCoord(),
                  geoms: [graphic.PointGeom(
                    position: graphic.PositionAttr(field: '0*1'),
                    size: graphic.SizeAttr(values: [2]),
                    color: graphic.ColorAttr(field: '4'),
                  )],
                  axes: {
                    '0': graphic.Defaults.circularAxis,
                    '1': graphic.Defaults.radialAxis
                      ..label = null,
                  },
                ),
              ),

              Padding(
                child: Text('Heatmap', style: TextStyle(fontSize: 20)),
                padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
              ),
              Container(
                width: 350,
                height: 300,
                child: graphic.Chart(
                  data: heatmapData,
                  scales: {
                    'name': graphic.CatScale(
                      accessor: (list) => list[0].toString(),
                    ),
                    'day': graphic.CatScale(
                      accessor: (list) => list[1].toString(),
                    ),
                    'sales': graphic.NumScale(
                      accessor: (list) => list[2] as num,
                    )
                  },
                  geoms: [graphic.PolygonGeom(
                    position: graphic.PositionAttr(field: 'name*day'),
                    color: graphic.ColorAttr(
                      field: 'sales',
                      values: [Color(0xffbae7ff), Color(0xff1890ff), Color(0xff0050b3)],
                      isTween: true,
                    ),
                  )],
                  axes: {
                    'name': graphic.Defaults.horizontalAxis,
                    'day': graphic.Defaults.verticalAxis,
                  },
                ),
              ),

              Padding(
                child: Text('Polar Coord Heatmap', style: TextStyle(fontSize: 20)),
                padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
              ),
              Container(
                width: 350,
                height: 300,
                child: graphic.Chart(
                  data: heatmapData,
                  scales: {
                    'name': graphic.CatScale(
                      accessor: (list) => list[0].toString(),
                    ),
                    'day': graphic.CatScale(
                      accessor: (list) => list[1].toString(),
                    ),
                    'sales': graphic.NumScale(
                      accessor: (list) => list[2] as num,
                    )
                  },
                  coord: graphic.PolarCoord(),
                  geoms: [graphic.PolygonGeom(
                    position: graphic.PositionAttr(field: 'name*day'),
                    color: graphic.ColorAttr(
                      field: 'sales',
                      values: [Color(0xffbae7ff), Color(0xff1890ff), Color(0xff0050b3)],
                      isTween: true,
                    ),
                  )],
                  axes: {
                    'name': graphic.Defaults.circularAxis
                      ..line = null
                      ..grid = null,
                  },
                  padding: EdgeInsets.all(20),
                  margin: EdgeInsets.zero,
                ),
              ),

              Padding(
                child: Text('Box Schema', style: TextStyle(fontSize: 20)),
                padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
              ),
              Container(
                width: 350,
                height: 300,
                child: graphic.Chart(
                  data: boxData,
                  scales: {
                    'x': graphic.CatScale(
                      accessor: (map) => map['x'] as String,
                    ),
                    'low': graphic.NumScale(
                      accessor: (map) => map['low'] as num,
                      max: 35,
                    ),
                    'q1': graphic.NumScale(
                      accessor: (map) => map['q1'] as num,
                      max: 35,
                    ),
                    'median': graphic.NumScale(
                      accessor: (map) => map['median'] as num,
                      max: 35,
                    ),
                    'q3': graphic.NumScale(
                      accessor: (map) => map['q3'] as num,
                      max: 35,
                    ),
                    'high': graphic.NumScale(
                      accessor: (map) => map['high'] as num,
                      max: 35,
                    ),
                  },
                  geoms: [graphic.SchemaGeom(
                    position: graphic.PositionAttr(field: 'x*low*q1*median*q3*high'),
                    shape: graphic.ShapeAttr(values: [graphic.Shapes.boxSchema]),
                  )],
                  axes: {
                    'x': graphic.Defaults.horizontalAxis
                      ..label.rotation = 0.9
                      ..label.offset = Offset(0, 25),
                    'low': graphic.Defaults.verticalAxis,
                  },
                  padding: EdgeInsets.fromLTRB(40, 5, 10, 60),
                ),
              ),

              Padding(
                child: Text('Box Schema Transposed', style: TextStyle(fontSize: 20)),
                padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
              ),
              Container(
                width: 350,
                height: 300,
                child: graphic.Chart(
                  data: boxData,
                  scales: {
                    'x': graphic.CatScale(
                      accessor: (map) => map['x'] as String,
                    ),
                    'low': graphic.NumScale(
                      accessor: (map) => map['low'] as num,
                      max: 35,
                    ),
                    'q1': graphic.NumScale(
                      accessor: (map) => map['q1'] as num,
                      max: 35,
                    ),
                    'median': graphic.NumScale(
                      accessor: (map) => map['median'] as num,
                      max: 35,
                    ),
                    'q3': graphic.NumScale(
                      accessor: (map) => map['q3'] as num,
                      max: 35,
                    ),
                    'high': graphic.NumScale(
                      accessor: (map) => map['high'] as num,
                      max: 35,
                    ),
                  },
                  coord: graphic.CartesianCoord(transposed: true),
                  geoms: [graphic.SchemaGeom(
                    position: graphic.PositionAttr(field: 'x*low*q1*median*q3*high'),
                    shape: graphic.ShapeAttr(values: [graphic.Shapes.boxSchema]),
                  )],
                  axes: {
                    'x': graphic.Defaults.verticalAxis
                      ..grid = null
                      ..line = graphic.AxisLine(style: graphic.LineStyle(color: Color(0xffe8e8e8))),
                    'low': graphic.Defaults.horizontalAxis
                      ..line = null
                      ..grid = graphic.AxisGrid(style: graphic.LineStyle(color: Color(0xffe8e8e8))),
                  },
                  padding: EdgeInsets.fromLTRB(80, 5, 5, 40),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
