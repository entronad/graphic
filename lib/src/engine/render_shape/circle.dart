import 'dart:ui';

import 'package:meta/meta.dart';
import 'package:graphic/src/common/base_classes.dart';

import 'base.dart';

class CircleRenderShapeProps extends Props<RenderShapeType> {
  CircleRenderShapeProps({
    @required double x,
    @required double y,
    @required double r,

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
  }) {
    this['x'] = x;
    this['y'] = y;
    this['r'] = r;

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
  }

  @override
  RenderShapeType get type => RenderShapeType.circle;
}

class CircleRenderShapeState extends RenderShapeState {
  double get x => this['x'] as double;
  set x(double value) => this['x'] = value;

  double get y => this['y'] as double;
  set y(double value) => this['y'] = value;

  double get r => this['r'] as double;
  set r(double value) => this['r'] = value;
}

class CircleRenderShape extends RenderShape<CircleRenderShapeState> {
  CircleRenderShape([CircleRenderShapeProps props]) : super(props);

  @override
  CircleRenderShapeState get originalState => CircleRenderShapeState();

  @override
  void createPath(Path path) {
    final x = state.x;
    final y = state.y;
    final r = state.r;

    path.addOval(Rect.fromCircle(center: Offset(x, y), radius: r));
  }
}
