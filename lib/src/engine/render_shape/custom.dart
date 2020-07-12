import 'dart:ui';

import 'package:meta/meta.dart';
import 'package:graphic/src/common/typed_map.dart';
import 'package:graphic/src/common/base_classes.dart';

import 'base.dart';

class CustomRenderShapeProps extends Props<RenderShapeType> {
  CustomRenderShapeProps({
    @required Path path,

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
    this['path'] = path;

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
  RenderShapeType get type => RenderShapeType.custom;
}

class CustomRenderShapeState extends RenderShapeState {
  Path get path => this['path'] as Path;
  set path(Path value) => this['path'] = value;
}

class CustomRenderShape extends RenderShape<CustomRenderShapeState> {
  CustomRenderShape([TypedMap cfg]) : super(cfg);

  @override
  CustomRenderShapeState get originalState => CustomRenderShapeState();

  @override
  void createPath(Path path) {
    path.addPath(path, Offset(0, 0));
  }
}
