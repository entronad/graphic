import 'base.dart';
import './auto/cat.dart';

class CatScale<F> extends Scale<F> {
  CatScale(ScaleCfg<F> cfg) : super(cfg);

  @override
  ScaleCfg<F> get defaultCfg => super.defaultCfg
    ..type = ScaleType.cat
    ..isCategory = true
    ..isRounding = true;

  @override
  void init() {
    final values = cfg.values;
    final tickCount = cfg.tickCount;

    if (cfg.ticks == null) {
      var ticks = values;
      if (tickCount != null && tickCount > 0) {
        final temp = catAuto<F>(
          maxCount: tickCount,
          data: values,
          isRounding: cfg.isRounding,
        );
        ticks = temp.ticks;
      }
      cfg.ticks = ticks;
    }
  }

  @override
  String getText(Object value) {
    if (value is num) {
      return super.getText(cfg.values[value.round()]);
    }
    return super.getText(value);
  }

  @override
  num translate(F value) {
    num index;
    if (value is num) {
      index = value;
    } else {
      index = cfg.values.indexOf(value);
    }
    if (index < 0) {
      index = double.nan;
    }
    return index;
  }

  @override
  double scale(F value) {
    double percent;

    num valueNum;
    if (value is num) {
      valueNum = value;
    } else {
      valueNum = this.translate(value);
    }
    
    if (cfg.values.length > 1) {
      percent = valueNum / (cfg.values.length - 1);
    } else {
      percent = valueNum;
    }
    return rangeMin + percent * (rangeMax - rangeMin);
  }

  @override
  F invert(Object value) {
    if (value is num) {
      final min = rangeMin;
      final max = rangeMax;

      final percent = (value.clamp(min, max) - min) / (max - min);
      final index = (percent * (cfg.values.length - 1)).round() % cfg.values.length;
      return cfg.values[index];
    }
    if (value is F) {
      return value;
    }
    return null;
  }

  @override
  CatScale<F> clone() =>
    CatScale<F>(ScaleCfg<F>().mix(cfg));
}
