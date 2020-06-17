import 'dart:math';
import 'dart:ui';

import 'package:graphic/src/base.dart';
import 'package:graphic/src/coord/base.dart';
import 'package:graphic/src/util/typed_map_mixin.dart';
import 'package:graphic/src/scale/base.dart';
import 'package:graphic/src/global.dart';
import 'package:graphic/src/component/axis/base.dart';
import 'package:graphic/src/engine/container.dart';
import 'package:graphic/src/engine/shape/text.dart';
import 'package:graphic/src/engine/attrs.dart';
import 'package:graphic/src/engine/cfg.dart';

import '../chart_controller.dart';

List<Tick> formatTicks(List<Tick> ticks) {
  final tmp = [...ticks];
  if (tmp.isNotEmpty) {
    final first = tmp.first;
    final last = tmp.last;
    if (first.value != 0) {
      tmp.insert(0, Tick(null, null, 0));
    }
    if (last.value != 1) {
      tmp.add(Tick(null, null, 1));
    }
  }

  return tmp;
}

class AxisControllerCfg with TypedMapMixin {
  Map<String, AxisCfg> get axisCfg => this['axisCfg'] as Map<String, AxisCfg>;
  set axisCfg(Map<String, AxisCfg> value) => this['axisCfg'] = value;

  Container get frontPlot => this['frontPlot'] as Container;
  set frontPlot(Container value) => this['frontPlot'] = value;

  Container get backPlot => this['backPlot'] as Container;
  set backPlot(Container value) => this['backPlot'] = value;

  Map<String, AxisCfg> get axes => this['axes'] as Map<String, AxisCfg>;
  set axes(Map<String, AxisCfg> value) => this['axes'] = value;

  ChartController get chart => this['chart'] as ChartController;
  set chart(ChartController value) => this['chart'] = value;
}

class AxisController extends Base<AxisControllerCfg> {
  AxisController(AxisControllerCfg cfg) : super(cfg);

  @override
  AxisControllerCfg get defaultCfg => AxisControllerCfg()
    ..axisCfg = {}
    ..axes = {};

  bool _isHide(String field) {
    final axisCfg = cfg.axisCfg;
    return axisCfg == null || axisCfg[field] == null;
  }

  String _getLinePosition(
    Scale scale,
    String dimType,
    int index,
    bool transposed,
  ) {
    String position;
    final field = scale.cfg.field;
    final axisCfg = cfg.axisCfg;
    if (axisCfg[field]?.position != null) {
      position = axisCfg[field].position;
    } else if (dimType == 'x') {
      position = transposed ? 'left' : 'bottom';
    } else if (dimType == 'y') {
      position = (index != null && index != 0) ? 'right' : 'left';
      if (transposed) {
        position = 'bottom';
      }
    }

    return position;
  }

  Map<String, Object> _getLineCfg(
    Coord coord,
    String dimType,
    String position,
  ) {
    Offset start;
    Offset end;
    var factor = 1;
    if (dimType == 'x') {
      start = Offset(0, 0);
      end = Offset(1, 0);
    } else {
      if (position == 'right') {
        start = Offset(1, 0);
        end = Offset(1, 1);
      } else {
        start = Offset(0, 0);
        end = Offset(0, 1);
        factor = -1;
      }
    }
    if (coord.cfg.transposed) {
      factor *= -1;
    }

    return {
      'offsetFactor': factor,
      'start': coord.convertPoint(start),
      'end': coord.convertPoint(end),
    };
  }

  CoordCfg _getCircleCfg(Coord coord) => CoordCfg()
    ..startAngle = coord.cfg.startAngle
    ..endAngle = coord.cfg.endAngle
    ..center = coord.cfg.center
    ..radius = coord.cfg.radius;

  Map<String, Object> _getRadiusCfg(Coord coord) {
    final transposed = coord.cfg.transposed;
    Offset start;
    Offset end;
    if (transposed) {
      start = Offset(0, 0);
      end = Offset(1, 0);
    } else {
      start = Offset(0, 0);
      end = Offset(0, 1);
    }
    return {
      'offsetFactor': -1,
      'start': coord.convertPoint(start),
      'end': coord.convertPoint(end),
    };
  }

  AxisCfg _getAxisCfg(
    Coord coord,
    Scale scale,
    Scale verticalScale,
    String dimType,
    AxisCfg defaultCfg,
  ) {
    final axisCfg = cfg.axisCfg;
    final ticks = scale.getTicks();

    final rst = AxisCfg()
      ..ticks = ticks
      ..frontContainer = cfg.frontPlot
      ..backContainer = cfg.backPlot
      ..deepMix(defaultCfg)
      ..deepMix(axisCfg[scale.cfg.field]);

    final labels = <Text>[];
    final label = rst.label;
    final labelCallback = rst.labelCallback;
    final count = ticks.length;
    var maxWidth = 0.0;
    var maxHeight = 0.0;
    var labelCfg = label;

    for (var i = 0; i < ticks.length; i++) {
      final tick = ticks[i];
      if (labelCallback != null) {
        final executedLabel = labelCallback(tick.text, i, count);
        labelCfg = executedLabel != null
          ? TextCfg().mix(Global.defaultAxis.label).mix(executedLabel)
          : null;
      }
      if (labelCfg != null) {
        final textStyle = TextCfg();
        if (labelCfg.textAlign != null) {
          textStyle.textAlign = labelCfg.textAlign;
        }
        final axisLabel = Text(Cfg()
          ..attrs = Attrs(
            x: 0,
            y: 0,
            text: tick.text,
            // TODO: set fontFamily to chart.canvas fontFamily param
          ).mix(labelCfg).mix(textStyle)
          ..value = tick.value
          ..top = labelCfg.top
          // TODO: set chart.canvas context
        );
        labels.add(axisLabel);
        final width = axisLabel.bbox.width;
        final height = axisLabel.bbox.height;
        maxWidth = max(maxWidth, width);
        maxHeight = max(maxHeight, height);
      }
    }

    rst.labels = labels;
    rst.maxWidth = maxWidth;
    rst.maxHeight = maxHeight;
    return rst;
  }

  void _createAxis(
    Coord coord,
    Scale scale,
    Scale verticalScale,
    String dimType,
    int index
  ) {
    final coordType = coord.cfg.type;
    final transposed = coord.cfg.transposed;
    AxisType type;
    String key;
    AxisCfg defaultCfg;
    if (coordType == CoordType.rect) {
      final position = _getLinePosition(scale, dimType, index, transposed);
      defaultCfg = Global.theme.axis[position];
      defaultCfg.position = position;
      type = AxisType.line;
      key = position;
    } else {
      if (
        (dimType == 'x' && !transposed) ||
        (dimType == 'y' && transposed)
      ) {
        defaultCfg = Global.theme.axis['circle'];
        type = AxisType.circle;
        key = 'circle';
      } else {
        defaultCfg = Global.theme.axis['radius'];
        type = AxisType.line;
        key = 'radius';
      }
    }
    final axisCfg = _getAxisCfg(coord, scale, verticalScale, dimType, defaultCfg);
    axisCfg.type = type;
    axisCfg.dimType = dimType;
    axisCfg.verticalScale = verticalScale;
    axisCfg.index = index;
    cfg.axes[key] = axisCfg;
  }

  void createAxis(Coord coord, Scale xScale, List<Scale> yScales) {
    // TODO: implement
  }

  void clear() {
    cfg.axes = {};
    cfg.frontPlot.clear();
    cfg.backPlot.clear();
  }
}
