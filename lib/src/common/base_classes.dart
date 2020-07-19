import 'package:meta/meta.dart';

import 'typed_map.dart';

abstract class Props<T> with TypedMap {
  T get type;
}

abstract class Component<S extends TypedMap> {
  Component([TypedMap props]) {
    state = originalState;
    initDefaultState();
    state.mix(props);
  }

  S state;

  @protected
  S get originalState;

  @protected
  void initDefaultState() {}
}
