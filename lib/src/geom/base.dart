import 'dart:ui';

import 'package:meta/meta.dart';
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
import 'package:graphic/src/scale/category/base.dart';
import 'package:graphic/src/util/list.dart';

import 'shape/base.dart';
import 'adjust/base.dart';

double _scaleDatum<D>(ScaleComponent scale, D datum) =>
  scale.scale(scale.state.accessor(datum));

class AttrValueRecord {
  AttrValueRecord({
    this.color,
    this.size,
    this.position,
    this.shape,
  });

  Color color;
  double size;
  List<Offset> position;
  Shape shape;
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

  AdjustComponent get adjust => this['adjust'] as AdjustComponent;
  set adjust(AdjustComponent value) => this['adjust'] = value;
}

abstract class GeomComponent<S extends GeomState<D>, D>
  extends Component<S>
{
  final _shapeComponents = <RenderShapeComponent>[];

  void setColor(ColorAttr color) =>
    state.color = ColorSingleLinearAttrComponent(color);
  
  void setShape(ShapeAttr shape) =>
    state.shape = ShapeSingleLinearAttrComponent(shape);
  
  void setSize(SizeAttr size) =>
    state.size = SizeSingleLinearAttrComponent(size);
  
  void setPosition(PositionAttr position) {
    final positionComponent = PositionAttrComponent(position);
    if (positionComponent.state.mapper == null) {
      positionComponent.state.mapper = defaultPositionMapper;
    }
    state.position = positionComponent;
  }

  // Base implimentation for sigle Point
  @protected
  List<Offset> defaultPositionMapper(List<double> scaledValues) {
    if (scaledValues == null || scaledValues.isEmpty) {
      return null;
    }
    assert(scaledValues.length == 2);

    return [Offset(
      scaledValues[0],
      scaledValues[1],
    )];
  }

  void render() {
    if (_shapeComponents.isNotEmpty) {
      for (var component in _shapeComponents) {
        component.remove();
      }
      _shapeComponents.clear();
    }

    final renderShapes = _getRenderShapes();
    for (var renderShape in renderShapes) {
      final component = state.plot.addShape(renderShape);
      _shapeComponents.add(component);
    }
  }

  List<RenderShape> _getRenderShapes() {
    final coord = state.chart.state.coord;
    final recordsGroup = _getRecordsGroup();
    _adjustRecordsGroup(recordsGroup);
    
    final rst = <RenderShape>[];

    for (var records in recordsGroup) {
      final shape = records.first.shape;
      rst.addAll(shape(
        records,
        coord,
      ));
    }

    return rst;
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

  List<List<D>> _getDataGroup() {
    final chart = state.chart;
    final data = chart.state.data;
    final groupField = _getGroupField();

    if (groupField == null) {
      return [data];
    }

    // only group by category scale
    final groupScale = chart.state.scales[groupField];
    if (groupScale is CategoryScaleComponent) {
      final accessor = groupScale.state.accessor;
      final values = groupScale.state.values;
      return group(data, accessor, values);
    }
    
    return [data];
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

  void _adjustRecordsGroup(List<List<AttrValueRecord>> recordsGroup) {
    final adjust = state.adjust;
    if (adjust != null) {
      adjust.adjust(recordsGroup);
    }
  }
}
