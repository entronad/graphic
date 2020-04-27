import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart' as graphic;

class ShapePage extends StatefulWidget {
  @override
  _ShapePageState createState() => _ShapePageState();
}

class _ShapePageState extends State<ShapePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final graphic.Renderer renderer = graphic.Renderer();

  @override
  void initState() {
    super.initState();

    renderer.addShape(graphic.Cfg(
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
