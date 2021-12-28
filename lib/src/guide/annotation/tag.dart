import 'package:flutter/painting.dart';
import 'package:graphic/src/common/label.dart';
import 'package:graphic/src/graffiti/figure.dart';

import 'figure.dart';

/// The specification of a tag annotation.
class TagAnnotation extends FigureAnnotation {
  /// Creates a tag annotation.
  TagAnnotation({
    required this.label,
    List<String>? variables,
    List? values,
    Offset Function(Size)? anchor,
    int? layer,
  }) : super(
          variables: variables,
          values: values,
          anchor: anchor,
          layer: layer,
        );

  /// The label definition of this tag.
  Label label;

  @override
  bool operator ==(Object other) =>
      other is TagAnnotation && super == other && label == other.label;
}

/// The tag figure annotation operator.
class TagAnnotOp extends FigureAnnotOp {
  TagAnnotOp(Map<String, dynamic> params) : super(params);

  @override
  List<Figure>? evaluate() {
    final anchor = params['anchor'] as Offset;
    final label = params['label'] as Label;

    return [
      renderLabel(
        label,
        anchor,
        Alignment.center,
      )
    ];
  }
}
