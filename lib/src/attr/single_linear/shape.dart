import 'package:graphic/src/geom/shape/base.dart';

import '../base.dart';
import 'base.dart';

class ShapeAttr extends SingleLinearAttr<Shape> {
  ShapeAttr({
    String field,

    List<Shape> values,
    List<double> stops,
    bool isTween,
    Shape Function(List<double>) mapper,
  }) : super(field) {
    this['values'] = values;
    this['stops'] = stops;
    this['isTween'] = isTween;
    this['mapper'] = mapper;
  }

  @override
  AttrType get type => AttrType.shape;
}

class ShapeSingleLinearAttrState extends SingleLinearAttrState<Shape> {}

class ShapeSingleLinearAttrComponent
  extends SingleLinearAttrComponent<ShapeSingleLinearAttrState, Shape>
{
  ShapeSingleLinearAttrComponent([ShapeAttr props]) : super(props);

   @override
  ShapeSingleLinearAttrState get originalState => ShapeSingleLinearAttrState();

  @override
  Shape lerp(Shape a, Shape b, double t) =>
    t < 0.5 ? a : b;
}
