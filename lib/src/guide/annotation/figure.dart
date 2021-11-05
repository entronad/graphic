import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:collection/collection.dart';
import 'package:graphic/src/chart/view.dart';
import 'package:graphic/src/common/layers.dart';
import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/dataflow/operator.dart';
import 'package:graphic/src/graffiti/figure.dart';
import 'package:graphic/src/scale/scale.dart';
import 'package:graphic/src/util/assert.dart';

import 'annotation.dart';

/// The Specification of a figure annotation.
abstract class FigureAnnotation extends Annotation {
  /// Creates a figure annotation.
  FigureAnnotation({
    this.variables,
    this.values,
    this.anchor,
    int? zIndex,
  })  : assert(isSingle([variables, anchor], allowNone: true)),
        assert(isSingle([values, anchor])),
        super(
          zIndex: zIndex,
        );

  /// The variables in each dimension refered to for position.
  ///
  /// If null, the first variables assigned to each dimension are set by default.
  List<String>? variables;

  /// The values of [variables] for position.
  List? values;

  /// Indicates the anchor position of this annotation directly.
  ///
  /// This is a function with chart size as input that you may need to calculate
  /// the position.
  ///
  /// If set, this annotation's position will no longer determined by [variables]
  /// and [values], and can be out of the coordinate region.
  Offset Function(Size)? anchor;

  @override
  bool operator ==(Object other) =>
      other is FigureAnnotation &&
      super == other &&
      DeepCollectionEquality().equals(variables, other.variables) &&
      DeepCollectionEquality().equals(values, values);
  // anchor is Function
}

/// The operator to create figures of a figure annotation.
abstract class FigureAnnotOp extends Operator<List<Figure>?> {
  FigureAnnotOp(Map<String, dynamic> params) : super(params);
}

/// The operator to get figure annotation's anchor if it is set directly.
class FigureAnnotSetAnchorOp extends Operator<Offset> {
  FigureAnnotSetAnchorOp(Map<String, dynamic> params) : super(params);

  @override
  Offset evaluate() {
    final anchor = params['anchor'] as Offset Function(Size);
    final size = params['size'] as Size;

    return anchor(size);
  }
}

/// The operator to get figure annotation's anchor if it is calculated.
class FigureAnnotCalcAnchorOp extends Operator<Offset> {
  FigureAnnotCalcAnchorOp(Map<String, dynamic> params) : super(params);

  @override
  Offset evaluate() {
    final variables = params['variables'] as List<String>;
    final values = params['values'] as List;
    final scales = params['scales'] as Map<String, ScaleConv>;
    final coord = params['coord'] as CoordConv;

    final scaleX = scales[variables[0]]!;
    final scaleY = scales[variables[1]]!;
    return coord.convert(Offset(
      scaleX.normalize(scaleX.convert(values[0])),
      scaleY.normalize(scaleY.convert(values[1])),
    ));
  }
}

/// The figure annotation scene.
class FigureAnnotScene extends AnnotScene {
  FigureAnnotScene(int zIndex) : super(zIndex);

  @override
  int get layer => Layers.figureAnnot;
}

/// The figure annotation render operator.
class FigureAnnotRenderOp extends AnnotRenderOp<FigureAnnotScene> {
  FigureAnnotRenderOp(
    Map<String, dynamic> params,
    FigureAnnotScene scene,
    View view,
  ) : super(params, scene, view);

  @override
  void render() {
    final figures = params['figures'] as List<Figure>?;
    final inRegion = params['inRegion'] as bool;
    final coord = params['coord'] as CoordConv;

    scene..figures = figures;

    if (inRegion) {
      scene.setRegionClip(coord.region);
    }
  }
}
