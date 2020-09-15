import 'package:graphic/src/coord/base.dart';

import '../base.dart';

abstract class LinearScale<V, D> extends Scale<V, D> {
  @override
  void complete(List<D> data, CoordComponent coord) {
    if (this['max'] == null || this['min'] == null) {
      final accessor = this['accessor'] as V Function(D);
      final values = data.map(accessor).toList();
      final maxValue = values.reduce(max);
      final minValue = values.reduce(min);
      if (compare(minValue, zero) > 0) {
        this['max'] = this['max'] ?? maxValue;
        this['min'] = this['min'] ?? zero;
      } else if (compare(maxValue, zero) < 0) {
        this['max'] = this['max'] ?? zero;
        this['min'] = this['min'] ?? minValue;
      } else {
        this['max'] = this['max'] ?? maxValue;
        this['min'] = this['min'] ?? minValue;
      }
    }
  }

  int compare(V a, V b);

  V get zero;

  V max(V a, V b) => compare(a, b) >= 0 ? a : b;

  V min(V a, V b) => compare(a, b) <= 0 ? a : b;
}

abstract class LinearScaleState<V, D> extends ScaleState<V, D> {
  bool get nice => this['nice'] as bool ?? false;
  set nice(bool value) => this['nice'] = value;

  V get min => this['min'] as V;
  set min(V value) => this['min'] = value;

  V get max => this['max'] as V;
  set max(V value) => this['max'] = value;

  V get tickInterval => this['tickInterval'] as V;
  set tickInterval(V value) => this['tickInterval'] = value;
}

abstract class LinearScaleComponent<S extends LinearScaleState<V, D>, V, D>
  extends ScaleComponent<S, V, D>
{
  LinearScaleComponent([LinearScale<V, D> props]) : super(props);

  // operations

  int compare(V a, V b);

  V add(V a, V b);

  V substarct(V a, V b);

  V multiply(V a, double k);

  double divide(V a, V b);

  V get zero;

  V get one;

  @override
  void assign() {
    if (state.ticks == null) {
      _assignTicks();
    } else {
      final firstTick = state.ticks.first;
      final lastTick = state.ticks.last;
      if (compare(state.min, firstTick) > 0) {
        state.min = firstTick;
      }
      if (compare(state.max, lastTick) < 0){
        state.max = lastTick;
      }
    }
  }

  void _assignTicks() {
    final calcTicks = getAutoTicks();

    if (state.nice) {
      state.ticks = calcTicks;
      state.min = calcTicks.first;
      state.max = calcTicks.last;
    } else {
      final ticks = <V>[];
      for (var tick in calcTicks) {
        if (compare(tick, state.min) >= 0 && compare(tick, state.max) <= 0) {
          ticks.add(tick);
        }
      }

      if (ticks.isEmpty) {
        ticks.add(state.min);
        ticks.add(state.max);
      }

      state.ticks = ticks;
    }
  }

  @override
  double scale(V value) {
    if (value == null) {
      return null;
    }

    final min = state.min;
    final max = state.max;
    final rangeMin = state.range.first;
    final rangeMax = state.range.last;

    if (max == min) {
      return rangeMin;
    }

    final percent = divide(substarct(value, min), substarct(max, min));
    return rangeMin + percent * (rangeMax - rangeMin);
  }

  @override
  V invert(double scaled) {
    final min = state.min;
    final max = state.max;
    final rangeMin = state.range.first;
    final rangeMax = state.range.last;

    final percent = (scaled - rangeMin) / (rangeMax - rangeMin);
    return add(min, multiply(substarct(max, min), percent));
  }

  @override
  double get origin => scale(zero);
}
