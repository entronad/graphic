import 'package:flutter/material.dart';

import 'home.dart';
import 'pages/basic.dart';

final routes = {
  '/': (context) => HomePage(),
  '/demos/basic': (context) => Basic(),
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
