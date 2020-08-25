import 'dart:ui';

import 'base.dart';

class PositionAttr extends Attr<List<Offset>> {
  PositionAttr({
    String field,

    List<List<Offset>> values,
    List<Offset> Function(List<double>) mapper,

    List<String> xFields,
    List<String> yFields,
  }) : super(field) {
    assert(
      this['mapper'] == null
        || (this['xFields'] != null && this['yFields'] != null),
      'xFields and yFields must be specified if mapper is custom',
    );

    this['values'] = values;
    this['mapper'] = mapper;
  }

  @override
  AttrType get type => AttrType.position;
}

class PositionAttrState extends AttrState<List<Offset>> {
  List<String> get xFields => this['xFields'] as List<String>;
  set xFields(List<String> value) => this['xFields'] = value;

  List<String> get yFields => this['yFields'] as List<String>;
  set yFields(List<String> value) => this['yFields'] = value;
}

class PositionAttrComponent
  extends AttrComponent<PositionAttrState, List<Offset>>
{
  PositionAttrComponent([PositionAttr props]) : super(props);

  @override
  PositionAttrState get originalState => PositionAttrState();

  // Only map to abstract position
  @override
  List<Offset> defaultMapper(List<double> scaledValues) =>
    throw UnimplementedError(
      'Position default mapper must define in geom.',
    );
}
