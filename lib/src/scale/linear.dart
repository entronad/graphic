import 'dart:math';

import 'package:meta/meta.dart';
import 'package:graphic/src/coord/base.dart';

import 'base.dart';
import 'auto_ticks/num.dart';

class LinearScale<D> extends Scale<num, D> {
  LinearScale({
    bool nice,
    num min,
    num max,
    num tickInterval,

    String Function(num) formatter,
    List<double> range,
    String alias,
    int tickCount,
    List<num> ticks,
    double origin,

    @required num Function(D) accessor,
  }) {
    assert(
      tickCount == null || tickCount > 1,
      'TickCount should greater than 1.',
    );
    assert(
      max == null || min == null || max >= min,
      'max: $max should not be less than min: $min',
    );
    assert(
      range == null || range.length == 2,
      'range can only has 2 items'
    );

    this['nice'] = nice;
    this['min'] = min;
    this['max'] = max;
    this['tickInterval'] = tickInterval;
    this['formatter'] = formatter;
    this['range'] = range;
    this['alias'] = alias;
    this['tickCount'] = tickCount;
    this['ticks'] = ticks;
    this['origin'] = origin;
    this['accessor'] = accessor;
  }

  @override
  ScaleType get type => ScaleType.linear;

  @override
  void complete(List<D> data, CoordComponent coord) {
    if (this['max'] == null || this['min'] == null) {
      final accessor = this['accessor'] as num Function(D);
      final values = data.map(accessor).toList();
      final maxValue = values.reduce(max);
      final minValue = values.reduce(min);
      if (minValue > 0) {
        this['max'] = this['max'] ?? maxValue;
        this['min'] = this['min'] ?? 0;
      } else if (maxValue < 0) {
        this['max'] = this['max'] ?? 0;
        this['min'] = this['min'] ?? minValue;
      } else {
        this['max'] = this['max'] ?? maxValue;
        this['min'] = this['min'] ?? minValue;
      }
    }
  }
}

class LinearScaleState<D> extends ScaleState<num, D> {
  bool get nice => this['nice'] as bool ?? false;
  set nice(bool value) => this['nice'] = value;

  num get min => this['min'] as num;
  set min(num value) => this['min'] = value;

  num get max => this['max'] as num;
  set max(num value) => this['max'] = value;

  num get tickInterval => this['tickInterval'] as num;
  set tickInterval(num value) => this['tickInterval'] = value;
}

class LinearScaleComponent<D>
  extends ScaleComponent<LinearScaleState<D>, num, D>
{
  LinearScaleComponent([LinearScale<D> props]) : super(props);

  @override
  LinearScaleState<D> createState() => LinearScaleState<D>();

  @override
  void assign() {
    if (state.ticks == null) {
      _assignTicks();
    } else {
      final firstTick = state.ticks.first;
      final lastTick = state.ticks.last;
      if (state.min > firstTick) {
        state.min = firstTick;
      }
      if (state.max < lastTick){
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
      final ticks = <num>[];
      for (var tick in calcTicks) {
        if (tick >= state.min && tick <= state.max) {
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
  double scale(num value) {
    if (value == null) {
      return null;
    }

    final minValue = state.min;
    final maxValue = state.max;
    final rangeMin = state.range.first;
    final rangeMax = state.range.last;

    if (maxValue == minValue) {
      return rangeMin;
    }

    final percent = (value - minValue) / (maxValue - minValue);
    return rangeMin + percent * (rangeMax - rangeMin);
  }

  @override
  num invert(double scaled) {
    final minValue = state.min;
    final maxValue = state.max;
    final rangeMin = state.range.first;
    final rangeMax = state.range.last;

    final percent = (scaled - rangeMin) / (rangeMax - rangeMin);
    return minValue + (maxValue - minValue) * percent;
  }

  @override
  List<num> getAutoTicks() => numAutoTicks(
    minValue: state.min,
    maxValue: state.max,
    minCount: state.tickCount,
    maxCount: state.tickCount,
    interval: state.tickInterval,
  );

  @override
  double get origin => scale(0);
}
