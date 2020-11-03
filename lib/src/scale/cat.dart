import 'package:meta/meta.dart';
import 'package:graphic/src/coord/base.dart';
import 'package:graphic/src/coord/polar.dart';

import 'base.dart';
import 'auto_ticks/cat.dart';

class CatScale<D> extends Scale<String, D> {
  CatScale({
    List<String> values,
    bool isRounding,

    String Function(String) formatter,
    List<double> range,
    String alias,
    int tickCount,
    List<String> ticks,
    double origin,

    @required String Function(D) accessor,
  }) {
    assert(
      range == null || range.length == 2,
      'range can only has 2 items',
    );

    this['values'] = values;
    this['isRounding'] = isRounding;
    this['formatter'] = formatter;
    this['range'] = range;
    this['alias'] = alias;
    this['tickCount'] = tickCount;
    this['ticks'] = ticks;
    this['origin'] = origin;
    this['accessor'] = accessor;
  }

  @override
  ScaleType get type => ScaleType.cat;

  List<double> get range => this['range'] as List<double>;
  set range(List<double> value) => this['range'] = value;

  String Function(D) get accessor => this['accessor'] as String Function(D);
  set accessor(String Function(D) value) => this['accessor'] = value;

  List<String> get values => this['values'] as List<String>;
  set values(List<String> value) => this['values'] = value;

  @override
  void complete(List<D> data, CoordComponent coord) {
    if (values == null) {
      values = data.map(accessor).toSet().toList();
    }

    if (range == null) {
      final count = values.length;
      if (coord is PolarCoordComponent) {
        range = [0, 1 - 1 / count];
      } else {
        range = [1 / count / 2, 1 - 1 / count / 2];
      }
    }
  }
}

class CatScaleState<D> extends ScaleState<String, D> {
  List<String> get values => this['values'] as List<String>;
  set values(List<String> value) => this['values'] = value;

  bool get isRounding => this['isRounding'] as bool ?? false;
  set isRounding(bool value) => this['isRounding'] = value;
}

class CatScaleComponent<D>
  extends ScaleComponent<CatScaleState<D>, String, D>
{
  CatScaleComponent([CatScale<D> props]) : super(props);

  @override
  CatScaleState<D> createState() => CatScaleState<D>();

  @override
  void initDefaultState() {
    super.initDefaultState();
    state
      ..isRounding = true;
  }

  @override
  List<String> getAutoTicks() => catAutoTicks<String>(
    maxCount: state.tickCount,
    categories: state.values,
    isRounding: state.isRounding,
  );

  @override
  void assign() {
    // Do not return. subclass may reuse.
    if (state.ticks == null) {
      final values = state.values;
      final tickCount = state.tickCount;
      var ticks = values;
      if (tickCount != null && tickCount > 0) {
        ticks = getAutoTicks();
      }
      state.ticks = ticks;
    }
  }

  @override
  double scale(String value) {
    if (value == null) {
      return null;
    }
    final index = getIndex(value);
    if (index <0) {
      return null;
    }
    final intervalsCount = state.values.length - 1;
    final rangeMin = state.range.first;
    final rangeMax = state.range.last;

    // when values has one item and that is value, The same as identity.
    if (intervalsCount < 1) {
      return rangeMin;
    }

    final ratio = index / intervalsCount;
    return rangeMin + ratio * (rangeMax - rangeMin);
  }

  @protected
  int getIndex(String value) {
    final values = state.values;
    int index = values.indexOf(value);
    return index;
  }

  @override
  String invert(double scaled) {
    final values = state.values;
    final valuesCount = values.length;
    final intervalsCount = valuesCount - 1;
    final rangeMin = state.range.first;
    final rangeMax = state.range.last;

    final ratio = (scaled.clamp(rangeMin, rangeMax) - rangeMin) / (rangeMax - rangeMin);
    final index = (ratio * intervalsCount).round() % valuesCount;
    return values[index];
  }

  @override
  double get origin => 0;
}
