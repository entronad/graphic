import 'package:meta/meta.dart';
import 'package:graphic/src/common/typed_map.dart';

import '../base.dart';

abstract class SingleLinearAttrState<A> extends AttrState<A> {
  List<A> get values => this['values'] as List<A>;
  set values(List<A> value) => this['values'] = value;

  List<double> get stops => this['stops'] as List<double>;
  set stops(List<double> value) => this['stops'] = value;
}

abstract class SingleLinearAttrComponent<S extends SingleLinearAttrState, A>
  extends AttrComponent<S, A>
{
  SingleLinearAttrComponent([TypedMap props]) : super(props);

  @override
  A defaultMap(List<double> scaledValues) {
    if (scaledValues == null || scaledValues.isEmpty) {
      return null;
    }
    assert(scaledValues.length == 1);
    final ratio = scaledValues.first;

    final values = state.values;
    var stops = state.stops;
    assert(stops == null || stops.length == values.length);

    if (stops == null) {
      stops = <double>[];
      for (var i = 0; i < values.length; i++) {
        stops.add(i * (1 / (values.length - 1)));
      }
    }
    for (var s = 0; s < stops.length - 1; s++) {
      final leftStop = stops[s], rightStop = stops[s + 1];
      final leftColor = values[s], rightColor = values[s + 1];
      if (ratio <= leftStop) {
        return leftColor;
      } else if (ratio < rightStop) {
        final sectionT = (ratio - leftStop) / (rightStop - leftStop);
        return lerp(leftColor, rightColor, sectionT);
      }
    }
    return values.last;
  }

  @protected
  A lerp(A a, A b, double t);
}
