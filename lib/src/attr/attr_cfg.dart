import 'package:graphic/src/util/typed_map_mixin.dart' show TypedMapMixin;
import 'package:graphic/src/scale/base.dart' show Scale;
import 'package:graphic/src/coord/base.dart' show Coord;

enum AttrType {
  color,
  position,
  shape,
  size,
}

typedef AttrCallback<V> = V Function(List<Object> params);

class AttrCfg<V> with TypedMapMixin {
  AttrCfg({
    String field,
    List<V> values,
    List<double> stops,
    AttrCallback<V> callback,
  }) {
    this['field'] = field;
    this['values'] = values;
    this['stops'] = stops;
    this['callback'] = callback;
  }

  String get field => this['field'] as String;
  set field(String value) => this['field'] = value;

  List<V> get values => this['values'] as List<V>;
  set values(List<V> value) => this['values'] = value;

  List<double> get stops => this['stops'] as List<double>;
  set stops(List<double> value) => this['stops'] = value;

  AttrCallback<V> get callback => this['callback'] as AttrCallback<V>;
  set callback(AttrCallback<V> value) => this['callback'] = value;

  // base

  AttrType get type => this['type'] as AttrType;
  set type(AttrType value) => this['type'] = value;

  String get name => this['name'] as String;
  set name(String value) => this['name'] = value;

  List<Scale> get scales => this['scales'] as List<Scale>;
  set scales(List<Scale> value) => this['scales'] = value;

  bool get linear => this['linear'] as bool ?? false;
  set linear(bool value) => this['linear'] = value;

  List<String> get names => this['names'] as List<String>;
  set names(List<String> value) => this['names'] = value;

  // position

  Coord get coord => this['coord'] as Coord;
  set coord(Coord value) => this['coord'] = value;
}
