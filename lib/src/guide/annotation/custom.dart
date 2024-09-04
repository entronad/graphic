import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:graphic/src/graffiti/element/element.dart';

import 'element.dart';

/// The specification of a custom annotation.
class CustomAnnotation extends ElementAnnotation {
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
  List<MarkElement> Function(Offset, Size) renderer;

  @override
  bool operator ==(Object other) =>
      other is CustomAnnotation && super == other && values == other.values;
}

/// The custom element annotation operator.
class CustomAnnotOp extends ElementAnnotOp {
  CustomAnnotOp(Map<String, dynamic> params) : super(params);

  @override
  List<MarkElement>? evaluate() {
    final anchor = params['anchor'] as Offset;
    final size = params['size'] as Size;
    final renderer =
        params['renderer'] as List<MarkElement> Function(Offset, Size);

    return renderer(anchor, size);
  }
}
