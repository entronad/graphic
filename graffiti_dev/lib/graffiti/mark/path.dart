import 'dart:ui';

import 'mark.dart';
import 'segment/segment.dart';

class PathMark extends Primitive {
  PathMark({
    required this.segments,

    required Paint style,
    Shadow? shadow,
    List<double>? dash,
  }) : super(
    style: style,
    shadow: shadow,
    dash: dash,
  );

  final List<Segment> segments;
  
  @override
  void createPath(Path path) {
    for (var segment in segments) {
      segment.drawPath(path);
    }
  }
}
