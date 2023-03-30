import 'dart:ui';

import 'package:graphic/src/util/collection.dart';

import 'element.dart';
import 'polyline.dart';
import 'segment/segment.dart';
import 'segment/move.dart';
import 'segment/line.dart';
import 'segment/close.dart';

/// A polygon element.
class PolygonElement extends PrimitiveElement {
  /// Creates a polygon element.
  PolygonElement({
    required this.points,
    required PaintStyle style,
    double? rotation,
    Offset? rotationAxis,
    String? tag,
  })  : assert(points.length >= 2),
        super(
          style: style,
          rotation: rotation,
          rotationAxis: rotationAxis,
          tag: tag,
        );

  /// The vertex points of this polygon.
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
      tag: tag,
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

  @override
  bool operator ==(Object other) =>
      other is PolygonElement &&
      super == other &&
      deepCollectionEquals(points, other.points);
}
