import 'dart:ui';

import 'package:graphic/src/attr/single_linear/color.dart';
import 'package:graphic/src/attr/single_linear/shape.dart';
import 'package:graphic/src/attr/single_linear/size.dart';
import 'package:graphic/src/attr/position.dart';
import 'package:graphic/src/geom/adjust/base.dart';

import 'base.dart';
import 'shape/schema.dart';

final _defaultShape = BoxShape();

class SchemaGeom extends Geom {
  SchemaGeom({
    ColorAttr color,
    ShapeAttr<SchemaShape> shape,
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
  SchemaGeomState<D> createState() => SchemaGeomState<D>();

  @override
  get defaultShape => _defaultShape;

  @override
  double get defaultSize => null;

  @override
  List<Offset> defaultPositionMapper(List<double> scaledValues) {
    if (scaledValues == null || scaledValues.isEmpty) {
      return null;
    }
    assert(scaledValues.length >= 2);

    final rst = <Offset>[];

    // x*y0*y1*y2 => [(x, y0), (x, y1), (x, y2)]
    for (var i = 1; i < scaledValues.length; i++) {
      rst.add(Offset(scaledValues[0], scaledValues[i] ?? double.nan));
    }

    return rst;
  }

  @override
  void initPositionAxisFields(PositionAttrComponent attrComponent) {
    attrComponent.state.xFields = Set()..add(attrComponent.state.fields[0]);
    attrComponent.state.yFields = Set.from(attrComponent.state.fields.sublist(1));
  }
}
