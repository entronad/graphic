import 'dart:async';
import 'dart:ui';

import 'package:graphic/src/graffiti/element/element.dart';
import 'package:graphic/src/graffiti/element/rect.dart';
import 'package:graphic/src/graffiti/transition.dart';
import 'package:graphic/src/interaction/selection/selection.dart';
import 'package:graphic/src/util/collection.dart';
import 'package:flutter/painting.dart';
import 'package:graphic/src/encode/color.dart';
import 'package:graphic/src/encode/elevation.dart';
import 'package:graphic/src/encode/gradient.dart';
import 'package:graphic/src/encode/label.dart';
import 'package:graphic/src/algebra/varset.dart';
import 'package:graphic/src/encode/shape.dart';
import 'package:graphic/src/encode/size.dart';
import 'package:graphic/src/chart/view.dart';
import 'package:graphic/src/common/operators/render.dart';
import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/dataflow/operator.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/graffiti/scene.dart';
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
import 'area.dart';
import 'custom.dart';
import 'interval.dart';
import 'line.dart';
import 'point.dart';
import 'polygon.dart';

enum MarkEntrance {
  x,
  y,
  xy,
  size,
  alpha,
}

/// The specification of a geometry mark.
///
/// A geometry mark applies a certain graphing rule to get a graph from the
/// tuples.
///
/// A *geometry mark* corresponds to a set of all tuples, while an *mark
/// item* corresponds to a single tuple.
abstract class Mark<S extends Shape> {
  /// Creates a geometry mark.
  Mark({
    this.color,
    this.elevation,
    this.gradient,
    this.label,
    this.position,
    this.shape,
    this.size,
    this.modifiers,
    this.layer,
    this.selected,
    this.selectionStream,
    this.transition,
    this.entrance,
    this.tag,
  })  : assert(isSingle([color, gradient], allowNone: true)),
        assert(selected == null || selected.keys.length == 1);

  /// The color encode of this mark.
  ///
  /// Only one in [color] and [gradient] can be set.
  ///
  /// If null and [gradient] is also null, a default `ColorEncode(value: Defaults.primaryColor)`
  /// is set.
  ColorEncode? color;

  /// The shadow elevation encode of this mark.
  ElevationEncode? elevation;

  /// The gradient encode of this mark.
  ///
  /// Only one in [color] and [gradient] can be set.
  GradientEncode? gradient;

  /// The label encode of this mark.
  ///
  /// For an mark, labels are always painted above item graphics, no matter how
  /// their [MarkElement]s are rendered in [Shape]s.
  LabelEncode? label;

  /// Algebra expression of the mark position.
  ///
  /// See details about graphics algebra in [Varset].
  ///
  /// A certain type of graphing requires a certain count of variables in each
  /// dimension. If not satisfied, The geometry types have their own rules tring
  /// to complete the points. See details in subclasses.
  ///
  /// If null, a crossing of first two variables is set by default.
  Varset? position;

  /// The shape encode of this mark.
  ///
  /// If null, a default shape is set according to the geometry type. See details
  /// in subclasses.
  ShapeEncode<S>? shape;

  /// The size encode of this mark.
  ///
  /// If null, a default size is set according to the shape definition (See details
  /// in [Shape.defaultSize]).
  ///
  /// See also:
  ///
  /// - [Shape.defaultSize], the default size setting of each shape.
  SizeEncode? size;

  /// The collision modifiers applied to this mark.
  ///
  /// They are applied in order of the list index.
  ///
  /// If set, a nesting in the algebra for grouping is requied. See details in [Varset].
  List<Modifier>? modifiers;

  /// The layer of this mark.
  ///
  /// If null, a default 0 is set.
  int? layer;

  /// The selection name and selected tuple indexes triggered initially.
  ///
  /// This initial selection will not trigger [selectionStream].
  Selected? selected;

  /// The interaction stream of selections.
  ///
  /// You can either get selection results by listening to it's stream, or mannually
  /// emit selections into this mark by add to it's sink.
  ///
  /// You can also share it with other charts for sharing selections, in witch case
  /// make sure it is broadcast.
  StreamController<Selected?>? selectionStream;

  Transition? transition;

  MarkEntrance? entrance;

  String? Function(Tuple)? tag;

  @override
  bool operator ==(Object other) =>
      other is Mark &&
      color == other.color &&
      elevation == other.elevation &&
      gradient == other.gradient &&
      label == other.label &&
      position == other.position &&
      shape == other.shape &&
      size == other.size &&
      deepCollectionEquals(modifiers, other.modifiers) &&
      layer == other.layer &&
      selected == other.selected &&
      selectionStream == other.selectionStream &&
      transition == other.transition &&
      entrance == other.entrance;
      // tag is a function.
}

/// The operator to group attributes.
///
/// The nesters, no matter `x * y`, `a + y`, or `a / y`, will be used in cartesian
/// production. If empty, all eases will be in a same group.
///
/// Empty groups will be removed after each grouping, which reflects the feature
/// of nesting. It is nessasary especially in multiple nesters grouping.
///
/// Groups with same value of smaller indexed nester will stay together.
///
/// List is the best way to store groups. If nester values are needed for indexing,
/// store them in another corresponding list. List indexes are better then map keys.
class GroupOp extends Operator<AttributesGroups> {
  GroupOp(Map<String, dynamic> params) : super(params);

  @override
  AttributesGroups evaluate() {
    final attributes = params['attributes'] as List<Attributes>;
    final tuples = params['tuples'] as List<Tuple>;
    final nesters = params['nesters'] as List<AlgForm>;
    final scales = params['scales'] as Map<String, ScaleConv>;

    final nesterVariables = <String>[];
    for (var nesterForm in nesters) {
      for (var nesterTerm in nesterForm) {
        nesterVariables.addAll(nesterTerm);
      }
    }

    var rst = [attributes];

    for (var nester in nesterVariables) {
      final tmpRst = <List<Attributes>>[];
      for (var group in rst) {
        final nesterValues = (scales[nester] as DiscreteScaleConv).values;
        final tmpGroup = <dynamic, List<Attributes>>{};
        for (var nesterValue in nesterValues) {
          tmpGroup[nesterValue] = <Attributes>[];
        }
        for (var attributes in group) {
          final tuple = tuples[attributes.index];
          tmpGroup[tuple[nester]]!.add(attributes);
        }
        tmpRst.addAll(tmpGroup.values.where((g) => g.isNotEmpty));
      }
      rst = tmpRst;
    }

    return rst;
  }
}

/// The geometry mark render operator.
class MarkPrimitiveRenderOp extends Render {
  MarkPrimitiveRenderOp(
    Map<String, dynamic> params,
    Scene scene,
    View view,
  ) : super(params, scene, view);

  @override
  void render() {
    final groups = params['groups'] as AttributesGroups;
    final coord = params['coord'] as CoordConv;
    final origin = params['origin'] as Offset;
    final transition = params['transition'] as Transition?;
    final entrance = params['entrance'] as MarkEntrance;

    final clip = RectElement(rect: coord.region, style: PaintStyle());

    final rst = <MarkElement>[];
    for (var group in groups) {
      rst.addAll(group.first.shape.drawGroupPrimitives(
        group,
        coord,
        origin,
      ));
    }

    if (transition != null && !scene.hasCurrent) {
      final entranceRst = <MarkElement>[];
      for (var group in groups) {
        final entranceGroup =
            group.map((item) => item.deflate(entrance)).toList();
        entranceRst.addAll(entranceGroup.first.shape.drawGroupPrimitives(
          entranceGroup,
          coord,
          origin,
        ));
      }
      scene.set(entranceRst, clip);
    }

    scene.set(rst, clip);
  }
}

class MarkLabelRenderOp extends Render {
  MarkLabelRenderOp(
    Map<String, dynamic> params,
    Scene scene,
    View view,
  ) : super(params, scene, view);

  @override
  void render() {
    final groups = params['groups'] as AttributesGroups;
    final coord = params['coord'] as CoordConv;
    final origin = params['origin'] as Offset;
    final transition = params['transition'] as Transition?;
    final entrance = params['entrance'] as MarkEntrance;

    final clip = RectElement(rect: coord.region, style: PaintStyle());

    final rst = <MarkElement>[];
    for (var group in groups) {
      rst.addAll(group.first.shape.drawGroupLabels(
        group,
        coord,
        origin,
      ));
    }

    if (transition != null && !scene.hasCurrent) {
      final entranceRst = <MarkElement>[];
      for (var group in groups) {
        final entranceGroup =
            group.map((item) => item.deflate(entrance)).toList();
        entranceRst.addAll(entranceGroup.first.shape.drawGroupLabels(
          entranceGroup,
          coord,
          origin,
        ));
      }
      scene.set(entranceRst, clip);
    }

    scene.set(rst, clip);
  }
}

/// Checks and completes the position points.
typedef PositionCompleter = List<Offset> Function(
    List<Offset> position, Offset origin);

/// Gets the position completer of the geometry mark type.
PositionCompleter getPositionCompleter(Mark spec) => spec is AreaMark
    ? areaCompleter
    : spec is CustomMark
        ? customCompleter
        : spec is IntervalMark
            ? intervalCompleter
            : spec is LineMark
                ? lineCompleter
                : spec is PointMark
                    ? pointCompleter
                    : spec is PolygonMark
                        ? polygonCompleter
                        : throw UnimplementedError('No such geom $spec.');

/// Gets the default shape of the geometry mark type.
Shape getDefaultShape(Mark spec) => spec is AreaMark
    ? BasicAreaShape()
    : spec is CustomMark
        ? throw ArgumentError('Custom geom must designate shape.')
        : spec is IntervalMark
            ? RectShape()
            : spec is LineMark
                ? BasicLineShape()
                : spec is PointMark
                    ? CircleShape()
                    : spec is PolygonMark
                        ? HeatmapShape()
                        : throw UnimplementedError('No such geom $spec.');
