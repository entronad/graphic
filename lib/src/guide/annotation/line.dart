import 'dart:ui';

import 'package:graphic/src/chart/view.dart';
import 'package:graphic/src/common/dim.dart';
import 'package:graphic/src/common/intrinsic_layers.dart';
import 'package:graphic/src/common/styles.dart';
import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/coord/polar.dart';
import 'package:graphic/src/graffiti/figure.dart';
import 'package:graphic/src/scale/scale.dart';
import 'package:graphic/src/util/path.dart';

import 'annotation.dart';

/// The specification of a line annotation.
class LineAnnotation extends Annotation {
  /// Creates a line annotation.
  LineAnnotation({
    this.dim,
    this.variable,
    required this.value,
    this.style,
    int? layer,
  }) : super(
          layer: layer,
        );

  /// The dimension where the line stands.
  ///
  /// If null, a default [Dim.x] is set.
  Dim? dim;

  /// The variable refered to for position.
  ///
  /// If null, the first variable assigned to [dim] is set by default.
  String? variable;

  /// The value of [variable] for position.
  dynamic value;

  /// The stroke style of this line.
  StrokeStyle? style;

  @override
  bool operator ==(Object other) =>
      other is LineAnnotation &&
      super == other &&
      dim == other.dim &&
      variable == other.variable &&
      value == other.value &&
      style == other.style;
}

/// The line annotation scene.
class LineAnnotScene extends AnnotScene {
  LineAnnotScene(int layer) : super(layer);

  @override
  int get intrinsicLayer => IntrinsicLayers.lineAnnot;
}

/// The line annotation render operator.
class LineAnnotRenderOp extends AnnotRenderOp<LineAnnotScene> {
  LineAnnotRenderOp(
    Map<String, dynamic> params,
    LineAnnotScene scene,
    View view,
  ) : super(params, scene, view);

  @override
  void render() {
    final dim = params['dim'] as Dim;
    final variable = params['variable'] as String;
    final value = params['value'];
    final style = params['style'] as StrokeStyle;
    final scales = params['scales'] as Map<String, ScaleConv>;
    final coord = params['coord'] as CoordConv;

    scene..setRegionClip(coord.region);

    final scale = scales[variable]!;
    final position = scale.normalize(scale.convert(value));

    if (coord is PolarCoordConv && coord.getCanvasDim(dim) == Dim.y) {
      scene.figures = [
        PathFigure(
          style.dashPath(Path()
            ..addArc(
              Rect.fromCircle(
                center: coord.center,
                radius: coord.convertRadius(position),
              ),
              coord.angles.first,
              coord.angles.last - coord.angles.first,
            )),
          style.toPaint(),
        )
      ];
    } else {
      scene.figures = [
        PathFigure(
          style.dashPath(Paths.line(
            from: coord.convert(
              dim == Dim.x ? Offset(position, 0) : Offset(0, position),
            ),
            to: coord.convert(
              dim == Dim.x ? Offset(position, 1) : Offset(1, position),
            ),
          )),
          style.toPaint(),
        )
      ];
    }
  }
}
