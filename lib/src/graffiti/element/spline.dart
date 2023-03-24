import 'dart:ui';

import 'package:graphic/src/util/collection.dart';

import 'element.dart';
import 'segment/segment.dart';
import 'segment/move.dart';
import 'segment/cubic.dart';

class SplineElement extends PrimitiveElement {
  SplineElement({
    required this.start,
    required this.cubics,
    required PaintStyle style,
    double? rotation,
    Offset? rotationAxis,
  }) : super(
          style: style,
          rotation: rotation,
          rotationAxis: rotationAxis,
        );

  final Offset start;

  final List<List<Offset>> cubics;

  @override
  void drawPath(Path path) {
    path.moveTo(start.dx, start.dy);

    for (var cubic in cubics) {
      path.cubicTo(
        cubic[0].dx,
        cubic[0].dy,
        cubic[1].dx,
        cubic[1].dy,
        cubic[2].dx,
        cubic[2].dy,
      );
    }
  }

  @override
  SplineElement lerpFrom(covariant SplineElement from, double t) {
    final cubicsRst = <List<Offset>>[];

    var fromCubics = from.cubics;
    var toCubics = cubics;

    final dl = toCubics.length - fromCubics.length;
    if (dl > 0) {
      fromCubics = [...fromCubics, ...List.filled(dl, fromCubics.last)];
    } else if (dl < 0) {
      toCubics = [...toCubics, ...List.filled(-dl, toCubics.last)];
    }

    for (var i = 0; i < toCubics.length; i++) {
      cubicsRst.add([
        Offset.lerp(fromCubics[i][0], toCubics[i][0], t)!,
        Offset.lerp(fromCubics[i][1], toCubics[i][1], t)!,
        Offset.lerp(fromCubics[i][2], toCubics[i][2], t)!,
      ]);
    }

    return SplineElement(
      start: Offset.lerp(from.start, start, t)!,
      cubics: cubicsRst,
      style: style.lerpFrom(from.style, t),
      rotation: lerpDouble(from.rotation, rotation, t),
      rotationAxis: Offset.lerp(from.rotationAxis, rotationAxis, t),
    );
  }

  @override
  List<Segment> toSegments() {
    final rst = <Segment>[];

    rst.add(MoveSegment(end: Offset(start.dx, start.dy)));

    for (var cubic in cubics) {
      rst.add(
          CubicSegment(control1: cubic[0], control2: cubic[1], end: cubic[2]));
    }

    return rst;
  }

  @override
  bool operator ==(Object other) =>
      other is SplineElement &&
      super == other &&
      start == other.start &&
      deepCollectionEquals(cubics, other.cubics);
}
