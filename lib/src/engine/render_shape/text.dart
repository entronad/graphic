import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:meta/meta.dart';
import 'package:graphic/src/util/exception.dart';

import 'base.dart';

class TextRenderShape extends RenderShape {
  TextRenderShape({
    @required double x,
    @required double y,
    double maxWidth,
    double minWidth,

    InlineSpan textSpan,

    String text,
    TextStyle textStyle,

    TextAlign textAlign,
    TextDirection textDirection,
    double textScaleFactor,
    int maxLines,
    String ellipsis,
    Locale locale,
    StrutStyle strutStyle,
    TextWidthBasis textWidthBasis,
  }) {
    assert(
      testParamRedundant([textSpan, text]),
      paramRedundantWarning('textSpan, text'),
    );
    assert(
      testParamRedundant([textSpan, textStyle]),
      paramRedundantWarning('textSpan, textStyle'),
    );

    this['x'] = x;
    this['y'] = y;
    this['maxWidth'] = maxWidth;
    this['minWidth'] = minWidth;
    
    this['textSpan'] = textSpan;

    this['text'] = text;
    this['textStyle'] = textStyle;

    this['textAlign'] = textAlign;
    this['textDirection'] = textDirection;
    this['textScaleFactor'] = textScaleFactor;
    this['maxLines'] = maxLines;
    this['ellipsis'] = ellipsis;
    this['locale'] = locale;
    this['strutStyle'] = strutStyle;
    this['textWidthBasis'] = textWidthBasis;
  }

  @override
  RenderShapeType get type => RenderShapeType.text;
}

class TextRenderShapeState extends RenderShapeState {
  double get x => this['x'] as double;
  set x(double value) => this['x'] = value;

  double get y => this['y'] as double;
  set y(double value) => this['y'] = value;

  double get minWidth => this['minWidth'] as double;
  set minWidth(double value) => this['minWidth'] = value;

  double get maxWidth => this['maxWidth'] as double;
  set maxWidth(double value) => this['maxWidth'] = value;

  InlineSpan get textSpan => this['textSpan'] as InlineSpan;
  set textSpan(InlineSpan value) => this['textSpan'] = value;

  String get text => this['text'] as String;
  set text(String value) => this['text'] = value;

  TextStyle get textStyle => this['textStyle'] as TextStyle;
  set textStyle(TextStyle value) => this['textStyle'] = value;

  TextAlign get textAlign => this['textAlign'] as TextAlign ?? TextAlign.start;
  set textAlign(TextAlign value) => this['textAlign'] = value;

  // This default value TextDirection.ltr is picked randomly. It dose not mean we hold
  // the idea that any sigle language habit in the world should be considered as "default".
  TextDirection get textDirection => this['textDirection'] as TextDirection ?? TextDirection.ltr;
  set textDirection(TextDirection value) => this['textDirection'] = value;

  double get textScaleFactor => this['textScaleFactor'] as double ?? 1;
  set textScaleFactor(double value) => this['textScaleFactor'] = value;

  int get maxLines => this['maxLines'] as int;
  set maxLines(int value) => this['maxLines'] = value;

  String get ellipsis => this['ellipsis'] as String;
  set ellipsis(String value) => this['ellipsis'] = value;

  Locale get locale => this['locale'] as Locale;
  set locale(Locale value) => this['locale'] = value;

  StrutStyle get strutStyle => this['strutStyle'] as StrutStyle;
  set strutStyle(StrutStyle value) => this['strutStyle'] = value;

  TextWidthBasis get textWidthBasis => this['textWidthBasis'] as TextWidthBasis ?? TextWidthBasis.parent;
  set textWidthBasis(TextWidthBasis value) => this['textWidthBasis'] = value;

  void applyToTextPainter(TextPainter textPainter) {
    assert(textPainter != null);

    textPainter.text = textSpan ?? TextSpan(text: text, style: textStyle);
    textPainter.textAlign = textAlign;
    textPainter.textDirection = textDirection;
    textPainter.textScaleFactor = textScaleFactor;
    textPainter.maxLines = maxLines;
    textPainter.ellipsis = ellipsis;
    textPainter.locale = locale;
    textPainter.strutStyle = strutStyle;
    textPainter.textWidthBasis = textWidthBasis;
  }
}

class TextRenderShapeComponent
  extends RenderShapeComponent<TextRenderShapeState>
{
  TextRenderShapeComponent([TextRenderShape props]) : super(props);

  TextPainter _textPainter = TextPainter();

  @override
  TextRenderShapeState get originalState => TextRenderShapeState();

  @override
  void initDefaultState() {
    super.initDefaultState();
    state
      ..minWidth = 0
      ..maxWidth = double.infinity;
  }

  @override
  void assign() {
    state.applyToTextPainter(_textPainter);
    _textPainter.layout(
      minWidth: state.minWidth,
      maxWidth: state.maxWidth,
    );

    shapeBBox = calculateBBox();
  }

  @override
  void draw(Canvas canvas) {
    final x = state.x;
    final y = state.y;

    _textPainter.paint(canvas, Offset(x, y));
  }

  @override
  Rect calculateBBox() {
    final widthSign = _textPainter.textDirection == TextDirection.ltr ? 1 : -1;
    final width = widthSign * _textPainter.width;
    final height = _textPainter.height;
    return Rect.fromLTWH(state.x, state.y, width, height);
  }

  @override
  void createPath(Path path) {}
}
