import 'dart:ui';

import 'base.dart';

class ColorAttr extends Attr<Color> {
  ColorAttr(AttrCfg<Color> cfg) : super(cfg);

  @override
  AttrCfg<Color> get defaultCfg => super.defaultCfg
    ..names = ['color']
    ..type = AttrType.color;

  @override
  Color lerp(Color a, Color b, double t) =>
    Color.lerp(a, b, t);
}
