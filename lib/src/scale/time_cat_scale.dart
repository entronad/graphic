import 'package:intl/intl.dart';
import 'cat_scale.dart';
import 'base.dart';
import 'auto/cat.dart';

// F could only be formatted String or timestamp int
class TimeCatScale<F> extends CatScale<F> {
  TimeCatScale(ScaleCfg<F> cfg) : super(cfg);

  DateFormat _dateFormat;

  String get mask => cfg.mask;

  // must use this setter to change mask in order to update _dateFormat
  set mask(String value) {
    cfg.mask = value;
    _dateFormat = DateFormat(cfg.mask);
  } 

  @override
  ScaleCfg<F> get defaultCfg => super.defaultCfg
    ..type = ScaleType.timeCat
    ..sortable = true
    ..tickCount = 5
    ..mask = 'yyyy-MM-dd';

  @override
  void init() {
    _dateFormat = DateFormat(cfg.mask);

    final values = cfg.values;
    if (cfg.sortable) {
      values.sort((v1, v2) => toTimeStamp(v1) - toTimeStamp(v2));
    }

    if (cfg.ticks == null) {
      cfg.ticks = this.calculateTicks();
    }
  }

  List<F> calculateTicks() {
    final count = cfg.tickCount;
    var ticks;
    if (count != null) {
      final temp = catAuto<F>(
        maxCount: count,
        data: cfg.values,
        isRounding: cfg.isRounding,
      );
      ticks = temp.ticks;
    } else {
      ticks = cfg.values;
    }

    return ticks;
  }

  @override
  num translate(F value) {
    int valueStamp = toTimeStamp(value);
    num index = cfg.values.map(toTimeStamp).toList().indexOf(valueStamp);

    if (index == -1) {
      if (value is num && value < cfg.values.length) {
        index = value;
      } else {
        index = double.nan;
      }
    }
    return index;
  }

  @override
  double scale(Object value) {
    final index = this.translate(value);

    var percent;
    if (cfg.values.length == 1 || index.isNaN) { // is index is NAN should not be set as 0
      percent = index;
    } else if (index > -1) {
      percent = index / (cfg.values.length - 1);
    } else {
      percent = 0;
    }

    return rangeMin + percent * (rangeMax - rangeMin);
  }

  @override
  String getText(Object value) {
    F result;
    final index = this.translate(value);
    if (index > -1) {
      result = cfg.values[index];
    } else {
      result = value;
    }

    final formatter = cfg.formatter;
    if (formatter != null) {
      return formatter(result);
    }
    if (result is int) {
      return this._dateFormat.format(DateTime.fromMillisecondsSinceEpoch(result));
    }
    if (result is String) {
      return result;
    }
    return '';
  }

  @override
  List<Tick<F>> getTicks() {
    final ticks = cfg.ticks;
    final rst = <Tick<F>>[];
    ticks?.forEach((tick) {
      final obj = Tick<F>(
        this.getText(tick),
        tick,
        this.scale(tick),
      );
      rst.add(obj);
    });
    return rst;
  }

  int toTimeStamp(F value) =>
    (value is String) ? this._dateFormat.parse(value).millisecondsSinceEpoch : value;

  @override
  TimeCatScale<F> clone() =>
    TimeCatScale<F>(ScaleCfg<F>().mix(cfg));
}
