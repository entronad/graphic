import 'package:meta/meta.dart';

import '../base.dart';

abstract class SingleLinearAttr<A> extends Attr<A> {
  SingleLinearAttr(String field) : super(field) {
    assert(
      this['fields'] == null
        || (this['fields'] as List<String>).length == 1,
      'SingleLinearAttr only support one field',
    );
  }
}

abstract class SingleLinearAttrState<A> extends AttrState<A> {
  List<double> get stops => this['stops'] as List<double>;
  set stops(List<double> value) => this['stops'] = value;

  bool get isTween => this['isTween'] as bool ?? false;
  set isTween(bool value) => this['isTween'] = value;
}

abstract class SingleLinearAttrComponent<S extends SingleLinearAttrState, A>
  extends AttrComponent<S, A>
{
  SingleLinearAttrComponent([Attr props]) : super(props);

  @override
  A defaultMapper(List<double> scaledValues) {
    if (scaledValues == null || scaledValues.isEmpty) {
      return null;
    }
    assert(scaledValues.length == 1);
    final ratio = scaledValues.first;

    final values = state.values;
    final stops = state.stops;
    assert(stops.length == values.length);

    // Wether stops is increasing or decreasing
    if (stops.first <= stops.last) {
      for (var s = 0; s < stops.length - 1; s++) {
        final leftStop = stops[s];
        final rightStop = stops[s + 1];
        final leftValue = values[s];
        final rightValue = values[s + 1];
        if (ratio <= leftStop) {
          return leftValue;
        } else if (ratio < rightStop) {
          final sectionT = (ratio - leftStop) / (rightStop - leftStop);
          return lerp(leftValue, rightValue, sectionT);
        }
      }
      return values.last;
    } else {
      for (var s = 0; s < stops.length - 1; s++) {
        final leftStop = stops[s];
        final rightStop = stops[s + 1];
        final leftValue = values[s];
        final rightValue = values[s + 1];
        if (ratio >= leftStop) {
          return leftValue;
        } else if (ratio > rightStop) {
          final sectionT = (ratio - leftStop) / (rightStop - leftStop);
          return lerp(leftValue, rightValue, sectionT);
        }
      }
      return values.last;
    }
  }

  @protected
  A lerp(A a, A b, double t);
}
