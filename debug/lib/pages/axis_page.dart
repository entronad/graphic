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
import 'package:graphic/src/axis/base.dart';
import 'package:graphic/src/axis/horizontal.dart';
import 'package:graphic/src/axis/vertical.dart';
import 'package:graphic/src/axis/radial.dart';
import 'package:graphic/src/axis/circular.dart';
import 'package:graphic/src/common/styles.dart';

class AxisPage extends StatefulWidget {
  @override
  _AxisPageState createState() => _AxisPageState();
}

class _AxisPageState extends State<AxisPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  graphic.Renderer r1 = graphic.Renderer();
  graphic.Renderer r2 = graphic.Renderer();

  @override
  void initState() {
    super.initState();

    // Cartesian

    final backPlot1 = r1.addGroup();
    final plot1 = r1.addGroup();
    final frontPlot1 = r1.addGroup();
    final data1 = [
      { 'genre': 'Sports', 'sold': 275 },
      { 'genre': 'Strategy', 'sold': 115 },
      { 'genre': 'Action', 'sold': 120 },
      { 'genre': 'Shooter', 'sold': 350 },
      { 'genre': 'Other', 'sold': 150 },
    ];
    final coord1 = CartesianCoordComponent(graphic.CartesianCoord());
    coord1.setRegion(Rect.fromLTWH(20, 0, 280, 280));
    final scaleX1 = StringCategoryScaleComponent(graphic.CatScale(
      values: ['Sports', 'Strategy', 'Action', 'Shooter', 'Other'],
      accessor: (map) => map['genre'] as String,
      range: [1 / 10, 1 - 1 / 10],
      // range: [0, 1 - 0.2],
    ));
    final scaleY1 = NumLinearScaleComponent(graphic.NumScale(
      min: 100,
      max: 400,
      accessor: (map) => map['sold'] as num,
    ));
    final scales1 = <String, ScaleComponent>{
      'genre': scaleX1,
      'sold': scaleY1,
    };
    final chart1 = ChartComponent()
      ..state.data = data1
      ..state.coord = coord1
      ..state.middlePlot = plot1
      ..state.frontPlot = frontPlot1
      ..state.backPlot = backPlot1
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

    final axisX1 = HorizontalAxisComponent()
      ..state.position = 0
      ..state.line = AxisLine(style: LineStyle(color: Colors.grey))
      ..state.tickLine = AxisTickLine(length: 5, style: LineStyle(color: Colors.grey))
      ..state.grid = null
      ..state.label = AxisLabel(offset: Offset(0, 5), style: TextStyle(fontSize: 8, color: Colors.black))
      ..state.chart = chart1
      ..state.scale = scaleX1;
    
    axisX1.render();

    final axisY1 = VerticalAxisComponent()
      ..state.position = 0
      ..state.line = null
      ..state.tickLine = null
      ..state.grid = AxisGrid(style: LineStyle(color: Colors.grey[350]))
      ..state.label = AxisLabel(style: TextStyle(fontSize: 8, color: Colors.black))
      ..state.chart = chart1
      ..state.scale = scaleY1;
    
    axisY1.render();

    r1.mount(() { setState(() {}); });

    // Polar

    final backPlot2 = r2.addGroup();
    final plot2 = r2.addGroup();
    final frontPlot2 = r2.addGroup();
    final data2 = [
      { 'genre': 'Sports', 'sold': 275 },
      { 'genre': 'Strategy', 'sold': 115 },
      { 'genre': 'Action', 'sold': 120 },
      { 'genre': 'Shooter', 'sold': 350 },
      { 'genre': 'Other', 'sold': 150 },
    ];
    final coord2 = PolarCoordComponent(graphic.PolarCoord(
      // transposed: true,
      // innerRadius: 0.3,
    ));
    coord2.setRegion(Rect.fromLTWH(20, 0, 280, 280));
    final scaleX2 = StringCategoryScaleComponent(graphic.CatScale(
      values: ['Sports', 'Strategy', 'Action', 'Shooter', 'Other'],
      accessor: (map) => map['genre'] as String,
      range: [0, 1 - 0.2],
    ));
    final scaleY2 = NumLinearScaleComponent(graphic.NumScale(
      min: 100,
      max: 400,
      accessor: (map) => map['sold'] as num,
    ));
    final scales2 = <String, ScaleComponent>{
      'genre': scaleX2,
      'sold': scaleY2,
    };
    final chart2 = ChartComponent()
      ..state.data = data2
      ..state.coord = coord2
      ..state.middlePlot = plot2
      ..state.frontPlot = frontPlot2
      ..state.backPlot = backPlot2
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

    final axisX2 = CircularAxisComponent()
      ..state.position = 1
      ..state.line = AxisLine(style: LineStyle(color: Colors.grey))
      ..state.tickLine = AxisTickLine(length: 5, style: LineStyle(color: Colors.grey))
      ..state.grid = AxisGrid(style: LineStyle(color: Colors.grey))
      ..state.label = AxisLabel(offset: Offset(0, 5), style: TextStyle(fontSize: 12, color: Colors.black))
      ..state.chart = chart2
      ..state.scale = scaleX2;
    
    axisX2.render();

    final axisY2 = RadialAxisComponent()
      ..state.position = 0
      ..state.line = AxisLine(style: LineStyle(color: Colors.grey))
      ..state.tickLine = null
      ..state.grid = AxisGrid(style: LineStyle(color: Colors.grey[350]))
      ..state.label = AxisLabel(style: TextStyle(fontSize: 12, color: Colors.black))
      ..state.chart = chart2
      ..state.scale = scaleY2;
    
    axisY2.render();

    r2.mount(() { setState(() {}); });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Axis'),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              Container(
                width: 300,
                height: 300,
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
            ],
          ),
        ),
      ),
    );
  }
}
