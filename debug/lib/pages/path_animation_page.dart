import 'dart:ui' show Offset, Radius;

import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart' as graphic;

class PathAnimationPage extends StatefulWidget {
  @override
  _PathAnimationPageState createState() => _PathAnimationPageState();
}

class _PathAnimationPageState extends State<PathAnimationPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final graphic.Renderer renderer = graphic.Renderer();

  @override
  void initState() {
    super.initState();

    final path = renderer.addShape(graphic.Cfg(
      type: graphic.ShapeType.path,
      attrs: graphic.Attrs(
        pathCommands: [
          graphic.MoveTo(100, 300),
          graphic.RelativeLineTo(50, -25),
          graphic.RelativeArcToPoint(Offset(50, -25), radius: Radius.circular(25), rotation: -30, largeArc: false, clockwise: true),
          graphic.RelativeLineTo(50, -25),
          graphic.RelativeArcToPoint(Offset(50, -25), radius: Radius.elliptical(25, 50), rotation: -30, largeArc: false, clockwise: true),
          graphic.RelativeLineTo(50, -25),
          graphic.RelativeArcToPoint(Offset(50, -25), radius: Radius.elliptical(25, 75), rotation: -30, largeArc: false, clockwise: true),
          graphic.RelativeLineTo(50, -25),
          graphic.RelativeArcToPoint(Offset(50, -25), radius: Radius.elliptical(25, 100), rotation: -30, largeArc: false, clockwise: true),
          graphic.RelativeLineTo(50, -25),
          graphic.RelativeLineTo(0, 200),
          graphic.Close(),
        ],
        color: Color(0xff1890ff),
        strokeWidth: 4,
        style: PaintingStyle.stroke,
      ),
    ));

    final circle = renderer.addShape(graphic.Cfg(
      type: graphic.ShapeType.circle,
      attrs: graphic.Attrs(
        x: 100,
        y: 300,
        r: 20,
        color: Color(0xfff04864),
        style: PaintingStyle.fill,
      ),
    ));

    circle.animate(
      onFrame: (ratio) {
        final point = path.getPoint(ratio);
        return graphic.Attrs(
          x: point.dx,
          y: point.dy,
        );
      },
      animationCfg: graphic.AnimationCfg(
        duration: Duration(seconds: 5),
        repeat: true,
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('shape'),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              Container(
                width: 500,
                height: 500,
                child: graphic.Canvas(
                  renderer: renderer,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
