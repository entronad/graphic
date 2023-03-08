import 'package:flutter/material.dart';

import 'home.dart';
import 'pages/bigdata.dart';
import 'pages/debug.dart';
import 'pages/echarts.dart';
import 'pages/interaction_stream_dynamic.dart';
import 'pages/interval.dart';
import 'pages/line_area_point.dart';
import 'pages/polygon_custom.dart';

final routes = {
  '/': (context) => const HomePage(),
  '/examples/Interval Mark': (context) => IntervalPage(),
  '/examples/Line,Area,Point Mark': (context) => LineAreaPointPage(),
  '/examples/Polygon,Custom Mark': (context) => PolygonCustomPage(),
  '/examples/Interaction Stream, Dynamic': (context) =>
      const InteractionStreamDynamicPage(),
  '/examples/Bigdata': (context) => BigdataPage(),
  '/examples/Echarts': (context) => EchartsPage(),
  '/examples/Debug': (context) => const DebugPage(),
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
