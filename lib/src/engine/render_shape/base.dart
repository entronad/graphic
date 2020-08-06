import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:graphic/src/common/base_classes.dart';
import 'package:meta/meta.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:graphic/src/common/typed_map.dart';

import '../node.dart';
import 'arc.dart';
import 'circle.dart';
import 'custom.dart';
import 'line.dart';
import 'polygon.dart';
import 'polyline.dart';
import 'rect.dart';
import 'sector.dart';
import 'text.dart';

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

abstract class RenderShape extends Props<RenderShapeType> {}

abstract class RenderShapeState extends NodeState {
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
}

abstract class RenderShapeComponent<S extends RenderShapeState> extends Node<S> {
  static RenderShapeComponent create(RenderShape props) {
    switch (props.type) {
      case RenderShapeType.arc:
        return ArcRenderShapeComponent(props);
      case RenderShapeType.circle:
        return CircleRenderShapeComponent(props);
      case RenderShapeType.custom:
        return CustomRenderShapeComponent(props);
      case RenderShapeType.line:
        return LineRenderShapeComponent(props);
      case RenderShapeType.polygon:
        return PolygonRenderShapeComponent(props);
      case RenderShapeType.polyline:
        return PolylineRenderShapeComponent(props);
      case RenderShapeType.rect:
        return RectRenderShapeComponent(props);
      case RenderShapeType.sector:
        return SectorRenderShapeComponent(props);
      case RenderShapeType.text:
        return TextRenderShapeComponent(props);
      default: return null;
    }
  }

  RenderShapeComponent([TypedMap props]) : super(props) {
    assign();
  }

  final Path _path = Path();

  final Paint _style = Paint();

  @protected
  Rect shapeBBox;

  Path get path => _path;

  Paint get stylePaint => _style;

  @override
  Rect get bbox => shapeBBox;

  @override
  void draw(Canvas canvas) {
    canvas.drawPath(path, stylePaint);
  }

  void setProps(RenderShape props) {
    state.mix(props);
    onSetProps();
  }

  @protected
  void onSetProps() {
    assign();
  }

  @protected
  void assign() {
    _path.reset();
    createPath(_path);

    state.applyToPaint(_style);

    shapeBBox = calculateBBox();
  }

  @override
  void onTransform() {
    super.onTransform();

    // Transform only affects bbox.
    shapeBBox = calculateBBox();
  }

  @protected
  void createPath(Path path);

  @protected
  Rect calculateBBox() {
    var bbox = _path.getBounds();
    if (state.style == PaintingStyle.stroke) {
      bbox = bbox.inflate(state.strokeWidth / 2);
    }
    final matrix = state.matrix;
    if (matrix != Matrix4.identity()) {
      bbox = MatrixUtils.transformRect(matrix, bbox);
    }
    return bbox;
  }
}
