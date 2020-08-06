import 'dart:ui';

import 'package:graphic/src/common/typed_map.dart';
import 'package:graphic/src/common/base_classes.dart';
import 'package:graphic/src/chart/component.dart';
import 'package:graphic/src/engine/group.dart';
import 'package:graphic/src/engine/render_shape/base.dart';
import 'package:graphic/src/attr/single_linear/color.dart';
import 'package:graphic/src/attr/single_linear/shape.dart';
import 'package:graphic/src/attr/single_linear/size.dart';
import 'package:graphic/src/attr/position.dart';
import 'package:graphic/src/scale/base.dart';
import 'package:graphic/src/util/list.dart';

import 'shape/base.dart';

double _scaleDatum<D>(ScaleComponent scale, D datum) =>
  scale.scale(scale.state.accessor(datum));

class AttrValueRecord {
  AttrValueRecord({
    this.color,
    this.size,
    this.position,
    this.shape,
  });

  final Color color;
  final double size;
  final List<Offset> position;
  final Shape shape;
}

enum GeomType {
  area,
  interval,
  line,
  point,
  polygon,
  schema,
}

abstract class Geom extends Props<GeomType> {}

abstract class GeomState<D> with TypedMap {
  ChartComponent<D> get chart => this['chart'] as ChartComponent<D>;
  set chart(ChartComponent<D> value) => this['chart'] = value;

  Group get plot => this['plot'] as Group;
  set plot(Group value) => this['plot'] = value;

  Paint get style => this['style'] as Paint;
  set style(Paint value) => this['style'] = value;

  ColorSingleLinearAttrComponent get color =>
    this['color'] as ColorSingleLinearAttrComponent;
  set color(ColorSingleLinearAttrComponent value) =>
    this['color'] = value;

  ShapeSingleLinearAttrComponent get shape =>
    this['shape'] as ShapeSingleLinearAttrComponent;
  set shape(ShapeSingleLinearAttrComponent value) =>
    this['shape'] = value;

  SizeSingleLinearAttrComponent get size =>
    this['size'] as SizeSingleLinearAttrComponent;
  set size(SizeSingleLinearAttrComponent value) =>
    this['size'] = value;

  PositionAttrComponent get position =>
    this['position'] as PositionAttrComponent;
  set position(PositionAttrComponent value) =>
    this['position'] = value;
}

abstract class GeomComponent<S extends GeomState<D>, D>
  extends Component<S>
{
  GeomComponent([TypedMap props]) : super(props);

  void render() {
    final shapes = _getRenderShapes();
    for (var shape in shapes) {
      state.plot.addShape(shape);
    }
  }

  List<RenderShape> _getRenderShapes() {

  }

  String _getGroupField() {
    final positionFields = state.position.state.fields;

    final shapeField = state.shape.state.fields.first;
    if (shapeField != null && !positionFields.contains(shapeField)) {
      return shapeField;
    }
    final colorField = state.color.state.fields.first;
    if (colorField != null && !positionFields.contains(colorField)) {
      return colorField;
    }
    final sizeField = state.size.state.fields.first;
    if (sizeField != null && !positionFields.contains(sizeField)) {
      return sizeField;
    }

    return null;
  }

  List<List<D>> _getDataGroup() {
    final chart = state.chart;
    final data = chart.state.data;
    final groupField = _getGroupField();

    if (groupField == null) {
      return [data];
    }

    final accessor = chart.state.scales[groupField].state.accessor;
    return group(data, accessor);
  }

  List<List<AttrValueRecord>> _getRecordsGroup() {
    final dataGroup = _getDataGroup();
    final scales = state.chart.state.scales;

    final positionFields = state.position.state.fields;
    final positionScales = positionFields.map((field) => scales[field]);
    final colorScale = scales[state.color.state.fields.first];
    final sizeScale = scales[state.size.state.fields.first];
    final shapeScale = scales[state.shape.state.fields.first];
    

    final rst = <List<AttrValueRecord>>[];

    for (var data in dataGroup) {
      final records = <AttrValueRecord>[];
      for (var datum in data) {
        final positionValues = positionScales.map(
          (scale) => _scaleDatum(scale, datum)
        );
        final colorValues = [_scaleDatum(colorScale, datum)];
        final sizeValues = [_scaleDatum(sizeScale, datum)];
        final shapeValues = [_scaleDatum(shapeScale, datum)];

        records.add(AttrValueRecord(
          position: state.position.map(positionValues),
          color: state.color.map(colorValues),
          size: state.size.map(sizeValues),
          shape: state.shape.map(shapeValues),
        ));
      }
      rst.add(records);
    }

    return rst;
  }

  void _adjustRecordsGroup(List<List<AttrValueRecord>> recordsGroup) {

  }
}
