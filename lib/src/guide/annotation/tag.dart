import 'package:flutter/painting.dart';
import 'package:graphic/src/common/label.dart';
import 'package:graphic/src/graffiti/element/element.dart';
import 'package:graphic/src/graffiti/element/label.dart';

import 'element.dart';

/// The specification of a tag annotation.
class TagAnnotation extends ElementAnnotation {
  /// Creates a tag annotation.
  TagAnnotation({
    required this.label,
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

  /// The label definition of this tag.
  Label label;

  @override
  bool operator ==(Object other) =>
      other is TagAnnotation && super == other && label == other.label;
}

/// The tag element annotation operator.
class TagAnnotOp extends ElementAnnotOp {
  TagAnnotOp(Map<String, dynamic> params) : super(params);

  @override
  List<MarkElement>? evaluate() {
    final anchor = params['anchor'] as Offset;
    final label = params['label'] as Label;

    return label.haveText
        ? [
            LabelElement(text: label.text!, anchor: anchor, defaultAlign: Alignment.center, style: label.style),
          ]
        : null;
  }
}
