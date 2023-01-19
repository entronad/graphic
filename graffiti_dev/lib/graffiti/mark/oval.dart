import 'dart:ui';

import 'package:graffiti_dev/graffiti/mark/path.dart';

import 'mark.dart';

class OvalMark extends ShapeMark {
  OvalMark({
    required this.oval,

    required ShapeStyle style,
    double? rotation,
    Offset? rotationAxis,
  }) : super(
    style: style,
    rotation: rotation,
    rotationAxis: rotationAxis,
  );

  final Rect oval;
  
  @override
  void drawPath(Path path) =>
    path.addOval(oval);

  @override
  OvalMark lerpFrom(covariant OvalMark from, double t) => OvalMark(
    oval: Rect.lerp(from.oval, oval, t)!,
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
