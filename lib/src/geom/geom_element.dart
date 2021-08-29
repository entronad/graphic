import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:graphic/src/aes/color.dart';
import 'package:graphic/src/aes/elevation.dart';
import 'package:graphic/src/aes/gradient.dart';
import 'package:graphic/src/aes/label.dart';
import 'package:graphic/src/algebra/varset.dart';
import 'package:graphic/src/aes/shape.dart';
import 'package:graphic/src/aes/size.dart';
import 'package:graphic/src/common/layers.dart';
import 'package:graphic/src/common/operators/render.dart';
import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/coord/polar.dart';
import 'package:graphic/src/dataflow/operator.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/graffiti/graffiti.dart';
import 'package:graphic/src/scale/discrete.dart';
import 'package:graphic/src/scale/scale.dart';

import 'modifier/modifier.dart';

abstract class GeomElement {
  GeomElement({
    this.color,
    this.elevation,
    this.gradient,
    this.label,
    this.position,
    this.shape,
    this.size,
    this.modifier,
    this.zIndex,
    this.groupBy,
    this.selected,
  }) : assert(modifier == null || groupBy != null);

  final ColorAttr? color;

  final ElevationAttr? elevation;

  final GradientAttr? gradient;

  final LabelAttr? label;

  final Varset? position;

  final ShapeAttr? shape;

  final SizeAttr? size;

  final Modifier? modifier;

  final int? zIndex;

  /// How element items are grouped.
  /// Modifier require groups.
  final String? groupBy;

  final Set<int>? selected;

  @override
  bool operator ==(Object other) =>
    other is GeomElement &&
    color == other.color &&
    elevation == other.elevation &&
    gradient == other.gradient &&
    label == other.label &&
    position == other.position &&
    shape == other.shape &&
    size == other.size &&
    modifier == modifier &&
    zIndex == other.zIndex &&
    selected == other.selected;
}

/// Group aes value tuples by element's groupBy field.
/// If groupBy is null, all tuples will be in the same group.
class GroupOp extends Operator<AesGroups> {
  GroupOp(Map<String, dynamic> params) : super(params);

  @override
  AesGroups evaluate() {
    final aeses = params['aeses'] as List<Aes>;
    final originals = params['originals'] as List<Original>;
    final groupBy = params['groupBy'] as String?;
    final scales = params['scales'] as Map<String, ScaleConv>;

    if (groupBy == null) {
      return [aeses];
    }

    final groupValues = (scales[groupBy] as DiscreteScaleConv).values!;
    final tmp = <dynamic, List<Aes>>{};
    for (var groupValue in groupValues) {
      tmp[groupValue] = <Aes>[];
    }

    for (var i = 0; i < aeses.length; i++) {
      final aes = aeses[i];
      final original = originals[i];
      tmp[original[groupBy]]!.add(aes);
    }

    return tmp.values.toList();
  }
}

class ElementPainter extends Painter {
  ElementPainter(this.groups, this.coord);

  final AesGroups groups;

  final CoordConv coord;

  @override
  void paint(Canvas canvas) {
    for (var group in groups) {
      final represent = group.first.shape;
      represent.paintGroup(
        group,
        coord,
        canvas,
      );
    }
  }
}

class ElementScene extends Scene {
  @override
  int get layer => Layers.element;
}

class ElementRenderOp extends Render<ElementScene> {
  ElementRenderOp(
    Map<String, dynamic> params,
    ElementScene scene,
  ) : super(params, scene);

  @override
  void render() {
    final zIndex = params['zIndex'] as int;
    final groups = params['groups'] as AesGroups;
    final coord = params['coord'] as CoordConv;

    scene
      ..zIndex = zIndex
      ..setRegionClip(coord.region, coord is PolarCoordConv)
      ..painter = ElementPainter(groups, coord);
  }
}
