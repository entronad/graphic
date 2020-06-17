import 'dart:ui';

import 'package:graphic/src/util/typed_map_mixin.dart';

import 'attrs.dart';
import 'container.dart';
import 'element.dart';
import 'renderer.dart';

class Cfg with TypedMapMixin{
  Cfg({
    String type,
    Attrs attrs,
  }) {
    if (type != null) this['type'] = type;
    if (attrs != null) this['attrs'] = attrs;
  }

  // element cfg

  Attrs get attrs => this['attrs'] as Attrs;
  set attrs(Attrs value) => this['attrs'] = value;

  int get zIndex => this['zIndex'] as int;
  set zIndex(int value) => this['zIndex'] = value;

  bool get visible => this['visible'] as bool ?? false;
  set visible(bool value) => this['visible'] = value;

  bool get destroyed => this['destroyed'] as bool ?? false;
  set destroyed(bool value) => this['destroyed'] = value;

  bool get isGroup => this['isGroup'] as bool ?? false;
  set isGroup(bool value) => this['isGroup'] = value;

  bool get isShape => this['isShape'] as bool ?? false;
  set isShape(bool value) => this['isShape'] = value;

  Container get parent => this['parent'] as Container;
  set parent(Container value) => this['parent'] = value;

  List<Element> get children => this['children'] as List<Element>;
  set children(List<Element> value) => this['children'] = value;

  double get x => this['x'] as double;
  set x(double value) => this['x'] = value;

  double get y => this['y'] as double;
  set y(double value) => this['y'] = value;

  Renderer get renderer => this['renderer'] as Renderer;
  set renderer(Renderer value) => this['renderer'] = value;

  // Index as child, used for sorting comparison.
  int get index => this['index'] as int;
  set index(int value) => this['index'] = value;

  // shape cfg

  String get type => this['type'] as String;
  set type(String value) => this['type'] = value;

  Rect get bbox => this['bbox'] as Rect;
  set bbox(Rect value) => this['bbox'] = value;

  bool get isClip => this['isClip'] as bool ?? false;
  set isClip(bool value) => this['isClip'] = value;

  Attrs get endState => this['endState'] as Attrs;
  set endState(Attrs value) => this['endState'] = value;

  // extra

  // axis
  String get id => this['id'] as String;
  set id(String value) => this['id'] = value;

  // axis label
  bool get top => this['top'] as bool ?? false;
  set top(bool value) => this['top'] = value;

  double get value => this['value'] as double;
  set value(double value) => this['value'] = value;
}
