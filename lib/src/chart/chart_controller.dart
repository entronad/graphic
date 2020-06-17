import 'dart:math';
import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:graphic/src/base.dart';
import 'package:graphic/src/chart/chart.dart';
import 'package:graphic/src/component/axis/base.dart';
import 'package:graphic/src/engine/attrs.dart';
import 'package:graphic/src/engine/cfg.dart';
import 'package:graphic/src/engine/event/event_emitter.dart';
import 'package:graphic/src/scale/base.dart';
import 'package:graphic/src/attr/base.dart';
import 'package:graphic/src/util/field.dart';
import 'package:graphic/src/util/typed_map_mixin.dart';
import 'package:graphic/src/geom/base.dart';
import 'package:graphic/src/global.dart';
import 'package:graphic/src/coord/base.dart';
import 'package:graphic/src/engine/group.dart';
import 'package:graphic/src/engine/renderer.dart';
import 'package:graphic/src/util/helper.dart';

import 'controller/scale_controller.dart';
import 'controller/axis_controller.dart';
import 'const.dart';

typedef DataFilter = bool Function(Object value, [Map<String, Object> datum]);

class ChartControllerCfg with TypedMapMixin {
  bool get destroyed => this['destroyed'] as bool ?? false;
  set destroyed(bool value) => this['destroyed'] = value;

  String get id => this['id'] as String;
  set id(String value) => this['id'] = value;

  bool get renderered => this['renderered'] as bool ?? false;
  set renderered(bool value) => this['renderered'] = value;

  EdgeInsets get padding => this['padding'] as EdgeInsets;
  set padding(EdgeInsets value) => this['padding'] = value;

  EdgeInsets get appendPadding => this['appendPadding'] as EdgeInsets;
  set appendPadding(EdgeInsets value) => this['appendPadding'] = value;

  EdgeInsets get margin => this['margin'] as EdgeInsets;
  set margin(EdgeInsets value) => this['margin'] = value;

  EdgeInsets get storedPadding => this['storedPadding'] as EdgeInsets;
  set storedPadding(EdgeInsets value) => this['storedPadding'] = value;

  List<Map<String, Object>> get data => this['data'] as List<Map<String, Object>>;
  set data(List<Map<String, Object>> value) => this['data'] = value;

  List<Map<String, Object>> get filteredData => this['filteredData'] as List<Map<String, Object>>;
  set filteredData(List<Map<String, Object>> value) => this['filteredData'] = value;

  Map<String, Scale> get scales => this['scales'] as Map<String, Scale>;
  set scales(Map<String, Scale> value) => this['scales'] = value;

  List<Geom> get geoms => this['geoms'] as List<Geom>;
  set geoms(List<Geom> value) => this['geoms'] = value;

  Map<String, ScaleCfg> get colDefs => this['colDefs'] as Map<String, ScaleCfg>;
  set colDefs(Map<String, ScaleCfg> value) => this['colDefs'] = value;

  Map<String, DataFilter> get filters => this['filters'] as Map<String, DataFilter>;
  set filters(Map<String, DataFilter> value) => this['filters'] = value;

  bool get syncY => this['syncY'] as bool ?? false;
  set syncY(bool value) => this['syncY'] = value;

  Coord get coordObj => this['coordObj'] as Coord;
  set coordObj(Coord value) => this['coordObj'] = value;

  // This is cfg but to accord to ChartCfg field
  CoordCfg get coord => this['coord'] as CoordCfg;
  set coord(CoordCfg value) => this['coord'] = value;

  ScaleController get scaleController => this['scaleController'] as ScaleController;
  set scaleController(ScaleController value) => this['scaleController'] = value;

  AxisController get axisController => this['axisController'] as AxisController;
  set axisController(AxisController value) => this['axisController'] = value;

  Rect get plot => this['plot'] as Rect;
  set plot(Rect value) => this['plot'] = value;

  Group get frontPlot => this['frontPlot'] as Group;
  set frontPlot(Group value) => this['frontPlot'] = value;

  Group get middlePlot => this['middlePlot'] as Group;
  set middlePlot(Group value) => this['middlePlot'] = value;

  Group get backPlot => this['backPlot'] as Group;
  set backPlot(Group value) => this['backPlot'] = value;

  bool get limitInPlot => this['limitInPlot'] as bool ?? false;
  set limitInPlot(bool value) => this['limitInPlot'] = value;

  double get width => this['width'] as double;
  set width(double value) => this['width'] = value;

  double get height => this['height'] as double;
  set height(double value) => this['height'] = value;

  Renderer get renderer => this['renderer'] as Renderer;
  set renderer(Renderer value) => this['renderer'] = value;

  bool get isUpdate => this['isUpdate'] as bool ?? false;
  set isUpdate(bool value) => this['isUpdate'] = value;
}

class ChartController extends Base<ChartControllerCfg> with EventEmitter {
  ChartController(ChartCfg chartCfg) : super(null) {
    cfg.mix(chartCfg);
    _init();
    update(chartCfg);
  }

  @override
  ChartControllerCfg get defaultCfg => ChartControllerCfg()
    ..padding = Global.theme.padding
    ..scales = {}
    ..geoms = []
    ..appendPadding = Global.theme.appendPadding;

  Renderer get renderer => cfg.renderer;
  
  bool get destroyed => cfg.destroyed;

  void update(ChartCfg chartCfg) {
    source(chartCfg.data, chartCfg.scales);
    coord(chartCfg.coord);
    for (var field in chartCfg.axes.keys) {
      axis(field, chartCfg.axes[field]);
    }
    for (var geom in chartCfg.geoms) {
      addGeom(geom);
    }
  }
  
  void _syncYScale() {
    final syncY = cfg.syncY;
    if (!syncY) {
      return;
    }
    final geoms = cfg.geoms;
    final syncScales = <Scale>[];
    final minValues = <double>[];
    final maxValues = <double>[];
    for (var geom in geoms) {
      final yScale = geom.yScale;
      if (yScale.cfg.isLinear) {
        syncScales.add(yScale);
        minValues.add(yScale.cfg.min);
        maxValues.add(yScale.cfg.max);
      }
    }

    final minValue = minValues.reduce(min);
    final maxValue = maxValues.reduce(max);

    for (var scale in syncScales) {
      scale.change(ScaleCfg(min: minValue));
      scale.change(ScaleCfg(max: maxValue));
    }
  }

  List<String> _getFieldsForLegend() {
    final fields = <String>[];
    final geoms = cfg.geoms;
    for (var geom in geoms) {
      final attrOptions = geom.cfg.attrOptions;
      final attrCfg = attrOptions[AttrType.color];
      if (attrCfg?.field != null) {
        final arr = parseField(attrCfg.field);

        for (var item in arr) {
          if (!fields.contains(item)) {
            fields.add(item);
          }
        }
      }
    }
    return fields;
  }

  List<Map<String, Object>> getScaleData(String field) {
    var data = cfg.data;
    final filteredData = cfg.filteredData;
    if (filteredData.isNotEmpty) {
      final legendFields = _getFieldsForLegend();
      if (!legendFields.contains(field)) {
        data = filteredData;
      }
    }
    return data;
  }

  void _adjustScale() {
    final scaleController = cfg.scaleController;
    final geoms = cfg.geoms;
    for (var geom in geoms) {
      if (geom.cfg.type == GeomType.interval) {
        final yScale = geom.yScale;
        scaleController.adjustStartZero(yScale);
      }
    }
  }

  void _removeGeoms() {
    final geoms = cfg.geoms;
    while (geoms.isNotEmpty) {
      final geom = geoms.removeAt(0);
      geom.destroy();
    }
  }

  void _clearGeoms() {
    final geoms = cfg.geoms;
    for (var geom in geoms) {
      geom.clear();
    }
  }

  void _clearInner() {
    _clearGeoms();
    // TODO: notify plugins
    cfg.axisController?.clear();
  }

  void _initFilteredData() {
    final filters = cfg.filters;
    var data = cfg.data ?? <Map<String, Object>>[];
    if (filters != null) {
      data = data.where((obj) {
        var rst = true;
        for (var k in filters.keys) {
          final fn = filters[k];
          if (fn != null) {
            rst = fn(obj[k], obj);
            if (!rst) {
              return false;
            }
          }
        }
        return rst;
      });
    }
    cfg.filteredData = data;
  }

  void _changeGeomsData() {
    final geoms = cfg.geoms;
    final data = cfg.filteredData;
    for (var geom in geoms) {
      geom.changeData(data);
    }
  }

  void _initGeom(Geom geom) {
    final coord = cfg.coordObj;
    final data = cfg.filteredData;
    final colDefs = cfg.colDefs;
    final middlePlot = cfg.middlePlot;
    geom.cfg.chart = this;
    geom.cfg.container = middlePlot.addGroup();
    geom.cfg.data = data;
    geom.cfg.coord = coord;
    geom.cfg.colDefs = colDefs;
    geom.init();
    emitInner(eventAfterGeomInit, Geom);
  }

  void _initGeoms() {
    final geoms = cfg.geoms;
    geoms.forEach(_initGeom);
  }

  void _initCoord() {
    final plot = cfg.plot;
    final coordCfg = CoordCfg()
      ..type = CoordType.rect
      ..mix(cfg.coord)
      ..plot = plot;
    final type = coordCfg.type;
    final coord = Coord.creators[type](coordCfg);
    cfg.coordObj = coord;
  }

  void _initLayout() {
    var padding = cfg.storedPadding;
    if (padding == null) {
      padding = cfg.margin ?? cfg.padding;
    }

    final top = padding.top ?? 0.0;
    final right = padding.right ?? 0.0;
    final bottom = padding.bottom ?? 0.0;
    final left = padding.left ?? 0.0;

    final width = cfg.width;
    final height = cfg.height;

    final start = Offset(left, top);
    final end = Offset(width - right, height - bottom);
    cfg.plot = Rect.fromPoints(start, end);
  }

  void _initRenderer() {
    final renderer = Renderer();
    cfg.renderer = renderer;
    // TODO: notify plugins
  }

  void _initLayers() {
    final renderer = cfg.renderer;
    cfg.backPlot = renderer.addGroup();
    cfg.middlePlot = renderer.addGroup(Cfg()..zIndex = 10);
    cfg.frontPlot = renderer.addGroup(Cfg()..zIndex = 20);
  }

  void _initEvents() {
    onInner(eventAfterDataChange, (_) {
      _initFilteredData();

      _changeGeomsData();
      _adjustScale();
    });

    onInner(eventAfterSizeChange, (_) {
      _initLayout();

      final coord = cfg.coordObj;
      if (coord != null) {
        coord.reset(cfg.plot);
      }
    });
  }

  void _initScaleController() {
    final scaleController = ScaleController(ScaleControllerCfg()
      ..chart = this
    );
    cfg.colDefs = scaleController.cfg.defs;
    cfg.scales = scaleController.cfg.scales;
    cfg.scaleController = scaleController;
  }

  void _clearScaleController() {
    cfg.scaleController.clear();
  }

  void _init() {
    _initRenderer();
    _initLayout();
    _initLayers();
    _initEvents();
    _initScaleController();
    cfg.axisController = AxisController(AxisControllerCfg()
      ..frontPlot = cfg.frontPlot.addGroup()
      ..backPlot = cfg.backPlot.addGroup()
      ..chart = this
    );
    // TODO: notify plugins
  }

  void init() {
    _initFilteredData();
    _initCoord();

    // TODO: notify plugins
    _initGeoms();
    _syncYScale();
    _adjustScale();
    emitInner(eventAfterInit);
  }

  ChartController source(List<Map<String, Object>> data, [Map<String, ScaleCfg> colDefs]) {
    cfg.data = data;
    if (colDefs != null) {
      scale(colDefs);
    }
    return this;
  }

  ChartController scale(Map<String, ScaleCfg> defs) {
    final scaleController = cfg.scaleController;
    scaleController.setFieldDef(defs);

    return this;
  }

  ChartController axis(String field, AxisCfg axisCfg) {
    final axisController = cfg.axisController;
    if (field == null) {
      axisController.cfg.axisCfg = null;
    } else {
      axisController.cfg.axisCfg ??= {};
      axisController.cfg.axisCfg[field] = axisCfg;
    }
    return this;
  }

  ChartController coord(CoordCfg coordCfg) {
    coordCfg ??= CoordCfg();
    coordCfg.type ??= CoordType.rect;
    cfg.coord = coordCfg;
    return this;
  }

  void filter(
    String field,
    bool Function(Object, Map<String, Object>) condition
  ) {
    final filters = cfg.filters
      ?? <String, bool Function(Object, Map<String, Object>)>{};
    
    filters[field] = condition;
    cfg.filters = filters;

    if (cfg.renderered) {
      emitInner(eventAfterDataChange, cfg.data);
    }
  }

  ChartController render() {
    final rendered = cfg.renderered;
    final renderer = cfg.renderer;
    final geoms = cfg.geoms;

    if (!rendered) {
      init();
      cfg.renderered = true;
    }
    emitInner(eventBeforeRender);

    // TODO: notify plugins
    _renderAxis();

    final middlePlot = cfg.middlePlot;
    if (cfg.limitInPlot && middlePlot.attrs.clip == null) {
      final coord = cfg.coordObj;
      final clip = getClip(coord);
      clip.cfg.renderer = middlePlot.cfg.renderer;
      middlePlot.attr(Attrs(clip: clip));
    }

    for (var geom in geoms) {
      geom.draw();
    }

    // TODO: notify plugins
    renderer.sort();
    cfg.frontPlot.sort();
    // TODO: notify plugins
    renderer.repaint();

    emitInner(eventAfterRender);
    return this;
  }

  ChartController clear() {
    // TODO: notify plugins
    _clearInner();
    _removeGeoms();
    _clearScaleController();
    // TODO: legendItems to null
    cfg.filters = null;
    cfg.isUpdate = false;
    cfg.storedPadding = null;
    cfg.renderered = false;
    final renderer = cfg.renderer;
    renderer.repaint();
    return this;
  }

  void repaint() {
    final rendered = cfg.renderered;
    if (!rendered) {
      return;
    }
    cfg.isUpdate = true;
    // TODO: legendItems to null
    // TODO: notify plugins
    _clearInner();
    render();
  }

  void changeData(List<Map<String, Object>> data) {
    emitInner(eventBeforeDataChange, data);
    cfg.data = data;
    // TODO: notify plugins
    emitInner(eventAfterDataChange, data);
    cfg.storedPadding = null;
    repaint();
  }

  // ChartController changeSize(double width, double height) {
  //   if (width != null) {
  //     cfg.width = width;
  //   } else {
  //     width = cfg.width;
  //   }

  //   if (height != null) {
  //     cfg.height = height;
  //   } else {
  //     height = cfg.height;
  //   }

  //   final renderer = cfg.renderer;
  //   renderer.changeSize(width, height);
  //   emitInner(eventAfterSizeChange, {'width': width, 'height': height});
  //   repaint();
  //   return this;
  // }

  void destroy() {
    clear();
    final renderer = cfg.renderer;
    renderer.destroy();
    // TODO: notify plugins

    // TODO: destroy interactions

    cfg = null;
  }

  Offset getPosition(Map<String, Object> record) {
    final coord = cfg.coordObj;
    final xScale = this.xScale;
    final yScale = this.yScales.first;
    final xField = xScale.cfg.field;
    final x = xScale.scale(record[xField]);
    final yField = yScale.cfg.field;
    final y = yScale.scale(record[yField]);
    return coord.convertPoint(Offset(x, y));
  }

  Map<String, Object> getRecord(Offset point) {
    final coord = cfg.coordObj;
    final xScale = this.xScale;
    final yScale = this.yScales.first;
    final invertPoint = coord.invertPoint(point);
    final record = <String, Object>{};
    record[xScale.cfg.field] = xScale.invert(invertPoint.dx);
    record[yScale.cfg.field] = yScale.invert(invertPoint.dy);
    return record;
  }

  List<Map<String, Object>> getSnapRecords(Offset point) {
    final geom = cfg.geoms.first;
    var data = <Map<String, Object>>[];
    if (geom != null) {
      data = geom.getSnapRecords(point);
    }
    return data;
  }

  Scale createScale(String field) {
    final data = getScaleData(field);
    final scaleController = cfg.scaleController;
    return scaleController.createScale(field, data);
  }

  Geom addGeom(GeomCfg geomCfg) {
    final type = geomCfg.type;
    final geom = Geom.creators[type](geomCfg);

    final rendered = cfg.renderered;
    final geoms = cfg.geoms;
    geoms.add(geom);
    if (rendered) {
      _initGeom(geom);
    }

    return geom;
  }

  Scale get xScale {
    final geoms = cfg.geoms;
    final xScale = geoms[0].xScale;
    return xScale;
  }

  List<Scale> get yScales {
    final geoms = cfg.geoms;
    final rst = <Scale>[];

    for (var geom in geoms) {
      final yScale = geom.yScale;
      if (!rst.contains(yScale)) {
        rst.add(yScale);
      }
    }
    return rst;
  }

  // TODO: get LegendItems

  // TODO: registerPlugins

  void _renderAxis() {
    final axisController = cfg.axisController;
    final xScale = this.xScale;
    final yScales = this.yScales;
    final coord = cfg.coordObj;
    // TODO: notify plugins
    axisController.createAxis(coord, xScale, yScales);
  }

  bool _isAutoPadding() {
    if (cfg.storedPadding != null) {
      return false;
    }
    final padding = cfg.padding;
    return padding.left == null ||
      padding.top == null ||
      padding.right == null ||
      padding.bottom == null;
  }

  void _updateLayout(EdgeInsets padding) {
    final width = cfg.width;
    final height = cfg.height;
    final start = Offset(
      padding.left,
      padding.top,
    );
    final end = Offset(
      width - padding.right,
      height - padding.bottom,
    );

    cfg.plot = Rect.fromPoints(start, end);
    cfg.coordObj.reset(cfg.plot);
  }

  // TODO: Chart.plugins
}
