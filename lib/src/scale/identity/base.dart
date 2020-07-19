import 'package:graphic/src/common/base_classes.dart';

import '../base.dart';

abstract class IdentityScaleState<V> extends ScaleState<V> {
  V get value => this['value'] as V;
  set value(V value) => this['value'] = value;
}

abstract class IdentityScaleComponent<S extends IdentityScaleState<V>, V>
  extends ScaleComponent<S, V>
{
  IdentityScaleComponent([Props<ScaleType> props]) : super(props);

  @override
  List<V> getAutoTicks() => [state.value];

  @override
  double scale(V value) =>
    value == null ? null : state.scaledRange.first;

  @override
  V invert(double scaled) => state.value;
}
