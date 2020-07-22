import 'package:graphic/src/common/base_classes.dart';

import '../base.dart';

abstract class LinearScaleState<V> extends ScaleState<V> {
  bool get nice => this['nice'] as bool ?? false;
  set nice(bool value) => this['nice'] = value;

  V get min => this['min'] as V;
  set min(V value) => this['min'] = value;

  V get max => this['max'] as V;
  set max(V value) => this['max'] = value;

  V get tickInterval => this['tickInterval'] as V;
  set tickInterval(V value) => this['tickInterval'] = value;
}

abstract class LinearScaleComponent<S extends LinearScaleState<V>, V>
  extends ScaleComponent<S, V>
{
  LinearScaleComponent([Props<ScaleType> props]) : super(props);

  // operations

  int compare(V a, V b);

  V add(V a, V b);

  V substarct(V a, V b);

  V multiply(V a, double k);

  double divide(V a, V b);

  @override
  void assign() {
    if (state.ticks == null) {
      _assignTicks();
    } else {
      final firstTick = state.ticks.first;
      final lastTick = state.ticks.last;
      if (state.min == null || compare(state.min, firstTick) > 0) {
        state.min = firstTick;
      }
      if (state.max == null || compare(state.max, firstTick) < 0){
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
    final rangeMin = state.scaledRange.first;
    final rangeMax = state.scaledRange.last;

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
    final rangeMin = state.scaledRange.first;
    final rangeMax = state.scaledRange.last;

    final percent = (scaled - rangeMin) / (rangeMax - rangeMin);
    return add(min, multiply(substarct(max, min), percent));
  }
}
