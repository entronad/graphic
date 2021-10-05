import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:graphic/src/common/label.dart';
import 'package:graphic/src/graffiti/figure.dart';

import 'figure.dart';

class TagAnnotation extends FigureAnnotation {
  TagAnnotation({
    required this.label,
    this.align,

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

  Label label;

  Alignment? align;

  @override
  bool operator ==(Object other) =>
    other is TagAnnotation &&
    super == other &&
    label == other.label &&
    align == other.align;
}

class TagAnnotOp extends FigureAnnotOp {
  TagAnnotOp(Map<String, dynamic> params) : super(params);

  @override
  List<Figure>? evaluate() {
    final anchor = params['anchor'] as Offset;
    final label = params['label'] as Label;
    final align = params['align'] as Alignment;
    
    return [drawLabel(
      label,
      anchor,
      align,
    )];
  }
}
