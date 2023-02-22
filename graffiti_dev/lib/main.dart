import 'package:flutter/material.dart';

import 'home.dart';
import 'pages/shape.dart';

final routes = {
  '/': (context) => const HomePage(),
  '/examples/Shapes': (context) => ShapePage(),
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
