import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:graphic/src/chart/view.dart';
import 'package:graphic/src/common/layers.dart';
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
    int? zIndex,
  }) : super(
          zIndex: zIndex,
        );

  /// The dimension where this region stands.
  ///
  /// If null, a default 1 is set.
  int? dim;

  /// The variable refered to for position.
  ///
  /// If null, the first variable assigned to [dim] is set by default.
  String? variable;

  /// The values of [variable] for position.
  ///
  /// It is of 2 values for start and end respectively.
  List values;

  /// The color of this region.
  Color? color;

  @override
  bool operator ==(Object other) =>
      other is RegionAnnotation &&
      super == other &&
      dim == other.dim &&
      variable == other.variable &&
      DeepCollectionEquality().equals(values, other.values) &&
      color == color;
}

class RegionAnnotScene extends AnnotScene {
  @override
  int get layer => Layers.regionAnnot;
}

class RegionAnnotRenderOp extends AnnotRenderOp<RegionAnnotScene> {
  RegionAnnotRenderOp(
    Map<String, dynamic> params,
    RegionAnnotScene scene,
    View view,
  ) : super(params, scene, view);

  @override
  void render() {
    final dim = params['dim'] as int;
    final variable = params['variable'] as String;
    final values = params['values'] as List;
    final color = params['color'] as Color;
    final zIndex = params['zIndex'] as int;
    final scales = params['scales'] as Map<String, ScaleConv>;
    final coord = params['coord'] as CoordConv;

    scene
      ..zIndex = zIndex
      ..setRegionClip(coord.region);

    final scale = scales[variable]!;
    final start = scale.normalize(scale.convert(values.first));
    final end = scale.normalize(scale.convert(values.last));

    if (coord is RectCoordConv) {
      scene.figures = [
        PathFigure(
          Path()
            ..addRect(Rect.fromPoints(
              coord.convert(
                dim == 1 ? Offset(start, 0) : Offset(0, start),
              ),
              coord.convert(
                dim == 1 ? Offset(end, 1) : Offset(1, end),
              ),
            )),
          Paint()..color = color,
        )
      ];
    } else {
      coord as PolarCoordConv;
      if (coord.getCanvasDim(dim) == 1) {
        scene.figures = [
          PathFigure(
            Paths.sector(
              center: coord.center,
              r: coord.radiuses.last,
              r0: coord.radiuses.first,
              startAngle: coord.convertAngle(start),
              endAngle: coord.convertAngle(end),
              clockwise: true,
            ),
            Paint()..color = color,
          )
        ];
      } else {
        scene.figures = [
          PathFigure(
            Paths.sector(
              center: coord.center,
              r: coord.convertRadius(end),
              r0: coord.convertRadius(start),
              startAngle: coord.angles.first,
              endAngle: coord.angles.last,
              clockwise: true,
            ),
            Paint()..color = color,
          )
        ];
      }
    }
  }
}
