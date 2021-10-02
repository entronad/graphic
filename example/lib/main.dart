import 'package:flutter/material.dart';

import 'home.dart';
import 'pages/debug_page.dart';
import 'pages/debug_bigdata_page.dart';

final routes = {
  '/': (context) => HomePage(),
  '/demos/Debug': (context) => DebugPage(),
  '/demos/DebugBigdata': (context) => DebugBigdataPage(),
};

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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

void main() => runApp(const MyApp());
