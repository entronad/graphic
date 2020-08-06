import 'dart:ui';
import 'dart:math';

import 'package:meta/meta.dart';

import 'base.dart';

class ArcRenderShape extends RenderShape {
  ArcRenderShape({
    @required double x,
    @required double y,
    @required double r,
    double startAngle,
    double endAngle,
    bool clockwise,

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
    this['startAngle'] = startAngle;
    this['endAngle'] = endAngle;
    this['clockwise'] = clockwise;

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
  RenderShapeType get type => RenderShapeType.arc;
}

class ArcRenderShapeState extends RenderShapeState {
  double get x => this['x'] as double;
  set x(double value) => this['x'] = value;

  double get y => this['y'] as double;
  set y(double value) => this['y'] = value;

  double get r => this['r'] as double;
  set r(double value) => this['r'] = value;

  double get startAngle => this['startAngle'] as double;
  set startAngle(double value) => this['startAngle'] = value;

  double get endAngle => this['endAngle'] as double;
  set endAngle(double value) => this['endAngle'] = value;

  bool get clockwise => this['clockwise'] as bool ?? false;
  set clockwise(bool value) => this['clockwise'] = value;
}

class ArcRenderShapeComponent
  extends RenderShapeComponent<ArcRenderShapeState>
{
  ArcRenderShapeComponent([ArcRenderShape props]) : super(props);

  @override
  ArcRenderShapeState get originalState => ArcRenderShapeState();

  @override
  void initDefaultState() {
    super.initDefaultState();
    state
      ..startAngle = 0
      ..endAngle = 2 * pi
      ..clockwise = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
  }

  @override
  void createPath(Path path) {
    final x = state.x;
    final y = state.y;
    final r = state.r;
    final startAngle = state.startAngle;
    final endAngle = state.endAngle;
    final clockwise = state.clockwise;

    final sweepAngle = clockwise ? endAngle - startAngle : startAngle - endAngle;
    path.addArc(
      Rect.fromCircle(center: Offset(x, y), radius: r),
      startAngle,
      sweepAngle,
    );
  }
}
