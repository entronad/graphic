import 'dart:math' show min;

import 'package:graphic/src/scale/base.dart' show Scale;

import 'attr_cfg.dart' show AttrType, AttrCfg, AttrCallback;
import 'color_attr.dart' show ColorAttr;
import 'position_attr.dart' show PositionAttr;
import 'shape_attr.dart' show ShapeAttr;
import 'size_attr.dart' show SizeAttr;

Object _toScaleString<F>(Scale<F> scale, F value) {
  if (value is String) {
    return value;
  }
  return scale.invert(scale.scale(value));
}

abstract class Attr<V> {
  static final Map<AttrType, Attr Function(AttrCfg)> creators = {
    AttrType.color: (AttrCfg cfg) => ColorAttr(cfg),
    AttrType.position: (AttrCfg cfg) => PositionAttr(cfg),
    AttrType.shape: (AttrCfg cfg) => ShapeAttr(cfg),
    AttrType.size: (AttrCfg cfg) => SizeAttr(cfg),
  };

  Attr(AttrCfg<V> cfg) {
    AttrCallback mixedCallback;

    if (cfg.callback != null) {
      final userCallback = cfg.callback;
      mixedCallback = (List<Object> params) {
        V ret = userCallback(params);
        if (ret == null) {
          ret = _defaultCallback(params);
        }
        return ret;
      };
    }

    this.cfg = defaultCfg.mix(cfg);
    if (mixedCallback != null) {
      this.cfg.callback = mixedCallback;
    }
  }

  AttrCfg<V> cfg;

  AttrCfg<V> get defaultCfg => AttrCfg<V>(
    values: [],
  )
    ..scales = [];
  
  V _getAttrValue<F>(Scale<F> scale, F value) {
    final values = cfg.values;
    if (scale.cfg.isCategory && !cfg.linear) {
      final index = scale.translate(value);
      return values[index % values.length];
    }
    final percent = scale.scale(value);
    return getLinearValue(percent);
  }

  V getLinearValue(double percent) {
    // user must guarentee a right stops
    final values = cfg.values;
    var stops = cfg.stops;
    if (stops == null) {
      stops = <double>[];
      for (var i = 0; i < values.length; i++) {
        stops.add(i * (1 / (values.length - 1)));
      }
    }
    for (var s = 0; s < stops.length - 1; s++) {
      final leftStop = stops[s], rightStop = stops[s + 1];
      final leftColor = values[s], rightColor = values[s + 1];
      if (percent <= leftStop) {
        return leftColor;
      } else if (percent < rightStop) {
        final sectionT = (percent - leftStop) / (rightStop - leftStop);
        return lerp(leftColor, rightColor, sectionT);
      }
    }
    return values.last;
  }

  V lerp(V a, V b, double t);

  V _defaultCallback<F>(List<F> params) {
    final scale = cfg.scales[0];
    final rstValue = this._getAttrValue(scale, params[0]);
    return rstValue;
  }

  List<String> getNames() {
    final scales = cfg.scales ?? [];
    final names = cfg.names ?? [];
    final length = min(scales.length, names.length);
    final rst = <String>[];
    for (var i = 0; i < length; i++) {
      rst.add(names[i]);
    }
    return rst;
  }

  List<String> getFields() {
    final scales = cfg.scales;
    final rst = [];
    scales?.forEach((scale) {
      rst.add(scale.cfg.field);
    });
    return rst;
  }

  Scale getScale(String name) {
    final scales = cfg.scales;
    final names = cfg.names;
    final index = names.indexOf(name);
    return scales[index];
  }

  List mapping(List params) {
    final scales = cfg.scales;
    final callback = cfg.callback;
    if (callback != null) {
      final originParams = [];
      for (var i = 0, len = params.length; i < len; i++) {
        originParams.add(_toOriginParam(params[i], scales[i]));
      }
      final values = callback(originParams);
      return values is List ? values : [values];
    } else {
      return List<V>.from(params);
    }
  }

  Object _toOriginParam<F>(Object param, Scale<F> scale) {
    if (!scale.cfg.isLinear) {
      var rst;
      if (param is List<F>) {
        rst = [];
        for (var i = 0, len = param.length; i < len; i++) {
          rst.add(_toScaleString(scale, param[i]));
        }
      } else {
        rst = _toScaleString(scale, param);
      }
      return rst;
    }
    return param;
  }
}
