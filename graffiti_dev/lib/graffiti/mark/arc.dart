import 'dart:ui';

import 'package:graffiti_dev/graffiti/mark/path.dart';

import 'mark.dart';

class ArcMark extends ShapeMark {
  ArcMark({
    required this.oval,
    required this.startAngle,
    required this.endAngle,

    required ShapeStyle style,
    double? rotation,
    Offset? rotationAxis,
  }) : super(
    style: style,
    rotation: rotation,
    rotationAxis: rotationAxis,
  );

  final Rect oval;

  final double startAngle;

  final double endAngle;
  
  @override
  void drawPath(Path path) =>
    path.addArc(oval, startAngle, endAngle - startAngle);

  @override
  ArcMark lerpFrom(covariant ArcMark from, double t) => ArcMark(
    oval: Rect.lerp(from.oval, oval, t)!,
    startAngle: lerpDouble(from.startAngle, startAngle, t)!,
    endAngle: lerpDouble(from.endAngle, endAngle, t)!,
    style: style.lerpFrom(from.style, t),
    rotation: lerpDouble(from.rotation, rotation, t),
    rotationAxis: Offset.lerp(from.rotationAxis, rotationAxis, t),
  );

  @override
  PathMark toBezier() {
    // TODO: implement toBezier
    throw UnimplementedError();
  }
}
