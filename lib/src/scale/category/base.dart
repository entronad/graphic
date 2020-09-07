import 'package:meta/meta.dart';
import 'package:graphic/src/coord/base.dart';
import 'package:graphic/src/coord/polar.dart';

import '../base.dart';
import '../auto_ticks/cat.dart';

abstract class CategoryScale<V, D> extends Scale<V, D> {
  List<double> get scaledRange => this['scaledRange'] as List<double>;
  set scaledRange(List<double> value) => this['scaledRange'] = value;

  V Function(D) get accessor => this['accessor'] as V Function(D);
  set accessor(V Function(D) value) => this['accessor'] = value;

  List<V> get values => this['values'] as List<V>;
  set values(List<V> value) => this['values'] = value;

  @override
  void complete(List<D> data, CoordComponent coord) {
    if (values == null) {
      values = data.map(accessor).toSet().toList();
    }

    if (scaledRange == null) {
      final count = values.length;
      if (coord is PolarCoordComponent) {
        scaledRange = [0, 1 - 1 / count];
      } else {
        scaledRange = [1 / count / 2, 1 - 1 / count / 2];
      }
    }
  }
}

abstract class CategoryScaleState<V, D> extends ScaleState<V, D> {
  List<V> get values => this['values'] as List<V>;
  set values(List<V> value) => this['values'] = value;

  bool get isRounding => this['isRounding'] as bool ?? false;
  set isRounding(bool value) => this['isRounding'] = value;
}

abstract class CategoryScaleComponent<S extends CategoryScaleState<V, D>, V, D>
  extends ScaleComponent<S, V, D>
{
  CategoryScaleComponent([CategoryScale<V, D> props]) : super(props);

  @override
  void initDefaultState() {
    super.initDefaultState();
    state
      ..isRounding = true;
  }

  @override
  List<V> getAutoTicks() => catAutoTicks<V>(
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
  double scale(V value) {
    if (value == null) {
      return null;
    }
    final index = getIndex(value);
    if (index <0) {
      return null;
    }
    final intervalsCount = state.values.length - 1;
    final rangeMin = state.scaledRange.first;
    final rangeMax = state.scaledRange.last;

    // when values has one item and that is value, The same as identity.
    if (intervalsCount < 1) {
      return rangeMin;
    }

    final ratio = index / intervalsCount;
    return rangeMin + ratio * (rangeMax - rangeMin);
  }

  @protected
  int getIndex(V value) {
    final values = state.values;
    int index = values.indexOf(value);
    return index;
  }

  @override
  V invert(double scaled) {
    final values = state.values;
    final valuesCount = values.length;
    final intervalsCount = valuesCount - 1;
    final rangeMin = state.scaledRange.first;
    final rangeMax = state.scaledRange.last;

    final ratio = (scaled.clamp(rangeMin, rangeMax) - rangeMin) / (rangeMax - rangeMin);
    final index = (ratio * intervalsCount).round() % valuesCount;
    return values[index];
  }
}
