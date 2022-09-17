import 'package:flutter/painting.dart';
import 'package:graphic/src/common/dim.dart';
import 'package:graphic/src/util/assert.dart';
import 'package:graphic/src/util/collection.dart';
import 'package:graphic/src/chart/view.dart';
import 'package:graphic/src/common/intrinsic_layers.dart';
import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/coord/polar.dart';
import 'package:graphic/src/coord/rect.dart';
import 'package:graphic/src/graffiti/figure.dart';
import 'package:graphic/src/scale/scale.dart';
import 'package:graphic/src/util/path.dart';

import 'annotation.dart';

/// The specification of a region annotation.
class RegionAnnotation extends Annotation {
  /// Creates a region annotation.
  RegionAnnotation({
    this.dim,
    this.variable,
    required this.values,
    this.color,
    this.gradient,
    int? layer,
  })  : assert(isSingle([color, gradient])),
        super(
          layer: layer,
        );

  /// The dimension where this region stands.
  ///
  /// If null, a default [Dim.x] is set.
  Dim? dim;

  /// The variable refered to for position.
  ///
  /// If null, the first variable assigned to [dim] is set by default.
  String? variable;

  /// The values of [variable] for position.
  ///
  /// It is of 2 values for start and end respectively.
  List values;

  /// The color of this region.
  ///
  /// Only one in [color] and [gradient] can be set.
  Color? color;

  /// The gradient of this region.
  ///
  /// Only one in [color] and [gradient] can be set.
  Gradient? gradient;

  @override
  bool operator ==(Object other) =>
      other is RegionAnnotation &&
      super == other &&
      dim == other.dim &&
      variable == other.variable &&
      deepCollectionEquals(values, other.values) &&
      color == other.color &&
      gradient == other.gradient;
}

/// The region annotation scene.
class RegionAnnotScene extends AnnotScene {
  RegionAnnotScene(int layer) : super(layer);

  @override
  int get intrinsicLayer => IntrinsicLayers.regionAnnot;
}

/// The region annotation render operator.
class RegionAnnotRenderOp extends AnnotRenderOp<RegionAnnotScene> {
  RegionAnnotRenderOp(
    Map<String, dynamic> params,
    RegionAnnotScene scene,
    View view,
  ) : super(params, scene, view);

  @override
  void render() {
    final dim = params['dim'] as Dim;
    final variable = params['variable'] as String;
    final values = params['values'] as List;
    final color = params['color'] as Color?;
    final gradient = params['gradient'] as Gradient?;
    final scales = params['scales'] as Map<String, ScaleConv>;
    final coord = params['coord'] as CoordConv;

    scene.setRegionClip(coord.region);

    final scale = scales[variable]!;
    final start = scale.normalize(scale.convert(values.first));
    final end = scale.normalize(scale.convert(values.last));

    final Path path;
    if (coord is RectCoordConv) {
      path = Path()
        ..addRect(Rect.fromPoints(
          coord.convert(
            dim == Dim.x ? Offset(start, 0) : Offset(0, start),
          ),
          coord.convert(
            dim == Dim.x ? Offset(end, 1) : Offset(1, end),
          ),
        ));
    } else {
      coord as PolarCoordConv;
      if (coord.getCanvasDim(dim) == Dim.x) {
        path = Paths.sector(
          center: coord.center,
          r: coord.radiuses.last,
          r0: coord.radiuses.first,
          startAngle: coord.convertAngle(start),
          endAngle: coord.convertAngle(end),
          clockwise: true,
        );
      } else {
        path = Paths.sector(
          center: coord.center,
          r: coord.convertRadius(end),
          r0: coord.convertRadius(start),
          startAngle: coord.angles.first,
          endAngle: coord.angles.last,
          clockwise: true,
        );
      }
    }

    final paint = Paint();
    if (color != null) {
      paint.color = color;
    }
    if (gradient != null) {
      paint.shader = gradient.createShader(path.getBounds());
    }

    scene.figures = [
      PathFigure(path, paint),
    ];
  }
}
