import 'package:meta/meta.dart';

import 'typed_map.dart';

@immutable
abstract class Props<T> with TypedMap {
  T get type;
}

abstract class Component<S extends TypedMap> {
  Component([TypedMap props]) {
    state = originalState;
    initDefaultState();
    state.mix(props);

    onUpdate();
  }

  S state;

  @protected
  S get originalState;

  @protected
  void initDefaultState() {}

  void update(TypedMap props) {
    state.mix(props);
    onUpdate();
  }

  @protected
  void onUpdate() {}
}
