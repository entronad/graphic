import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:graphic/src/component/axis/base.dart';
import 'package:graphic/src/engine/attrs.dart';
import 'package:graphic/src/geom/base.dart';

import 'theme.dart';

const color1 = Color(0xffe8e8e8);
const color2 = Color(0xff808080);

abstract class Global {
  static final Theme _theme = Theme(
    widthRatio: {
      'column': 1 / 2,
      'rose': 0.999999,
      'multiplePie': 3 / 4,
    },
    paintCfg: PaintCfg(
      color: Color(0xff1890ff),
    ),
    appendPadding: EdgeInsets.all(15),
    colors: [
      Color(0xff1890ff),
      Color(0xff2fc25b),
      Color(0xfffacc14),
      Color(0xff223273),
      Color(0xff8543e0),
      Color(0xff13c2c2),
      Color(0xff3436c7),
      Color(0xfff04864),
    ],
    sizes: [4, 10],
    axis: {
      'common': defaultAxis,
      'bottom': AxisCfg().mix(defaultAxis).mix(AxisCfg(
        grid: null,   // TODO: null override
      )),
      'left': AxisCfg().mix(defaultAxis).mix(AxisCfg(
        line: null,
      )),
      'right': AxisCfg().mix(defaultAxis).mix(AxisCfg(
        line: null,
      )),
      'circle': AxisCfg().mix(defaultAxis).mix(AxisCfg(
        line: null,
      )),
      'radius': AxisCfg().mix(defaultAxis).mix(AxisCfg(
        labelOffset: 4,
      )),
    },
    shape: {
      GeomType.line: Attrs(
        strokeWidth: 2,
        strokeJoin: StrokeJoin.round,
        strokeCap: StrokeCap.round,
      ),
      GeomType.point: Attrs(
        strokeWidth: 0,
        r: 3,
      ),
    }
  );

  static Theme get theme => _theme;

  static void setTheme(Theme theme) {
    _theme.deepMix(theme);
  }

  static final AxisCfg defaultAxis = AxisCfg(
    label: TextCfg(
      textStyle: TextStyle(
        color: color2,
        fontSize: 10,
      ),
    ),
    line: PaintCfg(
      color: color1,
      strokeWidth: 1,
    ),
    grid: PaintCfg(
      color: color1,
      strokeWidth: 1,
    ),
    tickLine: null,   // TODO: null override
    labelOffset: 7.5,
  );
}
