import 'dart:ui';

import 'package:meta/meta.dart';

import 'base.dart';

class PolygonRenderShape extends RenderShape {
  PolygonRenderShape({
    @required List<Offset> points,

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
  RenderShapeType get type => RenderShapeType.polygon;
}

class PolygonRenderShapeState extends RenderShapeState {
  List<Offset> get points => this['points'] as List<Offset>;
  set points(List<Offset> value) => this['points'] = value;
}

class PolygonRenderShapeComponent
  extends RenderShapeComponent<PolygonRenderShapeState>
{
  PolygonRenderShapeComponent([PolygonRenderShape props]) : super(props);

  @override
  PolygonRenderShapeState createState() => PolygonRenderShapeState();

  @override
  void createPath(Path path) {
    final points = state.points;

    if (points.isEmpty) {
      return;
    }

    path.moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final point = points[i];
      path.lineTo(point.dx, point.dy);
    }
    path.close();
  }
}
