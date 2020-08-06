import 'package:meta/meta.dart';
import 'package:graphic/src/common/typed_map.dart';
import 'package:graphic/src/common/base_classes.dart';
import 'package:graphic/src/common/field.dart';

enum AttrType {
  color,
  position,
  shape,
  size,
}

abstract class Attr extends Props<AttrType> {
  Attr(String field) {
    this['fields'] = parseField(field);
  }
}

abstract class AttrState<A> with TypedMap {
  A Function(List<double>) get mapper =>
    this['mapper'] as A Function(List<double>);
  set mapper(A Function(List<double>) value) =>
    this['mapper'] = value;
  
  List<String> get fields => this['fields'] as List<String>;
  set fields(List<String> value) => this['fields'] = value;
}

abstract class AttrComponent<S extends AttrState, A>
  extends Component<S>
{
  AttrComponent([TypedMap props]) : super(props);

  A map(List<double> scaledValues) =>
    state.mapper == null
      ? defaultMapper(scaledValues)
      : state.mapper(scaledValues);

  @protected
  A defaultMapper(List<double> scaledValues);
}
