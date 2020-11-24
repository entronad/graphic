import 'package:flutter/material.dart';

import 'home.dart';
import 'pages/interval_page.dart';
import 'pages/line_area_page.dart';
import 'pages/point_polygon_schema_page.dart';
import 'pages/custom_shape_page.dart';
import 'pages/big_data_page.dart';
import 'pages/interaction_page.dart';

final routes = {
  '/': (context) => HomePage(),
  '/demos/Interval': (context) => IntervalPage(),
  '/demos/Line, Area': (context) => LineAreaPage(),
  '/demos/Point, Polygon, Schema': (context) => PointPolygonSchemaPage(),
  '/demos/Custom Shape': (context) => CustomShapePage(),
  '/demos/Big Data': (context) => BigDataPage(),
  '/demos/Interaction': (context) => InteractionPage(),
};

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: routes,
      initialRoute: '/',
    );
  }
}

void main() => runApp(MyApp());
