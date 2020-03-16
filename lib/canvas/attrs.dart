import 'dart:ui';

import 'package:vector_math/vector_math_64.dart' show Matrix4;

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

  // Paint attrs, api refers to flutter 1.12.13

  bool get isAntiAlias => this['isAntiAlias'] as bool;
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

  bool get invertColors => this['invertColors'] as bool;
  set invertColors(bool value) => this['invertColors'] = value;

  // Tool members.

  Iterable<String> get keys => _attrs.keys;

  Attrs mix(Attrs src) => this.._attrs.addAll(src._attrs);

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
    if (paint == null) {
      return;
    }
    if (blendMode != null) {
      paint.blendMode = blendMode;
    }
    if (color != null) {
      paint.color = color;
    }
    if (colorFilter != null) {
      paint.colorFilter = colorFilter;
    }
    if (filterQuality != null) {
      paint.filterQuality = filterQuality;
    }
    if (imageFilter != null) {
      paint.imageFilter = imageFilter;
    }
    if (invertColors != null) {
      paint.invertColors = invertColors;
    }
    if (isAntiAlias != null) {
      paint.isAntiAlias = isAntiAlias;
    }
    if (maskFilter != null) {
      paint.maskFilter = maskFilter;
    }
    if (shader != null) {
      paint.shader = shader;
    }
    if (strokeCap != null) {
      paint.strokeCap = strokeCap;
    }
    if (strokeJoin != null) {
      paint.strokeJoin = strokeJoin;
    }
    if (strokeMiterLimit != null) {
      paint.strokeMiterLimit = strokeMiterLimit;
    }
    if (strokeWidth != null) {
      paint.strokeWidth = strokeWidth;
    }
    if (style != null) {
      paint.style = style;
    }
  }

  Object operator [](String k) => _attrs[k];

  void operator []=(String k, Object v) => v == null ? _attrs.remove(k) : _attrs[k] = v;
}
