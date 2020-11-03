import 'dart:ui';

import 'base.dart';

class PositionAttr extends Attr<List<Offset>> {
  PositionAttr({
    String field,

    List<List<Offset>> values,
    List<Offset> Function(List<double>) mapper,

    Set<String> xFields,
    Set<String> yFields,
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
  Set<String> get xFields => this['xFields'] as Set<String>;
  set xFields(Set<String> value) => this['xFields'] = value;

  Set<String> get yFields => this['yFields'] as Set<String>;
  set yFields(Set<String> value) => this['yFields'] = value;
}

class PositionAttrComponent
  extends AttrComponent<PositionAttrState, List<Offset>>
{
  PositionAttrComponent([PositionAttr props]) : super(props);

  @override
  PositionAttrState createState() => PositionAttrState();

  // Only map to abstract position
  @override
  List<Offset> defaultMapper(List<double> scaledValues) =>
    throw UnimplementedError(
      'Position default mapper must define in geom.',
    );
}
