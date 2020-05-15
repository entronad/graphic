import 'dart:math';
import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart' as graphic;

class ArcContainPainter extends CustomPainter {
  ArcContainPainter(
    this.arcEnd,
    {this.radius = Radius.zero,
    this.rotation = 0.0,
    this.largeArc = false,
    this.clockwise = true,
    this.lineWidth = 0.0,
    this.prePoint,});
  
  final Offset arcEnd;

  final Radius radius;

  final double rotation;

  final bool largeArc;

  final bool clockwise;

  final double lineWidth;

  final Offset prePoint;

  @override
  void paint(Canvas canvas, Size size) {
    final r = lineWidth / 2;
    final dx0 = arcEnd.dx - prePoint.dx;
    final dy0 = arcEnd.dy - prePoint.dy;
    var k = r / sqrt(dx0 * dx0 + dy0 * dy0);
    // The sign of k represents "is clockwise".
    k *= clockwise ? 1 : -1;
    // Define "clockwise offset" has a positive dx and a negtive dy.
    final dx = k * dy0;
    final dy = -k * dx0;
    final offset = Offset(dx, dy);
    // Define inner as clockwise and outer is anticlockwise.
    final innerPre = prePoint + offset;
    final outerPre = prePoint - offset;
    final innerEnd = arcEnd + offset;
    final outerEnd = arcEnd - offset;
    // Inner has a smaller radius.
    final dr = Radius.circular(r);
    final innerRadius = radius - dr;
    final outerRadius = radius + dr;
    final path = Path()
      ..moveTo(innerPre.dx, innerPre.dy)
      ..arcToPoint(
        innerEnd,
        radius: innerRadius,  
        rotation: rotation,
        largeArc: largeArc,
        clockwise: clockwise,
      )
      ..lineTo(outerEnd.dx, outerEnd.dy)
      ..arcToPoint(
        outerPre,
        radius: outerRadius,
        rotation: rotation,
        largeArc: largeArc,
        clockwise: !clockwise,
      )
      ..close();

    canvas.drawPath(path, Paint()..color = Colors.red..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
  
}

class ShapeEventPage extends StatefulWidget {
  @override
  _ShapeEventPageState createState() => _ShapeEventPageState();
}

class _ShapeEventPageState extends State<ShapeEventPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final graphic.Renderer renderer = graphic.Renderer();
  final graphic.Renderer r1 = graphic.Renderer();

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
        style: PaintingStyle.fill,
      ),
    ));

    circle.on(type: graphic.EventType.tap, callback: (_) {
      circle.attr(graphic.Attrs(color: Colors.red));
    });
    circle.on(type: graphic.EventType.doubleTap, callback: (_) {
      circle.attr(graphic.Attrs(color: Colors.yellow));
    });
    circle.on(type: graphic.EventType.longPress, callback: (_) {
      circle.attr(graphic.Attrs(color: Colors.green));
    });
    circle.on(type: graphic.EventType.longPressEnd, callback: (_) {
      circle.attr(graphic.Attrs(color: Color(0xff1890ff)));
    });

    final text = renderer.addShape(graphic.Cfg(
      type: graphic.ShapeType.text,
      attrs: graphic.Attrs(
        x: 20,
        y: 20,
        text: TextSpan(
          text: 'Axis Label',
          style: TextStyle(
            fontSize: 20,
            color: Color(0xff1890ff),
          ),
        ),
      ),
    ));

    text.on(type: graphic.EventType.tap, callback: (_) {
      text.attr(graphic.Attrs(text: TextSpan(
          text: 'Axis Label',
          style: TextStyle(
            fontSize: 20,
            color: Colors.red,
          ),
        ),));
    });
    text.on(type: graphic.EventType.doubleTap, callback: (_) {
      text.attr(graphic.Attrs(text: TextSpan(
          text: 'Axis Label',
          style: TextStyle(
            fontSize: 20,
            color: Colors.yellow,
          ),
        ),));
    });
    text.on(type: graphic.EventType.longPress, callback: (_) {
      text.attr(graphic.Attrs(text: TextSpan(
          text: 'Axis Label',
          style: TextStyle(
            fontSize: 20,
            color: Colors.green,
          ),
        ),));
    });
    text.on(type: graphic.EventType.longPressEnd, callback: (_) {
      text.attr(graphic.Attrs(text: TextSpan(
          text: 'Axis Label',
          style: TextStyle(
            fontSize: 20,
            color: Color(0xff1890ff),
          ),
        ),));
    });

    graphic.getAssetImage('assets/images/lena.jpg', targetWidth: 100, targetHeight: 100)
      .then((image) {
        renderer.addShape(graphic.Cfg(
          type: graphic.ShapeType.image,
          attrs: graphic.Attrs(
            x: 400,
            y: 20,
            image: image,
          ),
        ));
      });
    
    final path = r1.addShape(graphic.Cfg(
      type: graphic.ShapeType.path,
      attrs: graphic.Attrs(
        segments: [
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
        // segments: [
        //   graphic.MoveTo(100, 300),
        //   // graphic.RelativeQuadraticBezierTo(50, -200, 100, -50),
        //   graphic.RelativeCubicTo(150, -100, 150, -260, 300, -250),
        //   graphic.Close(),
        // ],
        color: Color(0xff1890ff),
        strokeWidth: 4,
        strokeAppendWidth: 10,
        style: PaintingStyle.stroke,
      ),
    ));

    path.on(type: graphic.EventType.tap, callback: (_) {
      path.attr(graphic.Attrs(color: Colors.red));
    });

    final line = r1.addShape(graphic.Cfg(
      type: graphic.ShapeType.line,
      attrs: graphic.Attrs(
        x1: 10,
        y1: 10,
        x2: 200,
        y2: 200,
        strokeAppendWidth: 10,
      ),
    ));

    line.on(type: graphic.EventType.tap, callback: (_) {
      line.attr(graphic.Attrs(color: Colors.red));
    });

    final linePath = r1.addShape(graphic.Cfg(
      type: graphic.ShapeType.path,
      attrs: graphic.Attrs(
        segments: [
          graphic.MoveTo(200, 10),
          graphic.ArcToPoint(Offset(500, 200), clockwise: false, radius: Radius.circular(300)),
        ],
        style: PaintingStyle.stroke,
        strokeAppendWidth: 10,
      ),
    ));

    linePath.on(type: graphic.EventType.tap, callback: (_) {
      linePath.attr(graphic.Attrs(color: Colors.red));
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
              Container(
                width: 500,
                height: 500,
                color: Colors.yellow,
                child: graphic.Canvas(
                  renderer: r1,
                ),
              ),
              Container(
                width: 500,
                height: 500,
                child: CustomPaint(
                  painter: ArcContainPainter(
                    Offset(400, 400),
                    prePoint: Offset(100, 100),
                    radius: Radius.elliptical(200, 300),
                    rotation: 4,
                    lineWidth: 5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
