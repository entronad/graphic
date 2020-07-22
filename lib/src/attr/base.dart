import 'package:meta/meta.dart';
import 'package:graphic/src/common/typed_map.dart';
import 'package:graphic/src/common/base_classes.dart';

enum AttrType {
  color,
  position,
  shape,
  size,
}

abstract class AttrState<A> with TypedMap {
  A Function(List<double>) get callback =>
    this['callback'] as A Function(List<double>);
  set callback(A Function(List<double>) value) =>
    this['callback'] = value;
}

abstract class AttrComponent<S extends AttrState, A>
  extends Component<S>
{
  AttrComponent([TypedMap props]) : super(props);

  A map(List<double> scaledValues) =>
    state.callback == null
      ? defaultMap(scaledValues)
      : state.callback(scaledValues);

  @protected
  A defaultMap(List<double> scaledValues);
}
