import '../base.dart';
import 'base.dart';

class SizeAttr extends SingleLinearAttr<double> {
  SizeAttr({
    String field,

    List<double> values,
    List<double> stops,
    bool isTween,
    double Function(List<double>) mapper,
  }) : super(field) {
    this['values'] = values;
    this['stops'] = stops;
    this['isTween'] = isTween;
    this['mapper'] = mapper;
  }

  @override
  AttrType get type => AttrType.size;
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
