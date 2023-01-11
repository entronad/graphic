import 'dart:ui';

import 'mark.dart';

class PolygonMark extends Primitive {
  PolygonMark({
    required this.points,
    required this.close,

    required Paint style,
    Shadow? shadow,
    List<double>? dash,
  }) : super(
    style: style,
    shadow: shadow,
    dash: dash,
  );

  final List<Offset> points;

  final bool close;
  
  @override
  void createPath(Path path) {
    path.moveTo(points[0].dx, points[0].dy);

    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    if (close) {
      path.close();
    }
  }
}
