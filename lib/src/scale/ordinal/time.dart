import 'package:intl/intl.dart';
import 'package:graphic/src/util/exception.dart';

import '../base.dart';
import 'base.dart';

class TimeScale<D> extends Scale {
  TimeScale({
    String mask,

    bool isSorted,

    List<DateTime> values,
    bool isRounding,

    String Function(DateTime) formatter,
    List<double> scaledRange,
    String alias,
    int tickCount,
    List<DateTime> ticks,

    DateTime Function(D) accessor,
  }) {
    assert(
      testParamRedundant([mask, formatter]),
      paramRedundantWarning('mask, formatter'),
    );
    assert(
      scaledRange == null || scaledRange.length == 2,
      'range can only has 2 items'
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
    this['accessor'] = accessor;
  }

  @override
  ScaleType get type => ScaleType.time;
}

class TimeOrdinalScaleState<D> extends OrdinalScaleState<DateTime, D> {
  String get mask => this['mask'] as String;
  set mask(String value) => this['mask'] = value;
}

class TimeOrdinalScaleComponent<D>
  extends OrdinalScaleComponent<TimeOrdinalScaleState<D>, DateTime, D>
{
  TimeOrdinalScaleComponent([TimeScale props]) : super(props);

  @override
  TimeOrdinalScaleState<D> get originalState => TimeOrdinalScaleState<D>();

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
