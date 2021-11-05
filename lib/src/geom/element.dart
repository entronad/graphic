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
import 'package:graphic/src/chart/chart.dart';
import 'package:graphic/src/chart/view.dart';
import 'package:graphic/src/common/layers.dart';
import 'package:graphic/src/common/operators/render.dart';
import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/dataflow/operator.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/graffiti/figure.dart';
import 'package:graphic/src/graffiti/scene.dart';
import 'package:graphic/src/parse/parse.dart';
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

/// The specification of a geometory element.
///
/// A geometory element applies a certain graphing rule to get a graph from the
/// tuples.
///
/// A *geometory element* corresponds to a set of all tuples, while an *element
/// item* corresponds to a single tuple.
abstract class GeomElement<S extends Shape> {
  /// Creates a geometory element.
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
  })  : assert(isSingle([color, gradient], allowNone: true)),
        assert(selected == null || selected.keys.length == 1);

  /// The color attribute of this element.
  ///
  /// Only one in [color] and [gradient] can be set.
  ///
  /// If null and [gradient] is also null, a default `ColorAttr(value: Defaults.primaryColor)`
  /// is set.
  ColorAttr? color;

  /// The shadow elevation attribute of this element.
  ElevationAttr? elevation;

  /// The gradient attribute of this element.
  ///
  /// Only one in [color] and [gradient] can be set.
  GradientAttr? gradient;

  /// The label attribute of this element.
  LabelAttr? label;

  /// Algebra expression of the element position.
  ///
  /// See details about graphic algebra in [Varset].
  ///
  /// A certain type of graphing requires a certain count of variables in each
  /// dimension. If not satisfied, The geometory types have their own rules tring
  /// to complete the points. See details in subclasses.
  ///
  /// If null, a crossing of first 2 variables is set by default.
  Varset? position;

  /// The shape attribute of this element.
  ///
  /// If null, a default shape is set according to the geometory type. See details
  /// in subclasses.
  ShapeAttr<S>? shape;

  /// The size attribute of this element.
  ///
  /// If null, a default size is set according to the shape definition (See details
  /// in [Shape.defaultSize]).
  ///
  /// See also:
  ///
  /// - [Shape.defaultSize], the default size setting of each shape.
  SizeAttr? size;

  /// The collision modifiers applied to this element.
  ///
  /// They are applied in order of the list index.
  ///
  /// If set, a [groupBy] is required.
  List<Modifier>? modifiers;

  /// The z index of this element.
  ///
  /// If null, a default 0 is set.
  int? zIndex;

  /// The variable by which the tuples are grouped.
  ///
  /// The grouping is usfull to seperate line and area shapes, and is requred for
  /// [modifiers].
  String? groupBy;

  /// The selection name and selected tuple indexes triggered initially.
  ///
  /// The map must be single entried.
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

/// The operator to group aeses.
///
/// The grouping is by [GeomElement.groupBy]. If it is null, all aeses will be in
/// a same group.
class GroupOp extends Operator<AesGroups> {
  GroupOp(Map<String, dynamic> params) : super(params);

  @override
  AesGroups evaluate() {
    final aeses = params['aeses'] as List<Aes>;
    final tuples = params['tuples'] as List<Tuple>;
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
      final tuple = tuples[i];
      tmp[tuple[groupBy]]!.add(aes);
    }

    return tmp.values.toList();
  }
}

/// The geometory element scene.
///
/// All items of a geometory element are in a same scene, and their order is immutable.
class ElementScene extends Scene {
  ElementScene(int zIndex) : super(zIndex);

  @override
  int get layer => Layers.element;
}

/// The geometory element render operator.
class ElementRenderOp extends Render<ElementScene> {
  ElementRenderOp(
    Map<String, dynamic> params,
    ElementScene scene,
    View view,
  ) : super(params, scene, view);

  @override
  void render() {
    final groups = params['groups'] as AesGroups;
    final coord = params['coord'] as CoordConv;
    final origin = params['origin'] as Offset;

    final figures = <Figure>[];

    for (var group in groups) {
      final representShape = group.first.shape;
      figures.addAll(representShape.renderGroup(
        group,
        coord,
        origin,
      ));
    }

    scene
      ..setRegionClip(coord.region)
      ..figures = figures.isEmpty ? null : figures;
  }
}

/// Checks and completes the position points.
typedef PositionCompleter = List<Offset> Function(
    List<Offset> position, Offset origin);

/// Gets the position completer of the geometory element type.
PositionCompleter getPositionCompleter(GeomElement spec) => spec is AreaElement
    ? areaCompleter
    : spec is CustomElement
        ? customCompleter
        : spec is IntervalElement
            ? intervalCompleter
            : spec is LineElement
                ? lineCompleter
                : spec is PointElement
                    ? pointCompleter
                    : spec is PolygonElement
                        ? polygonCompleter
                        : throw UnimplementedError('No such geom $spec.');

/// Gets the default shape of the geometory element type.
Shape getDefaultShape(GeomElement spec) => spec is AreaElement
    ? BasicAreaShape()
    : spec is CustomElement
        ? throw ArgumentError('Custom geom must designate shape.')
        : spec is IntervalElement
            ? RectShape()
            : spec is LineElement
                ? BasicLineShape()
                : spec is PointElement
                    ? CircleShape()
                    : spec is PolygonElement
                        ? HeatmapShape()
                        : throw UnimplementedError('No such geom $spec.');

/// Parses geometory related specifications.
void parseGeom(
  Chart spec,
  View view,
  Scope scope,
) {
  for (var i = 0; i < spec.elements.length; i++) {
    final elementSpec = spec.elements[i];
    final aeses = scope.aesesList[i];

    Operator<AesGroups> groups = view.add(GroupOp({
      'aeses': aeses,
      'tuples': scope.tuples,
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
