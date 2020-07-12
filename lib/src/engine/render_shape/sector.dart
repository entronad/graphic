import 'dart:ui';
import 'dart:math';

import 'package:meta/meta.dart';
import 'package:graphic/src/common/typed_map.dart';
import 'package:graphic/src/common/base_classes.dart';

import 'base.dart';

class SectorRenderShapeProps extends Props<RenderShapeType> {
  SectorRenderShapeProps({
    @required double x,
    @required double y,
    @required double r,
    double r0,
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
    this['r0'] = r0;
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
  RenderShapeType get type => RenderShapeType.sector;
}

class SectorRenderShapeState extends RenderShapeState {
  double get x => this['x'] as double;
  set x(double value) => this['x'] = value;

  double get y => this['y'] as double;
  set y(double value) => this['y'] = value;

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
}

class SectorRenderShape extends RenderShape<SectorRenderShapeState> {
  SectorRenderShape([TypedMap cfg]) : super(cfg);

  @override
  SectorRenderShapeState get originalState => SectorRenderShapeState();

  @override
  void initDefaultState() {
    super.initDefaultState();
    state
      ..r0 = 0
      ..startAngle = 0
      ..endAngle = 2 * pi
      ..clockwise = true;
  }

  @override
  void createPath(Path path) {
    final x = state.x;
    final y = state.y;
    final r = state.r;
    final r0 = state.r0;
    final startAngle = state.startAngle;
    final endAngle = state.endAngle;
    final clockwise = state.clockwise;

    final sweepAngle = clockwise ? endAngle - startAngle : startAngle - endAngle;
    final unitX = cos(startAngle);
    final unitY = sin(startAngle);

    path.moveTo(unitX * r0 + x, unitY * r0 + y);
    path.lineTo(unitX * r + x, unitY * r + y);

    if (sweepAngle.abs() > 0.0001 || startAngle == 0 && endAngle < 0) {
      path.arcTo(
        Rect.fromCircle(center: Offset(x, y), radius: r),
        startAngle,
        sweepAngle,
        false,
      );
      path.lineTo(cos(endAngle) * r0 + x, sin(endAngle) * r0 + y);
      if (r0 != 0) {
        path.arcTo(
          Rect.fromCircle(center: Offset(x, y), radius: r0),
          endAngle,
          -sweepAngle,
          false,
        );
      }
    }
    path.close();
  }
}
