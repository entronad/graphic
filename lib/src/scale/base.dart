import 'package:graphic/src/base.dart';
import 'package:graphic/src/util/typed_map_mixin.dart';

import 'cat_scale.dart';
import 'identity_scale.dart';
import 'linear_scale.dart';
import 'time_cat_scale.dart';

class Tick<F> {
  Tick(this.text, this.tickValue, this.value);

  final String text;
  final F tickValue;
  final double value;
}

enum ScaleType {
  cat,
  timeCat,
  linear,
  identity,
}

class ScaleCfg<F> with TypedMapMixin {
  ScaleCfg({
    ScaleType type,
    String Function(F) formatter,
    List<double> range,
    String alias,
    int tickCount,
    List<F> ticks,

    List<F> values,
    bool isRounding,

    bool nice,
    String mask,
    
    double min,
    double max,
    double tickInterval,

    F value,
  }) {
    if (type != null) this['type'] = type;
    if (formatter != null) this['formatter'] = formatter;
    if (range != null) this['range'] = range;
    if (alias != null) this['alias'] = alias;
    if (tickCount != null) this['tickCount'] = tickCount;
    if (ticks != null) this['ticks'] = ticks;

    if (values != null) this['values'] = values;
    if (isRounding != null) this['isRounding'] = isRounding;

    if (nice != null) this['nice'] = nice;
    if (mask != null) this['mask'] = mask;
    
    if (min != null) this['min'] = min;
    if (max != null) this['max'] = max;
    if (tickInterval != null) this['tickInterval'] = tickInterval;

    if (value != null) this['value'] = value;
  }

  // base

  ScaleType get type => this['type'] as ScaleType;
  set type(ScaleType value) => this['type'] = value;

  String Function(F) get formatter => this['formatter'] as String Function(F);
  set formatter(String Function(F) value) => this['formatter'] = value;

  List<double> get range => this['range'] as List<double>;
  set range(List<double> value) => this['range'] = value;

  List<F> get ticks => this['ticks'] as List<F>;
  set ticks(List<F> value) => this['ticks'] = value;

  List<F> get values => this['values'] as List<F>;
  set values(List<F> value) => this['values'] = value;

  String get alias => this['alias'] as String;
  set alias(String value) => this['alias'] = value;

  String get field => this['field'] as String;
  set field(String value) => this['field'] = value;

  // cat

  bool get isCategory => this['isCategory'] as bool ?? false;
  set isCategory(bool value) => this['isCategory'] = value;

  bool get isRounding => this['isRounding'] as bool ?? false;
  set isRounding(bool value) => this['isRounding'] = value;

  // timeCat

  bool get sortable => this['sortable'] as bool ?? false;
  set sortable(bool value) => this['sortable'] = value;

  int get tickCount => this['tickCount'] as int;
  set tickCount(int value) => this['tickCount'] = value;

  String get mask => this['mask'] as String;
  set mask(String value) => this['mask'] = value;

  // linear

  bool get isLinear => this['isLinear'] as bool ?? false;
  set isLinear(bool value) => this['isLinear'] = value;

  bool get nice => this['nice'] as bool ?? false;
  set nice(bool value) => this['nice'] = value;

  double get min => this['min'] as double;
  set min(double value) => this['min'] = value;

  double get minLimit => this['minLimit'] as double;
  set minLimit(double value) => this['minLimit'] = value;

  double get max => this['max'] as double;
  set max(double value) => this['max'] = value;

  double get maxLimit => this['maxLimit'] as double;
  set maxLimit(double value) => this['maxLimit'] = value;

  double get tickInterval => this['tickInterval'] as double;
  set tickInterval(double value) => this['tickInterval'] = value;

  double get minTickInterval => this['minTickInterval'] as double;
  set minTickInterval(double value) => this['minTickInterval'] = value;

  List<double> get snapArray => this['snapArray'] as List<double>;
  set snapArray(List<double> value) => this['snapArray'] = value;

  // identity
  bool get isIdentity => this['isIdentity'] as bool ?? false;
  set isIdentity(bool value) => this['isIdentity'] = value;

  F get value => this['value'] as F;
  set value(F value) => this['value'] = value;
}

abstract class Scale<F> extends Base<ScaleCfg<F>> {
  static final Map<ScaleType, Scale Function(ScaleCfg)> creators = {
    ScaleType.cat: (ScaleCfg cfg) => CatScale(cfg),
    ScaleType.identity: (ScaleCfg cfg) => IdentityScale(cfg),
    ScaleType.linear: (ScaleCfg cfg) => LinearScale(cfg),
    ScaleType.timeCat: (ScaleCfg cfg) => TimeCatScale(cfg),
  };

  Scale(ScaleCfg<F> cfg) : super(cfg) {
    init();
  }

  @override
  ScaleCfg<F> get defaultCfg => ScaleCfg<F>(
    range: [0, 1],
    values: [],
  );

  void init() {}

  List<Tick<F>> getTicks() {
    final ticks = cfg.ticks;
    final rst = <Tick<F>>[];
    if (ticks != null) {
      for (var tick in ticks) {
        final obj = Tick<F>(
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
