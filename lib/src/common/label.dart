import 'package:flutter/painting.dart';
import 'package:graphic/src/aes/label.dart';
import 'package:graphic/src/graffiti/figure.dart';
import 'package:graphic/src/guide/annotation/tag.dart';

import 'defaults.dart';

/// The style of a [Label].
///
/// It includes not only styles of text, but also position settings to the anchor
/// point.
///
/// See also:
///
/// - [renderLabel], renders a label with an anchor point.
class LabelStyle {
  /// Creates a label style.
  LabelStyle(
    this.style, {
    this.offset,
    this.rotation,
    this.align,
  });

  /// The text style of the label.
  ///
  /// Note that the default color is white.
  TextStyle style;

  /// The offset of the label from the anchor.
  Offset? offset;

  /// The rotation of the label.
  ///
  /// The rotation axis is the anchor point with [offset].
  double? rotation;

  /// How the label align to the anchor point.
  Alignment? align;

  @override
  bool operator ==(Object other) =>
      other is LabelStyle &&
      style == other.style &&
      offset == other.offset &&
      rotation == other.rotation &&
      align == other.align;
}

/// Specification of a label.
///
/// A label is a span of text with styles. In is used for [LabelAttr], [TagAnnotation],
/// etc in the chart.
class Label {
  /// Creates a label.
  Label(
    this.text, [
    LabelStyle? style,
  ]) : this.style = style ?? LabelStyle(Defaults.textStyle);

  /// The label text.
  String text;

  /// The label style.
  LabelStyle style;

  @override
  bool operator ==(Object other) =>
      other is Label && text == other.text && style == other.style;
}

/// Calculates the real paint point for [TextPainter.paint].
///
/// The [axis] is the anchor point with the [Label]'s offset.
Offset getPaintPoint(
  Offset axis,
  double width,
  double height,
  Alignment align,
) =>
    Offset(
      axis.dx - (width / 2) + ((width / 2) * align.x),
      axis.dy - (height / 2) + ((height / 2) * align.y),
    );

/// Gets the figure of a label.
///
/// The default align of lables is various in different situations, so it can be
/// configured by [defaultAlign] in this method.
Figure renderLabel(
  Label label,
  Offset anchor,
  Alignment defaultAlign,
) {
  final painter = TextPainter(
    text: TextSpan(text: label.text, style: label.style.style),
    textDirection: TextDirection.ltr,
  );
  painter.layout();

  final axis =
      label.style.offset == null ? anchor : anchor + label.style.offset!;

  final align = label.style.align ?? defaultAlign;

  var paintPoint = getPaintPoint(
    axis,
    painter.width,
    painter.height,
    align,
  );
  final rotation = label.style.rotation;
  if (rotation != null) {
    return RotatedTextFigure(
      painter,
      paintPoint,
      rotation,
      axis,
    );
  } else {
    return TextFigure(painter, paintPoint);
  }
}
