import 'dart:ui';

import 'package:flutter/painting.dart' hide Axis;
import 'package:graphic/src/chart/theme.dart';
import 'package:graphic/src/common/styles.dart';
import 'package:graphic/src/axis/base.dart';

const lineColor = Color(0xffe8e8e8);
const textColor = Color(0xff808080);

abstract class Defaults {
  static Theme get theme => Theme(
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
  );

  static Axis get horizontalAxis => Axis(
    position: 0,
    line: AxisLine(style: LineStyle(color: lineColor)),
    label: AxisLabel(offset: Offset(0, 7.5), style: TextStyle(fontSize: 10, color: textColor)),
  );
  static Axis get verticalAxis => Axis(
    position: 0,
    label: AxisLabel(offset: Offset(-7.5, 0), style: TextStyle(fontSize: 10, color: textColor)),
    grid: AxisGrid(style: LineStyle(color: lineColor)),
  );
  static Axis get radialAxis => Axis(
    position: 0,
    line: AxisLine(style: LineStyle(color: lineColor)),
    label: AxisLabel(style: TextStyle(fontSize: 10, color: textColor)),
    grid: AxisGrid(style: LineStyle(color: lineColor)),
  );
  static Axis get circularAxis => Axis(
    position: 1,
    line: AxisLine(style: LineStyle(color: lineColor)),
    label: AxisLabel(style: TextStyle(fontSize: 10, color: textColor)),
    grid: AxisGrid(style: LineStyle(color: lineColor)),
  );
}
