import 'dart:ui';

import 'package:graphic/src/common/base_classes.dart';

import '../base.dart';
import 'base.dart';

class ColorAttr extends Props<AttrType> {
  ColorAttr({
    String field,

    List<Color> values,
    List<double> stops,
    Color Function(List<double>) callback,
  })
    : this.field = field
  {
    this['values'] = values;
    this['stops'] = stops;
    this['callback'] = callback;
  }

  @override
  AttrType get type => AttrType.color;

  final String field;
}

class ColorSingleLinearAttrState extends SingleLinearAttrState<Color> {}

class ColorSingleLinearAttrComponent
  extends SingleLinearAttrComponent<ColorSingleLinearAttrState, Color>
{
  ColorSingleLinearAttrComponent([ColorAttr props]) : super(props);

   @override
  ColorSingleLinearAttrState get originalState => ColorSingleLinearAttrState();

  @override
  Color lerp(Color a, Color b, double t) =>
    Color.lerp(a, b, t);
}
