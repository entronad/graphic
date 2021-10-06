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

abstract class FigureAnnotation extends Annotation {
  FigureAnnotation({
    this.variables,
    this.values,
    this.anchor,

    int? zIndex,
  }) 
    : assert(isSingle([variables, anchor], allowNone: true)),
      assert(isSingle([values, anchor])),
      super(
        zIndex: zIndex,
      );

  /// Default to the dim 1 and dim 2 variables.
  List<String>? variables;

  List? values;

  /// You may need to know the chart size.
  Offset Function(Size)? anchor;

  @override
  bool operator ==(Object other) =>
    other is FigureAnnotation &&
    super == other &&
    DeepCollectionEquality().equals(variables, other.variables) &&
    DeepCollectionEquality().equals(values, values);
    // anchor is Function
}

abstract class FigureAnnotOp extends Operator<List<Figure>?> {
  FigureAnnotOp(Map<String, dynamic> params) : super(params);
}

class FigureAnnotSetAnchorOp extends Operator<Offset> {
  FigureAnnotSetAnchorOp(Map<String, dynamic> params) : super(params);

  @override
  Offset evaluate() {
    final anchor = params['anchor'] as Offset Function(Size);
    final size = params['size'] as Size;

    return anchor(size);
  }
}

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

class FigureAnnotScene extends AnnotScene {
  @override
  int get layer => Layers.figureAnnot;
}

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
    final zIndex = params['zIndex'] as int;
    final coord = params['coord'] as CoordConv;
    
    scene
      ..zIndex = zIndex
      ..figures = figures;

    if (inRegion) {
      scene.setRegionClip(coord.region);
    }
  }
}
