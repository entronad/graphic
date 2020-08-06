import '../base.dart';
import 'base.dart';

class CatScale<D> extends Scale {
  CatScale({
    List<String> values,
    bool isRounding,

    String Function(String) formatter,
    List<double> scaledRange,
    String alias,
    int tickCount,
    List<String> ticks,

    String Function(D) accessor,
  }) {
    assert(
      scaledRange == null || scaledRange.length == 2,
      'range can only has 2 items'
    );

    this['values'] = values;
    this['isRounding'] = isRounding;
    this['formatter'] = formatter;
    this['scaledRange'] = scaledRange;
    this['alias'] = alias;
    this['tickCount'] = tickCount;
    this['ticks'] = ticks;
    this['accessor'] = accessor;
  }

  @override
  ScaleType get type => ScaleType.cat;
}

class StringCategoryScaleState<D> extends CategoryScaleState<String, D> {}

class StringCategoryScaleComponent<D>
  extends CategoryScaleComponent<StringCategoryScaleState<D>, String, D>
{
  StringCategoryScaleComponent([CatScale props]) : super(props);

  @override
  StringCategoryScaleState<D> get originalState => StringCategoryScaleState<D>();
}
