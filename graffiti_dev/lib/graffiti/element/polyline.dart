import 'dart:ui';

import 'element.dart';
import 'segment/segment.dart';
import 'segment/move.dart';
import 'segment/line.dart';

List<Offset> lerpPointList(List<Offset> from, List<Offset> to, double t) {
  final rst = <Offset>[];

  var fromPoints = from;
  var toPoints = to;

  final dl = toPoints.length - fromPoints.length;
  if (dl > 0) {
    fromPoints = [...fromPoints, ...List.filled(dl, fromPoints.last)];
  } else if (dl < 0) {
    toPoints = [...toPoints, ...List.filled(-dl, toPoints.last)];
  }

  for (var i = 0; i < toPoints.length; i++) {
    rst.add(Offset.lerp(fromPoints[i], toPoints[i], t)!);
  }

  return rst;
}

class PolylineElement extends ShapeElement {
  PolylineElement({
    required this.points,

    ShapeStyle? style,
    double? rotation,
    Offset? rotationAxis,
  }) : assert(points.length >= 2),
       super(
         style: style ?? defaultShapeStyle,
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
  }

  @override
  PolylineElement lerpFrom(covariant PolylineElement from, double t) {
    final pointsRst = lerpPointList(from.points, points, t);

    return PolylineElement(
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

    return rst;
  }
}
