import 'package:flutter/painting.dart';

import 'mark.dart';

class RectMark extends Primitive {
  RectMark({
    required this.rect,
    this.borderRadius,

    required Paint style,
    Shadow? shadow,
    List<double>? dash,
  }) : super(
    style: style,
    shadow: shadow,
    dash: dash,
  );

  final Rect rect;

  final BorderRadius? borderRadius;
  
  @override
  void createPath(Path path) {
    if (borderRadius == null || borderRadius == BorderRadius.zero) {
      path.addRect(rect);
    } else {
      path.addRRect(borderRadius!.toRRect(rect));
    }
  }
}
