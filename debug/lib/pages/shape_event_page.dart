import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart' as graphic;

class ShapeEventPage extends StatefulWidget {
  @override
  _ShapeEventPageState createState() => _ShapeEventPageState();
}

class _ShapeEventPageState extends State<ShapeEventPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final graphic.Renderer renderer = graphic.Renderer();

  @override
  void initState() {
    super.initState();

    final circle = renderer.addShape(graphic.Cfg(
      type: graphic.ShapeType.circle,
      attrs: graphic.Attrs(
        x: 200,
        y: 200,
        r: 100,
        color: Color(0xff1890ff),
        strokeWidth: 4,
        style: PaintingStyle.stroke,
      ),
    ));

    circle.on(type: graphic.EventType.longPressStart, callback: (_) {
      circle.attr(graphic.Attrs(color: Color(0xff2fc25b)));
    });
    circle.on(type: graphic.EventType.longPressEnd, callback: (_) {
      circle.attr(graphic.Attrs(color: Color(0xff1890ff)));
    });
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
