import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:graphic/src/common/layers.dart';
import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/coord/polar.dart';
import 'package:graphic/src/coord/rect.dart';
import 'package:graphic/src/scale/scale.dart';
import 'package:graphic/src/shape/util/paths.dart';

import 'annotation.dart';

class RegionAnnotation extends Annotation {
  RegionAnnotation({
    this.dim,
    this.variable,
    required this.values,
    this.color,

    int? zIndex,
  }) : super(
    zIndex: zIndex,
  );

  final int? dim;

  final String? variable;

  final List values;

  final Color? color;

  @override
  bool operator ==(Object other) =>
    other is RegionAnnotation &&
    super == other &&
    dim == other.dim &&
    variable == other.variable &&
    DeepCollectionEquality().equals(values, other.values) &&
    color == color;
}

class RectRegionAnnotPainter extends AnnotPainter {
  RectRegionAnnotPainter(
    this.p1,
    this.p2,
    this.color,
  );

  final Offset p1;

  final Offset p2;

  final Color color;

  @override
  void paint(Canvas canvas) => canvas.drawRect(
    Rect.fromPoints(p1, p2),
    Paint()..color = color,
  );
}

class SectorRegionAnnotPainter extends AnnotPainter {
  SectorRegionAnnotPainter(
    this.center,
    this.r,
    this.r0,
    this.startAngle,
    this.endAngle,
    this.color,
  );

  final Offset center;

  final double r;

  final double r0;

  final double startAngle;

  final double endAngle;

  final Color color;

  @override
  void paint(Canvas canvas) => canvas.drawPath(
    Paths.sector(
      center: center,
      r: r,
      r0: r0,
      startAngle: startAngle,
      endAngle: endAngle,
      clockwise: true,
    ),
    Paint()..color = color,
  );
}

class RegionAnnotScene extends AnnotScene {
  @override
  int get layer => Layers.regionAnnot;
}

class RegionAnnotRenderOp extends AnnotRenderOp<RegionAnnotScene> {
  RegionAnnotRenderOp(
    Map<String, dynamic> params,
    RegionAnnotScene value,
  ) : super(params, value);

  @override
  void render(RegionAnnotScene scene) {
    final dim = params['dim'] as int;
    final variable = params['variable'] as String;
    final values = params['values'] as List;
    final color = params['color'] as Color;
    final zIndex = params['zIndex'] as int;
    final scales = params['scales'] as Map<String, ScaleConv>;
    final coord = params['coord'] as CoordConv;
    final region = params['region'] as Rect;

    scene
      ..zIndex = zIndex
      ..setRegionClip(region, coord is PolarCoordConv);
    
    final scale = scales[variable]!;
    final start = scale.normalize(scale.convert(values.first));
    final end = scale.normalize(scale.convert(values.last));

    if (coord is RectCoordConv) {
      scene.painter = RectRegionAnnotPainter(
        coord.convert(
          dim == 1
            ? Offset(start, 0)
            : Offset(0, start),
        ),
        coord.convert(
          dim == 1 
            ? Offset(end, 1)
            : Offset(1, end),
        ),
        color,
      );
    } else {
      coord as PolarCoordConv;
      if (coord.getCanvasDim(dim) == 1) {
        scene.painter = SectorRegionAnnotPainter(
          coord.center,
          coord.radiuses.last,
          coord.radiuses.first,
          coord.convertAngle(start),
          coord.convertAngle(end),
          color,
        );
      } else {
        scene.painter = SectorRegionAnnotPainter(
          coord.center,
          coord.convertRadius(end),
          coord.convertRadius(start),
          coord.angles.first,
          coord.angles.last,
          color,
        );
      }
    }
  }
}
