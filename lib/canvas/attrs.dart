import 'dart:ui';

import 'package:vector_math/vector_math_64.dart' show Matrix4;

import './shape/path_segment.dart' show PathSegment;
import './shape/marker.dart' show SymbolType;

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

    SymbolType symbolType,

    List<Offset> points,

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
      if (symbolType != null) 'symbolType': symbolType,
      if (points != null) 'points': points,
      // paint attrs
      'isAntiAlias': isAntiAlias != null ? isAntiAlias : true,
      'color': color != null ? color : Color.fromARGB(255, 0, 0, 0),
      'blendMode': blendMode != null ? blendMode : BlendMode.srcOver,
      'style': style != null ? style : PaintingStyle.fill,
      'strokeWidth': strokeWidth != null ? strokeWidth : 0.0,
      'strokeCap': strokeCap != null ? strokeCap : StrokeCap.butt,
      'strokeJoin': strokeJoin != null ? strokeJoin : StrokeJoin.miter,
      'strokeMiterLimit': strokeMiterLimit != null ? strokeMiterLimit : 0.0,
      'maskFilter': maskFilter != null ? maskFilter : null,
      'filterQuality': filterQuality != null ? filterQuality : FilterQuality.none,
      'shader': shader != null ? shader : null,
      'colorFilter': colorFilter != null ? colorFilter : null,
      'imageFilter': imageFilter != null ? imageFilter : null,
      'invertColors': invertColors != null ? invertColors : false,
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
  SymbolType get symbolType => this['symbolType'] as SymbolType;
  set symbolType(SymbolType value) => this['symbolType'] = value;

  // polyline polygon attrs
  List<Offset> get points => this['points'] as List<Offset>;
  set points(List<Offset> value) => this['points'] = value;

  // Paint attrs, api refers to flutter 1.12.13

  bool get isAntiAlias => this['isAntiAlias'] as bool ?? false;
  set isAntiAlias(bool value) => this['isAntiAlias'] = value;

  Color get color => this['color'] as Color;
  set color(Color value) => this['color'] = value;

  BlendMode get blendMode => this['blendMode'] as BlendMode;
  set blendMode(BlendMode value) => this['blendMode'] = value;

  PaintingStyle get style => this['style'] as PaintingStyle;
  set style(PaintingStyle value) => this['style'] = value;

  double get strokeWidth => this['strokeWidth'] as double;
  set strokeWidth(double value) => this['strokeWidth'] = value;

  StrokeCap get strokeCap => this['strokeCap'] as StrokeCap;
  set strokeCap(StrokeCap value) => this['strokeCap'] = value;

  StrokeJoin get strokeJoin => this['strokeJoin'] as StrokeJoin;
  set strokeJoin(StrokeJoin value) => this['strokeJoin'] = value;

  double get strokeMiterLimit => this['strokeMiterLimit'] as double;
  set strokeMiterLimit(double value) => this['strokeMiterLimit'] = value;

  MaskFilter get maskFilter => this['maskFilter'] as MaskFilter;
  set maskFilter(MaskFilter value) => this['maskFilter'] = value;

  FilterQuality get filterQuality => this['filterQuality'] as FilterQuality;
  set filterQuality(FilterQuality value) => this['filterQuality'] = value;

  Shader get shader => this['shader'] as Shader;
  set shader(Shader value) => this['shader'] = value;

  ColorFilter get colorFilter => this['colorFilter'] as ColorFilter;
  set colorFilter(ColorFilter value) => this['colorFilter'] = value;

  ImageFilter get imageFilter => this['imageFilter'] as ImageFilter;
  set imageFilter(ImageFilter value) => this['imageFilter'] = value;

  bool get invertColors => this['invertColors'] as bool ?? false;
  set invertColors(bool value) => this['invertColors'] = value;

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

  void applyTo(Paint paint) {
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

  Object operator [](String k) => _attrs[k];

  void operator []=(String k, Object v) => v == null ? _attrs.remove(k) : _attrs[k] = v;
}
