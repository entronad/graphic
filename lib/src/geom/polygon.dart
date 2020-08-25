import 'package:graphic/src/attr/single_linear/color.dart';
import 'package:graphic/src/attr/single_linear/shape.dart';
import 'package:graphic/src/attr/single_linear/size.dart';
import 'package:graphic/src/attr/position.dart';
import 'package:graphic/src/geom/adjust/base.dart';

import 'base.dart';
import 'shape/polygon.dart';

class PolygonGeom extends Geom {
  PolygonGeom({
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
  GeomType get type => GeomType.polygon;
}

class PolygonGeomState<D> extends GeomState<D> {}

class PolygonGeomComponent<D> extends GeomComponent<PolygonGeomState<D>, D> {
  @override
  PolygonGeomState<D> get originalState => PolygonGeomState<D>();

  @override
  get defaultShape => mosaicPolygon;

  @override
  double get defaultSize => null;
}
