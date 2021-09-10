import 'dart:ui';

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
import 'package:graphic/src/coord/polar.dart';
import 'package:graphic/src/dataflow/operator.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/graffiti/graffiti.dart';
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
import 'area.dart';
import 'custom.dart';
import 'interval.dart';
import 'line.dart';
import 'point.dart';
import 'polygon.dart';

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
  })
    : assert(modifier == null || groupBy != null),
      assert(isSingle([color, gradient], allowNone: true));

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

    if (elementSpec.modifier != null) {
      final modifier = elementSpec.modifier!;
      final form = scope.forms[i];
      final origin = scope.origins[i];
      if (modifier is DodgeModifier) {
        final geomModifier = view.add(DodgeGeomModifierOp({
          'ratio': modifier.ratio,
          'symmetric': modifier.symmetric ?? true,
          'form': form,
          'scales': scope.scales,
          'groups': groups,
        }));
        groups = view.add(ModifyOp({
          'groups': groups,
          'modifier': geomModifier,
        }));
      } else if (modifier is JitterModifier) {
        final geomModifier = view.add(JitterGeomModifierOp({
          'ratio': modifier.ratio ?? 0.5,
          'form': form,
          'scales': scope.scales,
        }));
        groups = view.add(ModifyOp({
          'groups': groups,
          'modifier': geomModifier,
        }));
      } else if (modifier is StackModifier) {
        final geomModifier = view.add(StackGeomModifierOp({
          'symmetric': modifier.symmetric ?? false,
          'origin': origin,
        }));
        groups = view.add(ModifyOp({
          'groups': groups,
          'modifier': geomModifier,
        }));
      } else {
        throw UnimplementedError('No such modifier type: $modifier.');
      }
    }

    scope.geomsList.add(groups);
  }
}
