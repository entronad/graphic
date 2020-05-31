import 'package:graphic/src/util/typed_map_mixin.dart' show TypedMapMixin;

enum AdjustType {
  dodge,
  stack,
  symmetric,
}

class AdjustCfg with TypedMapMixin {
  AdjustCfg({
    AdjustType type,
    double marginRatio,
    double dodgeRatio,
    String xField,
    String yField,
    bool reverseOrder,
  }) {
    this['type'] = type;
    this['marginRatio'] = marginRatio;
    this['dodgeRatio'] = dodgeRatio;
    this['xField'] = xField;
    this['yField'] = yField;
    this['reverseOrder'] = reverseOrder;
  }

  // geom usage

  AdjustType get type => this['type'] as AdjustType;
  set type(AdjustType value) => this['type'] = value;

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
