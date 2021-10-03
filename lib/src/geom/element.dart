import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/painting.dart';
import 'package:graphic/src/aes/color.dart';
import 'package:graphic/src/aes/elevation.dart';
import 'package:graphic/src/aes/gradient.dart';
import 'package:graphic/src/aes/label.dart';
import 'package:graphic/src/algebra/varset.dart';
import 'package:graphic/src/aes/shape.dart';
import 'package:graphic/src/aes/size.dart';
import 'package:graphic/src/chart/view.dart';
import 'package:graphic/src/common/layers.dart';
import 'package:graphic/src/common/operators/render.dart';
import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/dataflow/operator.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/graffiti/figure.dart';
import 'package:graphic/src/graffiti/graffiti.dart';
import 'package:graphic/src/graffiti/scene.dart';
import 'package:graphic/src/parse/parse.dart';
import 'package:graphic/src/parse/spec.dart';
import 'package:graphic/src/scale/discrete.dart';
import 'package:graphic/src/scale/scale.dart';
import 'package:graphic/src/shape/area.dart';
import 'package:graphic/src/shape/interval.dart';
import 'package:graphic/src/shape/line.dart';
import 'package:graphic/src/shape/point.dart';
import 'package:graphic/src/shape/polygon.dart';
import 'package:graphic/src/shape/shape.dart';
import 'package:graphic/src/util/assert.dart';

import 'modifier/modifier.dart';
import 'modifier/dodge.dart';
import 'modifier/jitter.dart';
import 'modifier/stack.dart';
import 'modifier/symmetric.dart';
import 'area.dart';
import 'custom.dart';
import 'interval.dart';
import 'line.dart';
import 'point.dart';
import 'polygon.dart';

abstract class GeomElement<S extends Shape> {
  GeomElement({
    this.color,
    this.elevation,
    this.gradient,
    this.label,
    this.position,
    this.shape,
    this.size,
    this.modifiers,
    this.zIndex,
    this.groupBy,
    this.selected,
  })
    : assert(isSingle([color, gradient], allowNone: true)),
      assert(selected == null || selected.keys.length == 1);

  ColorAttr? color;

  ElevationAttr? elevation;

  GradientAttr? gradient;

  LabelAttr? label;

  Varset? position;

  ShapeAttr<S>? shape;

  SizeAttr? size;

  List<Modifier>? modifiers;

  int? zIndex;

  /// How element items are grouped.
  /// Modifier require groups.
  String? groupBy;

  Map<String, Set<int>>? selected;

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
    DeepCollectionEquality().equals(modifiers, other.modifiers) &&
    zIndex == other.zIndex &&
    groupBy == other.groupBy &&
    selected == other.selected;
}

/// Group aes value originals by element's groupBy field.
/// If groupBy is null, all originals will be in the same group.
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

    final groupValues = (scales[groupBy] as DiscreteScaleConv).values;
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

class ElementScene extends Scene {
  @override
  int get layer => Layers.element;
}

class ElementRenderOp extends Render<ElementScene> {
  ElementRenderOp(
    Map<String, dynamic> params,
    ElementScene scene,
    View view,
  ) : super(params, scene, view);

  @override
  void render() {
    final zIndex = params['zIndex'] as int;
    final groups = params['groups'] as AesGroups;
    final coord = params['coord'] as CoordConv;
    final origin = params['origin'] as Offset;

    final figures = <Figure>[];

    for (var group in groups) {
      final representShape = group.first.shape;
      figures.addAll(representShape.drawGroup(
        group,
        coord,
        origin,
      ));
    }

    scene
      ..zIndex = zIndex
      ..setRegionClip(coord.region)
      ..figures = figures.isEmpty ? null : figures;
  }
}

// Defaults for each geom.

typedef PositionCompleter = List<Offset> Function(List<Offset> position, Offset origin);

PositionCompleter getPositionCompleter(GeomElement spec) =>
  spec is AreaElement ? areaCompleter :
  spec is CustomElement ? customCompleter :
  spec is IntervalElement ? intervalCompleter :
  spec is LineElement ? lineCompleter :
  spec is PointElement ? pointCompleter :
  spec is PolygonElement ? polygonCompleter :
  throw UnimplementedError('No such geom $spec.');

Shape getDefaultShape(GeomElement spec) =>
  spec is AreaElement ? BasicAreaShape() :
  spec is CustomElement ? throw ArgumentError('Custom geom must designate shape.') :
  spec is IntervalElement ? RectShape() :
  spec is LineElement ? BasicLineShape() :
  spec is PointElement ? CircleShape() :
  spec is PolygonElement ? HeatmapShape() :
  throw UnimplementedError('No such geom $spec.');

void parseGeom(
  Spec spec,
  View view,
  Scope scope,
) {
  for (var i = 0; i < spec.elements.length; i++) {
    final elementSpec = spec.elements[i];
    final aeses = scope.aesesList[i];

    Operator<AesGroups> groups = view.add(GroupOp({
      'aeses': aeses,
      'originals': scope.originals,
      'groupBy': elementSpec.groupBy,
      'scales': scope.scales,
    }));

    if (elementSpec.modifiers != null) {
      for (var modifier in elementSpec.modifiers!) {
        final form = scope.forms[i];
        final origin = scope.origins[i];
        GeomModifierOp geomModifier;
        if (modifier is DodgeModifier) {
          geomModifier = view.add(DodgeGeomModifierOp({
            'ratio': modifier.ratio,
            'symmetric': modifier.symmetric ?? true,
            'form': form,
            'scales': scope.scales,
            'groups': groups,
          }));
        } else if (modifier is JitterModifier) {
          geomModifier = view.add(JitterGeomModifierOp({
            'ratio': modifier.ratio ?? 0.5,
            'form': form,
            'scales': scope.scales,
          }));
        } else if (modifier is StackModifier) {
          geomModifier = view.add(StackGeomModifierOp({
            'origin': origin,
          }));
        } else if (modifier is SymmetricModifier) {
          geomModifier = view.add(SymmetricGeomModifierOp({
            'origin': origin,
          }));
        } else {
          throw UnimplementedError('No such modifier type: $modifier.');
        }
        groups = view.add(ModifyOp({
          'groups': groups,
          'modifier': geomModifier,
        }));
      }
    }

    scope.groupsList.add(groups);
  }
}
