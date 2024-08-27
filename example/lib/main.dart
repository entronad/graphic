import 'package:flutter/material.dart';
import 'package:graphic_example/pages/crosshair.dart';

import 'home.dart';
import 'pages/bigdata.dart';
import 'pages/debug.dart';
import 'pages/echarts.dart';
import 'pages/interaction_stream_dynamic.dart';
import 'pages/interval.dart';
import 'pages/line_area_point.dart';
import 'pages/polygon_custom.dart';
import 'pages/animation.dart';

final routes = {
  '/': (context) => const HomePage(),
  '/examples/Interval': (context) => IntervalPage(),
  '/examples/Line,Area,Point': (context) => LineAreaPointPage(),
  '/examples/Polygon,Custom': (context) => PolygonCustomPage(),
  '/examples/Interaction Stream, Dynamic': (context) =>
      const InteractionStreamDynamicPage(),
  '/examples/Animation': (context) => const AnimationPage(),
  '/examples/Bigdata': (context) => BigdataPage(),
  '/examples/Echarts': (context) => EchartsPage(),
  '/examples/Crosshair': (context) => const CrosshairPage(),
  '/examples/Debug': (context) => DebugPage(),
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
