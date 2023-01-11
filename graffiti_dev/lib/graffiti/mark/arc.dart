import 'dart:ui';

import 'mark.dart';

class ArcMark extends Primitive {
  ArcMark({
    required this.oval,
    required this.startAngle,
    required this.endAngle,

    required Paint style,
    Shadow? shadow,
    List<double>? dash,
  }) : super(
    style: style,
    shadow: shadow,
    dash: dash,
  );

  final Rect oval;

  final double startAngle;

  final double endAngle;
  
  @override
  void createPath(Path path) =>
    path.addArc(oval, startAngle, endAngle - startAngle);
}
