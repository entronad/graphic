import 'dart:ui';

import 'package:graffiti_dev/graffiti/mark/segment/close.dart';

import 'mark.dart';
import 'segment/segment.dart';
import 'segment/move.dart';
import 'segment/line.dart';

class PolygonMark extends ShapeMark {
  PolygonMark({
    required this.points,
    required this.close,

    required ShapeStyle style,
    double? rotation,
    Offset? rotationAxis,
  }) : assert(points.length >= 2),
       super(
         style: style,
         rotation: rotation,
         rotationAxis: rotationAxis,
       );

  final List<Offset> points;

  final bool close;
  
  @override
  void drawPath(Path path) {
    path.moveTo(points[0].dx, points[0].dy);

    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    if (close) {
      path.close();
    }
  }

  @override
  PolygonMark lerpFrom(covariant PolygonMark from, double t) {
    final rst = <Offset>[];

    var fromPoints = from.points;
    var toPoints = points;

    final dl = toPoints.length - fromPoints.length;
    if (dl > 0) {
      fromPoints = [...fromPoints, ...List.filled(dl, fromPoints.last)];
    } else if (dl < 0) {
      toPoints = [...toPoints, ...List.filled(-dl, toPoints.last)];
    }

    for (var i = 0; i < points.length; i++) {
      rst.add(Offset.lerp(from.points[i], points[i], t)!);
    }

    return PolygonMark(
      points: rst,
      close: close,
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

    if (close) {
      rst.add(CloseSegment());
    }

    return rst;
  }
}
