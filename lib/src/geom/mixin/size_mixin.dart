import 'dart:ui' show Offset;
import 'dart:math' show sqrt, pow;

import 'package:graphic/src/chart/const.dart' show eventAfterSizeChange;
import 'package:graphic/src/util/array.dart' show uniq;
import 'package:graphic/src/attr/attr_cfg.dart' show AttrType;

import '../adjust/adjust_cfg.dart' show AdjustType;
import '../base.dart' show Geom;

mixin SizeMixin on Geom {
  void initEvent() {
    final chart = cfg.chart;
    if (chart == null) {
      return;
    }
    chart.onInner(eventAfterSizeChange, (_) {
      cfg.width = null;
    });
  }

  double get defaultSize {
    var defaultSize = cfg.defaultSize;
    if (defaultSize == null) {
      final coord = cfg.coord;
      final xScale = this.xScale;
      final dataArray = cfg.dataArray;
      final values = uniq(xScale.cfg.values);
      final count = values.length;
      final range = xScale.cfg.range;
      var normalizeSize = 1 / count;
      var widthRatio = 1;

      // TODO: set normalizeSize and widthRatio accoring to Global theme

      normalizeSize *= widthRatio;
      if(hasAdjust(AdjustType.dodge)) {
        normalizeSize = normalizeSize / dataArray.length;
      }
      defaultSize = normalizeSize;
      cfg.defaultSize = defaultSize;
    }
    return defaultSize;
  }

  double getDimWidth(String dimName) {
    final coord = cfg.coord;
    final start = coord.convertPoint(Offset.zero);
    final end = coord.convertPoint(Offset(
      dimName == 'x' ? 1 : 0,
      dimName == 'x' ? 0 : 1,
    ));
    var width = 0.0;
    if (start != null && end != null) {
      width = sqrt(pow(end.dx - start.dx, 2) + pow(end.dy - start.dy, 2));
    }
    return width;
  }

  double _getWidth() {
    var width = cfg.width;
    if (width == null) {
      final coord = cfg.coord;
      if (coord != null && coord.cfg.isPolar && coord.cfg.transposed) {
        width = (coord.cfg.endAngle - coord.cfg.startAngle) * coord.cfg.circleRadius;
      } else {
        width = getDimWidth('x');
      }
      cfg.width = width;
    }
    return width;
  }

  double _toNormalizedSize(double size) {
    final width = _getWidth();
    return size / width;
  }

  double _toCoordSize(double normalizeSize) {
    final width = _getWidth();
    return width * normalizeSize;
  }

  double getNormalizedSize(Map<String, Object> obj) {
    var size = getAttrValue(AttrType.size, obj);
    if (size == null) {
      size = defaultSize;
    } else {
      size = _toNormalizedSize(size);
    }
    return size;
  }

  double getSize(Map<String, Object> obj) {
    var size = getAttrValue(AttrType.size, obj);
    if (size == null) {
      final normalizeSize = defaultSize;
      size = _toCoordSize(normalizeSize);
    }
    return size;
  }
}
