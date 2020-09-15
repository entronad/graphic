import 'dart:ui';

import 'package:meta/meta.dart';

import 'base.dart';
import '../util/smooth.dart' as smooth_util;

List<Offset> _filterPoints(List<Offset> points) {
  final filteredPoints = <Offset>[];
  for (var point in points) {
    if (
      point.dx != null && point.dx.isFinite &&
      point.dy != null && point.dy.isFinite
    ) {
      filteredPoints.add(point);
    }
  }
  return filteredPoints;
}

class PolylineRenderShape extends RenderShape {
  PolylineRenderShape({
    @required List<Offset> points,
    bool smooth,

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
    this['points'] = points;
    this['smooth'] = smooth;

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
  RenderShapeType get type => RenderShapeType.polyline;
}

class PolylineRenderShapeState extends RenderShapeState {
  List<Offset> get points => this['points'] as List<Offset>;
  set points(List<Offset> value) => this['points'] = value;

  bool get smooth => this['smooth'] as bool ?? false;
  set smooth(bool value) => this['smooth'] = value;
}

class PolylineRenderShapeComponent
  extends RenderShapeComponent<PolylineRenderShapeState>
{
  PolylineRenderShapeComponent([PolylineRenderShape props]) : super(props);

  @override
  PolylineRenderShapeState get originalState => PolylineRenderShapeState();

  @override
  void initDefaultState() {
    super.initDefaultState();
    state
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
  }

  @override
  void createPath(Path path) {
    final points = state.points;
    final smooth = state.smooth;

    final filteredPoints = _filterPoints(points);

    if (filteredPoints.isEmpty) {
      return;
    }

    path.moveTo(filteredPoints[0].dx, filteredPoints[0].dy);
    if (smooth) {
      final segments = smooth_util.smooth(filteredPoints, false, true);
      for (var s in segments) {
        path.cubicTo(s.cp1.dx, s.cp1.dy, s.cp2.dx, s.cp2.dy, s.p.dx, s.p.dy);
      }
    } else {
      for (var i = 1; i < filteredPoints.length; i++) {
        path.lineTo(filteredPoints[i].dx, filteredPoints[i].dy);
      }
    }
  }
}
