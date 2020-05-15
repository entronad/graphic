import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart' as graphic;

class TransformPage extends StatefulWidget {
  @override
  _TransformPageState createState() => _TransformPageState();
}

class _TransformPageState extends State<TransformPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final graphic.Renderer r1 = graphic.Renderer();
  final graphic.Renderer r2 = graphic.Renderer();
  final graphic.Renderer r3 = graphic.Renderer();

  @override
  void initState() {
    super.initState();

    r1.addShape(graphic.Cfg(
      type: graphic.ShapeType.circle,
      attrs: graphic.Attrs(
        x: 50,
        y: 50,
        r: 50,
        color: Color(0xff1890ff),
        strokeWidth: 4,
        style: PaintingStyle.stroke,
      ),
    ));

    final ellipse = r1.addShape(graphic.Cfg(
      type: graphic.ShapeType.ellipse,
      attrs: graphic.Attrs(
        x: 260,
        y: 50,
        rx: 55,
        ry: 35,
        color: Color(0xff1890ff),
        strokeWidth: 10,
        style: PaintingStyle.stroke,
      ),
    ));

    // ellipse.translate(100, 100);
    // ellipse.rotateAtPoint(Offset(0, 0), 2);
    // ellipse.scale(0.5);

    // ---------------------------------------

    r2.addShape(graphic.Cfg(
      type: graphic.ShapeType.marker,
      attrs: graphic.Attrs(
        x: 50,
        y: 50,
        r: 40,
        color: Color(0xff1890ff),
        symbol: graphic.Symbols.circle,
      ),
    ));
    r2.addShape(graphic.Cfg(
      type: graphic.ShapeType.marker,
      attrs: graphic.Attrs(
        x: 150,
        y: 50,
        r: 40,
        color: Color(0xff1890ff),
        style: PaintingStyle.stroke,
        symbol: graphic.Symbols.circle,
      ),
    ));

    r2.addShape(graphic.Cfg(
      type: graphic.ShapeType.marker,
      attrs: graphic.Attrs(
        x: 250,
        y: 50,
        r: 40,
        color: Color(0xff1890ff),
        symbol: graphic.Symbols.diamond,
      ),
    ));
    r2.addShape(graphic.Cfg(
      type: graphic.ShapeType.marker,
      attrs: graphic.Attrs(
        x: 350,
        y: 50,
        r: 40,
        color: Color(0xff1890ff),
        style: PaintingStyle.stroke,
        symbol: graphic.Symbols.diamond,
      ),
    ));
    r2.addShape(graphic.Cfg(
      type: graphic.ShapeType.marker,
      attrs: graphic.Attrs(
        x: 50,
        y: 150,
        r: 40,
        color: Color(0xff1890ff),
        symbol: graphic.Symbols.square,
      ),
    ));
    r2.addShape(graphic.Cfg(
      type: graphic.ShapeType.marker,
      attrs: graphic.Attrs(
        x: 150,
        y: 150,
        r: 40,
        color: Color(0xff1890ff),
        style: PaintingStyle.stroke,
        symbol: graphic.Symbols.square,
      ),
    ));
    r2.addShape(graphic.Cfg(
      type: graphic.ShapeType.marker,
      attrs: graphic.Attrs(
        x: 50,
        y: 250,
        r: 40,
        color: Color(0xff1890ff),
        symbol: graphic.Symbols.triangle,
      ),
    ));
    r2.addShape(graphic.Cfg(
      type: graphic.ShapeType.marker,
      attrs: graphic.Attrs(
        x: 150,
        y: 250,
        r: 40,
        color: Color(0xff1890ff),
        style: PaintingStyle.stroke,
        symbol: graphic.Symbols.triangle,
      ),
    ));
    r2.addShape(graphic.Cfg(
      type: graphic.ShapeType.marker,
      attrs: graphic.Attrs(
        x: 50,
        y: 350,
        r: 40,
        color: Color(0xff1890ff),
        symbol: graphic.Symbols.triangleDown,
      ),
    ));
    r2.addShape(graphic.Cfg(
      type: graphic.ShapeType.marker,
      attrs: graphic.Attrs(
        x: 150,
        y: 350,
        r: 40,
        color: Color(0xff1890ff),
        style: PaintingStyle.stroke,
        symbol: graphic.Symbols.triangleDown,
      ),
    ));

    // -------------------------------------

    r3.addShape(graphic.Cfg(
      type: graphic.ShapeType.path,
      attrs: graphic.Attrs(
        segments: [
          graphic.MoveTo(10, 10),
          graphic.QuadraticBezierTo(40, 40, 50, 20),
          graphic.CubicTo(50, 50, 70, 70, 100, 50),
          graphic.Close(),
        ],
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
                  renderer: r1,
                ),
              ),
              Container(
                width: 500,
                height: 500,
                child: graphic.Canvas(
                  renderer: r2,
                ),
              ),
              Container(
                width: 500,
                height: 500,
                child: graphic.Canvas(
                  renderer: r3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
