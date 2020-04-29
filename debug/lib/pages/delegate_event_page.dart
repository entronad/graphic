import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart' as graphic;

class DelegateEventPage extends StatefulWidget {
  @override
  _DelegateEventPageState createState() => _DelegateEventPageState();
}

class _DelegateEventPageState extends State<DelegateEventPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final graphic.Renderer renderer = graphic.Renderer();

  @override
  void initState() {
    super.initState();

    final group = renderer.addGroup();

    final circle = group.addShape(graphic.Cfg(
      type: graphic.ShapeType.circle,
      name: 'circle',
      attrs: graphic.Attrs(
        x: 200,
        y: 200,
        r: 100,
        color: Color(0xff1890ff),
        strokeWidth: 4,
        style: PaintingStyle.fill,
      ),
    ));

    group.on(
      type: graphic.EventType.longPressStart,
      name: 'circle',
      callback: (_) {
        circle.attr(graphic.Attrs(color: Color(0xff2fc25b)));
      }
    );
    group.on(
      type: graphic.EventType.longPressEnd,
      name: 'circle',
      callback: (_) {
        circle.attr(graphic.Attrs(color: Color(0xff1890ff)));
      }
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
