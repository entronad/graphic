import 'package:graphic/src/common/base_classes.dart';

import '../base.dart';
import 'base.dart';

class SizeAttr extends Props<AttrType> {
  SizeAttr({
    String field,

    List<double> values,
    List<double> stops,
    double Function(List<double>) callback,
  })
    : this.field = field
  {
    this['values'] = values;
    this['stops'] = stops;
    this['callback'] = callback;
  }

  @override
  AttrType get type => AttrType.size;

  final String field;
}

class SizeSingleLinearAttrState extends SingleLinearAttrState<double> {}

class SizeSingleLinearAttrComponent
  extends SingleLinearAttrComponent<SizeSingleLinearAttrState, double>
{
  SizeSingleLinearAttrComponent([SizeAttr props]) : super(props);

   @override
  SizeSingleLinearAttrState get originalState => SizeSingleLinearAttrState();

  @override
  double lerp(double a, double b, double t) =>
    (b - a) * t + a;
}
