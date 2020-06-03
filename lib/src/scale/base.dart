import 'package:graphic/src/base.dart' show Base;

import 'scale_cfg.dart' show ScaleCfg;

class TickObj<F> {
  TickObj(this.text, this.tickValue, this.value);

  final String text;
  final F tickValue;
  final double value;
}

abstract class Scale<F> extends Base<ScaleCfg<F>> {
  Scale(ScaleCfg<F> cfg) : super(cfg) {
    init();
  }

  @override
  ScaleCfg<F> get defaultCfg => ScaleCfg<F>(
    range: [0, 1],
    values: [],
  );

  void init() {}

  List<TickObj<F>> getTicks() {
    final ticks = cfg.ticks;
    final rst = <TickObj<F>>[];
    if (ticks != null) {
      for (var tick in ticks) {
        final obj = TickObj<F>(
          getText(tick),
          tick,
          scale(tick),
        );
        rst.add(obj);
      }
    }
    return rst;
  }

  // Only value param used.
  String getText(Object value) {
    final formatter = cfg.formatter;
    var rst = (formatter != null) ? formatter(value) : value?.toString();
    rst = rst ?? '';
    return rst;
  }

  double get rangeMin => cfg.range.first;

  double get rangeMax => cfg.range.last;

  // value is double or F
  // value is double return inverted F, value is F return itself
  F invert(Object value);

  // transform F to num, may be double or int,
  // used in double scale(F value)
  num translate(F value);

  double scale(F value);

  Scale<F> clone();

  void change(ScaleCfg<F> cfg) {
    this.cfg.ticks = null;
    this.cfg.mix(cfg);
    init();
  }
}
