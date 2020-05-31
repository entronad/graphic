import 'dart:math' show max, min;
import 'dart:ui' show Offset;

import 'package:graphic/src/base.dart' show Base;
import 'package:graphic/src/util/field.dart' show parseField;
import 'package:graphic/src/scale/base.dart' show Scale;
import 'package:graphic/src/scale/scale_cfg.dart' show ScaleCfg, ScaleType;
import 'package:graphic/src/scale/time_cat_scale.dart' show TimeCatScale;
import 'package:graphic/src/attr/attr_cfg.dart' show AttrType, AttrCfg, AttrCallback;
import 'package:graphic/src/attr/base.dart' show Attr;
import 'package:graphic/src/geom/adjust/base.dart' show Adjust;
import 'package:graphic/src/geom/adjust/adjust_cfg.dart' show AdjustType, AdjustCfg;
import 'package:graphic/src/util/array.dart' show group, flattern;
import 'package:graphic/src/coord/coord_cfg.dart' show CoordType;
import 'package:graphic/src/engine/attrs.dart' show Attrs;
import 'package:graphic/src/engine/container.dart' show Container;

import 'geom_cfg.dart' show GeomCfg, StyleOption;
import 'shape/shape.dart' show Shape, ShapeFactoryBase;
import 'shape/shape_cfg.dart' show ShapeCfg;

// Datum Map<String, Object>
// aditional keys: 'x', 'y', 'points', 'nextPoints', '_origin', '_originY'

const groupAttrs = [
  AttrType.color,
  AttrType.size,
  AttrType.shape,
];

abstract class Geom extends Base<GeomCfg> {
  Geom(GeomCfg cfg) : super(cfg) {
    // TODO: init attr
  }

  @override
  GeomCfg get defaultCfg => GeomCfg()
    ..attrs = {}
    ..attrOptions = {}
    ..scales = {}
    ..generatePoints = false
    ..sortable = false
    ..startOnZero = true
    ..visible = true
    ..connectNulls = false
    ..ignoreEmptyGroup = false;

  void init() {
    _initAttrs();
    _processData();
  }

  List<Scale> _getGroupScales() {
    final scales = <Scale>[];
    for (var attrName in groupAttrs) {
      final attr = getAttr(attrName);
      if (attr != null) {
        final attrScales = attr.cfg.scales;
        for (var scale in attrScales) {
          if (scale != null && scale.cfg.isCategory && !scales.contains(scale)) {
            scales.add(scale);
          }
        }
      }
    }
    return scales;
  }

  List<List<Map<String, Object>>> _groupData(List<Map<String, Object>> data) {
    final colDefs = cfg.colDefs;
    final groupScales = _getGroupScales();
    if (groupScales.isNotEmpty) {
      final appendConditions = <String, List<Object>>{};
      final names = <String>[];
      for (var scale in groupScales) {
        final field = scale.cfg.field;
        names.add(field);
        if (colDefs != null && colDefs[field]?.values != null) {
          appendConditions[scale.cfg.field] = colDefs[field].values;
        }
      }
      return group(data, names, appendConditions);
    }
    return [data];
  }

  void _setAttrOption(AttrType attrName, AttrCfg attrCfg) {
    final options = cfg.attrOptions;
    options[attrName] = attrCfg;

    final attrs = cfg.attrs;
    if (attrs.isNotEmpty) {
      _createAttr(attrName, attrCfg);
    }
  }

  void _createAttrOption<V>(
    AttrType attrName,
    AttrCfg attrCfg,
    List<V> defaultValues,
  ) {
    attrCfg.values ??= defaultValues;
    _setAttrOption(attrName, attrCfg);
  }

  Attr _createAttr(AttrType type, AttrCfg option) {
    final attrs = cfg.attrs;
    final coord = cfg.coord;
    final fields = parseField(option.field);
    if (type == AttrType.position) {
      option.coord = coord;
    }
    final scales = <Scale>[];
    for (var field in fields) {
      final scale = _createScale(field);
      scales.add(scale);
    }
    if (type == AttrType.position) {
      final yScale = scales[1] as Scale<double>;

      if (coord.cfg.type == CoordType.polar
        && coord.cfg.transposed
        && hasAdjust(AdjustType.stack)
      ) {
        if (yScale.cfg.values.isNotEmpty) {
          yScale.change(ScaleCfg(
            nice: false,
            min: 0,
            max: yScale.cfg.values.reduce(max),
          ));
        }
      }
    }

    option.scales = scales;
    final attr = Attr.creators[type](option);
    attrs[type] = attr;
    return attr;
  }

  void _initAttrs() {
    final attrOptions = cfg.attrOptions;

    for (var type in attrOptions.keys) {
      _createAttr(type, attrOptions[type]);
    }
  }

  Scale _createScale(String field) {
    final scales = cfg.scales;
    var scale = scales[field];
    if (scale == null) {
      scale = cfg.chart.createScale(field);
      scales[field] = scale;
    }
    return scale;
  }

  List<List<Map<String, Object>>> _processData() {
    final data = cfg.data;
    final dataArray = <List<Map<String, Object>>>[];
    var groupedArray = _groupData(data);

    if (cfg.ignoreEmptyGroup) {
      var yScale = this.yScale;
      groupedArray = groupedArray.where(
        (group) => group.any(
          (item) => item[yScale.cfg.field] != null
        )
      );
    }
    for (var subData in groupedArray) {
      var tempData = _saveOrigin(subData);
      if (hasAdjust(AdjustType.dodge)) {
        _numberic(tempData);
      }
      dataArray.add(tempData);
    }

    if (cfg.adjust != null) {
      _adjustData(dataArray);
    }

    if (cfg.sortable) {
      _sort(dataArray);
    }

    cfg.dataArray = dataArray;
    return dataArray;
  }

  List<Map<String, Object>> _saveOrigin(List<Map<String, Object>> data) {
    final rst = <Map<String, Object>>[];
    for (var origin in data) {
      final obj = {...origin};
      obj['_origin'] = origin;
      rst.add(obj);
    }
    return rst;
  }

  void _numberic(List<Map<String, Object>> data) {
    final positionAttr = getAttr(AttrType.position);
    final scales = positionAttr.cfg.scales;
    for (var obj in data) {
      final count = min(2, scales.length);
      for (var i = 0; i < count; i++) {
        final scale = scales[i];
        if (scale.cfg.isCategory) {
          final field = scale.cfg.field;
          obj[field] = scale.translate(obj[field]);
        }
      }
    }
  }

  void _adjustData(List<List<Map<String, Object>>> dataArray) {
    final adjust = cfg.adjust;
    if (adjust != null) {
      final adjustType = adjust.type;
      final cfg = AdjustCfg(
        xField: xScale.cfg.field,
        yField: yScale.cfg.field,
      ).mix(adjust);
      final adjustObject = Adjust.creators[adjustType](cfg);
      adjustObject.processAdjust(dataArray);
      if (adjustType == AdjustType.stack) {
        _updateStackRange(yScale.cfg.field, yScale, dataArray);
      }
    }
  }

  void _updateStackRange(
    String field,
    Scale scale,
    List<List<Map<String, Object>>> dataArray,
  ) {
    final flatArray = flattern(dataArray);

    var minValue = scale.cfg.min;
    var maxValue = scale.cfg.max;

    for (var obj in flatArray) {
      final values = obj[field] as List<double>;
      final tmpMin = values.reduce(min);
      final tmpMax = values.reduce(max);

      if (tmpMin < minValue) {
        minValue = tmpMin;
      }

      if(tmpMax > maxValue) {
        maxValue = tmpMax;
      }
    }

    if (minValue < scale.cfg.min || maxValue > scale.cfg.max) {
      scale.change(ScaleCfg(
        min: minValue,
        max: maxValue,
      ));
    }
  }

  void _sort(List<List<Map<String, Object>>> mappedArray) {
    final xScale = this.xScale;
    final field = xScale.cfg.field;
    final type = xScale.cfg.type;
    if (type != ScaleType.identity && xScale.cfg.values.length > 1) {
      for (var itemArr in mappedArray) {
        itemArr.sort((obj1, obj2) {
          final v1 = (obj1['_origin'] as Map<String, Object>)[field];
          final v2 = (obj2['_origin'] as Map<String, Object>)[field];
          if (type == ScaleType.timeCat) {
            final xScaleTC = xScale as TimeCatScale;
            return xScaleTC.toTimeStamp(v1) - xScaleTC.toTimeStamp(v2);
          }
          return xScale.translate(v1) - xScale.translate(v2);
        });
      }
    }

    cfg.hasSorted = true;
    cfg.dataArray = mappedArray;
  }

  void draw() {
    final dataArray = cfg.dataArray;
    final mappedArray = <List<Map<String, Object>>>[];
    final shapeFactory = getShapeFactory();
    shapeFactory.coord = cfg.coord;
    _beforeMapping(dataArray);
    for (var data in dataArray) {
      if (data.isNotEmpty) {
        data = _mapping(data);
        mappedArray.add(data);
        drawData(data, shapeFactory);
      }
    }
    cfg.dataArray = mappedArray;
  }

  ShapeFactoryBase getShapeFactory() {
    var shapeFactory = cfg.shapeFactory;
    if (shapeFactory == null) {
      final type = cfg.type;
      shapeFactory = Shape.getShapeFctory(type)();
      cfg.shapeFactory = shapeFactory;
    }
    return shapeFactory;
  }

  List<Map<String, Object>> _mapping(List<Map<String, Object>> data) {
    final attrs = cfg.attrs;
    final yField = yScale.cfg.field;

    final mappedCache = <String, Object>{};

    for (var k in attrs.keys) {
      final attr = attrs[k];
      final names = attr.cfg.names;
      final scales = attr.cfg.scales;

      for (var record in data) {
        record['_originY'] = record[yField];

        if (attr.cfg.type == AttrType.position) {
          final values = _getAttrValues(attr, record);
          for (var i = 0; i < values.length; i++) {
            final val = values[i];
            final name = names[i];
            record[name] = (val is List && val.length == 1) ? val[0] : val;
          }
        } else {
          final name = names[0];
          final field = scales[0].cfg.field;
          final value = record[field];
          final key = '$name$value';
          var values = mappedCache[key];
          if (values == null) {
            values = _getAttrValues(attr, record);
            mappedCache[key] = values;
          }
          record[name] = (values as List)[0];
        }
      }
    }
    return data;
  }

  List<Object> _getAttrValues(Attr attr, Map<String, Object> record) {
    final scales = attr.cfg.scales;
    final params = [];
    for (var scale in scales) {
      final field = scale.cfg.field;
      if (scale.cfg.type == ScaleType.identity) {
        params.add(scale.cfg.value);
      } else {
        params.add(record[field]);
      }
    }
    final values = attr.mapping(params);
    return values;
  }

  Object getAttrValue(AttrType attrName, record) {
    final attr = getAttr(attrName);
    Object rst;
    if (attr != null) {
      final values = _getAttrValues(attr, record);
      rst = values[0];
    }
    return rst;
  }

  void _beforeMapping(List<List<Map<String, Object>>> dataArray) {
    if (cfg.generatePoints) {
      _generatePoints(dataArray);
    }
  }

  bool get isInCircle {
    final coord = cfg.coord;
    return coord != null && coord.cfg.isPolar;
  }

  Attrs getCallbackCfg(String field, Attrs style, Map<String, Object> origin) {
    // TODO: need to merge callback and value, but seems not here
    return style;
  }

  ShapeCfg getDrawCfg(Map<String, Object> obj) {
    final isInCircle = this.isInCircle;
    final shapeCfg = ShapeCfg()
      ..x = obj['x']
      ..y = obj['y']
      ..color = obj['color']
      ..size = obj['size']
      ..shape = obj['shape']
      ..isInCircle = obj['isInCircle'];
    final styleOption = cfg.styleOption;
    if (styleOption != null && styleOption.style != null) {
      shapeCfg.style = getCallbackCfg(styleOption.field, styleOption.style, obj['_origin']);
    }
    if (cfg.generatePoints) {
      shapeCfg.points = obj['points'];
      shapeCfg.nextPoints = obj['nextPoints'];
    }
    if (isInCircle) {
      shapeCfg.center = cfg.coord.cfg.center;
    }
    return shapeCfg;
  }

  void drawData(List<Map<String, Object>> data, ShapeFactoryBase shapeFactory) {
    final container = cfg.container;
    final yScale = this.yScale;
    for (var i = 0; i < data.length; i++) {
      final obj = data[i];
      final origin = obj['_origin'] as Map;
      if (origin[yScale?.cfg?.field] == null) {
        return;
      }
      obj['index'] = i;
      final shapeCfg = getDrawCfg(obj);
      final shape = obj['shape'] as String;
      drawShape(shape, obj, shapeCfg, container, shapeFactory);
    }
  }

  void drawShape(
    String shape,
    Map<String, Object> shapeDatum,
    ShapeCfg cfg,
    Container container,
    ShapeFactoryBase shapeFactory,
  ) {
    shapeFactory.drawShape(shape, cfg, container);
    // TODO: maybe have to add the origin to cfg
  }

  void _generatePoints(List<List<Map<String, Object>>> dataArray) {

  }

  Map<String, Object> createShapePointsCfg(Map<String, Object> obj) {
    final xScale = this.xScale;
    final yScale = this.yScale;
    final x = _normalizeValues(obj[xScale.cfg.field], xScale);
    List<double> y;

    if (yScale != null) {
      y = _normalizeValues(obj[yScale.cfg.field], yScale);
    } else {
      y = obj['y'] != null ? obj['y'] != null : [0.1];
    }

    return {
      'x': x,
      'y': y,
      'y0': yScale?.scale(yMinValue),
    };
  }

  double get yMinValue {
    final yScale = this.yScale;
    final minValue = yScale.cfg.min;
    final maxValue = yScale.cfg.max;
    double value;

    if (cfg.startOnZero) {
      if (maxValue <= 0 && minValue <= 0) {
        value = maxValue;
      } else {
        value = minValue >= 0 ? minValue : 0;
      }
    } else {
      value = minValue;
    }

    return value;
  }

  List<double> _normalizeValues(Object values, Scale scale) {
    var rst = <double>[];
    if (values is List) {
      for (var v in values) {
        rst.add(scale.scale(v));
      }
    } else {
      rst = [scale.scale(values)];
    }
    return rst;
  }

  Attr getAttr(AttrType name) =>
    cfg.attrs[name];
  
  Scale get xScale =>
    getAttr(AttrType.position).cfg.scales[0];
  
  Scale get yScale =>
    getAttr(AttrType.position).cfg.scales[1];
  
  bool hasAdjust(AdjustType adjust) =>
    cfg.adjust != null && cfg.adjust.type == adjust;

  List<double> _getSnap(Scale scale, double item, [List<Map<String, Object>> arr]) {
    var i = 0;
    List<List<double>> values;
    final yField = yScale.cfg.field;
    if (hasAdjust(AdjustType.stack) && scale.cfg.field == yField) {
      values = [];
      for (var obj in arr) {
        values.add(obj['_originY']);
      }

      for (var i = 0; i < values.length; i++) {
        if (values[0][0] > item) {
          break;
        }
        if (values[values.length - 1][1] <= item) {
          i = values.length - 1;
          break;
        }
        if (values[i][0] <= item && values[i][1] > item) {
          break;
        }
      }
    } else {
      values = scale.cfg.values.map((e) => [e]);
      values.sort((a, b) => a.first > b.first ? 1 : -1);
      for (var i = 0; i < values.length; i++) {
        if (values.length <= 1) {
          break;
        }
        if ((values[0].first + values[1].first) / 2 > item) {
          break;
        }
        if (
          (values[i - 1].first + values[i].first) / 2 <= item
            && (values[i + 1].first + values[i].first) / 2 > item
        ) {
          break;
        }
        if ((values[values.length - 2].first + values[values.length - 1].first) / 2 <= item) {
          i = values.length - 1;
          break;
        }
      }
    }
    final result = values[i];
    return result;
  }

  List<Map<String, Object>> getSnapRecords(Offset point) {
    final coord = cfg.coord;
    final xScale = this.xScale;
    final yScale = this.yScale;
    final xField = xScale.cfg.field;

    final dataArray = cfg.dataArray;
    if (!cfg.hasSorted) {
      _sort(dataArray);
    }

    var rst = <Map<String, Object>>[];
    final invertPoint = coord.invertPoint(point);
    var invertPointX = invertPoint.dx;
    if (isInCircle && !coord.cfg.transposed && invertPointX > (1 + xScale.rangeMax) / 2) {
      invertPointX = xScale.rangeMin;
    }

    var xValue = xScale.invert(invertPointX);
    if (!xScale.cfg.isCategory) {
      xValue = _getSnap(xScale, xValue);
    }

    final tmp = <Map<String, Object>>[];

    for (var data in dataArray) {
      for (var obj in data) {
        final origin = obj['_origin'] as Map<String, Object>;
        final originValue = origin == null ? obj[xField] : origin[xField];
        if (_isEqual(originValue, xValue, xScale)) {
          tmp.add(obj);
        }
      }
    }

    if (hasAdjust(AdjustType.stack) && coord.cfg.isPolar && coord.cfg.transposed) {
      if (invertPointX >= 0 && invertPointX <= 1) {
        final yValueItem = yScale.invert(invertPoint.dy);
        final yValue = _getSnap(yScale, yValueItem, tmp);
        for (var obj in tmp) {
          if (obj['_originY'].toString() == yValue.toString()) {
            rst.add(obj);
          }
        }
      }
    } else {
      rst = tmp;
    }

    return rst;
  }

  List<Map<String, Object>> getRecords(Object value) {
    final xScale = this.xScale;
    final dataArray = cfg.dataArray;
    final xField = xScale.cfg.field;

    return dataArray.map((data) {
      for (var obj in data) {
        final origin = obj['_origin'] as Map<String, Object>;
        final originValue = origin == null ? obj[xField] : origin[xField];
        if (_isEqual(originValue, value, xScale)) {
          return obj;
        }
      }
      return null;
    }).toList();
  }

  bool _isEqual(Object originValue, Object value, Scale scale) {
    if (scale.cfg.type == ScaleType.timeCat) {
      return (scale as TimeCatScale).toTimeStamp(originValue) == value;
    }
    return value == originValue;
  }

  void position(AttrCfg cfg) =>
    _setAttrOption(AttrType.position, cfg);

  void color(AttrCfg cfg) =>
    _createAttrOption(AttrType.color, cfg, null);    // TODO: global theme

  void size(AttrCfg cfg) =>
    _createAttrOption(AttrType.size, cfg, null);    // TODO: global theme
  
  void shape(AttrCfg cfg) {
    final type = cfg.type;
    final shapes = <String>[];    // TODO: global theme
    _createAttrOption(AttrType.shape, cfg, shapes);
  }

  void style(StyleOption style) =>
    cfg.styleOption = style;

  void adjust(AdjustCfg cfg) =>
    this.cfg.adjust = cfg;
  
  // TODO: animate

  void changeData(List<Map<String, Object>> data) {
    cfg.data = data;
    cfg.scales = {};
    init();
  }

  void clearInner() =>
    cfg.container?.clear();
  
  void reset() {
    cfg.attrs = {};
    cfg.attrOptions = {};
    cfg.adjust = null;
    clearInner();
  }

  void clear() =>
    clearInner();

  @override
  void destroy() {
    clear();
    super.destroy();
  }

  void _display(bool visible) {
    cfg.visible = visible;
    final container = cfg.container;
    final renderer = container.cfg.renderer;
    container.cfg.visible = visible;
    // TODO: renderer.draw();
  }

  void show() => _display(true);

  void hide() => _display(false);
}
