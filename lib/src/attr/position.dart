import 'dart:ui';

import 'package:meta/meta.dart';

import 'base.dart';

class PositionAttr extends Attr {
  PositionAttr({
    @required String field,

    List<Offset> Function(List<double>) mapper,
  }) : super(field) {
    this['mapper'] = mapper;
  }

  @override
  AttrType get type => AttrType.position;
}

class PositionAttrState extends AttrState<List<Offset>> {}

class PositionAttrComponent
  extends AttrComponent<PositionAttrState, List<Offset>>
{
  PositionAttrComponent([PositionAttr props]) : super(props);

  @override
  PositionAttrState get originalState => PositionAttrState();

  // Only map to abstract position
  @override
  List<Offset> defaultMapper(List<double> scaledValues) {
    if (scaledValues == null || scaledValues.isEmpty) {
      return null;
    }
    assert(scaledValues.length == 2);

    return [Offset(
      scaledValues[0],
      scaledValues[1],
    )];
  }
}
