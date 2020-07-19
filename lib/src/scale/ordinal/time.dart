import 'package:intl/intl.dart';
import 'package:graphic/src/common/base_classes.dart';
import 'package:graphic/src/util/exception.dart';

import '../base.dart';
import 'base.dart';

class TimeScale extends Props<ScaleType> {
  TimeScale({
    String mask,

    bool isSorted,

    List<String> values,
    bool isRounding,

    String Function(DateTime) formatter,
    List<double> scaledRange,
    String alias,
    int tickCount,
    List<DateTime> ticks,
  }) {
    assert(
      testParamRedundant([mask, formatter]),
      paramRedundantWarning('mask, formatter'),
    );

    this['mask'] = mask;
    this['isSorted'] = isSorted;
    this['values'] = values;
    this['isRounding'] = isRounding;
    this['formatter'] = formatter;
    this['scaledRange'] = scaledRange;
    this['alias'] = alias;
    this['tickCount'] = tickCount;
    this['ticks'] = ticks;
  }

  @override
  ScaleType get type => ScaleType.time;
}

class TimeOrdinalScaleState extends OrdinalScaleState<DateTime> {
  String get mask => this['mask'] as String;
  set mask(String value) => this['mask'] = value;
}

class TimeOrdinalScaleComponent
  extends OrdinalScaleComponent<TimeOrdinalScaleState, DateTime>
{
  TimeOrdinalScaleComponent([TimeScale props]) : super(props);

  @override
  TimeOrdinalScaleState get originalState => TimeOrdinalScaleState();

  @override
  void initDefaultState() {
    super.initDefaultState();
    state
      ..tickCount = 5
      ..formatter = null
      ..mask = 'yyyy-MM-dd';
  }

  DateFormat _dateFormat;

  @override
  int compare(DateTime a, DateTime b) => a.compareTo(b);

  @override
  void assign() {
    super.assign();

    _dateFormat = DateFormat(state.mask);
  }

  @override
  String getText(DateTime value) {
    final formatter = state.formatter;
    if (formatter != null) {
      return formatter(value);
    }
    return _dateFormat.format(value);
  }
}
