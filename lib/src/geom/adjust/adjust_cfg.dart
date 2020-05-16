import 'package:graphic/src/util/typed_map_mixin.dart' show TypedMapMixin;

class AdjustCfg<F> with TypedMapMixin {

  // base

  List<String> get adjustNames => this['adjustNames'] as List<String>;
  set adjustNames(List<String> value) => this['adjustNames'] = value;

  // dodge

  double get marginRatio => this['marginRatio'] as double;
  set marginRatio(double value) => this['marginRatio'] = value;

  double get dodgeRatio => this['dodgeRatio'] as double;
  set dodgeRatio(double value) => this['dodgeRatio'] = value;

  // stack

  String get xField => this['xField'] as String;
  set xField(String value) => this['xField'] = value;

  String get yField => this['yField'] as String;
  set yField(String value) => this['yField'] = value;

  bool get reverseOrder => this['reverseOrder'] as bool ?? false;
  set reverseOrder(bool value) => this['reverseOrder'] = value;
}
