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

