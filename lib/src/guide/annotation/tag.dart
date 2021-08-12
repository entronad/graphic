import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:collection/collection.dart';
import 'package:graphic/src/common/label.dart';
import 'package:graphic/src/common/layers.dart';
import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/coord/polar.dart';
import 'package:graphic/src/scale/scale.dart';

import 'annotation.dart';

class TagAnnotation extends Annotation {
  TagAnnotation({
    this.variables,
    required this.values,
    required this.label,

    int? zIndex,
  }) : super(
    zIndex: zIndex,
  );

  /// Default to the dim 1 and dim 2 variables.
  final List<String>? variables;

  final List values;

  final Label label;

  @override
  bool operator ==(Object other) =>
    other is TagAnnotation &&
    super == other &&
    DeepCollectionEquality().equals(variables, other.variables) &&
    DeepCollectionEquality().equals(values, values) &&
    label == other.label;
}

class TagAnnotPainter extends AnnotPainter {
  TagAnnotPainter(
    this.anchor,
    this.label,
  );

  final Offset anchor;

  final Label label;

  @override
  void paint(Canvas canvas) => paintLabel(
    label,
    anchor,
    Alignment.center,
    canvas,
  );
}

class TagAnnotScene extends AnnotScene {
  @override
  int get layer => Layers.tagAnnot;
}

class TagAnnotRenderOp extends AnnotRenderOp<TagAnnotScene> {
  TagAnnotRenderOp(
    Map<String, dynamic> params,
    TagAnnotScene scene,
  ) : super(params, scene);

  @override
  void render() {
    final variables = params['variables'] as List<String>;
    final values = params['values'] as List;
    final label = params['label'] as Label;
    final zIndex = params['zIndex'] as int;
    final scales = params['scales'] as Map<String, ScaleConv>;
    final coord = params['coord'] as CoordConv;
    final region = params['region'] as Rect;

    scene
      ..zIndex = zIndex
      ..setRegionClip(region, coord is PolarCoordConv);
    
    final scaleX = scales[variables[0]]!;
    final scaleY = scales[variables[1]]!;
    scene.painter = TagAnnotPainter(
      coord.convert(Offset(
        scaleX.normalize(scaleX.convert(values[0])),
        scaleY.normalize(scaleY.convert(values[1])),
      )),
      label,
    );
  }
}
