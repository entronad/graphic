import 'package:meta/meta.dart';
import 'package:intl/intl.dart';
import 'package:graphic/src/coord/base.dart';
import 'package:graphic/src/util/exception.dart';

import 'base.dart';

const _defaultMask = 'yyyy-MM-dd';

DateTime _later(DateTime a, DateTime b) =>
  a.isAfter(b) ? a : b;

DateTime _earlier(DateTime a, DateTime b) =>
  a.isBefore(b) ? a : b;

class TimeScale<D> extends Scale<DateTime, D> {
  TimeScale({
    DateTime min,
    DateTime max,

    String Function(DateTime) formatter,
    List<double> range,
    String alias,
    int tickCount,
    List<DateTime> ticks,
    double origin,

    String mask,

    @required DateTime Function(D) accessor,
  }) {
    assert(
      tickCount == null || tickCount > 1,
      'TickCount should greater than 1.',
    );
    assert(
      max == null || min == null || max.isAfter(min),
      'max: $max should not be less than min: $min',
    );
    assert(
      range == null || range.length == 2,
      'range can only has 2 items'
    );
    assert(
      testParamRedundant([mask, formatter]),
      paramRedundantWarning('mask, formatter'),
    );

    this['min'] = min;
    this['max'] = max;
    this['formatter'] = formatter;
    this['range'] = range;
    this['alias'] = alias;
    this['tickCount'] = tickCount;
    this['ticks'] = ticks;
    this['origin'] = origin;
    this['mask'] = mask;
    this['accessor'] = accessor;
  }

  @override
  ScaleType get type => ScaleType.time;

  @override
  void complete(List<D> data, CoordComponent coord) {
    if (this['max'] == null || this['min'] == null) {
      final accessor = this['accessor'] as DateTime Function(D);
      final values = data.map(accessor).toList();
      final maxValue = values.reduce(_later);
      final minValue = values.reduce(_earlier);
      this['max'] = this['max'] ?? maxValue;
      this['min'] = this['min'] ?? minValue;
    }
  }
}

class TimeScaleState<D> extends ScaleState<DateTime, D> {
  DateTime get min => this['min'] as DateTime;
  set min(DateTime value) => this['min'] = value;

  DateTime get max => this['max'] as DateTime;
  set max(DateTime value) => this['max'] = value;

  String get mask => this['mask'] as String;
  set mask(String value) => this['mask'] = value;
}

class TimeScaleComponent<D>
  extends ScaleComponent<TimeScaleState<D>, DateTime, D>
{
  TimeScaleComponent([TimeScale<D> props]) : super(props);

  @override
  TimeScaleState<D> createState() => TimeScaleState<D>();

  @override
  void initDefaultState() {
    super.initDefaultState();
    state
      ..tickCount = 5
      ..formatter = null
      ..mask = _defaultMask;
  }

  DateFormat _dateFormat;

  @override
  void assign() {
    if (state.ticks == null) {
      _assignTicks();
    } else {
      final firstTick = state.ticks.first;
      final lastTick = state.ticks.last;
      if (state.min.isAfter(firstTick)) {
        state.min = firstTick;
      }
      if (state.max.isBefore(lastTick)){
        state.max = lastTick;
      }
    }

    _dateFormat = DateFormat(state.mask);
  }

  void _assignTicks() {
    state.ticks = getAutoTicks();
  }

  @override
  double scale(DateTime value) {
    if (value == null) {
      return null;
    }

    final valueMicro = value.microsecondsSinceEpoch;
    final minValue = state.min.microsecondsSinceEpoch;
    final maxValue = state.max.microsecondsSinceEpoch;
    final rangeMin = state.range.first;
    final rangeMax = state.range.last;

    if (maxValue == minValue) {
      return rangeMin;
    }

    final percent = (valueMicro - minValue) / (maxValue - minValue);
    return rangeMin + percent * (rangeMax - rangeMin);
  }

  @override
  DateTime invert(double scaled) {
    final minValue = state.min.microsecondsSinceEpoch;
    final maxValue = state.max.microsecondsSinceEpoch;
    final rangeMin = state.range.first;
    final rangeMax = state.range.last;

    final percent = (scaled - rangeMin) / (rangeMax - rangeMin);
    return DateTime.fromMicrosecondsSinceEpoch(
      (minValue + (maxValue - minValue) * percent).round()
    );
  }

  @override
  List<DateTime> getAutoTicks() {
    final minMicro = state.min.microsecondsSinceEpoch;
    final maxMicro = state.max.microsecondsSinceEpoch;
    final count = state.tickCount;
    final step = (maxMicro - minMicro) ~/ (count - 1);
    
    final rst = <DateTime>[];
    rst.add(state.min);
    for (var i = 1; i < count - 1; i++) {
      rst.add(DateTime.fromMicrosecondsSinceEpoch(minMicro + i * step));
    }
    rst.add(state.max);
    return rst;
  }

  @override
  String getText(DateTime value) {
    final formatter = state.formatter;
    if (formatter != null) {
      return formatter(value);
    }
    return _dateFormat.format(value);
  }

  @override
  double get origin => 0;
}
