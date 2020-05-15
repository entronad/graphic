import 'dart:ui';

import 'package:flutter/painting.dart';

import 'package:vector_math/vector_math_64.dart' show Matrix4;

import './shape/path_segment.dart' show PathSegment;
import './shape/marker.dart' show Symbol;

List<T> _cloneListAttr<T>(List<T> list) {
  if (list is List<List>) {
    final rst = <T>[];
    for (var subList in list) {
      rst.add([...(subList as List)] as T);
    }
    return rst;
  } else {
    return [...list];
  }
}

class Attrs {
  Attrs({
    double strokeAppendWidth,
    Matrix4 matrix,

    double x,
    double y,
    double r,
    double x1,
    double y1,
    double x2,
    double y2,
    double width,
    double height,
    double rx,
    double ry,

    List<PathSegment> segments,

    Symbol symbol,

    List<Offset> points,

    Image image,

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
  })
    : _attrs = {
      if (strokeAppendWidth != null) 'strokeAppendWidth': strokeAppendWidth,
      if (matrix != null) 'matrix': matrix,
      if (x != null) 'x': x,
      if (y != null) 'y': y,
      if (r != null) 'r': r,
      if (x1 != null) 'x1': x1,
      if (y1 != null) 'y1': y1,
      if (x2 != null) 'x2': x2,
      if (y2 != null) 'y2': y2,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (rx != null) 'rx': rx,
      if (ry != null) 'ry': ry,
      if (segments != null) 'segments': segments,
      if (symbol != null) 'symbol': symbol,
      if (points != null) 'points': points,
      if (image != null) 'image': image,
      if (isAntiAlias != null) 'isAntiAlias': isAntiAlias,
      if (color != null) 'color': color,
      if (blendMode != null) 'blendMode': blendMode,
      if (style != null) 'style': style,
      if (strokeWidth != null) 'strokeWidth': strokeWidth,
      if (strokeCap != null) 'strokeCap': strokeCap,
      if (strokeJoin != null) 'strokeJoin': strokeJoin,
      if (strokeMiterLimit != null) 'strokeMiterLimit': strokeMiterLimit,
      if (maskFilter != null) 'maskFilter': maskFilter,
      if (filterQuality != null) 'filterQuality': filterQuality,
      if (shader != null) 'shader': shader,
      if (colorFilter != null) 'colorFilter': colorFilter,
      if (imageFilter != null) 'imageFilter': imageFilter,
      if (invertColors != null) 'invertColors': invertColors,
      if (text != null) 'text': text,
      if (textAlign != null) 'textAlign': textAlign,
      if (textDirection != null) 'textDirection': textDirection,
      if (textScaleFactor != null) 'textScaleFactor': textScaleFactor,
      if (maxLines != null) 'maxLines': maxLines,
      if (ellipsis != null) 'ellipsis': ellipsis,
      if (locale != null) 'locale': locale,
      if (strutStyle != null) 'strutStyle': strutStyle,
      if (textWidthBasis != null) 'textWidthBasis': textWidthBasis,
    };

  final Map<String, Object> _attrs;

  // element attrs

  double get strokeAppendWidth => this['strokeAppendWidth'] as double;
  set strokeAppendWidth(double value) => this['strokeAppendWidth'] = value;

  Matrix4 get matrix => this['matrix'] as Matrix4;
  set matrix(Matrix4 value) => this['matrix'] = value;

  // shape attrs

  double get x => this['x'] as double;
  set x(double value) => this['x'] = value;

  double get y => this['y'] as double;
  set y(double value) => this['y'] = value;

  double get r => this['r'] as double;
  set r(double value) => this['r'] = value;

  double get x1 => this['x1'] as double;
  set x1(double value) => this['x1'] = value;

  double get y1 => this['y1'] as double;
  set y1(double value) => this['y1'] = value;

  double get x2 => this['x2'] as double;
  set x2(double value) => this['x2'] = value;

  double get y2 => this['y2'] as double;
  set y2(double value) => this['y2'] = value;

  double get width => this['width'] as double;
  set width(double value) => this['width'] = value;

  double get height => this['height'] as double;
  set height(double value) => this['height'] = value;

  double get rx => this['rx'] as double;
  set rx(double value) => this['rx'] = value;

  double get ry => this['ry'] as double;
  set ry(double value) => this['ry'] = value;

  // path attrs

  List<PathSegment> get segments => this['segments'] as List<PathSegment>;
  set segments(List<PathSegment> value) => this['segments'] = value;

  // marker attrs
  Symbol get symbol => this['symbol'] as Symbol;
  set symbol(Symbol value) => this['symbol'] = value;

  // polyline polygon attrs
  List<Offset> get points => this['points'] as List<Offset>;
  set points(List<Offset> value) => this['points'] = value;

  // image attrs
  Image get image => this['image'] as Image;
  set image(Image value) => this['image'] = value;

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

  // textPainter attrs

  InlineSpan get text => this['text'] as InlineSpan;
  set text(InlineSpan value) => this['text'] = value;

  TextAlign get textAlign => this['textAlign'] as TextAlign ?? TextAlign.start;
  set textAlign(TextAlign value) => this['textAlign'] = value;

  // This default value TextDirection.ltr is picked randomly. It dose not mean that we hold
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

  Iterable<String> get keys => _attrs.keys;

  Attrs mix(Attrs src) {
    if (src != null) {
      this._attrs.addAll(src._attrs);
    }
    return this;
  }

  Attrs clone() {
    final rst = Attrs();
    for (var k in _attrs.keys) {
      if (_attrs[k] is List) {
        rst[k] = _cloneListAttr(_attrs[k]);
      } else if(_attrs[k] is Matrix4) {
        rst[k] = (_attrs[k] as Matrix4).clone();
      } else {
        rst[k] = _attrs[k];
      }
    }
    return rst;
  }

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

  Object operator [](String k) => _attrs[k];

  void operator []=(String k, Object v) => v == null ? _attrs.remove(k) : _attrs[k] = v;
}
