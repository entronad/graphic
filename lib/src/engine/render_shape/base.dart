import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:meta/meta.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:graphic/src/common/typed_map.dart';

import '../element.dart';

enum RenderShapeType {
  arc,
  circle,
  line,
  polygon,
  polyline,
  rect,
  sector,
  text,

  custom,
}

abstract class RenderShapeAttrs extends ElementAttrs {
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

  RenderShapeType get type;
}

class RenderShapeProps<A extends RenderShapeAttrs> extends ElementProps<RenderShapeAttrs> {
  Rect get bbox => this['bbox'] as Rect;
  set bbox(Rect value) => this['bbox'] = value;

  // All components' type is got form props.type
  // RenderShapeType is determined by attrs type, but can be got from props.type
  RenderShapeType _type;
  RenderShapeType get type => _type;
}

abstract class RenderShape<P extends RenderShapeProps, A extends RenderShapeAttrs> extends Element<P, A> {
  static RenderShape create(RenderShapeAttrs attrs) {

  }

  RenderShape([TypedMap cfg]) : super(cfg) {
    props._type = attrs.type;
  }

  final Path _path = Path();

  final Paint _stylePaint = Paint();

  Path get path {
    _path.reset();
    createPath(_path);
    return _path;
  }

  Paint get stylePaint {
    attrs.applyToPaint(_stylePaint);
    return _stylePaint;
  }

  void createPath(Path path);

  @override
  void draw(Canvas canvas) {
    canvas.drawPath(path, stylePaint);
  }

  @override
  Rect get bbox {
    var bbox = props.bbox;
    if (bbox == null) {
      bbox = calculateBBox();
      props.bbox = bbox;
    }
    return bbox;
  }

  @protected
  Rect calculateBBox() {
    var bbox = _path.getBounds();
    if (attrs.style == PaintingStyle.stroke) {
      bbox = bbox.inflate(attrs.strokeWidth / 2);
    }
    final matrix = attrs.matrix;
    if (matrix != Matrix4.identity()) {
      bbox = MatrixUtils.transformRect(matrix, bbox);
    }
    return bbox;
  }
}