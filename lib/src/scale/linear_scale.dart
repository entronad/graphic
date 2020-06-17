import 'base.dart';
import 'auto/number.dart';

class LinearScale extends Scale<double> {
  LinearScale(ScaleCfg<double> cfg) : super(cfg);

  @override
  num translate(double value) => value;

  @override
  ScaleCfg<double> get defaultCfg => super.defaultCfg
    ..type = ScaleType.linear
    ..isLinear = true
    ..nice = false;
  
  @override
  void init() {
    if (cfg.ticks == null) {
      cfg.min = translate(cfg.min);
      cfg.max = translate(cfg.max);
      initTicks();
    } else {
      final ticks = cfg.ticks;
      final firstValue = translate(ticks[0]);
      final lastValue = translate(ticks.last);
      if (cfg.min == null || cfg.min > firstValue) {
        cfg.min = firstValue;
      }
      if (cfg.max == null || cfg.max < lastValue) {
        cfg.max = lastValue;
      }
    }
  }

  List<num> calculateTicks() {
    final min = cfg.min;
    final max = cfg.max;
    final minLimit = cfg.minLimit;
    final maxLimit = cfg.maxLimit;
    final tickCount = cfg.tickCount;
    final tickInterval = cfg.tickInterval;
    final minTickInterval = cfg.minTickInterval;
    final snapArray = cfg.snapArray;

    if (tickCount == 1) {
      throw Exception('linear scale\'tickCount should not be 1');
    }
    if (max < min) {
      throw Exception('max: $max should not be less than min: $min');
    }
    final tmp = numberAuto(
      min: min,
      max: max,
      minLimit: minLimit,
      maxLimit: maxLimit,
      minCount: tickCount,
      maxCount: tickCount,
      interval: tickInterval,
      minTickInterval: minTickInterval,
      snapArray: snapArray,
    );
    return tmp.ticks;
  }

  void initTicks() {
    final calTicks = calculateTicks();
    if (cfg.nice) {
      cfg.ticks = calTicks;
      cfg.min = calTicks[0];
      cfg.max = calTicks.last;
    } else {
      final ticks = <num>[];
      calTicks?.forEach((tick) {
        if (tick >= cfg.min && tick <= cfg.max) {
          ticks.add(tick);
        }
      });

      if (ticks.isEmpty) {
        ticks.add(cfg.min);
        ticks.add(cfg.max);
      }

      cfg.ticks = ticks;
    }
  }

  @override
  double scale(num value) {
    if (value == null) {
      return double.nan;
    }
    final max = cfg.max;
    final min = cfg.min;
    if (max == min) {
      return 0;
    }

    final percent = (value - min) / (max - min);
    return rangeMin + percent * (rangeMax - rangeMin);
  }

  @override
  double invert(Object value) {
    if (value is num) {
      final percent = (value - rangeMin) / (rangeMax - rangeMin);
      return cfg.min + percent * (cfg.max - cfg.min);
    }
    return double.nan;
  }

  @override
  LinearScale clone() =>
    LinearScale(ScaleCfg<double>().mix(cfg));
}
