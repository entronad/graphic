import 'dart:ui';

import 'package:graphic/src/attr/single_linear/color.dart';
import 'package:graphic/src/attr/single_linear/shape.dart';
import 'package:graphic/src/attr/single_linear/size.dart';
import 'package:graphic/src/attr/position.dart';
import 'package:graphic/src/geom/adjust/base.dart';

import 'base.dart';

class SchemaGeom extends Geom {
  SchemaGeom({
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
  GeomType get type => GeomType.schema;
}

class SchemaGeomState<D> extends GeomState<D> {}

class SchemaGeomComponent<D> extends GeomComponent<SchemaGeomState<D>, D> {
  @override
  SchemaGeomState<D> get originalState => SchemaGeomState();

  @override
  List<Offset> defaultPositionMapper(List<double> scaledValues) {
    if (scaledValues == null || scaledValues.isEmpty) {
      return null;
    }
    assert(scaledValues.length >= 2);

    final rst = <Offset>[];

    // x*y0*y1*y2 => [(x, y0), (x, y1), (x, y2)]
    for (var i = 1; i < scaledValues.length; i++) {
      rst.add(Offset(scaledValues[0], scaledValues[i]));
    }

    return rst;
  }
}
