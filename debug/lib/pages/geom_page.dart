import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:graphic/graphic.dart' as graphic;
import 'package:graphic/src/chart/component.dart';
import 'package:graphic/src/coord/cartesian.dart';
import 'package:graphic/src/coord/polar.dart';
import 'package:graphic/src/scale/base.dart';
import 'package:graphic/src/scale/category/string.dart';
import 'package:graphic/src/scale/linear/num.dart';
import 'package:graphic/src/scale/ordinal/date_time.dart';
import 'package:graphic/src/geom/interval.dart';
import 'package:graphic/src/geom/line.dart';
import 'package:graphic/src/geom/area.dart';
import 'package:graphic/src/geom/point.dart';
import 'package:graphic/src/geom/polygon.dart';
import 'package:graphic/src/geom/schema.dart';

class GeomPage extends StatefulWidget {
  @override
  _GeomPageState createState() => _GeomPageState();
}

class _GeomPageState extends State<GeomPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  graphic.Renderer r1 = graphic.Renderer();
  graphic.Renderer r2 = graphic.Renderer();
  graphic.Renderer r3 = graphic.Renderer();
  graphic.Renderer r4 = graphic.Renderer();
  graphic.Renderer r5 = graphic.Renderer();
  graphic.Renderer r6 = graphic.Renderer();

  @override
  void initState() {
    super.initState();

    // Interval

    final plot1 = r1.addGroup();
    final data1 = [
      { 'genre': 'Sports', 'sold': 275 },
      { 'genre': 'Strategy', 'sold': 115 },
      { 'genre': 'Action', 'sold': 120 },
      { 'genre': 'Shooter', 'sold': 350 },
      { 'genre': 'Other', 'sold': 150 },
    ];
    final coord1 = CartesianCoordComponent(graphic.CartesianCoord());
    // final coord1 = PolarCoordComponent(graphic.PolarCoord(
    //   // transposed: true,
    //   // innerRadius: 0.3,
    // ));
    coord1.setRegion(Rect.fromLTWH(0, 0, 300, 300));
    final scales1 = <String, ScaleComponent>{
      'genre': StringCategoryScaleComponent(graphic.CatScale(
        values: ['Sports', 'Strategy', 'Action', 'Shooter', 'Other'],
        accessor: (map) => map['genre'] as String,
        scaledRange: [1 / 10, 1 - 1 / 10],
        // scaledRange: [0, 1 - 0.2],
      )),
      'sold': NumLinearScaleComponent(graphic.NumberScale(
        min: 100,
        max: 400,
        accessor: (map) => map['sold'] as num,
      )),
    };
    final chart1 = ChartComponent()
      ..state.data = data1
      ..state.coord = coord1
      ..state.middlePlot = plot1
      ..state.scales = scales1;
    
    final geom1 = IntervalGeomComponent()
      ..state.chart = chart1
      ..setColor(graphic.ColorAttr(
        field: 'genre',
        values: [Colors.blue, Colors.red],
        isTween: true,
      ))
      ..setShape(graphic.ShapeAttr())
      ..setSize(graphic.SizeAttr())
      ..setPosition(graphic.PositionAttr(field: 'genre*sold'));
    
    geom1.render();

    r1.mount(() { setState(() {}); });

    // line

    final plot2 = r2.addGroup();
    final data2 = [
      { 'genre': 'Sports', 'sold': 275 },
      { 'genre': 'Strategy', 'sold': 115 },
      { 'genre': 'Action', 'sold': 120 },
      { 'genre': 'Shooter', 'sold': 350 },
      { 'genre': 'Other', 'sold': 150 },
    ];
    final coord2 = CartesianCoordComponent(graphic.CartesianCoord(transposed: true));
    // final coord2 = PolarCoordComponent(graphic.PolarCoord(
    //   innerRadius: 0.5,
    // ));
    coord2.setRegion(Rect.fromLTWH(0, 0, 300, 300));
    final scales2 = <String, ScaleComponent>{
      'genre': StringCategoryScaleComponent(graphic.CatScale(
        values: ['Sports', 'Strategy', 'Action', 'Shooter', 'Other'],
        accessor: (map) => map['genre'] as String,
        scaledRange: [1 / 10, 1 - 1 / 10],
        // scaledRange: [0, 1 - 0.2],
      )),
      'sold': NumLinearScaleComponent(graphic.NumberScale(
        min: 100,
        max: 400,
        accessor: (map) => map['sold'] as num,
      )),
    };
    final chart2 = ChartComponent()
      ..state.data = data2
      ..state.coord = coord2
      ..state.middlePlot = plot2
      ..state.scales = scales2;
    
    final geom2 = LineGeomComponent()
      ..state.chart = chart2
      ..setColor(graphic.ColorAttr(
        field: 'genre',
        values: [Colors.blue, Colors.red],
        isTween: true,
      ))
      ..setShape(graphic.ShapeAttr())
      ..setSize(graphic.SizeAttr())
      ..setPosition(graphic.PositionAttr(field: 'genre*sold'));
    
    geom2.render();

    r2.mount(() { setState(() {}); });

    // area

    final plot3 = r3.addGroup();
    final data3 = [
      { 'genre': 'Sports', 'sold': 275 },
      { 'genre': 'Strategy', 'sold': 115 },
      { 'genre': 'Action', 'sold': 120 },
      { 'genre': 'Shooter', 'sold': 350 },
      { 'genre': 'Other', 'sold': 150 },
    ];
    // final coord3 = CartesianCoordComponent(graphic.CartesianCoord(transposed: true));
    final coord3 = PolarCoordComponent(graphic.PolarCoord(
      innerRadius: 0.5,
    ));
    coord3.setRegion(Rect.fromLTWH(0, 0, 300, 300));
    final scales3 = <String, ScaleComponent>{
      'genre': StringCategoryScaleComponent(graphic.CatScale(
        values: ['Sports', 'Strategy', 'Action', 'Shooter', 'Other'],
        accessor: (map) => map['genre'] as String,
      )),
      'sold': NumLinearScaleComponent(graphic.NumberScale(
        min: 100,
        max: 400,
        accessor: (map) => map['sold'] as num,
      )),
    };
    final chart3 = ChartComponent()
      ..state.data = data3
      ..state.coord = coord3
      ..state.middlePlot = plot3
      ..state.scales = scales3;
    
    final geom3 = AreaGeomComponent()
      ..state.chart = chart3
      ..setColor(graphic.ColorAttr(
        field: 'genre',
        values: [Colors.blue, Colors.red],
        isTween: true,
      ))
      ..setShape(graphic.ShapeAttr())
      ..setSize(graphic.SizeAttr())
      ..setPosition(graphic.PositionAttr(field: 'genre*sold'));
    
    geom3.render();

    r3.mount(() { setState(() {}); });

    // point

    final plot4 = r4.addGroup();
    final data4 = [
      { 'genre': 'Sports', 'sold': 275 },
      { 'genre': 'Strategy', 'sold': 115 },
      { 'genre': 'Action', 'sold': 120 },
      { 'genre': 'Shooter', 'sold': 350 },
      { 'genre': 'Other', 'sold': 150 },
    ];
    // final coord4 = CartesianCoordComponent(graphic.CartesianCoord());
    final coord4 = PolarCoordComponent(graphic.PolarCoord(
      innerRadius: 0.5,
    ));
    coord4.setRegion(Rect.fromLTWH(0, 0, 300, 300));
    final scales4 = <String, ScaleComponent>{
      'genre': StringCategoryScaleComponent(graphic.CatScale(
        values: ['Sports', 'Strategy', 'Action', 'Shooter', 'Other'],
        accessor: (map) => map['genre'] as String,
      )),
      'sold': NumLinearScaleComponent(graphic.NumberScale(
        min: 100,
        max: 400,
        accessor: (map) => map['sold'] as num,
      )),
    };
    final chart4 = ChartComponent()
      ..state.data = data4
      ..state.coord = coord4
      ..state.middlePlot = plot4
      ..state.scales = scales4;
    
    final geom4 = PointGeomComponent()
      ..state.chart = chart4
      ..setColor(graphic.ColorAttr(
        field: 'genre',
        values: [Colors.blue, Colors.red],
        isTween: true,
      ))
      ..setShape(graphic.ShapeAttr())
      ..setSize(graphic.SizeAttr())
      ..setPosition(graphic.PositionAttr(field: 'genre*sold'));
    
    geom4.render();

    r4.mount(() { setState(() {}); });

    // polygon

    final plot5 = r5.addGroup();
    final data5 = [
      [ '0', '0', 10 ],
      [ '0', '1', 19 ],
      [ '0', '2', 8 ],
      [ '0', '3', 24 ],
      [ '0', '4', 67 ],
      [ '1', '0', 92 ],
      [ '1', '1', 58 ],
      [ '1', '2', 78 ],
      [ '1', '3', 117 ],
      [ '1', '4', 48 ],
      [ '2', '0', 35 ],
      [ '2', '1', 15 ],
      [ '2', '2', 123 ],
      [ '2', '3', 64 ],
      [ '2', '4', 52 ],
      [ '3', '0', 72 ],
      [ '3', '1', 132 ],
      [ '3', '2', 114 ],
      [ '3', '3', 19 ],
      [ '3', '4', 16 ],
      [ '4', '0', 38 ],
      [ '4', '1', 5 ],
      [ '4', '2', 8 ],
      [ '4', '3', 117 ],
      [ '4', '4', 115 ],
      [ '5', '0', 88 ],
      [ '5', '1', 32 ],
      [ '5', '2', 12 ],
      [ '5', '3', 6 ],
      [ '5', '4', 120 ],
      [ '6', '0', 13 ],
      [ '6', '1', 44 ],
      [ '6', '2', 88 ],
      [ '6', '3', 98 ],
      [ '6', '4', 96 ],
      [ '7', '0', 31 ],
      [ '7', '1', 1 ],
      [ '7', '2', 82 ],
      [ '7', '3', 32 ],
      [ '7', '4', 30 ],
      [ '8', '0', 85 ],
      [ '8', '1', 97 ],
      [ '8', '2', 123 ],
      [ '8', '3', 64 ],
      [ '8', '4', 84 ],
      [ '9', '0', 47 ],
      [ '9', '1', 114 ],
      [ '9', '2', 31 ],
      [ '9', '3', 48 ],
      [ '9', '4', 91 ]
    ];
    // final coord5 = CartesianCoordComponent(graphic.CartesianCoord());
    final coord5 = PolarCoordComponent(graphic.PolarCoord(
      // innerRadius: 0.5,
    ));
    coord5.setRegion(Rect.fromLTWH(0, 0, 300, 300));
    final scales5 = <String, ScaleComponent>{
      'name': StringCategoryScaleComponent(graphic.CatScale(
        values: ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'],
        accessor: (list) => list[0] as String,
        // scaledRange: [0.05, 1 - 0.05],
        scaledRange: [0, 1 - 0.1],
      )),
      'day': StringCategoryScaleComponent(graphic.CatScale(
        values: ['0', '1', '2', '3', '4'],
        accessor: (list) => list[1] as String,
        // scaledRange: [0.1, 1 - 0.1],
        scaledRange: [0, 1 - 0.2],
      )),
      'sales': NumLinearScaleComponent(graphic.NumberScale(
        min: 0,
        max: 200,
        accessor: (list) => list[2] as num,
      )),
    };
    final chart5 = ChartComponent()
      ..state.data = data5
      ..state.coord = coord5
      ..state.middlePlot = plot5
      ..state.scales = scales5;
    
    final geom5 = PolygonGeomComponent()
      ..state.chart = chart5
      ..setColor(graphic.ColorAttr(
        field: 'sales',
        values: [Color(0xFFBAE7FF), Color(0xFF1890FF), Color(0xFF0050B3)],
        isTween: true,
      ))
      ..setShape(graphic.ShapeAttr())
      ..setSize(graphic.SizeAttr())
      ..setPosition(graphic.PositionAttr(field: 'name*day'));
    
    geom5.render();

    r5.mount(() { setState(() {}); });

    // schema

    final plot6 = r6.addGroup();
    final data6 = [
      { 'time': '2015-11-19', 'start': 8.18, 'max': 8.33, 'min': 7.98, 'end': 8.32, 'volumn': 1810, 'mony': 14723.56 },
      { 'time': '2015-11-18', 'start': 8.37, 'max': 8.6, 'min': 8.03, 'end': 8.09, 'volumn': 2790.37, 'mony': 23309.19 },
      { 'time': '2015-11-17', 'start': 8.7, 'max': 8.78, 'min': 8.32, 'end': 8.37, 'volumn': 3729.04, 'mony': 31709.71 },
      { 'time': '2015-11-16', 'start': 8.18, 'max': 8.69, 'min': 8.05, 'end': 8.62, 'volumn': 3095.44, 'mony': 26100.69 },
      { 'time': '2015-11-13', 'start': 8.01, 'max': 8.75, 'min': 7.97, 'end': 8.41, 'volumn': 5815.58, 'mony': 48562.37 },
      { 'time': '2015-11-12', 'start': 7.76, 'max': 8.18, 'min': 7.61, 'end': 8.15, 'volumn': 4742.6, 'mony': 37565.36 },
      { 'time': '2015-11-11', 'start': 7.55, 'max': 7.81, 'min': 7.49, 'end': 7.8, 'volumn': 3133.82, 'mony': 24065.42 },
      { 'time': '2015-11-10', 'start': 7.5, 'max': 7.68, 'min': 7.44, 'end': 7.57, 'volumn': 2670.35, 'mony': 20210.58 },
      { 'time': '2015-11-09', 'start': 7.65, 'max': 7.66, 'min': 7.3, 'end': 7.58, 'volumn': 2841.79, 'mony': 21344.36 },
      { 'time': '2015-11-06', 'start': 7.52, 'max': 7.71, 'min': 7.48, 'end': 7.64, 'volumn': 2725.44, 'mony': 20721.51 },
      { 'time': '2015-11-05', 'start': 7.48, 'max': 7.57, 'min': 7.29, 'end': 7.48, 'volumn': 3520.85, 'mony': 26140.83 },
      { 'time': '2015-11-04', 'start': 7.01, 'max': 7.5, 'min': 7.01, 'end': 7.46, 'volumn': 3591.47, 'mony': 26285.52 },
      { 'time': '2015-11-03', 'start': 7.1, 'max': 7.17, 'min': 6.82, 'end': 7, 'volumn': 2029.21, 'mony': 14202.33 },
      { 'time': '2015-11-02', 'start': 7.09, 'max': 7.44, 'min': 6.93, 'end': 7.17, 'volumn': 3191.31, 'mony': 23205.11 },
      { 'time': '2015-10-30', 'start': 6.98, 'max': 7.27, 'min': 6.84, 'end': 7.18, 'volumn': 3522.61, 'mony': 25083.44 },
      { 'time': '2015-10-29', 'start': 6.94, 'max': 7.2, 'min': 6.8, 'end': 7.05, 'volumn': 2752.27, 'mony': 19328.44 },
      { 'time': '2015-10-28', 'start': 7.01, 'max': 7.14, 'min': 6.8, 'end': 6.85, 'volumn': 2311.11, 'mony': 16137.32 },
      { 'time': '2015-10-27', 'start': 6.91, 'max': 7.31, 'min': 6.48, 'end': 7.18, 'volumn': 3172.9, 'mony': 21827.3 },
      { 'time': '2015-10-26', 'start': 6.9, 'max': 7.08, 'min': 6.87, 'end': 6.95, 'volumn': 2769.31, 'mony': 19337.44 },
      { 'time': '2015-10-23', 'start': 6.71, 'max': 6.85, 'min': 6.58, 'end': 6.79, 'volumn': 2483.18, 'mony': 16714.31 },
      { 'time': '2015-10-22', 'start': 6.38, 'max': 6.67, 'min': 6.34, 'end': 6.65, 'volumn': 2225.88, 'mony': 14465.56 },
    ];
    final coord6 = CartesianCoordComponent(graphic.CartesianCoord());
    coord6.setRegion(Rect.fromLTWH(0, 0, 300, 300));
    final scales6 = <String, ScaleComponent>{
      'time': DateTimeOrdinalScaleComponent(graphic.TimeScale(
        stringAccessor: (map) => map['time'] as String,
        stringValues: data6.map((map) => map['time'] as String).toList(),
      )),
      'start': NumLinearScaleComponent(graphic.NumberScale(
        min: 6,
        max: 9,
        accessor: (map) => map['start'] as num,
      )),
      'max': NumLinearScaleComponent(graphic.NumberScale(
        min: 6,
        max: 9,
        accessor: (map) => map['max'] as num,
      )),
      'min': NumLinearScaleComponent(graphic.NumberScale(
        min: 6,
        max: 9,
        accessor: (map) => map['min'] as num,
      )),
      'end': NumLinearScaleComponent(graphic.NumberScale(
        min: 6,
        max: 9,
        accessor: (map) => map['end'] as num,
      )),
    };
    final chart6 = ChartComponent()
      ..state.data = data6
      ..state.coord = coord6
      ..state.middlePlot = plot6
      ..state.scales = scales6;
    
    final geom6 = SchemaGeomComponent()
      ..state.chart = chart6
      ..setColor(graphic.ColorAttr())
      ..setShape(graphic.ShapeAttr())
      ..setSize(graphic.SizeAttr())
      ..setPosition(graphic.PositionAttr(field: 'time*start*end*max*min'));
    
    geom6.render();

    r6.mount(() { setState(() {}); });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Geom'),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              Container(
                width: 300,
                height: 300,
                color: Colors.green,
                child: CustomPaint(
                  painter: r1.painter,
                ),
                margin: EdgeInsets.all(20),
              ),
              Container(
                width: 300,
                height: 300,
                color: Colors.green,
                child: CustomPaint(
                  painter: r2.painter,
                ),
                margin: EdgeInsets.all(20),
              ),
              Container(
                width: 300,
                height: 300,
                color: Colors.green,
                child: CustomPaint(
                  painter: r3.painter,
                ),
                margin: EdgeInsets.all(20),
              ),
              Container(
                width: 300,
                height: 300,
                color: Colors.green,
                child: CustomPaint(
                  painter: r4.painter,
                ),
                margin: EdgeInsets.all(20),
              ),
              Container(
                width: 300,
                height: 300,
                color: Colors.green,
                child: CustomPaint(
                  painter: r5.painter,
                ),
                margin: EdgeInsets.all(20),
              ),
              Container(
                width: 300,
                height: 300,
                color: Colors.green,
                child: CustomPaint(
                  painter: r6.painter,
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
