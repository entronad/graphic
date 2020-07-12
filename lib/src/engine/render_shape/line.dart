import 'dart:ui';

import 'package:graphic/src/common/base_classes.dart';
import 'package:meta/meta.dart';
import 'package:graphic/src/common/typed_map.dart';

import 'base.dart';

class LineRenderShapeProps extends Props<RenderShapeType> {
  LineRenderShapeProps({
    @required double x1,
    @required double y1,
    @required double x2,
    @required double y2,

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
    this['x1'] = x1;
    this['y1'] = y1;
    this['x2'] = x2;
    this['y2'] = y2;

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
  RenderShapeType get type => RenderShapeType.line;
}

class LineRenderShapeState extends RenderShapeState {
  double get x1 => this['x1'] as double;
  set x1(double value) => this['x1'] = value;

  double get y1 => this['y1'] as double;
  set y1(double value) => this['y1'] = value;

  double get x2 => this['x2'] as double;
  set x2(double value) => this['x2'] = value;

  double get y2 => this['y2'] as double;
  set y2(double value) => this['y2'] = value;
}

class LineRenderShape extends RenderShape<LineRenderShapeState> {
  LineRenderShape([TypedMap cfg]) : super(cfg);

  @override
  LineRenderShapeState get originalState => LineRenderShapeState();

  @override
  void initDefaultState() {
    super.initDefaultState();
    state
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
  }

  @override
  void createPath(Path path) {
    final x1 = state.x1;
    final y1 = state.y1;
    final x2 = state.x2;
    final y2 = state.y2;

    path.moveTo(x1, y1);
    path.lineTo(x2, y2);
  }
}
