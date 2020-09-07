import 'package:intl/intl.dart';
import 'package:graphic/src/util/exception.dart';

import '../base.dart';
import 'base.dart';

const _defaultMask = 'yyyy-MM-dd';

class TimeScale<D> extends OrdinalScale<DateTime, D> {
  TimeScale({
    String mask,

    bool isSorted,

    List<DateTime> values,
    List<String> stringValues,
    bool isRounding,

    String Function(DateTime) formatter,
    List<double> scaledRange,
    String alias,
    int tickCount,
    List<DateTime> ticks,

    DateTime Function(D) accessor,
    String Function(D) stringAccessor,
  }) {
    assert(
      testParamRedundant([mask, formatter]),
      paramRedundantWarning('mask, formatter'),
    );
    assert(
      scaledRange == null || scaledRange.length == 2,
      'range can only has 2 items'
    );
    assert(
      testParamRedundant([values, stringValues]),
      paramRedundantWarning('values, stringValues'),
    );
    assert(
      testParamRedundant([accessor, stringAccessor]),
      paramRedundantWarning('accessor, stringAccessor'),
    );

    this['mask'] = mask;
    this['isSorted'] = isSorted;
    this['isRounding'] = isRounding;
    this['formatter'] = formatter;
    this['scaledRange'] = scaledRange;
    this['alias'] = alias;
    this['tickCount'] = tickCount;
    this['ticks'] = ticks;

    final dateFormat = DateFormat(mask ?? _defaultMask);

    if (stringValues == null) {
      this['values'] = values;
    } else {
      this['values'] =
        stringValues.map((s) => dateFormat.parse(s)).toList();
    }

    if (stringAccessor == null) {
      this['accessor'] = accessor;
    } else {
      this['accessor'] =
        (D datum) => dateFormat.parse(stringAccessor(datum));
    }
  }

  @override
  ScaleType get type => ScaleType.time;
}

class DateTimeOrdinalScaleState<D> extends OrdinalScaleState<DateTime, D> {
  String get mask => this['mask'] as String;
  set mask(String value) => this['mask'] = value;
}

class DateTimeOrdinalScaleComponent<D>
  extends OrdinalScaleComponent<DateTimeOrdinalScaleState<D>, DateTime, D>
{
  DateTimeOrdinalScaleComponent([TimeScale<D> props]) : super(props);

  @override
  DateTimeOrdinalScaleState<D> get originalState => DateTimeOrdinalScaleState<D>();

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
