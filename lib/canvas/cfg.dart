import 'dart:ui' show Rect;

import 'package:flutter/scheduler.dart' show TickerProvider;
import 'package:flutter/widgets.dart' show UniqueKey;
import 'package:vector_math/vector_math_64.dart' show Matrix4;

import 'attrs.dart' show Attrs;
import 'container.dart' show Container;
import 'canvas_controller.dart' show CanvasController;
import './shape/shape.dart' show ShapeType, Shape;
import 'element.dart' show Element, Pause;
import './animate/animation.dart' show Animation;
import './animate/timeline.dart' show Timeline;

class Cfg {
  Cfg({
    bool destroyed,

    UniqueKey id,
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
    Rect cacheCanvasBBox,
    bool hasChanged,
    List<Animation> animations,
    Timeline timeline,

    Attrs attrs,
    Rect bbox,
    Rect canvasBBox,
    double totalLength,
    List<List<double>> tCache,

    bool clearing,
    List<Element> children,

    ShapeType type,
    bool isClipShape,

    bool autoDraw,
    TickerProvider tickerProvider,
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
      if (cacheCanvasBBox != null) 'cacheCanvasBBox': cacheCanvasBBox,
      if (hasChanged != null) 'hasChanged': hasChanged,
      if (animations != null) 'animations': animations,
      if (timeline != null) 'timeline': timeline,
      if (attrs != null) 'attrs': attrs,
      if (bbox != null) 'bbox': bbox,
      if (canvasBBox != null) 'canvasBBox': canvasBBox,
      if (totalLength != null) 'totalLength': totalLength,
      if (tCache != null) 'tCache': tCache,
      if (clearing != null) 'clearing': clearing,
      if (children != null) 'children': children,
      if (type != null) 'type': type,
      if (isClipShape != null) 'isClipShape': isClipShape,
      if (autoDraw != null) 'autoDraw': autoDraw,
      if (tickerProvider != null) 'autoDraw': tickerProvider,
    };

  final Map<String, Object> _cfg;

  // base cfg

  bool get destroyed => this['destroyed'] as bool;
  set destroyed(bool value) => this['destroyed'] = value;

  // element cfg

  UniqueKey get id => this['id'] as UniqueKey;
  set id(UniqueKey value) => this['id'] = value;

  int get zIndex => this['zIndex'] as int;
  set zIndex(int value) => this['zIndex'] = value;

  bool get visible => this['visible'] as bool;
  set visible(bool value) => this['visible'] = value;

  bool get capture => this['capture'] as bool;
  set capture(bool value) => this['capture'] = value;

  bool get animable => this['animable'] as bool;
  set animable(bool value) => this['animable'] = value;

  bool get animating => this['animating'] as bool;
  set animating(bool value) => this['animating'] = value;

  Container get parent => this['parent'] as Container;
  set parent(Container value) => this['parent'] = value;

  CanvasController get canvasController => this['canvasController'] as CanvasController;
  set canvasController(CanvasController value) => this['canvasController'] = value;

  Matrix4 get totalMatrix => this['totalMatrix'] as Matrix4;
  set totalMatrix(Matrix4 value) => this['totalMatrix'] = value;

  Matrix4 get parentMatrix => this['parentMatrix'] as Matrix4;
  set parentMatrix(Matrix4 value) => this['parentMatrix'] = value;

  Shape get clipShape => this['clipShape'] as Shape;
  set clipShape(Shape value) => this['clipShape'] = value;

  Pause get pause => this['pause'] as Pause;
  set pause(Pause value) => this['pause'] = value;

  String get name => this['name'] as String;
  set name(String value) => this['name'] = value;

  Element get delegateObject => this['delegateObject'] as Element;
  set delegateObject(Element value) => this['delegateObject'] = value;

  Rect get cacheCanvasBBox => this['cacheCanvasBBox'] as Rect;
  set cacheCanvasBBox(Rect value) => this['cacheCanvasBBox'] = value;

  bool get hasChanged => this['hasChanged'] as bool;
  set hasChanged(bool value) => this['hasChanged'] = value;

  List<Animation> get animations => this['animations'] as List<Animation>;
  set animations(List<Animation> value) => this['animations'] = value;

  Timeline get timeline => this['timeline'] as Timeline;
  set timeline(Timeline value) => this['timeline'] = value;

  // shape cfg

  Attrs get attrs => this['attrs'] as Attrs;
  set attrs(Attrs value) => this['attrs'] = value;

  Rect get bbox => this['bbox'] as Rect;
  set bbox(Rect value) => this['bbox'] = value;

  Rect get canvasBBox => this['canvasBBox'] as Rect;
  set canvasBBox(Rect value) => this['canvasBBox'] = value;

  double get totalLength => this['totalLength'] as double;
  set totalLength(double value) => this['totalLength'] = value;

  List<List<double>> get tChache => this['tChache'] as List<List<double>>;
  set tChache(List<List<double>> value) => this['tChache'] = value;

  // container cfg

  bool get clearing => this['clearing'] as bool;
  set clearing(bool value) => this['clearing'] = value;

  List<Element> get children => this['children'] as List<Element>;
  set children(List<Element> value) => this['children'] = value;

  // clip cfg

  ShapeType get type => this['type'] as ShapeType;
  set type(ShapeType value) => this['type'] = value;

  bool get isClipShape => this['isClipShape'] as bool;
  set isClipShape(bool value) => this['isClipShape'] = value;

  // canvas controller cfg

  bool get autoDraw => this['autoDraw'] as bool;
  set autoDraw(bool value) => this['autoDraw'] = value;

  TickerProvider get tickerProvider => this['tickerProvider'] as TickerProvider;
  set tickerProvider(TickerProvider value) => this['tickerProvider'] = value;

  // Tool members.

  Cfg mix(Cfg src) => this.._cfg.addAll(src._cfg);

  Cfg clone() => Cfg(
    attrs: attrs.clone(),
    zIndex: zIndex,
    capture: capture,
    visible: visible,
    type: type,
  );

  Object operator [](String k) => _cfg[k];

  void operator []=(String k, Object v) => v == null ? _cfg.remove(k) : _cfg[k] = v;
}
