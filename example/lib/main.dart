import 'package:flutter/material.dart';

import 'home.dart';
import 'pages/rectangle_interval.dart';
import 'pages/polar_interval.dart';
import 'pages/line_area.dart';
import 'pages/point.dart';
import 'pages/polygon.dart';
import 'pages/custom.dart';
import 'pages/dynamic.dart';
import 'pages/bigdata.dart';
import 'pages/echarts.dart';
// import 'pages/debug.dart';

final routes = {
  '/': (context) => const HomePage(),
  '/examples/Rectangle Interval Element': (context) => RectangleIntervalPage(),
  '/examples/Polar Interval Element': (context) => PolarIntervalPage(),
  '/examples/Line and Area Element': (context) => LineAreaPage(),
  '/examples/Point Element': (context) => PointPage(),
  '/examples/Polygon Element': (context) => PolygonPage(),
  '/examples/Dynamic': (context) => const DynamicPage(),
  '/examples/Custom': (context) => CustomPage(),
  '/examples/Bigdata': (context) => BigdataPage(),
  '/examples/Echarts': (context) => EchartsPage(),
  // '/examples/Debug': (context) => DebugPage(),
};

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: routes,
      initialRoute: '/',
    );
  }
}

void main() => runApp(const MyApp());
