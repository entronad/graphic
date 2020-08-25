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

abstract class Attr<A> extends Props<AttrType> {
  Attr(String field) {
    this['fields'] = parseField(field);
  }
}

abstract class AttrState<A> with TypedMap {
  List<A> get values => this['values'] as List<A>;
  set values(List<A> value) => this['values'] = value;

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

  // With fields: attr.map(scaledValues)
  // Without fields: attr.map()
  A map([List<double> scaledValues]) {
    if (state.fields == null) {
      return state.values.first;
    }
    return state.mapper == null
      ? defaultMapper(scaledValues)
      : state.mapper(scaledValues);
  }

  @protected
  A defaultMapper(List<double> scaledValues);
}
