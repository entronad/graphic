import 'dart:ui';

import 'mark.dart';

class CircleMark extends Primitive {
  CircleMark({
    required this.center,
    required this.radius,

    required Paint style,
    Shadow? shadow,
    List<double>? dash,
  }) : super(
    style: style,
    shadow: shadow,
    dash: dash,
  );

  final Offset center;

  final double radius;
  
  @override
  void createPath(Path path) =>
    path.addOval(Rect.fromCircle(center: center, radius: radius));
}
