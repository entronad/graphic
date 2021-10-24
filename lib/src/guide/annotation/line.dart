import 'dart:ui';

import 'package:graphic/src/chart/view.dart';
import 'package:graphic/src/common/layers.dart';
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

    int? zIndex,
  }) : super(
    zIndex: zIndex,
  );

  /// The dimension where the line stands.
  /// 
  /// If null, a default 1 is set.
  int? dim;

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

class LineAnnotScene extends AnnotScene {
  @override
  int get layer => Layers.lineAnnot;
}

class LineAnnotRenderOp extends AnnotRenderOp<LineAnnotScene> {
  LineAnnotRenderOp(
    Map<String, dynamic> params,
    LineAnnotScene scene,
    View view,
  ) : super(params, scene, view);

  @override
  void render() {
    final dim = params['dim'] as int;
    final variable = params['variable'] as String;
    final value = params['value'];
    final style = params['style'] as StrokeStyle;
    final zIndex = params['zIndex'] as int;
    final scales = params['scales'] as Map<String, ScaleConv>;
    final coord = params['coord'] as CoordConv;

    scene
      ..zIndex = zIndex
      ..setRegionClip(coord.region);
    
    final scale = scales[variable]!;
    final position = scale.normalize(scale.convert(value));

    if (coord is PolarCoordConv && coord.getCanvasDim(dim) == 2) {
      scene.figures = [PathFigure(
        Path()..addArc(
          Rect.fromCircle(
            center: coord.center,
            radius: coord.convertRadius(position),
          ),
          coord.angles.first,
          coord.angles.last - coord.angles.first,
        ),
        style.toPaint(),
      )];
    } else {
      scene.figures = [PathFigure(
        Paths.line(
          from: coord.convert(
            dim == 1
              ? Offset(position, 0)
              : Offset(0, position),
          ),
          to: coord.convert(
            dim == 1 
              ? Offset(position, 1)
              : Offset(1, position),
          ),
        ),
        style.toPaint(),
      )];
    }
  }
}
