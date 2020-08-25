import 'dart:ui';

import 'package:graphic/src/common/typed_map.dart';

class Theme with TypedMap {
  Theme({
    List<Color> colors,
  }) {
    this['colors'] = colors;
  }

  List<Color> get colors => this['colors'] as List<Color>;
  set colors(List<Color> value) => this['colors'] = value;
}

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
);
