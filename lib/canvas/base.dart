import 'dart:ui';

import 'package:vector_math/vector_math_64.dart' show Matrix4;

import './event/event_emitter.dart' show EventEmitter;

abstract class Attrs {
  Attrs({
    double strokeAppendWidth,
    Matrix4 matrix,

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

  final Map<String, dynamic> _attrs;

  bool get strokeAppendWidth => _attrs['strokeAppendWidth'] as bool;
  set strokeAppendWidth(bool value) => _attrs['strokeAppendWidth'] = value;

  bool get matrix => _attrs['matrix'] as bool;
  set matrix(bool value) => _attrs['matrix'] = value;

  // Paint attrs, api refers to flutter 1.12.13

  bool get isAntiAlias => _attrs['isAntiAlias'] as bool;
  set isAntiAlias(bool value) => _attrs['isAntiAlias'] = value;

  Color get color => _attrs['color'] as Color;
  set color(Color value) => _attrs['color'] = value;

  BlendMode get blendMode => _attrs['blendMode'] as BlendMode;
  set blendMode(BlendMode value) => _attrs['blendMode'] = value;

  PaintingStyle get style => _attrs['style'] as PaintingStyle;
  set style(PaintingStyle value) => _attrs['style'] = value;

  double get strokeWidth => _attrs['strokeWidth'] as double;
  set strokeWidth(double value) => _attrs['strokeWidth'] = value;

  StrokeCap get strokeCap => _attrs['strokeCap'] as StrokeCap;
  set strokeCap(StrokeCap value) => _attrs['strokeCap'] = value;

  StrokeJoin get strokeJoin => _attrs['strokeJoin'] as StrokeJoin;
  set strokeJoin(StrokeJoin value) => _attrs['strokeJoin'] = value;

  double get strokeMiterLimit => _attrs['strokeMiterLimit'] as double;
  set strokeMiterLimit(double value) => _attrs['strokeMiterLimit'] = value;

  MaskFilter get maskFilter => _attrs['maskFilter'] as MaskFilter;
  set maskFilter(MaskFilter value) => _attrs['maskFilter'] = value;

  FilterQuality get filterQuality => _attrs['filterQuality'] as FilterQuality;
  set filterQuality(FilterQuality value) => _attrs['filterQuality'] = value;

  Shader get shader => _attrs['shader'] as Shader;
  set shader(Shader value) => _attrs['shader'] = value;

  ColorFilter get colorFilter => _attrs['colorFilter'] as ColorFilter;
  set colorFilter(ColorFilter value) => _attrs['colorFilter'] = value;

  ImageFilter get imageFilter => _attrs['imageFilter'] as ImageFilter;
  set imageFilter(ImageFilter value) => _attrs['imageFilter'] = value;

  bool get invertColors => _attrs['invertColors'] as bool;
  set invertColors(bool value) => _attrs['invertColors'] = value;

  Attrs mix(Iterable<Attrs> srcs) {
    for (var src in srcs) {
      _attrs.addAll(src._attrs);
    }
    return this;
  }

  void applyTo(Paint paint) {
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
}

class Cfg {
  Cfg({
    bool destroyed,

    String id,
    int zIndex,
    bool visible,
    bool capture,

    Attrs attrs,
  })
    : _cfg = {
      if (destroyed != null) 'destroyed': destroyed,
      if (id != null) 'id': id,
      if (zIndex != null) 'zIndex': zIndex,
      if (visible != null) 'visible': visible,
      if (capture != null) 'capture': capture,
      if (attrs != null) 'attrs': attrs,
    };

  final Map<String, dynamic> _cfg;

  // base cfg

  bool get destroyed => _cfg['destroyed'] as bool;
  set destroyed(bool value) => _cfg['destroyed'] = value;

  // element cfg

  String get id => _cfg['id'] as String;
  set id(String value) => _cfg['id'] = value;

  int get zIndex => _cfg['zIndex'] as int;
  set zIndex(int value) => _cfg['zIndex'] = value;

  bool get visible => _cfg['visible'] as bool;
  set visible(bool value) => _cfg['visible'] = value;

  bool get capture => _cfg['capture'] as bool;
  set capture(bool value) => _cfg['capture'] = value;

  // shape cfg
  Attrs get attrs => _cfg['attrs'] as Attrs;
  set attrs(Attrs value) => _cfg['attrs'] = value;

  Cfg mix(Iterable<Cfg> srcs) {
    for (var src in srcs) {
      _cfg.addAll(src._cfg);
    }
    return this;
  }
}

abstract class Base extends EventEmitter {
  Base(Cfg cfg){
    this.cfg = defaultCfg.mix([cfg]);
  } 

  Cfg cfg;

  bool destroyed = false;

  Cfg get defaultCfg => Cfg();

  void destroy() {
    cfg = Cfg(destroyed: true);
    off();
    destroyed = true;
  }
}
