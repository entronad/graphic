import 'package:graphic/src/geom/shape/base.dart';

import '../base.dart';
import 'base.dart';

class ShapeAttr<S extends Shape> extends SingleLinearAttr<S> {
  ShapeAttr({
    String field,

    List<S> values,
    List<double> stops,
    bool isTween,
    S Function(List<double>) mapper,
  }) : super(field) {
    this['values'] = values;
    this['stops'] = stops;
    this['isTween'] = isTween;
    this['mapper'] = mapper;
  }

  @override
  AttrType get type => AttrType.shape;
}

class ShapeSingleLinearAttrState<S extends Shape> extends SingleLinearAttrState<S> {}

class ShapeSingleLinearAttrComponent<S extends Shape>
  extends SingleLinearAttrComponent<ShapeSingleLinearAttrState<S>, S>
{
  ShapeSingleLinearAttrComponent([ShapeAttr<S> props]) : super(props);

  @override
  ShapeSingleLinearAttrState<S> createState() => ShapeSingleLinearAttrState<S>();

  @override
  S lerp(S a, Shape b, double t) =>
    t < 0.5 ? a : b;
}
