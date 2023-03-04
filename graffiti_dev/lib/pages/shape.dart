import 'dart:math';

import 'package:graffiti_dev/graffiti/element/arc.dart';
import 'package:graffiti_dev/graffiti/element/circle.dart';
import 'package:graffiti_dev/graffiti/element/spline.dart';
import 'package:graffiti_dev/graffiti/element/group.dart';
import 'package:graffiti_dev/graffiti/element/label.dart';
import 'package:graffiti_dev/graffiti/element/oval.dart';
import 'package:graffiti_dev/graffiti/element/path.dart';
import 'package:graffiti_dev/graffiti/element/polygon.dart';
import 'package:graffiti_dev/graffiti/element/polyline.dart';
import 'package:graffiti_dev/graffiti/element/rect.dart';
import 'package:graffiti_dev/graffiti/element/sector.dart';
import 'package:graffiti_dev/graffiti/element/segment/arc.dart';
import 'package:graffiti_dev/graffiti/element/segment/arc_to_point.dart';
import 'package:graffiti_dev/graffiti/element/segment/close.dart';
import 'package:graffiti_dev/graffiti/element/segment/conic.dart';
import 'package:graffiti_dev/graffiti/element/segment/cubic.dart';
import 'package:graffiti_dev/graffiti/element/segment/line.dart';
import 'package:graffiti_dev/graffiti/element/segment/move.dart';
import 'package:graffiti_dev/graffiti/element/segment/quadratic.dart';
import 'package:graffiti_dev/graffiti/graffiti.dart';
import 'package:graffiti_dev/graffiti/element/line.dart';
import 'package:graffiti_dev/graffiti/element/element.dart';
import 'package:flutter/material.dart';
import 'package:graffiti_dev/graffiti/scene.dart';
import 'package:graffiti_dev/graffiti/transition.dart';

List<List<double>> getPointBigData(int n) {
  final rdm = Random();

  final rst = <List<double>>[];
  for (var i = 0; i < n; i++) {
    rst.add([
      rdm.nextDouble() * 5000,
      rdm.nextDouble() * 5000,
      rdm.nextDouble() * 5000,
      rdm.nextDouble() * 5000,
    ]);
  }

  return rst;
}

final points1 = getPointBigData(100000).map((e) => Offset(e[0], e[1])).toList();

final points2 = getPointBigData(100000).map((e) => Offset(e[0], e[1])).toList();

final cubics = getPointBigData(100000).map((e) => [Offset(e[0], e[2]), Offset(e[1], e[3]), Offset(e[0], e[2])]).toList();

class ShapePage extends StatefulWidget {
  const ShapePage({super.key});

  @override
  State<ShapePage> createState() => _ShapePageState();
}

// final style = PaintStyle(strokeColor: Colors.black);
final style = PaintStyle(fillColor: Colors.black);

class _ShapePageState extends State<ShapePage> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late final Graffiti graffiti;

  late final Scene scene;

  void repaint() {
    setState(() {});
  }

  @override
  void initState() {
    graffiti = Graffiti(tickerProvider: this, repaint: repaint);

    scene = graffiti.createScene(transition: Transition(duration: Duration(seconds: 2)));

    // final a = SplineElement(start: Offset(10, 10), cubics: [
    //   [Offset(20, 10), Offset(10, 20), Offset(20, 20)],
    //   [Offset(60, 30), Offset(10, 50), Offset(40, 40)],
    //   [Offset(40, 70), Offset(10, 40), Offset(80, 70)],
    // ], style: style);

    // final a = RectElement(rect: Rect.fromPoints(Offset(10, 10), Offset(100, 100)), borderRadius: BorderRadius.all(Radius.circular(20)), style: style);

    // final b = CircleElement(center: Offset(150, 50), radius: 30, style: style);

    // final n = nomalizeElement(a, b);

    // final start = Offset(100, 100);
    // final s = ArcToPointSegment(end: Offset(100, 200), radius: Radius.elliptical(0, 55));
    // final s = ArcSegment(oval: Rect.fromPoints(Offset(0, 50), Offset(150, 200)), startAngle: - pi / 2, endAngle: pi / 2);
    // final s = QuadraticSegment(control: Offset(300, 100), end: Offset(200, 200));
    // final s = ConicSegment(control: Offset(300, 100), end: Offset(200, 200), weight: 0.8);
    // final c = s.toCubic(start);

    // final e = ArcElement(oval: Rect.fromPoints(Offset(100, 100), Offset(200, 200)), startAngle: 2, endAngle: 4, style: style);
    // final segments = e.toSegments();
    // final start = (segments[0] as MoveSegment).end;
    // final s = segments[1];
    // final c = s.toCubic(start);

    // scene.set([
      // LineElement(start: Offset(0, 0), end: Offset(50, 50), style: PaintStyle(strokeColor: Colors.black)),
      // ArcElement(oval: Rect.fromCircle(center: Offset(100, 100), radius: 50), startAngle: 0, endAngle: pi, style: PaintStyle(strokeColor: Colors.black)),
      // CircleElement(center: Offset(50, 50), radius: 30, style: style),
      // GroupElement(elements: [LineElement(start: Offset(0, 0), end: Offset(50, 50), style: PaintStyle(strokeColor: Colors.black)),CircleElement(center: Offset(50, 50), radius: 30, style: style)]),
      // LabelElement(text: 'text', anchor: Offset(50, 50), defaultAlign: Alignment.center, style: LabelStyle(textStyle: TextStyle())),
      // OvalElement(oval: Rect.fromCircle(center: Offset(100, 100), radius: 50), style: style),
      // PolygonElement(points: [Offset(0, 0), Offset(10, 10), Offset(30, 60)], close: true, style: style),
      // RectElement(rect: Rect.fromPoints(Offset(0, 0), Offset(100, 100)), borderRadius: BorderRadius.all(Radius.circular(5)), style: style),
      // SectorElement(center: Offset(100, 100), startRadius: 20, endRadius: 80, startAngle: 0, endAngle: 3, borderRadius: BorderRadius.all(Radius.circular(10)), style: style)
      // GroupElement(elements: [
      //   LineElement(start: Offset(0, 0), end: Offset(50, 50), style: PaintStyle(strokeColor: Colors.black)),
      //   ArcElement(oval: Rect.fromCircle(center: Offset(100, 100), radius: 50), startAngle: 0, endAngle: pi, style: PaintStyle(strokeColor: Colors.black)),
      //   CircleElement(center: Offset(50, 50), radius: 30, style: style),
      //   GroupElement(elements: [LineElement(start: Offset(0, 0), end: Offset(50, 50), style: PaintStyle(strokeColor: Colors.black)),CircleElement(center: Offset(50, 50), radius: 30, style: style)]),
      //   LabelElement(text: 'text', anchor: Offset(50, 50), defaultAlign: Alignment.center, style: LabelStyle(textStyle: TextStyle())),
      //   OvalElement(oval: Rect.fromCircle(center: Offset(100, 100), radius: 50), style: style),
      //   PolygonElement(points: [Offset(0, 0), Offset(10, 10), Offset(30, 60)], close: true, style: style),
      //   RectElement(rect: Rect.fromPoints(Offset(0, 0), Offset(100, 100)), borderRadius: BorderRadius.all(Radius.circular(5)), style: style),
      //   SectorElement(center: Offset(100, 100), startRadius: 20, endRadius: 80, startAngle: 0, endAngle: 3, borderRadius: BorderRadius.all(Radius.circular(10)), style: style),
      // ])
      // PathElement(segments: [
      //   MoveSegment(end: Offset(10, 10)),
      //   // ArcToPointSegment(end: Offset(40, 40), radius: Radius.circular(30)),
      //   // ArcSegment(oval: Rect.fromPoints(Offset(0, 0), Offset(100, 100)), startAngle: 3, endAngle: 5),
      //   // ConicSegment(control: Offset(20, 20), end: Offset(40, 70), weight: 0.6),
      //   LineSegment(end: Offset(50, 110)),
      //   MoveSegment(end: Offset(20, 20)),
      //   // CubicSegment(control1: Offset(0, 50), control2: Offset(66, 0), end: Offset(100, 100)),
      //   QuadraticSegment(control: Offset(0, 50), end: Offset(100, 100)),
      //   CloseSegment(),
      // ], style: style),
      // a,
      // b,
      // e,
    //   PathElement(segments: [
    //     MoveSegment(end: start),
    //     s,
    //   ], style: style),
    //   PathElement(segments: [
    //     MoveSegment(end: start),
    //     c,
    //   ], style: style)
    // ]);

    // scene.set([ArcElement(oval: Rect.fromPoints(Offset(100, 100), Offset(200, 200)), startAngle: 2, endAngle: 4, style: style)]);

    scene.set([RectElement(rect: Rect.fromPoints(Offset(0, 0), Offset(500, 500)), style: style)], CircleElement(center: Offset(150, 150), radius: 70));

    // scene.set([PolylineElement(points: points1, style: style)], CircleElement(center: Offset(150, 150), radius: 70, style: style));

    graffiti.update();

    super.initState();
  }

  void _update() {
    // scene.set([LineElement(start: Offset(300, 300), end: Offset(350, 350), style: PaintStyle(strokeColor: Colors.black))]);
    // scene.set([CircleElement(center: Offset(150, 150), radius: 70, style: style)]);
    // scene.set([
    //   GroupElement(elements: [
    //     LineElement(start: Offset(0, 0), end: Offset(50, 50), style: PaintStyle(strokeColor: Colors.black)),
    //     ArcElement(oval: Rect.fromCircle(center: Offset(100, 100), radius: 50), startAngle: 0, endAngle: pi, style: PaintStyle(strokeColor: Colors.black)),
    //     CircleElement(center: Offset(50, 50), radius: 30, style: style),
    //     GroupElement(elements: [LineElement(start: Offset(0, 0), end: Offset(50, 50), style: PaintStyle(strokeColor: Colors.black)),CircleElement(center: Offset(50, 50), radius: 30, style: style)]),
    //     LabelElement(text: 'text', anchor: Offset(50, 50), defaultAlign: Alignment.center, style: LabelStyle(textStyle: TextStyle())),
    //     OvalElement(oval: Rect.fromCircle(center: Offset(100, 100), radius: 50), style: style),
    //     PolygonElement(points: [Offset(0, 0), Offset(10, 10), Offset(30, 60)], style: style),
    //     RectElement(rect: Rect.fromPoints(Offset(0, 0), Offset(100, 100)), borderRadius: BorderRadius.all(Radius.circular(5)), style: style),
    //     SectorElement(center: Offset(100, 100), startRadius: 20, endRadius: 80, startAngle: 0, endAngle: 3, borderRadius: BorderRadius.all(Radius.circular(10)), style: style),
    //   ])
    // ]);
    // scene.set([PathElement(segments: [
    //   MoveSegment(end: Offset(100, 100)),
    //   LineSegment(end: Offset(200, 200), tag: 'top'),
    //   LineSegment(end: Offset(50, 500)),
    //   CloseSegment(),
    // ], style: style)]);
    // scene.set([CircleElement(center: Offset(150, 150), radius: 50, style: style)]);
    // scene.set([SectorElement(center: Offset(150, 150), startRadius: 10, endRadius: 60, startAngle: 0, endAngle: 3, style: style)]);

    // scene.set([PolygonElement(points: points2, style: style)]);

    // scene.set([SplineElement(start: Offset(500, 500), cubics: cubics, style: style)], RectElement(rect: Rect.fromPoints(Offset(0, 0), Offset(100, 100)), borderRadius: BorderRadius.all(Radius.circular(5)), style: style));
    scene.set([RectElement(rect: Rect.fromPoints(Offset(0, 0), Offset(500, 500)), style: style)], RectElement(rect: Rect.fromPoints(Offset(0, 0), Offset(100, 100)), borderRadius: BorderRadius.all(Radius.circular(5))));
    graffiti.update();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text(''),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              Container(
                width: 350,
                height: 300,
                child: CustomPaint(painter: _Painter(graffiti)),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _update,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    graffiti.dispose();
    super.dispose();
  }
}

class _Painter extends CustomPainter {
  _Painter(this.graffiti);

  final Graffiti graffiti;

  @override
  void paint(Canvas canvas, Size size) {
    graffiti.paint(canvas);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
