import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:graphic/src/graffiti/figure.dart';
import 'package:vector_math/vector_math_64.dart';

import 'figure.dart';

/// The specification of a mark annotation.
class MarkAnnotation extends FigureAnnotation {
  /// Creates a mark annotation.
  MarkAnnotation({
    required this.relativePath,
    required this.style,
    this.elevation,
    List<String>? variables,
    List? values,
    Offset Function(Size)? anchor,
    bool? clip,
    int? layer,
  }) : super(
          variables: variables,
          values: values,
          anchor: anchor,
          clip: clip,
          layer: layer,
        );

  /// The relative path definition of the mark.
  ///
  /// Use [Offset]s relative to [Offset.zero] in this definition. The path will
  /// be translated to the anchor position in rendering.
  Path relativePath;

  /// The style of this mark.
  Paint style;

  /// The shadow elevation of this mark.
  double? elevation;

  @override
  bool operator ==(Object other) =>
      other is MarkAnnotation &&
      super == other &&
      relativePath == other.relativePath &&
      style == other.style &&
      elevation == other.elevation;
}

/// The mark figure annotation operator.
class MarkAnnotOp extends FigureAnnotOp {
  MarkAnnotOp(Map<String, dynamic> params) : super(params);

  @override
  List<Figure>? evaluate() {
    final anchor = params['anchor'] as Offset;
    final relativePath = params['relativePath'] as Path;
    final style = params['style'] as Paint;
    final elevation = params['elevation'] as double?;

    final matrix = Matrix4.identity()..leftTranslate(anchor.dx, anchor.dy);
    final path = relativePath.transform(matrix.storage);

    final rst = <Figure>[];

    if (elevation != null && elevation != 0) {
      rst.add(ShadowFigure(
        path,
        style.color,
        elevation,
      ));
    }
    rst.add(PathFigure(path, style));

    return rst;
  }
}
