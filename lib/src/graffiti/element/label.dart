import 'dart:ui';

import 'package:flutter/painting.dart';

import 'package:graphic/src/util/assert.dart';

import 'element.dart';

/// The style of a label.
class LabelStyle extends BlockStyle {
  /// Creates a label style.
  LabelStyle({
    this.textStyle,
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
    Offset? offset,
    double? rotation,
    Alignment? align,
  })  : assert(isSingle([textStyle, span])),
        super(
          offset: offset,
          rotation: rotation,
          align: align,
        );

  /// The text style of the label.
  ///
  /// If set, it will construct the [TextPainter.text] with the text string, and
  /// [span] is not allowed.
  ///
  /// Note that the default color is white.
  final TextStyle? textStyle;

  /// The function to get the [TextPainter.text] form the text string.
  ///
  /// If set, [textStyle] is not allowed.
  final InlineSpan Function(String)? span;

  /// How the text should be aligned horizontally.
  ///
  /// It defaults to [TextAlign.start].
  final TextAlign? textAlign;

  /// The default directionality of the text.
  ///
  /// This controls how the [TextAlign.start], [TextAlign.end], and
  /// [TextAlign.justify] values of [textAlign] are resolved.
  ///
  /// This is also used to disambiguate how to render bidirectional text. For
  /// example, if the text string is an English phrase followed by a Hebrew phrase,
  /// in a [TextDirection.ltr] context the English phrase will be on the left
  /// and the Hebrew phrase to its right, while in a [TextDirection.rtl]
  /// context, the English phrase will be on the right and the Hebrew phrase on
  /// its left.
  ///
  /// It is default to [TextDirection.ltr]. **This default value is only for conciseness.
  /// We cherish the diversity of cultures, and insist that not any language habit
  /// should be regarded as "default".**
  final TextDirection? textDirection;

  /// The number of font pixels for each logical pixel.
  ///
  /// For example, if the text scale factor is 1.5, text will be 50% larger than
  /// the specified font size.
  final double? textScaleFactor;

  /// An optional maximum number of lines for the text to span, wrapping if
  /// necessary.
  ///
  /// If the text exceeds the given number of lines, it is truncated such that
  /// subsequent lines are dropped.
  final int? maxLines;

  /// The string used to ellipsize overflowing text. Setting this to a non-empty
  /// string will cause this string to be substituted for the remaining text
  /// if the text can not fit within the specified maximum width.
  ///
  /// Specifically, the ellipsis is applied to the last line before the line
  /// truncated by [maxLines], if [maxLines] is non-null and that line overflows
  /// the width constraint, or to the first line that is wider than the width
  /// constraint, if [maxLines] is null. The width constraint is the [maxWidth].
  final String? ellipsis;

  /// The locale used to select region-specific glyphs.
  final Locale? locale;

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
  final StrutStyle? strutStyle;

  /// Defines how to measure the width of the rendered text.
  final TextWidthBasis? textWidthBasis;

  /// Defines how the paragraph will apply TextStyle.height to the ascent of the
  /// first line and descent of the last line.
  ///
  /// Each boolean value represents whether the [TextStyle.height] modifier will
  /// be applied to the corresponding metric. By default, all properties are true,
  /// and [TextStyle.height] is applied as normal. When set to false, the font's
  /// default ascent will be used.
  final TextHeightBehavior? textHeightBehavior;

  /// The minimum width of the text layouting.
  ///
  /// It defaults to 0.
  final double? minWidth;

  /// The maximum width of the text layouting.
  ///
  /// It defaults to [double.infinity].
  final double? maxWidth;

  @override
  LabelStyle lerpFrom(covariant LabelStyle from, double t) => LabelStyle(
      textStyle: TextStyle.lerp(from.textStyle, textStyle, t),
      span: span,
      textAlign: textAlign,
      textDirection: textDirection,
      textScaleFactor: lerpDouble(from.textScaleFactor, textScaleFactor, t),
      maxLines: lerpDouble(from.maxLines, maxLines, t)?.toInt(),
      ellipsis: ellipsis,
      locale: locale,
      strutStyle: strutStyle,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      minWidth: lerpDouble(from.minWidth, minWidth, t),
      maxWidth: lerpDouble(from.maxWidth, maxWidth, t));

  @override
  bool operator ==(Object other) =>
      other is LabelStyle &&
      super == other &&
      textStyle == other.textStyle &&
      // span is a function.
      textAlign == other.textAlign &&
      textDirection == other.textDirection &&
      textScaleFactor == other.textScaleFactor &&
      maxLines == other.maxLines &&
      ellipsis == other.ellipsis &&
      locale == other.locale &&
      strutStyle == other.strutStyle &&
      textWidthBasis == other.textWidthBasis &&
      textHeightBehavior == other.textHeightBehavior &&
      minWidth == other.minWidth &&
      maxWidth == other.maxWidth;
}

/// A label element.
class LabelElement extends BlockElement<LabelStyle> {
  /// Creates a label element.
  LabelElement({
    required this.text,
    required Offset anchor,
    Alignment defaultAlign = Alignment.center,
    required LabelStyle style,
    String? tag,
  }) : super(
          anchor: anchor,
          defaultAlign: defaultAlign,
          style: style,
          tag: tag,
        ) {
    _painter = TextPainter(
      text: this.style.textStyle != null
          ? TextSpan(text: text, style: this.style.textStyle)
          : this.style.span!(text),
      textAlign: this.style.textAlign ?? TextAlign.start,
      textDirection: this.style.textDirection ?? TextDirection.ltr,
      textScaler: TextScaler.linear(this.style.textScaleFactor ?? 1.0),
      maxLines: this.style.maxLines,
      ellipsis: this.style.ellipsis,
      locale: this.style.locale,
      strutStyle: this.style.strutStyle,
      textWidthBasis: this.style.textWidthBasis ?? TextWidthBasis.parent,
      textHeightBehavior: this.style.textHeightBehavior,
    );
    _painter.layout(
      minWidth: this.style.minWidth ?? 0.0,
      maxWidth: this.style.maxWidth ?? double.infinity,
    );

    paintPoint = getBlockPaintPoint(rotationAxis!, _painter.width,
        _painter.height, this.style.align ?? this.defaultAlign);
  }

  /// The content text of this label.
  final String text;

  /// The text painter.
  late final TextPainter _painter;

  @override
  void draw(Canvas canvas) => _painter.paint(canvas, paintPoint);

  @override
  LabelElement lerpFrom(covariant LabelElement from, double t) => LabelElement(
        text: text,
        anchor: Offset.lerp(from.anchor, anchor, t)!,
        defaultAlign: Alignment.lerp(from.defaultAlign, defaultAlign, t)!,
        style: style.lerpFrom(from.style, t),
        tag: tag,
      );

  @override
  bool operator ==(Object other) =>
      other is LabelElement && super == other && text == other.text;
}
