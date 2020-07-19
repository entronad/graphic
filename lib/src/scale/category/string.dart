import 'package:graphic/src/common/base_classes.dart';

import '../base.dart';
import 'base.dart';

class CatScale extends Props<ScaleType> {
  CatScale({
    List<String> values,
    bool isRounding,

    String Function(String) formatter,
    List<double> scaledRange,
    String alias,
    int tickCount,
    List<String> ticks,
  }) {
    this['values'] = values;
    this['isRounding'] = isRounding;
    this['formatter'] = formatter;
    this['scaledRange'] = scaledRange;
    this['alias'] = alias;
    this['tickCount'] = tickCount;
    this['ticks'] = ticks;
  }

  @override
  ScaleType get type => ScaleType.cat;
}

class StringCategoryScaleState extends CategoryScaleState<String> {}

class StringCategoryScaleComponent
  extends CategoryScaleComponent<StringCategoryScaleState, String>
{
  StringCategoryScaleComponent([CatScale props]) : super(props);

  @override
  StringCategoryScaleState get originalState => StringCategoryScaleState();
}
