import 'dart:ui';

import 'package:flutter/painting.dart' hide Axis;
import 'package:graphic/src/common/typed_map.dart';
import 'package:graphic/src/common/styles.dart';
import 'package:graphic/src/axis/base.dart';

class Theme with TypedMap {
  Theme({
    List<Color> colors,
    Axis horizontalAxis,
    Axis verticalAxis,
    Axis radialAxis,
    Axis circularAxis,
  }) {
    this['colors'] = colors;
    this['horizontalAxis'] = horizontalAxis;
    this['verticalAxis'] = verticalAxis;
    this['radialAxis'] = radialAxis;
    this['circularAxis'] = circularAxis;
  }

  List<Color> get colors => this['colors'] as List<Color>;
  set colors(List<Color> value) => this['colors'] = value;

  Axis get horizontalAxis => this['horizontalAxis'] as Axis;
  set horizontalAxis(Axis value) => this['horizontalAxis'] = value;

  Axis get verticalAxis => this['verticalAxis'] as Axis;
  set verticalAxis(Axis value) => this['verticalAxis'] = value;

  Axis get radialAxis => this['radialAxis'] as Axis;
  set radialAxis(Axis value) => this['radialAxis'] = value;

  Axis get circularAxis => this['circularAxis'] as Axis;
  set circularAxis(Axis value) => this['circularAxis'] = value;
}

const lineColor = Color(0xffe8e8e8);
const textColor = Color(0xff808080);

final defaultTheme = Theme(
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
  horizontalAxis: Axis(
    position: 0,
    line: AxisLine(style: LineStyle(color: lineColor)),
    label: AxisLabel(offset: Offset(0, 7.5), style: TextStyle(fontSize: 10, color: textColor)),
  ),
  verticalAxis: Axis(
    position: 0,
    label: AxisLabel(offset: Offset(7.5, 0), style: TextStyle(fontSize: 10, color: textColor)),
    grid: AxisGrid(style: LineStyle(color: lineColor)),
  ),
  radialAxis: Axis(
    position: 0,
    line: AxisLine(style: LineStyle(color: lineColor)),
    label: AxisLabel(style: TextStyle(fontSize: 10, color: textColor)),
    grid: AxisGrid(style: LineStyle(color: lineColor)),
  ),
  circularAxis: Axis(
    position: 1,
    line: AxisLine(style: LineStyle(color: lineColor)),
    label: AxisLabel(offset: Offset(0, 7.5), style: TextStyle(fontSize: 10, color: textColor)),
  ),
);
