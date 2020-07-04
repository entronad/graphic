import 'package:meta/meta.dart';

import 'typed_map.dart';

abstract class Component<P extends TypedMap> {
  Component([TypedMap cfg]) {
    props = originalProps;
    initDefaultProps();
    props.mix(cfg);
  }

  P props;

  @protected
  P get originalProps;

  @protected
  void initDefaultProps() {}
}
