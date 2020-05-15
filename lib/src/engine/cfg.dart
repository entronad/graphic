import 'dart:ui' show Rect;

import 'package:graphic/src/util/typed_map_mixin.dart' show TypedMapMixin;

import 'attrs.dart' show Attrs;
import 'container.dart' show Container;
import 'element.dart' show Element;
import 'renderer.dart' show Renderer;

class Cfg with TypedMapMixin{
  Cfg({
    Attrs attrs,
    int zIndex,
    bool visible,
    bool destroyed,
    bool isGroup,
    bool isShape,
    Container parent,
    List<Element> children,
    double x,
    double y,
    Renderer renderer,

    String type,
    Rect bbox
  }) {
    this['attrs'] = attrs;
    this['zIndex'] = zIndex;
    this['visible'] = visible;
    this['destroyed'] = destroyed;
    this['isGroup'] = isGroup;
    this['isShape'] = isShape;
    this['parent'] = parent;
    this['children'] = children;
    this['x'] = x;
    this['y'] = y;
    this['renderer'] = renderer;

    this['type'] = type;
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

  // shape cfg

  String get type => this['type'] as String;
  set type(String value) => this['type'] = value;

  Rect get bbox => this['bbox'] as Rect;
  set bbox(Rect value) => this['bbox'] = value;
}
