import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:graphic/src/graffiti/figure.dart';
import 'package:vector_math/vector_math_64.dart';

import 'figure.dart';

class MarkAnnotation extends FigureAnnotation {
  MarkAnnotation({
    required this.path,
    required this.style,
    this.elevation,

    List<String>? variables,
    List? values,
    Offset? anchor,
    int? zIndex,
  }) : super(
    variables: variables,
    values: values,
    anchor: anchor,
    zIndex: zIndex,
  );

  // Relative, will move to anchor.
  Path path;

  Paint style;

  double? elevation;

  @override
  bool operator ==(Object other) =>
    other is MarkAnnotation &&
    super == other &&
    path == other.path &&
    style == other.style &&
    elevation == other.elevation;
}

class MarkAnnotOp extends FigureAnnotOp {
  MarkAnnotOp(Map<String, dynamic> params) : super(params);

  @override
  List<Figure>? evaluate() {
    final anchor = params['anchor'] as Offset;
    final path = params['path'] as Path;
    final style = params['style'] as Paint;
    final elevation = params['elevation'] as double?;

    final matrix = Matrix4.identity()
      ..leftTranslate(anchor.dx, anchor.dy);
    final absolutePath = path.transform(matrix.storage);

    final rst = <Figure>[PathFigure(path, style)];
    if (elevation != null) {
      rst.add(ShadowFigure(
        absolutePath,
        style.color,
        elevation,
      ));
    }
    return rst;
  }
}
