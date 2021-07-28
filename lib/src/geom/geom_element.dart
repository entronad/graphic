import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:graphic/src/aes/aes.dart';
import 'package:graphic/src/aes/color.dart';
import 'package:graphic/src/aes/elevation.dart';
import 'package:graphic/src/aes/gradient.dart';
import 'package:graphic/src/aes/label.dart';
import 'package:graphic/src/algebra/varset.dart';
import 'package:graphic/src/aes/shape.dart';
import 'package:graphic/src/aes/size.dart';
import 'package:graphic/src/common/layers.dart';
import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/dataflow/operator/updater.dart';
import 'package:graphic/src/dataflow/pulse/pulse.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/graffiti/scene.dart';
import 'package:graphic/src/scale/discrete.dart';
import 'package:graphic/src/scale/scale.dart';
import 'package:graphic/src/shape/shape.dart';
import 'package:graphic/src/util/map.dart';

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
    zIndex == other.zIndex;
}

/// Group aes value tuples by element's groupBy field.
/// If groupBy is null, all tuples will be in the same group.
/// 
/// params:
/// - tuples: List<Tuple>, aes value tuples from the sieve operator of aes value branch.
/// - groupBy: String?
/// - scales: Map<String, ScaleConv>
/// - scaledRelay: Map<Tuple, Tuple>, Relay from original value to scaled value.
/// - aesRelay: Map<Tuple, Tuple>, Relay from scaled value to aes value.
/// 
/// value: List<List<Tuple>>
class GroupOp extends Updater<List<List<Tuple>>> {
  GroupOp(Map<String, dynamic> params) : super(params);

  @override
  update(Pulse pulse) {
    final tuples = params['tuples'] as List<Tuple>;
    final groupBy = params['groupBy'] as String?;
    final scales = params['scales'] as Map<String, ScaleConv>;
    final scaledRelay = params['scaledRelay'] as Map<Tuple, Tuple>;
    final aesRelay = params['aesRelay'] as Map<Tuple, Tuple>;

    if (groupBy == null) {
      return [tuples];
    }

    final groupValues = (scales[groupBy] as DiscreteScaleConv).values!;
    final tmp = <dynamic, List<Tuple>>{};
    for (var groupValue in groupValues) {
      tmp[groupValue] = <Tuple>[];
    }
    
    for (var tuple in tuples) {
      final originalTuple = scaledRelay.keyOf(aesRelay.keyOf(tuple));
      tmp[originalTuple[groupBy]]!.add(tuple);
    }

    return tmp.values.toList();
  }
}

class ElementScene extends Scene {
  ElementScene(
    this.groups,
    this.coord,
    this.origin,
    Rect region,
  ) : super(Path()..addRect(region));

  List<List<Tuple>> groups;

  CoordConv coord;

  Offset origin;

  void set region(Rect value) {
    clip = Path()..addRect(value);
  }

  @override
  int get layer => Layer.element;

  @override
  void paint(Canvas canvas) {
    for (var group in groups) {
      final represent = group.first['shape'] as Shape;
      represent.paintGroup(
        group.map((tuple) => Aes(tuple)).toList(),
        coord,
        canvas,
      );
    }
  }
}
