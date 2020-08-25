import '../base.dart';

abstract class IdentityScale<V, D> extends Scale<V, D> {}

abstract class IdentityScaleState<V, D> extends ScaleState<V, D> {
  V get value => this['value'] as V;
  set value(V value) => this['value'] = value;
}

abstract class IdentityScaleComponent<S extends IdentityScaleState<V, D>, V, D>
  extends ScaleComponent<S, V, D>
{
  IdentityScaleComponent([IdentityScale<V, D> props]) : super(props);

  @override
  void assign() {
    state.ticks = [state.value];
  }

  @override
  List<V> getAutoTicks() => [state.value];

  @override
  double scale(V value) =>
    value == state.value ? state.scaledRange.first : null;

  @override
  V invert(double scaled) => state.value;
}
