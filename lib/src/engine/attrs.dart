import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:graphic/src/util/typed_map_mixin.dart' show TypedMapMixin;

import 'shape.dart' show Shape;
import 'util/matrix.dart' show Matrix;

class Attrs with TypedMapMixin {
  Attrs({
    Shape clip,
    Matrix matrix,
    double x,
    double y,
    double x1,
    double y1,
    double x2,
    double y2,
    double r,
    double r0,
    double startAngle,
    double endAngle,
    bool clockwise,
    List<Offset> points,
    bool smooth,
    double width,
    double height,
    Path path,

    bool isAntiAlias,
    Color color,
    BlendMode blendMode,
    PaintingStyle style,
    double strokeWidth,
    StrokeCap strokeCap,
    StrokeJoin strokeJoin,
    double strokeMiterLimit,
    MaskFilter maskFilter,
    FilterQuality filterQuality,
    Shader shader,
    ColorFilter colorFilter,
    ImageFilter imageFilter,
    bool invertColors,

    InlineSpan text,
    TextAlign textAlign,
    TextDirection textDirection,
    double textScaleFactor,
    int maxLines,
    String ellipsis,
    Locale locale,
    StrutStyle strutStyle,
    TextWidthBasis textWidthBasis,
  }) {
    this['clip'] = clip;
    this['matrix'] = matrix;
    this['x'] = x;
    this['y'] = y;
    this['x1'] = x1;
    this['y1'] = y1;
    this['x2'] = x2;
    this['y2'] = y2;
    this['r'] = r;
    this['r0'] = r0;
    this['startAngle'] = startAngle;
    this['endAngle'] = endAngle;
    this['clockwise'] = clockwise;
    this['points'] = points;
    this['smooth'] = smooth;
    this['width'] = width;
    this['height'] = height;
    this['path'] = path;

    this['isAntiAlias'] = isAntiAlias;
    this['color'] = color;
    this['blendMode'] = blendMode;
    this['style'] = style;
    this['strokeWidth'] = strokeWidth;
    this['strokeCap'] = strokeCap;
    this['strokeJoin'] = strokeJoin;
    this['strokeMiterLimit'] = strokeMiterLimit;
    this['maskFilter'] = maskFilter;
    this['filterQuality'] = filterQuality;
    this['shader'] = shader;
    this['colorFilter'] = colorFilter;
    this['imageFilter'] = imageFilter;
    this['invertColors'] = invertColors;

    this['text'] = text;
    this['textAlign'] = textAlign;
    this['textDirection'] = textDirection;
    this['textScaleFactor'] = textScaleFactor;
    this['maxLines'] = maxLines;
    this['ellipsis'] = ellipsis;
    this['locale'] = locale;
    this['strutStyle'] = strutStyle;
    this['textWidthBasis'] = textWidthBasis;
  }
  
  // element attrs

  Shape get clip => this['clip'] as Shape;
  set clip(Shape value) => this['clip'] = value;

  Matrix get matrix => this['matrix'] as Matrix;
  set matrix(Matrix value) => this['matrix'] = value;

  double get x => this['x'] as double;
  set x(double value) => this['x'] = value;

  double get y => this['y'] as double;
  set y(double value) => this['y'] = value;

  double get x1 => this['x1'] as double;
  set x1(double value) => this['x1'] = value;

  double get y1 => this['y1'] as double;
  set y1(double value) => this['y1'] = value;

  double get x2 => this['x2'] as double;
  set x2(double value) => this['x2'] = value;

  double get y2 => this['y2'] as double;
  set y2(double value) => this['y2'] = value;

  double get r => this['r'] as double;
  set r(double value) => this['r'] = value;

  double get r0 => this['r0'] as double;
  set r0(double value) => this['r0'] = value;

  double get startAngle => this['startAngle'] as double;
  set startAngle(double value) => this['startAngle'] = value;

  double get endAngle => this['endAngle'] as double;
  set endAngle(double value) => this['endAngle'] = value;

  bool get clockwise => this['clockwise'] as bool ?? false;
  set clockwise(bool value) => this['clockwise'] = value;

  List<Offset> get points => this['points'] as List<Offset>;
  set points(List<Offset> value) => this['points'] = value;

  bool get smooth => this['smooth'] as bool ?? false;
  set smooth(bool value) => this['smooth'] = value;

  double get width => this['width'] as double;
  set width(double value) => this['width'] = value;

  double get height => this['height'] as double;
  set height(double value) => this['height'] = value;

  Path get path => this['path'] as Path;
  set path(Path value) => this['path'] = value;

  // Paint attrs, api refers to flutter 1.12.13

  bool get isAntiAlias => this['isAntiAlias'] as bool ?? true;
  set isAntiAlias(bool value) => this['isAntiAlias'] = value;

  Color get color => this['color'] as Color ?? Color.fromARGB(255, 0, 0, 0);
  set color(Color value) => this['color'] = value;

  BlendMode get blendMode => this['blendMode'] as BlendMode ?? BlendMode.srcOver;
  set blendMode(BlendMode value) => this['blendMode'] = value;

  PaintingStyle get style => this['style'] as PaintingStyle ?? PaintingStyle.fill;
  set style(PaintingStyle value) => this['style'] = value;

  double get strokeWidth => this['strokeWidth'] as double ?? 0;
  set strokeWidth(double value) => this['strokeWidth'] = value;

  StrokeCap get strokeCap => this['strokeCap'] as StrokeCap ?? StrokeCap.butt;
  set strokeCap(StrokeCap value) => this['strokeCap'] = value;

  StrokeJoin get strokeJoin => this['strokeJoin'] as StrokeJoin ?? StrokeJoin.miter;
  set strokeJoin(StrokeJoin value) => this['strokeJoin'] = value;

  double get strokeMiterLimit => this['strokeMiterLimit'] as double ?? 0;
  set strokeMiterLimit(double value) => this['strokeMiterLimit'] = value;

  MaskFilter get maskFilter => this['maskFilter'] as MaskFilter;
  set maskFilter(MaskFilter value) => this['maskFilter'] = value;

  FilterQuality get filterQuality => this['filterQuality'] as FilterQuality ?? FilterQuality.none;
  set filterQuality(FilterQuality value) => this['filterQuality'] = value;

  Shader get shader => this['shader'] as Shader;
  set shader(Shader value) => this['shader'] = value;

  ColorFilter get colorFilter => this['colorFilter'] as ColorFilter;
  set colorFilter(ColorFilter value) => this['colorFilter'] = value;

  ImageFilter get imageFilter => this['imageFilter'] as ImageFilter;
  set imageFilter(ImageFilter value) => this['imageFilter'] = value;

  bool get invertColors => this['invertColors'] as bool ?? false;
  set invertColors(bool value) => this['invertColors'] = value;

  // textPainter attrs, api refers to flutter 1.12.13

  InlineSpan get text => this['text'] as InlineSpan;
  set text(InlineSpan value) => this['text'] = value;

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

  // Tool members.

  void applyToPaint(Paint paint) {
    assert(paint != null);

    paint.blendMode = blendMode;
    paint.color = color;
    paint.colorFilter = colorFilter;
    paint.filterQuality = filterQuality;
    paint.imageFilter = imageFilter;
    paint.invertColors = invertColors;
    paint.isAntiAlias = isAntiAlias;
    paint.maskFilter = maskFilter;
    paint.shader = shader;
    paint.strokeCap = strokeCap;
    paint.strokeJoin = strokeJoin;
    paint.strokeMiterLimit = strokeMiterLimit;
    paint.strokeWidth = strokeWidth;
    paint.style = style;
  }

  void applyToTextPainter(TextPainter textPainter) {
    assert(textPainter != null);

    textPainter.text = text;
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
