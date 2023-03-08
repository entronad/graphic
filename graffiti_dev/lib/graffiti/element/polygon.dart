import 'dart:ui';

import 'element.dart';
import 'polyline.dart';
import 'segment/segment.dart';
import 'segment/move.dart';
import 'segment/line.dart';
import 'segment/close.dart';

class PolygonElement extends PrimitiveElement {
  PolygonElement({
    required this.points,

    PaintStyle? style,
    double? rotation,
    Offset? rotationAxis,
  }) : assert(points.length >= 2),
       super(
         style: style ?? defaultPaintStyle,
         rotation: rotation,
         rotationAxis: rotationAxis,
       );

  final List<Offset> points;
  
  @override
  void drawPath(Path path) {
    path.moveTo(points[0].dx, points[0].dy);

    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    path.close();
  }

  @override
  PolygonElement lerpFrom(covariant PolygonElement from, double t) {
    final pointsRst = lerpPointList(from.points, points, t);

    return PolygonElement(
      points: pointsRst,
      style: style.lerpFrom(from.style, t),
      rotation: lerpDouble(from.rotation, rotation, t),
      rotationAxis: Offset.lerp(from.rotationAxis, rotationAxis, t),
    );
  }

  @override
  List<Segment> toSegments() {
    final rst = <Segment>[];

    rst.add(MoveSegment(end: Offset(points[0].dx, points[0].dy)));

    for (var i = 1; i < points.length; i++) {
      rst.add(LineSegment(end: Offset(points[i].dx, points[i].dy)));
    }

    rst.add(CloseSegment());

    return rst;
  }
}
