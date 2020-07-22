import 'package:meta/meta.dart';
import 'package:graphic/src/common/typed_map.dart';
import 'package:graphic/src/common/base_classes.dart';

import 'category/string.dart';
import 'identity/string.dart';
import 'linear/num.dart';
import 'ordinal/time.dart';

enum ScaleType {
  identity,  // StringIdentity
  cat,  // StringCategory
  time,  // DateTimeOrdinal
  linear,  // NumLinear
}

abstract class ScaleState<V> with TypedMap {
  String Function(V) get formatter => this['formatter'] as String Function(V);
  set formatter(String Function(V) value) => this['formatter'] = value;

  List<double> get scaledRange => this['scaledRange'] as List<double>;
  set scaledRange(List<double> value) => this['scaledRange'] = value;

  String get alias => this['alias'] as String;
  set alias(String value) => this['alias'] = value;

  int get tickCount => this['tickCount'] as int;
  set tickCount(int value) => this['tickCount'] = value;

  List<V> get ticks => this['ticks'] as List<V>;
  set ticks(List<V> value) => this['ticks'] = value;
}

abstract class ScaleComponent<S extends ScaleState<V>, V> extends Component<S> {
  static ScaleComponent create(Props props) {
    switch (props.type) {
      case ScaleType.identity:
        return StringIdentityScaleComponent(props);
      case ScaleType.cat:
        return StringCategoryScaleComponent(props);
      case ScaleType.time:
        return TimeOrdinalScaleComponent(props);
      case ScaleType.linear:
        return NumLinearScaleComponent(props);
      default: return null;
    }
  }

  ScaleComponent([TypedMap props]) : super(props) {
    assign();
  }

  @override
  void initDefaultState() {
    super.initDefaultState();
    state
      ..scaledRange = [0, 1]
      ..formatter = (v) => v?.toString();
  }

  @protected
  List<V> getAutoTicks();

  void setProps(Props<ScaleType> props) {
    state.ticks = null;

    state.mix(props);
    onSetProps();
  }

  @protected
  void onSetProps() {
    assign();
  }

  // subclass must assign ticks.
  @protected
  void assign();

  double scale(V value);

  V invert(double scaled);

  String getText(V value) => state.formatter(value);
}
