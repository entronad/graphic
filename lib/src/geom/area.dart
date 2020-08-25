import 'package:graphic/src/attr/single_linear/color.dart';
import 'package:graphic/src/attr/single_linear/shape.dart';
import 'package:graphic/src/attr/single_linear/size.dart';
import 'package:graphic/src/attr/position.dart';
import 'package:graphic/src/geom/adjust/base.dart';

import 'base.dart';
import 'shape/area.dart';

class AreaGeom extends Geom {
  AreaGeom({
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
  GeomType get type => GeomType.area;
}

class AreaGeomState<D> extends GeomState<D> {}

class AreaGeomComponent<D> extends GeomComponent<AreaGeomState<D>, D> {
  @override
  AreaGeomState<D> get originalState => AreaGeomState<D>();

  @override
  get defaultShape => area;

  @override
  double get defaultSize => null;
}
