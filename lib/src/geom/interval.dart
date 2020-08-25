import 'dart:ui';

import 'package:graphic/src/attr/single_linear/color.dart';
import 'package:graphic/src/attr/single_linear/shape.dart';
import 'package:graphic/src/attr/single_linear/size.dart';
import 'package:graphic/src/attr/position.dart';
import 'package:graphic/src/geom/adjust/base.dart';

import 'base.dart';
import 'shape/interval.dart';

class IntervalGeom extends Geom {
  IntervalGeom({
    ColorAttr color,
    ShapeAttr shape,
    SizeAttr size,
    PositionAttr position,
    Adjust adjust,
  }) {
    this['color'] = color;
    this['shape'] = shape;
    this['size'] = size;
    this['position'] = position;
    this['adjust'] = adjust;
  }

  @override
  GeomType get type => GeomType.interval;
}

class IntervalGeomState<D> extends GeomState<D> {}

class IntervalGeomComponent<D> extends GeomComponent<IntervalGeomState<D>, D> {
  @override
  IntervalGeomState<D> get originalState => IntervalGeomState<D>();

  @override
  get defaultShape => rectInterval;

  // Handle in shape
  @override
  double get defaultSize => null;

  @override
  List<Offset> defaultPositionMapper(List<double> scaledValues) {
    if (scaledValues == null || scaledValues.isEmpty) {
      return null;
    }
    assert(scaledValues.length == 2);

    // [start, end]
    return [
      Offset(scaledValues[0], 0),
      Offset(scaledValues[0], scaledValues[1]),
    ];
  }
}
