import 'package:flutter/painting.dart';
import 'package:graphic/src/common/dim.dart';
import 'package:graphic/src/graffiti/element/rect.dart';
import 'package:graphic/src/graffiti/element/sector.dart';
import 'package:graphic/src/graffiti/scene.dart';
import 'package:graphic/src/util/assert.dart';
import 'package:graphic/src/util/collection.dart';
import 'package:graphic/src/chart/view.dart';
import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/coord/polar.dart';
import 'package:graphic/src/coord/rect.dart';
import 'package:graphic/src/graffiti/element/element.dart';
import 'package:graphic/src/scale/scale.dart';

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

/// The region annotation render operator.
class RegionAnnotRenderOp extends AnnotRenderOp {
  RegionAnnotRenderOp(
    Map<String, dynamic> params,
    Scene scene,
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

    final style = PaintStyle(fillColor: color, fillGradient: gradient);

    final scale = scales[variable]!;
    final start = scale.normalize(scale.convert(values.first));
    final end = scale.normalize(scale.convert(values.last));

    if (coord is RectCoordConv) {
      scene.set([RectElement(rect: Rect.fromPoints(
          coord.convert(
            dim == Dim.x ? Offset(start, 0) : Offset(0, start),
          ),
          coord.convert(
            dim == Dim.x ? Offset(end, 1) : Offset(1, end),
          ),
        ), style: style)], RectElement(rect: coord.region));
    } else {
      coord as PolarCoordConv;
      if (coord.getCanvasDim(dim) == Dim.x) {
        scene.set([SectorElement(
          center: coord.center,
          startRadius: coord.radiuses.first,
          endRadius: coord.radiuses.last,
          startAngle: coord.convertAngle(start),
          endAngle: coord.convertAngle(end),
          style: style,
        )], RectElement(rect: coord.region));
      } else {
        scene.set([SectorElement(
          center: coord.center,
          startRadius: coord.convertRadius(start),
          endRadius: coord.convertRadius(end),
          startAngle: coord.angles.first,
          endAngle: coord.angles.last,
          style: style,
        )], RectElement(rect: coord.region));
      }
    }
  }
}
