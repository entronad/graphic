import 'dart:ui';

import 'package:graphic/src/attr/single_linear/color.dart';
import 'package:graphic/src/attr/single_linear/shape.dart';
import 'package:graphic/src/attr/single_linear/size.dart';
import 'package:graphic/src/attr/position.dart';
import 'package:graphic/src/geom/adjust/base.dart';

import 'base.dart';
import 'shape/area.dart';

final _defaultShape = BasicAreaShape();

class AreaGeom extends Geom {
  AreaGeom({
    ColorAttr color,
    ShapeAttr<AreaShape> shape,
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
  AreaGeomState<D> createState() => AreaGeomState<D>();

  @override
  get defaultShape => _defaultShape;

  @override
  double get defaultSize => null;

  @override
  List<Offset> defaultPositionMapper(List<double> scaledValues) {
    if (scaledValues == null || scaledValues.isEmpty) {
      return null;
    }

    final singleYField = state.position.state.yFields.last;
    final singleYOrigin = state.chart.state.scales[singleYField].origin;

    // x*y => [(x, origin), (x, y)]
    // x*y0*y1 => [(x, y0), (x, y1)]
    switch (scaledValues.length) {
      case 2:
        return [
          Offset(scaledValues[0], singleYOrigin ?? double.nan),
          Offset(scaledValues[0], scaledValues[1] ?? double.nan),
        ];
      case 3:
        return [
          Offset(scaledValues[0], scaledValues[1] ?? double.nan),
          Offset(scaledValues[0], scaledValues[2] ?? double.nan),
        ];
      default:
        throw Exception('Area position fields must be 2, or 3');
    }
  }

  @override
  void initPositionAxisFields(PositionAttrComponent attrComponent) {
    final fields = attrComponent.state.fields;
    switch (fields.length) {
      case 2:
        attrComponent.state.xFields = Set()..add(fields[0]);
        attrComponent.state.yFields = Set()..add(fields[1]);
        break;
      case 3:
        attrComponent.state.xFields = Set()..add(fields[0]);
        attrComponent.state.yFields = Set.from(attrComponent.state.fields.sublist(1));
        break;
      default:
        throw Exception('Area position fields must be 2, or 3');
    }
  }
}
