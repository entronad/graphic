import 'package:vector_math/vector_math_64.dart' show Matrix4;

import 'attrs.dart' show Attrs;
import 'container.dart' show Container;
import 'canvas_controller.dart' show CanvasController;
import './shape/shape.dart' show ShapeType, Shape;
import 'element.dart' show Element, Pause;

class Cfg {
  Cfg({
    bool destroyed,

    String id,
    int zIndex,
    bool visible,
    bool capture,
    bool animable,
    bool animating,
    Container parent,
    CanvasController canvasController,
    Matrix4 totalMatrix,
    Matrix4 parentMatrix,
    Shape clipShape,
    Pause pause,
    String name,
    Element delegateObject,

    Attrs attrs,

    bool clearing,

    ShapeType type,
    bool isClipShape,
  })
    : _cfg = {
      if (destroyed != null) 'destroyed': destroyed,
      if (id != null) 'id': id,
      if (zIndex != null) 'zIndex': zIndex,
      if (visible != null) 'visible': visible,
      if (capture != null) 'capture': capture,
      if (animable != null) 'animable': animable,
      if (animating != null) 'animating': animating,
      if (parent != null) 'parent': parent,
      if (canvasController != null) 'canvasController': canvasController,
      if (totalMatrix != null) 'totalMatrix': totalMatrix,
      if (parentMatrix != null) 'parentMatrix': parentMatrix,
      if (clipShape != null) 'clipShape': clipShape,
      if (pause != null) 'pause': pause,
      if (name != null) 'name': name,
      if (delegateObject != null) 'delegateObject': delegateObject,
      if (attrs != null) 'attrs': attrs,
      if (clearing != null) 'clearing': clearing,
      if (type != null) 'type': type,
      if (isClipShape != null) 'isClipShape': isClipShape,
    };

  final Map<String, Object> _cfg;

  // base cfg

  bool get destroyed => _cfg['destroyed'] as bool;
  set destroyed(bool value) => _cfg['destroyed'] = value;

  // element cfg

  String get id => _cfg['id'] as String;
  set id(String value) => _cfg['id'] = value;

  int get zIndex => _cfg['zIndex'] as int;
  set zIndex(int value) => _cfg['zIndex'] = value;

  bool get visible => _cfg['visible'] as bool;
  set visible(bool value) => _cfg['visible'] = value;

  bool get capture => _cfg['capture'] as bool;
  set capture(bool value) => _cfg['capture'] = value;

  bool get animable => _cfg['animable'] as bool;
  set animable(bool value) => _cfg['animable'] = value;

  bool get animating => _cfg['animating'] as bool;
  set animating(bool value) => _cfg['animating'] = value;

  Container get parent => _cfg['parent'] as Container;
  set parent(Container value) => _cfg['parent'] = value;

  CanvasController get canvasController => _cfg['canvasController'] as CanvasController;
  set canvasController(CanvasController value) => _cfg['canvasController'] = value;

  Matrix4 get totalMatrix => _cfg['totalMatrix'] as Matrix4;
  set totalMatrix(Matrix4 value) => _cfg['totalMatrix'] = value;

  Matrix4 get parentMatrix => _cfg['parentMatrix'] as Matrix4;
  set parentMatrix(Matrix4 value) => _cfg['parentMatrix'] = value;

  Shape get clipShape => _cfg['clipShape'] as Shape;
  set clipShape(Shape value) => _cfg['clipShape'] = value;

  Pause get pause => _cfg['pause'] as Pause;
  set pause(Pause value) => _cfg['pause'] = value;

  String get name => _cfg['name'] as String;
  set name(String value) => _cfg['name'] = value;

  Element get delegateObject => _cfg['delegateObject'] as Element;
  set delegateObject(Element value) => _cfg['delegateObject'] = value;

  // shape cfg

  Attrs get attrs => _cfg['attrs'] as Attrs;
  set attrs(Attrs value) => _cfg['attrs'] = value;

  // container cfg

  bool get clearing => _cfg['clearing'] as bool;
  set clearing(bool value) => _cfg['clearing'] = value;

  // clip cfg

  ShapeType get type => _cfg['type'] as ShapeType;
  set type(ShapeType value) => _cfg['type'] = value;

  bool get isClipShape => _cfg['isClipShape'] as bool;
  set isClipShape(bool value) => _cfg['isClipShape'] = value;

  // Tool members.

  Cfg mix(Cfg src) => this.._cfg.addAll(src._cfg);

  Cfg clone() => Cfg(
    attrs: attrs.clone(),
    zIndex: zIndex,
    capture: capture,
    visible: visible,
    type: type,
  );
}
