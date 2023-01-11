import 'dart:ui';

import 'mark.dart';

class LineMark extends Primitive {
  LineMark({
    required this.start,
    required this.end,

    required Paint style,
    Shadow? shadow,
    List<double>? dash,
  }) : super(
    style: style,
    shadow: shadow,
    dash: dash,
  );

  final Offset start;

  final Offset end;
  
  @override
  void createPath(Path path) {
    path.moveTo(start.dx, start.dy);
    path.lineTo(end.dx, end.dy);
  }
}
