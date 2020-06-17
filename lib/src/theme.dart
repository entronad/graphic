import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:graphic/src/util/typed_map_mixin.dart';
import 'package:graphic/src/engine/attrs.dart';
import 'package:graphic/src/component/axis/base.dart';
import 'package:graphic/src/geom/base.dart';

class Theme with TypedMapMixin {
  Theme({
    Map<String, double> widthRatio,
    PaintCfg paintCfg,
    TextCfg textCfg,
    EdgeInsets padding,
    EdgeInsets appendPadding,
    List<Color> colors,
    Map<String, List<String>> shapes,
    List<double> sizes,
    Map<String, AxisCfg> axis,
    Map<GeomType, Attrs> shape,
  }) {
    if (widthRatio != null) this['widthRatio'] = widthRatio;
    if (paintCfg != null) this['paintCfg'] = paintCfg;
    if (textCfg != null) this['textCfg'] = textCfg;
    if (padding != null) this['padding'] = padding;
    if (appendPadding != null) this['appendPadding'] = appendPadding;
    if (colors != null) this['colors'] = colors;
    if (shapes != null) this['shapes'] = shapes;
    if (sizes != null) this['sizes'] = sizes;
    if (axis != null) this['axis'] = axis;
    if (shape != null) this['shape'] = shape;
  }

  Map<String, double> get widthRatio => this['widthRatio'] as Map<String, double>;
  set widthRatio(Map<String, double> value) => this['widthRatio'] = value;

  PaintCfg get paintCfg => this['paintCfg'] as PaintCfg;
  set paintCfg(PaintCfg value) => this['paintCfg'] = value;

  TextCfg get textCfg => this['textCfg'] as TextCfg;
  set textCfg(TextCfg value) => this['textCfg'] = value;

  EdgeInsets get padding => this['padding'] as EdgeInsets;
  set padding(EdgeInsets value) => this['padding'] = value;

  EdgeInsets get appendPadding => this['appendPadding'] as EdgeInsets;
  set appendPadding(EdgeInsets value) => this['appendPadding'] = value;

  List<Color> get colors => this['colors'] as List<Color>;
  set colors(List<Color> value) => this['colors'] = value;

  Map<String, List<String>> get shapes => this['shapes'] as Map<String, List<String>>;
  set shapes(Map<String, List<String>> value) => this['shapes'] = value;

  List<double> get sizes => this['sizes'] as List<double>;
  set sizes(List<double> value) => this['sizes'] = value;

  Map<String, AxisCfg> get axis => this['axis'] as Map<String, AxisCfg>;
  set axis(Map<String, AxisCfg> value) => this['axis'] = value;

  Map<GeomType, Attrs> get shape => this['shape'] as Map<GeomType, Attrs>;
  set shape(Map<GeomType, Attrs> value) => this['shape'] = value;
}
