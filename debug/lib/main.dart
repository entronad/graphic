import 'package:flutter/material.dart';

import 'home.dart';
import 'pages/chart_page.dart';
import 'pages/adjust_page.dart';
import 'pages/shape_page.dart';
import 'pages/invalid_page.dart';

final routes = {
  '/': (context) => HomePage(),
  '/demos/chart': (context) => ChartPage(),
  '/demos/adjust': (context) => AdjustPage(),
  '/demos/shape': (context) => ShapePage(),
  '/demos/invalid': (context) => InvalidPage(),
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
