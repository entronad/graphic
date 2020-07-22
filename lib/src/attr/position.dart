import 'dart:ui';

import 'package:graphic/src/common/base_classes.dart';
import 'package:graphic/src/coord/base.dart';

import 'base.dart';

class PositionAttr extends Props<AttrType> {
  PositionAttr({
    String field,

    Offset Function(List<double>) callback,
  })
    : this.field = field
  {
    this['callback'] = callback;
  }

  @override
  AttrType get type => AttrType.position;

  final String field;
}

class PositionAttrState extends AttrState<Offset> {
  CoordComponent get coord => this['coord'] as CoordComponent;
  set coord(CoordComponent value) => this['coord'] = value;
}

class PositionAttrComponent
  extends AttrComponent<PositionAttrState, Offset>
{
  PositionAttrComponent([PositionAttr props]) : super(props);

  @override
  PositionAttrState get originalState => PositionAttrState();

  @override
  Offset defaultMap(List<double> scaledValues) {
    if (scaledValues == null || scaledValues.isEmpty) {
      return null;
    }
    assert(scaledValues.length == 2);

    return state.coord.convertPoint(Offset(
      scaledValues[0],
      scaledValues[1],
    ));
  }
}
