import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:graphic/src/graffiti/figure.dart';

import 'figure.dart';

/// The specification of a custom annotation.
class CustomAnnotation extends FigureAnnotation {
  /// Creates a custom annotation.
  CustomAnnotation({
    required this.renderer,
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

  /// Indicates the custom render funcion of this annotation.
  List<Figure> Function(Offset, Size) renderer;

  @override
  bool operator ==(Object other) => other is CustomAnnotation && super == other;
}

/// The custom figure annotation operator.
class CustomAnnotOp extends FigureAnnotOp {
  CustomAnnotOp(Map<String, dynamic> params) : super(params);

  @override
  List<Figure>? evaluate() {
    final anchor = params['anchor'] as Offset;
    final size = params['size'] as Size;
    final renderer = params['renderer'] as List<Figure> Function(Offset, Size);

    return renderer(anchor, size);
  }
}
