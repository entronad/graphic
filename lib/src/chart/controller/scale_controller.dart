import 'dart:math';

import 'package:graphic/src/base.dart';
import 'package:graphic/src/coord/base.dart';
import 'package:graphic/src/util/typed_map_mixin.dart';
import 'package:graphic/src/scale/base.dart';
import 'package:graphic/src/util/collection.dart' as collection;
import 'package:graphic/src/global.dart';

import '../chart_controller.dart';

bool isFullCircle(Coord coord) {
  if (!coord.cfg.isPolar) {
    return false;
  }
  final startAngle = coord.cfg.startAngle;
  final endAngle = coord.cfg.endAngle;
  if (
    startAngle != null &&
    endAngle != null &&
    (endAngle - startAngle) < pi * 2
  ) {
    return false;
  }
  return true;
}

class ScaleControllerCfg with TypedMapMixin {
  Map<String, ScaleCfg> get defs => this['defs'] as Map<String, ScaleCfg>;
  set defs(Map<String, ScaleCfg> value) => this['defs'] = value;

  Map<String, Scale> get scales => this['scales'] as Map<String, Scale>;
  set scales(Map<String, Scale> value) => this['scales'] = value;

  ChartController get chart => this['chart'] as ChartController;
  set chart(ChartController value) => this['chart'] = value;

  List<Map<String, Object>> get data => this['data'] as List<Map<String, Object>>;
  set data(List<Map<String, Object>> value) => this['data'] = value;
}

class ScaleController extends Base<ScaleControllerCfg> {
  ScaleController(ScaleControllerCfg cfg) : super(cfg);

  @override
  ScaleControllerCfg get defaultCfg => ScaleControllerCfg()
    ..defs = {}
    ..scales = {};
  
  void setFieldDef(Map<String, ScaleCfg> defs) {
    cfg.defs.addAll(defs);

    updateScales();
  }

  ScaleCfg _getDef(String field) {
    final v = cfg.defs[field];
    ScaleCfg def;
    if (v != null) {
      def = ScaleCfg().mix(v);
    }
    return def;
  }

  ScaleType _getDefaultType(
    String field,
    List<Map<String, Object>> data,
    ScaleCfg def,
  ) {
    if (def?.type != null) {
      return def.type;
    }
    var type = ScaleType.linear;
    final value = collection.firstValue(data, field);
    var valueItem;
    if (value is List) {
      valueItem = value.first;
    }
    if (value is String || valueItem is String) {
      type = ScaleType.cat;
    }
    return type;
  }

  ScaleCfg _getScaleDef(
    ScaleType type,
    String field,
    List<Map<String, Object>> data,
    ScaleCfg def,
  ) {
    List values;
    if (def?.values != null) {
      values = def.values;
    } else {
      values = collection.values(data, field);
    }
    final scaleCfg = ScaleCfg()
      ..field = field
      ..values = values;

    if (type != ScaleType.cat && type != ScaleType.timeCat) {
      final valuesNum = values as List<double>;
      if (def == null || !(def.min != null && def.max != null)) {
        final minValue = valuesNum.reduce(min);
        final maxValue = valuesNum.reduce(max);
        scaleCfg.min = minValue;
        scaleCfg.max = maxValue;
        scaleCfg.nice = true;
      }
    } else {
      scaleCfg.isRounding = false;
    }

    return scaleCfg;
  }

  ScaleCfg _adjustRange(ScaleType type, ScaleCfg scaleCfg) {
    final range = scaleCfg.range;
    final values = scaleCfg.values;
    if (type == ScaleType.linear || range != null || values != null) {
      return scaleCfg;
    }
    final count = values.length;
    if (count == 1) {
      scaleCfg.range = [0.5, 1];
    } else {
      final chart = cfg.chart;
      final coord = chart.cfg.coordObj;
      final widthRatio = Global.theme.widthRatio['multiplePie'];
      var offset = 0.0;
      if (isFullCircle(coord)) {
        if (!coord.cfg.transposed) {
          scaleCfg.range = [0, 1 - 1 / count];
        } else {
          offset = 1 / count * widthRatio;
          scaleCfg.range = [offset / 2, 1 - offset / 2];
        }
      } else {
        offset = 1 / count * 1 / 2;
        scaleCfg.range = [offset, 1 - offset];
      }
    }
    return scaleCfg;
  }

  ScaleCfg _getScaleCfg(String field, List<Map<String, Object>> data) {
    final def = _getDef(field);
    if (data == null || data.isEmpty) {
      if (def?.type != null) {
        def.field = field;
        return def;
      }
      return ScaleCfg(
        type: ScaleType.identity,
        value: field,
        values: [field],
      )..field = field;
    }
    final firstObj = data.first;
    var firstV = firstObj[field];
    if (firstV == null) {
      firstV = collection.firstValue(data, field);
    }

    if (firstV == null && def == null) {
      return ScaleCfg(
        type: ScaleType.identity,
        value: field,
        values: [field],
      )..field = field;
    }
    final type = _getDefaultType(field, data, def);
    var scaleCfg = _getScaleDef(type, field, data, def);
    if (def != null) {
      scaleCfg = scaleCfg.mix(def);
    }
    scaleCfg = _adjustRange(type, scaleCfg);
    return scaleCfg;
  }

  Scale createScale(String field, List<Map<String, Object>> data) {
    final scales = cfg.scales;
    final scaleCfg = _getScaleCfg(field, data);
    final type = scaleCfg.type;
    final scale = scales[field];
    if (scale?.cfg?.type == type) {
      scale.change(scaleCfg);
      return scale;
    }
    final newScale = Scale.creators[type](scaleCfg);
    scales[field] = newScale;
    return newScale;
  }

  void _updateScale(Scale scale) {
    final field = scale.cfg.field;
    final data = cfg.chart.getScaleData(field);
    final scaleCfg = _getScaleCfg(field, data);
    scale.change(scaleCfg);
  }

  void updateScales() {
    final scales = cfg.scales;
    for (var scale in scales.values) {
      _updateScale(scale);
    }
  }

  void adjustStartZero(Scale scale) {
    final defs = cfg.defs;
    final field = scale.cfg.field;
    final minValue = scale.cfg.min;
    final maxValue = scale.cfg.max;
    if (defs[field]?.min != null) {
      return;
    }
    if (minValue > 0) {
      scale.change(ScaleCfg(
        min: 0,
      ));
    } else if (maxValue < 0) {
      scale.change(ScaleCfg(
        max: 0,
      ));
    }
  }

  void clear() {
    cfg.defs.clear();
    cfg.scales.clear();
    cfg.data = null;
  }
}
