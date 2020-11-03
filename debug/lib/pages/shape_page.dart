import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart' as graphic;

const bubbleData = [
  [28604,77,17096869,'Australia',1990],[31163,77.4,27662440,'Canada',1990],[1516,68,1154605773,'China',1990],[13670,74.7,10582082,'Cuba',1990],[28599,75,4986705,'Finland',1990],[29476,77.1,56943299,'France',1990],[31476,75.4,78958237,'Germany',1990],[28666,78.1,254830,'Iceland',1990],[1777,57.7,870601776,'India',1990],[29550,79.1,122249285,'Japan',1990],[2076,67.9,20194354,'North Korea',1990],[12087,72,42972254,'South Korea',1990],[24021,75.4,3397534,'New Zealand',1990],[43296,76.8,4240375,'Norway',1990],[10088,70.8,38195258,'Poland',1990],[19349,69.6,147568552,'Russia',1990],[10670,67.3,53994605,'Turkey',1990],[26424,75.7,57110117,'United Kingdom',1990],[37062,75.4,252847810,'United States',1990],
  [44056,81.8,23968973,'Australia',2015],[43294,81.7,35939927,'Canada',2015],[13334,76.9,1376048943,'China',2015],[21291,78.5,11389562,'Cuba',2015],[38923,80.8,5503457,'Finland',2015],[37599,81.9,64395345,'France',2015],[44053,81.1,80688545,'Germany',2015],[42182,82.8,329425,'Iceland',2015],[5903,66.8,1311050527,'India',2015],[36162,83.5,126573481,'Japan',2015],[1390,71.4,25155317,'North Korea',2015],[34644,80.7,50293439,'South Korea',2015],[34186,80.6,4528526,'New Zealand',2015],[64304,81.6,5210967,'Norway',2015],[24787,77.3,38611794,'Poland',2015],[23038,73.13,143456918,'Russia',2015],[19360,76.5,78665830,'Turkey',2015],[38225,81.4,64715810,'United Kingdom',2015],[53354,79.1,321773631,'United States',2015]
];

const heatmapData = [
  [ 0, 0, 10 ],
  [ 0, 1, 19 ],
  [ 0, 2, 8 ],
  [ 0, 3, 24 ],
  [ 0, 4, 67 ],
  [ 1, 0, 92 ],
  [ 1, 1, 58 ],
  [ 1, 2, 78 ],
  [ 1, 3, 117 ],
  [ 1, 4, 48 ],
  [ 2, 0, 35 ],
  [ 2, 1, 15 ],
  [ 2, 2, 123 ],
  [ 2, 3, 64 ],
  [ 2, 4, 52 ],
  [ 3, 0, 72 ],
  [ 3, 1, 132 ],
  [ 3, 2, 114 ],
  [ 3, 3, 19 ],
  [ 3, 4, 16 ],
  [ 4, 0, 38 ],
  [ 4, 1, 5 ],
  [ 4, 2, 8 ],
  [ 4, 3, 117 ],
  [ 4, 4, 115 ],
  [ 5, 0, 88 ],
  [ 5, 1, 32 ],
  [ 5, 2, 12 ],
  [ 5, 3, 6 ],
  [ 5, 4, 120 ],
  [ 6, 0, 13 ],
  [ 6, 1, 44 ],
  [ 6, 2, 88 ],
  [ 6, 3, 98 ],
  [ 6, 4, 96 ],
  [ 7, 0, 31 ],
  [ 7, 1, 1 ],
  [ 7, 2, 82 ],
  [ 7, 3, 32 ],
  [ 7, 4, 30 ],
  [ 8, 0, 85 ],
  [ 8, 1, 97 ],
  [ 8, 2, 123 ],
  [ 8, 3, 64 ],
  [ 8, 4, 84 ],
  [ 9, 0, 47 ],
  [ 9, 1, 114 ],
  [ 9, 2, 31 ],
  [ 9, 3, 48 ],
  [ 9, 4, 91 ]
];

const boxData = [
  { 'x': 'Oceania', 'low': 1, 'q1': 9, 'median': 16, 'q3': 22, 'high': 24 },
  { 'x': 'East Europe', 'low': 1, 'q1': 5, 'median': 8, 'q3': 12, 'high': 16 },
  { 'x': 'Australia', 'low': 1, 'q1': 8, 'median': 12, 'q3': 19, 'high': 26 },
  { 'x': 'South America', 'low': 2, 'q1': 8, 'median': 12, 'q3': 21, 'high': 28 },
  { 'x': 'North Africa', 'low': 1, 'q1': 8, 'median': 14, 'q3': 18, 'high': 24 },
  { 'x': 'North America', 'low': 3, 'q1': 10, 'median': 17, 'q3': 28, 'high': 30 },
  { 'x': 'West Europe', 'low': 1, 'q1': 7, 'median': 10, 'q3': 17, 'high': 22 },
  { 'x': 'West Africa', 'low': 1, 'q1': 6, 'median': 8, 'q3': 13, 'high': 16 }
];

class ShapePage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Chart'),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              Container(
                width: 300,
                height: 300,
                child: graphic.Chart(
                  data: [
                    { 'genre': 'Sports', 'sold': 275 },
                    { 'genre': 'Strategy', 'sold': 115 },
                    { 'genre': 'Action', 'sold': 120 },
                    { 'genre': 'Shooter', 'sold': 350 },
                    { 'genre': 'Other', 'sold': 150 },
                  ],
                  scales: {
                    'genre': graphic.CatScale(
                      accessor: (map) => map['genre'] as String,
                    ),
                    'sold': graphic.LinearScale(
                      max: 400,
                      min: -100,
                      accessor: (map) => map['sold'] as num,
                      nice: true,
                    )
                  },
                  geoms: [graphic.IntervalGeom(
                    position: graphic.PositionAttr(field: 'genre*sold'),
                    shape: graphic.ShapeAttr(values: [graphic.RectShape(radius: Radius.circular(4))])
                  )],
                  axes: {
                    'genre': graphic.Defaults.horizontalAxis,
                    'sold': graphic.Defaults.verticalAxis,
                  },
                ),
                margin: EdgeInsets.all(20),
              ),
              Container(
                width: 300,
                height: 300,
                child: graphic.Chart(
                  data: [
                    { 'genre': 'Sports', 'sold': 275 },
                    { 'genre': 'Strategy', 'sold': 115 },
                    { 'genre': 'Action', 'sold': 120 },
                    { 'genre': 'Shooter', 'sold': 350 },
                    { 'genre': 'Other', 'sold': 150 },
                  ]..sort((a, b) => (b['sold'] as num) - (a['sold'] as num)),
                  scales: {
                    'genre': graphic.CatScale(
                      accessor: (map) => map['genre'] as String,
                      range: [0.9, 0.2],
                    ),
                    'sold': graphic.LinearScale(
                      max: 200,
                      min: -200,
                      accessor: (map) => map['sold'] as num,
                      nice: true,
                    )
                  },
                  geoms: [graphic.IntervalGeom(
                    position: graphic.PositionAttr(field: 'genre*sold'),
                    shape: graphic.ShapeAttr(values: [graphic.PyramidShape()]),
                    color: graphic.ColorAttr(field: 'genre'),
                    adjust: graphic.SymmetricAdjust(),
                  )],
                  coord: graphic.CartesianCoord(transposed: true),
                ),
                margin: EdgeInsets.all(20),
              ),
              Container(
                width: 300,
                height: 300,
                child: graphic.Chart(
                  data: bubbleData,
                  scales: {
                    '0': graphic.LinearScale(
                      accessor: (list) => list[0] as num,
                      range: [0.1, 0.9],
                    ),
                    '1': graphic.LinearScale(
                      accessor: (list) => list[1] as num,
                      range: [0.1, 0.9],
                    ),
                    '2': graphic.LinearScale(
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
                      graphic.CircleShape(hollow: true),
                      graphic.SquareShape(hollow: true),
                    ], isTween: true),
                  )],
                  axes: {
                    '0': graphic.Defaults.horizontalAxis,
                    '1': graphic.Defaults.verticalAxis,
                  },
                ),
                margin: EdgeInsets.all(20),
              ),
              Container(
                width: 300,
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
                    'sales': graphic.LinearScale(
                      accessor: (list) => list[2] as num,
                    )
                  },
                  geoms: [graphic.PointGeom(
                    position: graphic.PositionAttr(field: 'name*day'),
                    shape: graphic.ShapeAttr(values: [graphic.TileShape()]),
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
                margin: EdgeInsets.all(20),
              ),
              Container(
                width: 300,
                height: 300,
                child: graphic.Chart(
                  data: boxData,
                  scales: {
                    'x': graphic.CatScale(
                      accessor: (map) => map['x'] as String,
                    ),
                    'low': graphic.LinearScale(
                      accessor: (map) => map['low'] as num,
                      max: 40,
                      min: 0,
                    ),
                    'q1': graphic.LinearScale(
                      accessor: (map) => map['q1'] as num,
                      max: 40,
                      min: 0,
                    ),
                    'median': graphic.LinearScale(
                      accessor: (map) => map['median'] as num,
                      max: 40,
                      min: 0,
                    ),
                    'q3': graphic.LinearScale(
                      accessor: (map) => map['q3'] as num,
                      max: 40,
                      min: 0,
                    ),
                    'high': graphic.LinearScale(
                      accessor: (map) => map['high'] as num,
                      max: 40,
                      min: 0,
                    ),
                  },
                  geoms: [graphic.SchemaGeom(
                    position: graphic.PositionAttr(field: 'x*low*q1*median*q3*high'),
                    shape: graphic.ShapeAttr(values: [graphic.BoxShape()]),
                  )],
                  axes: {
                    'x': graphic.Defaults.horizontalAxis
                      ..label.rotation = 0.9
                      ..label.offset = Offset(0, 20),
                    'low': graphic.Defaults.verticalAxis,
                  },
                  padding: EdgeInsets.fromLTRB(40, 5, 10, 50),
                ),
                margin: EdgeInsets.all(20),
              ),
              Container(
                width: 300,
                height: 300,
                child: graphic.Chart(
                  data: boxData,
                  scales: {
                    'x': graphic.CatScale(
                      accessor: (map) => map['x'] as String,
                    ),
                    'low': graphic.LinearScale(
                      accessor: (map) => map['low'] as num,
                      max: 40,
                      min: 0,
                    ),
                    'q1': graphic.LinearScale(
                      accessor: (map) => map['q1'] as num,
                      max: 40,
                      min: 0,
                    ),
                    'median': graphic.LinearScale(
                      accessor: (map) => map['median'] as num,
                      max: 40,
                      min: 0,
                    ),
                    'q3': graphic.LinearScale(
                      accessor: (map) => map['q3'] as num,
                      max: 40,
                      min: 0,
                    ),
                    'high': graphic.LinearScale(
                      accessor: (map) => map['high'] as num,
                      max: 40,
                      min: 0,
                    ),
                  },
                  geoms: [graphic.SchemaGeom(
                    position: graphic.PositionAttr(field: 'x*low*q1*median*q3*high'),
                    shape: graphic.ShapeAttr(values: [graphic.BoxShape()]),
                  )],
                  axes: {
                    'x': graphic.Defaults.horizontalAxis
                      ..label.rotation = 0.9
                      ..label.offset = Offset(0, 0),
                    'low': graphic.Defaults.verticalAxis,
                  },
                  coord: graphic.CartesianCoord(transposed: true),
                  padding: EdgeInsets.fromLTRB(50, 5, 10, 20),
                ),
                margin: EdgeInsets.all(20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
