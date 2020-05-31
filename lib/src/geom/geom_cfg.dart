import 'dart:ui' show Offset, Color;

import 'package:graphic/src/base.dart' show BaseCfg;
import 'package:graphic/src/attr/attr_cfg.dart' show AttrCfg, AttrType;
import 'package:graphic/src/attr/base.dart' show Attr;
import 'package:graphic/src/scale/base.dart' show Scale;
import 'package:graphic/src/scale/scale_cfg.dart' show ScaleCfg;
import 'package:graphic/src/engine/container.dart' show Container;
import 'package:graphic/src/engine/attrs.dart' show Attrs;
import 'package:graphic/src/chart/chart_controller.dart' show ChartController;
import 'package:graphic/src/geom/adjust/adjust_cfg.dart' show AdjustCfg;
import 'package:graphic/src/coord/base.dart' show Coord;

import 'shape/shape.dart' show ShapeFactoryBase;

enum GeomType {
  area,
  interval,
  line,
  point,
  polygon,
  schema,
}

class StyleOption {
  StyleOption({this.field, this.style});

  String field;

  Attrs style;
}

class GeomCfg extends BaseCfg {
  GeomCfg({
    GeomType type,
    bool generatePoints,
    bool sortable,
    bool startOnZero,
    bool connectNulls,

    AttrCfg<double> position,
    AttrCfg<double> size,
    AttrCfg<Color> color,
    AttrCfg<String> shape,
    
    AdjustCfg adjust,
    StyleOption styleOption,
    // TODO: animation
  }) {
    this['type'] = type;
    this['generatePoints'] = generatePoints;
    this['sortable'] = sortable;
    this['startOnZero'] = startOnZero;
    this['connectNulls'] = connectNulls;

    this['attrOptions'] = {
      AttrType.position: position,
      AttrType.size: size,
      AttrType.color: color,
      AttrType.shape: shape,
    };

    this['adjust'] = adjust;
    this['styleOption'] = styleOption;
  }

  GeomType get type => this['type'] as GeomType;
  set type(GeomType value) => this['type'] = value;

  List<Map<String, Object>> get data => this['data'] as List<Map<String, Object>>;
  set data(List<Map<String, Object>> value) => this['data'] = value;

  List<List<Map<String, Object>>> get dataArray => this['dataArray'] as List<List<Map<String, Object>>>;
  set dataArray(List<List<Map<String, Object>>> value) => this['dataArray'] = value;

  Map<AttrType, Attr> get attrs => this['attrs'] as Map<AttrType, Attr>;
  set attrs(Map<AttrType, Attr> value) => this['attrs'] = value;

  Map<AttrType, AttrCfg> get attrOptions => this['attrOptions'] as Map<AttrType, AttrCfg>;
  set attrOptions(Map<AttrType, AttrCfg> value) => this['attrOptions'] = value;

  Map<String, Scale> get scales => this['scales'] as Map<String, Scale>;
  set scales(Map<String, Scale> value) => this['scales'] = value;

  Container get container => this['container'] as Container;
  set container(Container value) => this['container'] = value;

  AdjustCfg get adjust => this['adjust'] as AdjustCfg;
  set adjust(AdjustCfg value) => this['adjust'] = value;

  StyleOption get styleOption => this['styleOption'] as StyleOption;
  set styleOption(StyleOption value) => this['styleOption'] = value;

  ChartController get chart => this['chart'] as ChartController;
  set chart(ChartController value) => this['chart'] = value;

  bool get generatePoints => this['generatePoints'] as bool ?? false;
  set generatePoints(bool value) => this['generatePoints'] = value;

  bool get sortable => this['sortable'] as bool ?? false;
  set sortable(bool value) => this['sortable'] = value;

  bool get hasSorted => this['hasSorted'] as bool ?? false;
  set hasSorted(bool value) => this['hasSorted'] = value;

  bool get startOnZero => this['startOnZero'] as bool ?? false;
  set startOnZero(bool value) => this['startOnZero'] = value;

  bool get visible => this['visible'] as bool ?? false;
  set visible(bool value) => this['visible'] = value;

  bool get connectNulls => this['connectNulls'] as bool ?? false;
  set connectNulls(bool value) => this['connectNulls'] = value;

  bool get ignoreEmptyGroup => this['ignoreEmptyGroup'] as bool ?? false;
  set ignoreEmptyGroup(bool value) => this['ignoreEmptyGroup'] = value;

  Map<String, ScaleCfg> get colDefs => this['colDefs'] as Map<String, ScaleCfg>;
  set colDefs(Map<String, ScaleCfg> value) => this['colDefs'] = value;

  Coord get coord => this['coord'] as Coord;
  set coord(Coord value) => this['coord'] = value;

  ShapeFactoryBase get shapeFactory => this['shapeFactory'] as ShapeFactoryBase;
  set shapeFactory(ShapeFactoryBase value) => this['shapeFactory'] = value;
}
