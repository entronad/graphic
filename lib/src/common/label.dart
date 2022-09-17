import 'package:flutter/painting.dart';
import 'package:graphic/src/aes/label.dart';
import 'package:graphic/src/graffiti/figure.dart';
import 'package:graphic/src/guide/annotation/tag.dart';
import 'package:graphic/src/util/assert.dart';

import 'defaults.dart';

/// The style of a [Label].
///
/// It includes not only properties for [TextPainter], but also position settings
/// to the anchor point.
///
/// See also:
///
/// - [renderLabel], renders a label with an anchor point.
class LabelStyle {
  /// Creates a label style.
  LabelStyle({
    this.style,
    this.span,
    this.textAlign,
    this.textDirection,
    this.textScaleFactor,
    this.maxLines,
    this.ellipsis,
    this.locale,
    this.strutStyle,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.minWidth,
    this.maxWidth,
    this.offset,
    this.rotation,
    this.align,
  }) : assert(isSingle([style, span]));

  /// The text style of the label.
  ///
  /// If set, it will construct the [TextPainter.text] with the [Label.text], and
  /// [span] is not allowed.
  ///
  /// Note that the default color is white.
  TextStyle? style;

  /// The function to get the [TextPainter.text] form the [Label.text].
  ///
  /// If set, [style] is not allowed.
  InlineSpan Function(String)? span;

  /// How the text should be aligned horizontally.
  ///
  /// It defaults to [TextAlign.start].
  TextAlign? textAlign;

  /// The default directionality of the text.
  ///
  /// This controls how the [TextAlign.start], [TextAlign.end], and
  /// [TextAlign.justify] values of [textAlign] are resolved.
  ///
  /// This is also used to disambiguate how to render bidirectional text. For
  /// example, if the [Label.text] is an English phrase followed by a Hebrew phrase,
  /// in a [TextDirection.ltr] context the English phrase will be on the left
  /// and the Hebrew phrase to its right, while in a [TextDirection.rtl]
  /// context, the English phrase will be on the right and the Hebrew phrase on
  /// its left.
  ///
  /// It is default to [TextDirection.ltr]. **This default value is only for conciseness.
  /// We cherish the diversity of cultures, and insist that not any language habit
  /// should be regarded as "default".**
  TextDirection? textDirection;

  /// The number of font pixels for each logical pixel.
  ///
  /// For example, if the text scale factor is 1.5, text will be 50% larger than
  /// the specified font size.
  double? textScaleFactor;

  /// An optional maximum number of lines for the text to span, wrapping if
  /// necessary.
  ///
  /// If the text exceeds the given number of lines, it is truncated such that
  /// subsequent lines are dropped.
  int? maxLines;

  /// The string used to ellipsize overflowing text. Setting this to a non-empty
  /// string will cause this string to be substituted for the remaining text
  /// if the text can not fit within the specified maximum width.
  ///
  /// Specifically, the ellipsis is applied to the last line before the line
  /// truncated by [maxLines], if [maxLines] is non-null and that line overflows
  /// the width constraint, or to the first line that is wider than the width
  /// constraint, if [maxLines] is null. The width constraint is the [maxWidth].
  String? ellipsis;

  /// The locale used to select region-specific glyphs.
  Locale? locale;

  /// The strut style to use. Strut style defines the strut, which sets minimum
  /// vertical layout metrics.
  ///
  /// Omitting or providing null will disable strut.
  ///
  /// Omitting or providing null for any properties of [StrutStyle] will result in
  /// default values being used. It is highly recommended to at least specify a
  /// [StrutStyle.fontSize].
  ///
  /// See [StrutStyle] for details.
  StrutStyle? strutStyle;

  /// Defines how to measure the width of the rendered text.
  TextWidthBasis? textWidthBasis;

  /// Defines how the paragraph will apply TextStyle.height to the ascent of the
  /// first line and descent of the last line.
  ///
  /// Each boolean value represents whether the [TextStyle.height] modifier will
  /// be applied to the corresponding metric. By default, all properties are true,
  /// and [TextStyle.height] is applied as normal. When set to false, the font's
  /// default ascent will be used.
  TextHeightBehavior? textHeightBehavior;

  /// The minimum width of the text layouting.
  ///
  /// It defaults to 0.
  double? minWidth;

  /// The maximum width of the text layouting.
  ///
  /// It defaults to [double.infinity].
  double? maxWidth;

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
      textAlign == other.textAlign &&
      textDirection == other.textDirection &&
      textScaleFactor == other.textScaleFactor &&
      maxLines == other.maxLines &&
      ellipsis == other.ellipsis &&
      locale == other.locale &&
      strutStyle == other.strutStyle &&
      textWidthBasis == other.textWidthBasis &&
      minWidth == other.minWidth &&
      maxWidth == other.maxWidth &&
      offset == other.offset &&
      rotation == other.rotation &&
      align == other.align;
}

/// Specification of a label.
///
/// A label is a span of text with styles. In is used for [LabelAttr], [TagAnnotation],
/// etc in the chart.
///
/// If the [text] is null or empty, the label will render nothing.
class Label {
  /// Creates a label.
  Label(
    this.text, [
    LabelStyle? style,
  ]) : style = style ?? LabelStyle(style: Defaults.textStyle);

  /// The label text.
  String? text;

  /// The label style.
  LabelStyle style;

  @override
  bool operator ==(Object other) =>
      other is Label && text == other.text && style == other.style;

  /// Whether the [text] is not null or empty;
  bool get haveText => text != null && text!.isNotEmpty;
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
  assert(label.haveText);

  final painter = TextPainter(
    text: label.style.style != null
        ? TextSpan(text: label.text, style: label.style.style)
        : label.style.span!(label.text!),
    textAlign: label.style.textAlign ?? TextAlign.start,
    textDirection: label.style.textDirection ?? TextDirection.ltr,
    textScaleFactor: label.style.textScaleFactor ?? 1.0,
    maxLines: label.style.maxLines,
    ellipsis: label.style.ellipsis,
    locale: label.style.locale,
    strutStyle: label.style.strutStyle,
    textWidthBasis: label.style.textWidthBasis ?? TextWidthBasis.parent,
    textHeightBehavior: label.style.textHeightBehavior,
  );
  painter.layout(
    minWidth: label.style.minWidth ?? 0.0,
    maxWidth: label.style.maxWidth ?? double.infinity,
  );

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
