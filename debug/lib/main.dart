import 'package:flutter/material.dart';

import 'home.dart';
import 'pages/render_shape_page.dart';
import 'pages/geom_page.dart';
import 'pages/axis_page.dart';

final routes = {
  '/': (context) => HomePage(),
  '/demos/render_shape': (context) => RenderShapePage(),
  '/demos/geom': (context) => GeomPage(),
  '/demos/axis': (context) => AxisPage(),
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
