import 'package:graphic/src/attr/single_linear/color.dart';
import 'package:graphic/src/attr/single_linear/shape.dart';
import 'package:graphic/src/attr/single_linear/size.dart';
import 'package:graphic/src/attr/position.dart';
import 'package:graphic/src/geom/adjust/base.dart';

import 'base.dart';
import 'shape/point.dart';

class PointGeom extends Geom {
  PointGeom({
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
  GeomType get type => GeomType.point;
}

class PointGeomState<D> extends GeomState<D> {}

class PointGeomComponent<D> extends GeomComponent<PointGeomState<D>, D> {
  @override
  PointGeomState<D> get originalState => PointGeomState<D>();

  @override
  get defaultShape => circlePoint;

  @override
  double get defaultSize => 5;
}
